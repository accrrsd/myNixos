import app from "ags/gtk4/app"
import { Astal, Gdk, Gtk } from "ags/gtk4"
import { exec } from "ags/process"
import Cairo from "cairo"
import style from "./style.scss"

interface GapsOut {
  top: number
  right: number
  bottom: number
  left: number
}

function getHyprOption(option: string, defaultValue: number): number {
  try {
    const output = exec(`hyprctl getoption ${option} -j`)
    const config = JSON.parse(output)
    return config.int !== undefined ? config.int : defaultValue
  } catch (e) {
    return defaultValue
  }
}

function getHyprGapsOut(): GapsOut {
  const defaultGaps = { top: 16, right: 16, bottom: 16, left: 16 }
  try {
    const output = exec("hyprctl getoption general:gaps_out -j")
    const config = JSON.parse(output)
    
    const gapsString = config.custom || config.str || ""
    const matches = gapsString.match(/\d+/g)
    
    if (!matches) return defaultGaps

    if (matches.length === 1) {
      const val = parseInt(matches[0])
      return { top: val, right: val, bottom: val, left: val }
    } 
    
    if (matches.length >= 4) {
      return {
        top: parseInt(matches[0]),
        right: parseInt(matches[1]),
        bottom: parseInt(matches[2]),
        left: parseInt(matches[3])
      }
    }
    
    return defaultGaps
  } catch (e) {
    console.error("gaps parse error:", e)
    return defaultGaps
  }
}

export default function ScreenBorder(monitor: Gdk.Monitor) {
  app.apply_css(style)
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor

  // setting
  const gaps_proporiton = 0.33
  
  const hyprRounding = getHyprOption("decoration:rounding", 10)
  const hyprBorder = getHyprOption("general:border_size", 2)
  const gaps = Object.fromEntries(Object.entries(getHyprGapsOut()).map(([key, value]) => [key, Math.round(value * gaps_proporiton)])) as unknown as GapsOut

  const eraserRadius = hyprRounding + hyprBorder 

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
    const da = new Gtk.DrawingArea()
    da.set_content_width(config.w)
    da.set_content_height(config.h)
    da.get_style_context().add_class("corner-canvas")
    
    da.set_draw_func((_self, cr, w, h) => {
      const context = _self.get_style_context()
      const gdkColor = context.get_color()

      cr.setSourceRGBA(gdkColor.red, gdkColor.green, gdkColor.blue, gdkColor.alpha)
      cr.rectangle(0, 0, w, h)
      cr.fill()

      cr.setOperator(Cairo.Operator.CLEAR)
      cr.newSubPath()
      cr.arc(config.cx(), config.cy(), eraserRadius, 0, 2 * Math.PI)
      cr.fill()
    })

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