import { For, createState, createComputed } from "ags"
import { Astal, Gtk, Gdk } from "ags/gtk4"
import AstalApps from "gi://AstalApps"
import Graphene from "gi://Graphene"
import app from "ags/gtk4/app"
import style from "./style.scss"
import { gaps, eraserRadius, hyprRounding, createCornerWidget, launcherFont, launcherIconSize } from "../../settings"

const { BOTTOM } = Astal.WindowAnchor

export default function Applauncher() {
  app.apply_css(style)
  let contentbox: Gtk.Box
  let searchentry: Gtk.Entry
  let win: Astal.Window

  const apps = new AstalApps.Apps()
  const [list, setList] = createState(new Array<AstalApps.Application>())
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
    } else {
      setList(apps.fuzzy_query(text).slice(0, 8))
      setSelectedIndex(0)
    }
  }

  function launch(app?: AstalApps.Application) {
    if (app) {
      win.visible = false
      app.launch()
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
            <For each={list} id={(app) => app.entry || app.name}>
              {(app, index) => {
                const isActive = createComputed(() => selectedIndex() === index() ? "suggested" : "")
                return (
                  <button
                    onClicked={() => launch(app)}
                    class={isActive}
                  >
                    <box spacing={24}>
                      <image iconName={app.iconName} pixelSize={launcherIconSize} />
                      <label label={app.name} maxWidthChars={40} />
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