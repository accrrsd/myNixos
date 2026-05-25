import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { exec } from "ags/process"
import Cairo from "cairo"
import style from "./style.scss"

function getHyprOption(option: string, defaultValue: number): number {
  try {
    const output = exec(`hyprctl getoption ${option} -j`)
    const config = JSON.parse(output)
    return config.int !== undefined ? config.int : defaultValue
  } catch (e) {
    return defaultValue
  }
}

export default function ScreenBorder(monitor: Gdk.Monitor) {
  app.apply_css(style)

  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  
  const hyprRounding = getHyprOption("decoration:rounding", 10)
  const hyprBorder = getHyprOption("general:border_size", 4)
  const size = 8

  const eraserRadius = hyprRounding + hyprBorder 
  const boxSize = eraserRadius + size 

  const corners = {
    "top-left":     { anchor: TOP | LEFT,     cx: boxSize, cy: boxSize },
    "top-right":    { anchor: TOP | RIGHT,    cx: 0,       cy: boxSize },
    "bottom-left":  { anchor: BOTTOM | LEFT,  cx: boxSize, cy: 0 },
    "bottom-right": { anchor: BOTTOM | RIGHT, cx: 0,       cy: 0 },
  }

  function createSide(anchor: Astal.WindowAnchor, isHorizontal: boolean) {
    return (
      <window
        visible
        class={"screen-border-line"}
        name={`border-line-${anchor}-${monitor.get_description()}`}
        gdkmonitor={monitor}
        layer={Astal.Layer.OVERLAY}
        exclusivity={Astal.Exclusivity.IGNORE}
        anchor={anchor}
        widthRequest={isHorizontal ? monitor.get_geometry().width : size}
        heightRequest={isHorizontal ? size : monitor.get_geometry().height}
      />
    )
  }

const cornerElements = Object.entries(corners).map(([name, { anchor, cx, cy }]) => {
    const da = new Gtk.DrawingArea()
    da.set_content_width(boxSize)
    da.set_content_height(boxSize)

    da.get_style_context().add_class("corner-canvas")
    
    da.set_draw_func((_self, cr, w, h) => {
      const context = _self.get_style_context()
      const gdkColor = context.get_color()
      cr.setSourceRGBA(gdkColor.red, gdkColor.green, gdkColor.blue, gdkColor.alpha)

      cr.rectangle(0, 0, w, h)
      cr.fill()

      cr.setOperator(Cairo.Operator.CLEAR)
      cr.newSubPath()
      cr.arc(cx, cy, eraserRadius, 0, 2 * Math.PI)
      cr.fill()
    })

    return (
      <window
        visible
        class={"screen-border-corner-window"}
        name={`border-corner-${name}-${monitor.get_description()}`}
        gdkmonitor={monitor}
        namespace={`corner-${name}`}
        anchor={anchor}
        exclusivity={Astal.Exclusivity.IGNORE}
        layer={Astal.Layer.OVERLAY}
      >
        {da}
      </window>
    )
  })

  return [
    createSide(TOP | LEFT | RIGHT, true),
    createSide(BOTTOM | LEFT | RIGHT, true),
    createSide(LEFT | TOP | BOTTOM, false),
    createSide(RIGHT | TOP | BOTTOM, false),
    ...cornerElements,
  ]
}