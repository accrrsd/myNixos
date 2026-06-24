import { For, createState, createComputed } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import AstalApps from "gi://AstalApps"
import Graphene from "gi://Graphene"
import app from "ags/gtk4/app"
import { execAsync } from "ags/process"
import style from "./style.scss"
import {
  gaps,
  eraserRadius,
  hyprRounding,
  createCornerWidget,
  launcherFont,
  launcherIconSize,
  configState,
  CommandConfig
} from "../../settingsParser"

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
  let currentQueryId = 0

  const apps = new AstalApps.Apps()
  const [list, setList] = createState(new Array<LauncherItem>())
  const [selectedIndex, setSelectedIndex] = createState(0)

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
      setList([])
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
        setList(items)
        setSelectedIndex(0)
        return
      }

      const cmd = commands[commandKey]
      if (cmd) {
        if (cmd.type === "calc") {
          const expr = args
          let evalResult = ""

          if (expr.trim()) {
            const queryId = ++currentQueryId

            execAsync(["qalc", "-terse", expr])
              .then((stdout) => {
                if (queryId === currentQueryId) {
                  const res = stdout.trim()
                  if (res) {
                    evalResult = res
                    const display = `${expr} = ${res}`
                    const updatedItem: LauncherItem = {
                      id: `calc-${commandKey}-${display}`,
                      name: display,
                      iconName: cmd.icon || "accessories-calculator",
                      action: () => {
                        execAsync(["wl-copy", res]).catch(console.error)
                        win.visible = false
                      }
                    }
                    setList([updatedItem])
                  }
                }
              })
              .catch(() => {
                if (queryId === currentQueryId) {
                  const updatedItem: LauncherItem = {
                    id: `calc-${commandKey}-${expr}-err`,
                    name: expr,
                    iconName: cmd.icon || "accessories-calculator",
                    action: () => {
                      win.visible = false
                    }
                  }
                  setList([updatedItem])
                }
              })
          }

          const item: LauncherItem = {
            id: `calc-${commandKey}-${expr || "empty"}`,
            name: expr.trim() ? expr : "Type expression...",
            iconName: cmd.icon || "accessories-calculator",
            action: () => {
              if (evalResult) {
                execAsync(["wl-copy", evalResult]).catch(console.error)
              }
              win.visible = false
            }
          }
          setList([item])
          setSelectedIndex(0)
        } else if (cmd.type === "launch") {
          let execStr = cmd.exec || ""
          let commandToRun = execStr
          const urlArgs = encodeURIComponent(args)

          if (execStr.includes("{urlargs}")) {
            commandToRun = execStr.replace("{urlargs}", urlArgs)
          } else if (execStr.includes("{args}")) {
            commandToRun = execStr.replace("{args}", args)
          } else if (args) {
            commandToRun = `${execStr} ${args}`
          }

          const item: LauncherItem = {
            id: `launch-${commandKey}-${args || "empty"}`,
            name: `${cmd.name || commandKey}${args ? ` (${args})` : ""}`,
            iconName: cmd.icon || "system-run",
            action: () => {
              if (commandToRun) {
                execAsync(commandToRun).catch(console.error)
              }
              win.visible = false
            }
          }
          setList([item])
          setSelectedIndex(0)
        } else {
          setList([])
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
          setList(items)
          setSelectedIndex(0)
        } else {
          setList([])
          setSelectedIndex(0)
        }
      }
    } else {
      const appResults = apps.fuzzy_query(text).slice(0, 8)
      const items: LauncherItem[] = appResults.map((app) => ({
        id: app.entry || app.name,
        name: app.name,
        iconName: app.iconName,
        action: () => {
          win.visible = false
          app.launch()
        }
      }))
      setList(items)
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
      for (const i of [1, 2, 3, 4, 5, 6, 7, 8, 9] as const) {
        if (keyval === Gdk[`KEY_${i}`]) {
          launch(currentList[i - 1])
          return true
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
      $={(ref) => (win = ref)}
      name="launcher"
      class="launcher-window"
      namespace="launcher"
      anchor={BOTTOM}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.EXCLUSIVE}
      onNotifyVisible={({ visible }) => {
        if (visible) {
          searchentry.grab_focus()
          setSelectedIndex(0)
        } else {
          searchentry.set_text("")
        }
      }}
    >
      <Gtk.EventControllerKey onKeyPressed={onKey} />
      <Gtk.GestureClick onPressed={onClick} />
      <box
        orientation={Gtk.Orientation.HORIZONTAL}
        marginBottom={gaps.bottom}
        class="launcher-window-box"
        css={`font: ${launcherFont};`}
      >
        {leftFillet}
        <box
          $={(ref) => (contentbox = ref)}
          name="launcher-content"
          orientation={Gtk.Orientation.VERTICAL}
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
            <For each={list} id={(item) => item.id}>
              {(item, index) => {
                const isActive = createComputed(() => selectedIndex() === index() ? "suggested" : "")
                return (
                  <button
                    onClicked={() => launch(item)}
                    class={isActive}
                  >
                    <box spacing={24}>
                      <image iconName={item.iconName} pixelSize={launcherIconSize} />
                      <label label={item.name} maxWidthChars={40} />
                    </box>
                  </button>
                )
              }}
            </For>
          </box>
        </box>
        {rightFillet}
      </box>
    </window>
  )
}