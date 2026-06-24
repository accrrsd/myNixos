import { exec } from "ags/process"
import { Gtk } from "ags/gtk4"
import Cairo from "cairo"

export interface GapsOut {
  top: number
  right: number
  bottom: number
  left: number
}

export function getHyprOption(option: string, defaultValue: number): number {
  try {
    const output = exec(`hyprctl getoption ${option} -j`)
    const config = JSON.parse(output)
    return config.int !== undefined ? config.int : defaultValue
  } catch (e) {
    return defaultValue
  }
}

export function getHyprGapsOut(): GapsOut {
  const defaultGaps = { top: 16, right: 16, bottom: 16, left: 16 }
  try {
    const output = exec("hyprctl getoption general:gaps_out -j")
    const config = JSON.parse(output)

    const gapsString = config.custom || config.str || config.css || ""
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
        left: parseInt(matches[3]),
      }
    }

    return defaultGaps
  } catch (e) {
    console.error("gaps parse error:", e)
    return defaultGaps
  }
}

// Config Constants
export const GAPS_PROPORTION = 0.33
export const launcherFont = "14pt Hack Nerd Font, sans-serif"
export const launcherIconSizeMultiplayer = 1.25
export const launcherIconSize = (() => {
  const match = launcherFont.match(/(\d+)(pt|px)/)
  if (match) {
    const val = parseInt(match[1])
    const unit = match[2]
    const px = unit === "pt" ? val * 1.333 : val
    return Math.round(px * 1.5 * launcherIconSizeMultiplayer)
  }
  return 24
})()

export const hyprRounding = getHyprOption("decoration:rounding", 10)
export const hyprBorder = getHyprOption("general:border_size", 2)
export const rawGaps = getHyprGapsOut()

export const gaps: GapsOut = {
  top: Math.round(rawGaps.top * GAPS_PROPORTION),
  right: Math.round(rawGaps.right * GAPS_PROPORTION),
  bottom: Math.round(rawGaps.bottom * GAPS_PROPORTION),
  left: Math.round(rawGaps.left * GAPS_PROPORTION),
}

export const eraserRadius = hyprRounding + hyprBorder

export function createCornerWidget(
  width: number,
  height: number,
  cx: number,
  cy: number,
  radius: number,
  className: string,
  valign?: Gtk.Align
): Gtk.DrawingArea {
  const da = new Gtk.DrawingArea()
  da.set_content_width(width)
  da.set_content_height(height)
  da.get_style_context().add_class(className)
  if (valign !== undefined) {
    da.valign = valign
  }

  da.set_draw_func((_self, cr, w, h) => {
    const context = _self.get_style_context()
    const gdkColor = context.get_color()

    cr.setSourceRGBA(gdkColor.red, gdkColor.green, gdkColor.blue, gdkColor.alpha)
    cr.rectangle(0, 0, w, h)
    cr.fill()

    cr.setOperator(Cairo.Operator.CLEAR)
    cr.newSubPath()
    cr.arc(cx, cy, radius, 0, 2 * Math.PI)
    cr.fill()
  })

  return da
}
