import { createState, createComputed } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import AstalApps from "gi://AstalApps"
import Graphene from "gi://Graphene"
import app from "ags/gtk4/app"
import { execAsync } from "ags/process"
import GLib from "gi://GLib"
import style from "./style.scss"
import {
  gaps,
  eraserRadius,
  hyprRounding,
  createCornerWidget,
  launcherFont,
  launcherIconSize,
  configState,
  CommandConfig,
  heightMode,
  computeIconSize,
  computeGaps,
  fancySpeed
} from "../../settingsParser"
import { appLauncherPlugins } from "./appLauncherPlugins"

const { BOTTOM } = Astal.WindowAnchor

export interface LauncherItem {
  id: string
  name: string
  iconName: string
  action: () => void
}

export default function Applauncher() {
  app.apply_css(style)
  let contentbox: Gtk.Box
  let searchentry: Gtk.Entry
  let win: Astal.Window
  const currentQueryIdRef = { value: 0 }

  const apps = new AstalApps.Apps()
  const [list, setList] = createState(new Array<LauncherItem>())
  const [selectedIndex, setSelectedIndex] = createState(0)

  let animationTimeoutId: number | null = null

  function updateList(targetItems: LauncherItem[]) {
    const config = configState.peek()
    if (config.height_mode !== "fancy") {
      if (animationTimeoutId !== null) {
        GLib.source_remove(animationTimeoutId)
        animationTimeoutId = null
      }
      setList(targetItems)
      return
    }

    if (animationTimeoutId !== null) {
      GLib.source_remove(animationTimeoutId)
      animationTimeoutId = null
    }

    const targetLength = targetItems.length

    function step() {
      const current = list.peek()
      const currentLength = current.length
      const speed = fancySpeed ?? 0.05
      const delayMs = Math.round(speed * 1000)

      if (currentLength < targetLength) {
        // Grow: add next item
        const nextItem = targetItems[currentLength]
        setList([...current, nextItem])
        animationTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, delayMs, () => {
          step()
          return GLib.SOURCE_REMOVE
        })
      } else if (currentLength > targetLength) {
        // Shrink: remove last item
        setList(current.slice(0, -1))
        animationTimeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, delayMs, () => {
          step()
          return GLib.SOURCE_REMOVE
        })
      } else {
        // Same length: update contents of any that changed
        let contentChanged = false
        for (let i = 0; i < currentLength; i++) {
          if (current[i].id !== targetItems[i].id) {
            contentChanged = true
            break
          }
        }
        if (contentChanged) {
          setList(targetItems)
        }
        animationTimeoutId = null
      }
    }

    // Before starting the sequential grow/shrink loop, check if any currently visible items
    // have changed content, and update them immediately so labels/icons change instantly
    const current = list.peek()
    const minLen = Math.min(current.length, targetLength)
    let contentChanged = false
    for (let i = 0; i < minLen; i++) {
      if (current[i].id !== targetItems[i].id) {
        contentChanged = true
        break
      }
    }
    if (contentChanged) {
      const updated = [...targetItems.slice(0, minLen), ...current.slice(minLen)]
      setList(updated)
    }

    step()
  }

  // Derived state for the current page items (8 items per page)
  const displayedList = createComputed(() => {
    const matches = list()
    const index = selectedIndex()
    const page = Math.floor(index / 8)
    return matches.slice(page * 8, (page + 1) * 8)
  })

  // Derived state for local selected index on the current page
  const localSelectedIndex = createComputed(() => {
    return selectedIndex() % 8
  })

  // Derived states for pagination indicator
  const totalPages = createComputed(() => {
    return Math.ceil(list().length / 8)
  })

  const currentPage = createComputed(() => {
    return Math.floor(selectedIndex() / 8) + 1
  })

  const showPageIndicator = createComputed(() => {
    return totalPages() > 1
  })

  // Left fillet (concave corner)
  const leftFillet = createCornerWidget(
    eraserRadius,
    eraserRadius,
    0,
    0,
    eraserRadius,
    "launcher-fillet-left",
    Gtk.Align.END
  )

  // Right fillet (concave corner)
  const rightFillet = createCornerWidget(
    eraserRadius,
    eraserRadius,
    eraserRadius,
    0,
    eraserRadius,
    "launcher-fillet-right",
    Gtk.Align.END
  )

  function search(text: string) {
    if (text === "") {
      updateList([])
      setSelectedIndex(0)
      return
    }

    if (text.startsWith(">")) {
      const commandString = text.slice(1).trim()
      const parts = commandString.split(/\s+/)
      const commandKey = parts[0]
      const args = parts.slice(1).join(" ")

      const config = configState.peek()
      const commands = (config.commands || {}) as Record<string, CommandConfig>

      if (commandKey === "") {
        // Just ">" - list all available custom commands
        const items = Object.entries(commands).map(([key, cmd]) => {
          return {
            id: `cmd-${key}`,
            name: `${cmd.name || key} (>${key})`,
            iconName: cmd.icon || "system-run",
            action: () => {
              searchentry.set_text(`>${key} `)
              searchentry.set_position(-1)
            }
          }
        })
        updateList(items)
        setSelectedIndex(0)
        return
      }

      const queryId = ++currentQueryIdRef.value
      const cmd = commands[commandKey]
      if (cmd) {
        const plugin = appLauncherPlugins[cmd.type]
        if (plugin) {
          const items = plugin.execute(args, cmd, {
            queryId,
            currentQueryIdRef,
            win,
            setList: updateList
          })
          updateList(items)
          setSelectedIndex(0)
        } else {
          updateList([])
          setSelectedIndex(0)
        }
      } else {
        const matchingCommands = Object.entries(commands).filter(([key]) => key.startsWith(commandKey))
        if (matchingCommands.length > 0) {
          const items = matchingCommands.map(([key, c]) => {
            return {
              id: `cmd-${key}`,
              name: `${c.name || key} (>${key})`,
              iconName: c.icon || "system-run",
              action: () => {
                searchentry.set_text(`>${key} `)
                searchentry.set_position(-1)
              }
            }
          })
          updateList(items)
          setSelectedIndex(0)
        } else {
          updateList([])
          setSelectedIndex(0)
        }
      }
    } else {
      const appResults = apps.fuzzy_query(text)
      const seen = new Set<string>()
      const uniqueItems: LauncherItem[] = []
      for (const app of appResults) {
        const key = app.entry || app.name
        if (!seen.has(key)) {
          seen.add(key)
          uniqueItems.push({
            id: key,
            name: app.name,
            iconName: app.iconName,
            action: () => {
              win.visible = false
              app.launch()
            }
          })
        }
      }
      updateList(uniqueItems)
      setSelectedIndex(0)
    }
  }

  function launch(item?: LauncherItem) {
    if (item) {
      item.action()
    }
  }

  // close on ESC, navigate with arrows, launch with Enter, handle Alt+Number
  function onKey(
    _e: Gtk.EventControllerKey,
    keyval: number,
    _: number,
    mod: number,
  ) {
    if (keyval === Gdk.KEY_Escape) {
      win.visible = false
      return true
    }

    const currentList = list.peek()

    if (keyval === Gdk.KEY_Down) {
      if (currentList.length > 0) {
        setSelectedIndex((selectedIndex.peek() + 1) % currentList.length)
        return true
      }
    }

    if (keyval === Gdk.KEY_Up) {
      if (currentList.length > 0) {
        setSelectedIndex(
          (selectedIndex.peek() - 1 + currentList.length) % currentList.length,
        )
        return true
      }
    }

    if (keyval === Gdk.KEY_Return) {
      if (currentList.length > 0) {
        launch(currentList[selectedIndex.peek()])
        return true
      }
    }

    if (mod === Gdk.ModifierType.ALT_MASK) {
      const page = Math.floor(selectedIndex.peek() / 8)
      for (const i of [1, 2, 3, 4, 5, 6, 7, 8] as const) {
        if (keyval === Gdk[`KEY_${i}`]) {
          const targetIndex = page * 8 + (i - 1)
          if (targetIndex < currentList.length) {
            launch(currentList[targetIndex])
            return true
          }
        }
      }
    }
  }

  // close on clickaway
  function onClick(_e: Gtk.GestureClick, _: number, x: number, y: number) {
    const [, rect] = contentbox.compute_bounds(win)
    const position = new Graphene.Point({ x, y })

    if (!rect.contains_point(position)) {
      win.visible = false
      return true
    }
  }

  return (
    <window
      $={(ref) => {
        win = ref;
        (ref as any).openWithText = (text: string) => {
          ref.visible = true;
          searchentry.set_text(text);
          searchentry.set_position(-1);
          searchentry.grab_focus();
        };
      }}
      name="launcher"
      class="launcher-window"
      namespace="launcher"
      anchor={BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      heightRequest={createComputed(() => {
        const cfg = configState()
        const iconSize = computeIconSize(cfg.launcher_font, cfg.launcher_icon_size_multiplayer)
        const gapsOut = computeGaps(cfg.gaps_proportion)
        return 8 * (iconSize + 16) + 100 + gapsOut.bottom
      })}
      onNotifyVisible={({ visible }) => {
        if (visible) {
          searchentry.grab_focus()
          setSelectedIndex(0)
        } else {
          if (animationTimeoutId !== null) {
            GLib.source_remove(animationTimeoutId)
            animationTimeoutId = null
          }
          setList([])
          searchentry.set_text("")
        }
      }}
    >
      <Gtk.EventControllerKey onKeyPressed={onKey} />
      <Gtk.GestureClick onPressed={onClick} />
      <box
        orientation={Gtk.Orientation.HORIZONTAL}
        marginBottom={gaps.bottom}
        valign={Gtk.Align.END}
        class="launcher-window-box"
        css={`font: ${launcherFont};`}
      >
        {leftFillet}
        <box
          $={(ref) => (contentbox = ref)}
          name="launcher-content"
          orientation={Gtk.Orientation.VERTICAL}
          heightRequest={createComputed(() => {
            const cfg = configState()
            if (cfg.height_mode === "full") {
              const iconSize = computeIconSize(cfg.launcher_font, cfg.launcher_icon_size_multiplayer)
              return 8 * (iconSize + 16) + 94
            }
            return -1
          })}
          css={`
            border-top-left-radius: ${hyprRounding}px;
            border-top-right-radius: ${hyprRounding}px;
            border-bottom-left-radius: 0px;
            border-bottom-right-radius: 0px;
          `}
        >
          <entry
            $={(ref) => (searchentry = ref)}
            onNotifyText={({ text }) => search(text)}
            onActivate={() => {
              const currentList = list.peek()
              if (currentList.length > 0) {
                launch(currentList[selectedIndex.peek()])
              }
            }}
            placeholderText="Start typing to search"
          />
          <Gtk.Separator visible={list((l) => l.length > 0)} />
          <box orientation={Gtk.Orientation.VERTICAL} spacing={4}>
            {Array.from({ length: 8 }).map((_, i) => {
              const item = createComputed(() => displayedList()[i] || null)
              const isActive = createComputed(() => localSelectedIndex() === i ? "suggested" : "")
              const hasItem = createComputed(() => item() !== null)

              let lastVisibleName = ""
              let lastVisibleIcon = ""

              const name = createComputed(() => {
                const currentItem = item()
                if (currentItem) {
                  lastVisibleName = currentItem.name
                }
                return lastVisibleName
              })

              const icon = createComputed(() => {
                const currentItem = item()
                if (currentItem) {
                  lastVisibleIcon = currentItem.iconName
                }
                return lastVisibleIcon
              })

              return (
                <Gtk.Revealer
                  revealChild={hasItem}
                  transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
                  transitionDuration={200}
                >
                  <button
                    onClicked={() => {
                      const currentItem = item()
                      if (currentItem) launch(currentItem)
                    }}
                    class={isActive}
                  >
                    <box spacing={24}>
                      <image iconName={icon} pixelSize={launcherIconSize} />
                      <label label={name} maxWidthChars={40} />
                    </box>
                  </button>
                </Gtk.Revealer>
              )
            })}
            <label
              class="launcher-page-indicator"
              visible={showPageIndicator}
              label={createComputed(() => `Page ${currentPage()} of ${totalPages()}`)}
              halign={Gtk.Align.CENTER}
              css="font-size: 0.8em; opacity: 0.5; margin-top: 8px;"
            />
          </box>
        </box>
        {rightFillet}
      </box>
    </window>
  )
}