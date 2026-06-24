import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import Cairo from "cairo"
import style from "./style.scss"
import { gaps, eraserRadius, createCornerWidget } from "../../settings"

export default function ScreenBorder(monitor: Gdk.Monitor) {
  app.apply_css(style)
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

  function createSide(anchor: Astal.WindowAnchor, isHorizontal: boolean, currentSize: number) {
    return (
      <window
        visible
        class={"screen-border-line"}
        name={`border-line-${anchor}-${monitor.get_description()}`}
        gdkmonitor={monitor}
        layer={Astal.Layer.OVERLAY}
        exclusivity={Astal.Exclusivity.IGNORE}
        anchor={anchor}
        widthRequest={isHorizontal ? monitor.get_geometry().width : currentSize}
        heightRequest={isHorizontal ? currentSize : monitor.get_geometry().height}

      />
    )
  }

  const cornersConfig = {
    "top-left": {
      anchor: TOP | LEFT,
      w: eraserRadius + gaps.left,
      h: eraserRadius + gaps.top,
      cx: () => eraserRadius + gaps.left,
      cy: () => eraserRadius + gaps.top
    },
    "top-right": {
      anchor: TOP | RIGHT,
      w: eraserRadius + gaps.right,
      h: eraserRadius + gaps.top,
      cx: () => 0,
      cy: () => eraserRadius + gaps.top
    },
    "bottom-left": {
      anchor: BOTTOM | LEFT,
      w: eraserRadius + gaps.left,
      h: eraserRadius + gaps.bottom,
      cx: () => eraserRadius + gaps.left,
      cy: () => 0
    },
    "bottom-right": {
      anchor: BOTTOM | RIGHT,
      w: eraserRadius + gaps.right,
      h: eraserRadius + gaps.bottom,
      cx: () => 0,
      cy: () => 0
    }
  }

  const cornerElements = Object.entries(cornersConfig).map(([name, config]) => {
    const da = createCornerWidget(
      config.w,
      config.h,
      config.cx(),
      config.cy(),
      eraserRadius,
      "corner-canvas"
    )

    return (
      <window
        visible
        class={"screen-border-corner-window"}
        name={`border-corner-${name}-${monitor.get_description()}`}
        gdkmonitor={monitor}
        namespace={`corner-${name}`}
        anchor={config.anchor}
        exclusivity={Astal.Exclusivity.IGNORE}
        layer={Astal.Layer.OVERLAY}
        widthRequest={config.w}
        heightRequest={config.h}
      >
        {da}
      </window>
    )
  })

  return [
    createSide(TOP | LEFT | RIGHT, true, gaps.top),
    createSide(BOTTOM | LEFT | RIGHT, true, gaps.bottom),
    createSide(LEFT | TOP | BOTTOM, false, gaps.left),
    createSide(RIGHT | TOP | BOTTOM, false, gaps.right),
    ...cornerElements,
  ]
}