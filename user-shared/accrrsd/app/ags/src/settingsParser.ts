import { createState } from "ags"
import { readFile, monitorFile } from "ags/file"
import { exec } from "ags/process"
import { Gtk } from "ags/gtk4"
import Cairo from "cairo"
import GLib from "gi://GLib"
import Gio from "gi://Gio"

export interface GapsOut {
  top: number
  right: number
  bottom: number
  left: number
}

export interface CommandConfig {
  type: "calc" | "launch"
  exec?: string
  icon?: string
  name?: string
}

export interface LauncherConfig {
  gaps_proportion: number
  launcher_font: string
  launcher_icon_size_multiplayer: number
  height_mode: "fancy" | "full"
  fancy_speed: number
  commands: Record<string, CommandConfig>
}

const configPath = `${GLib.get_home_dir()}/.config/ags-launcher.json`

export const DEFAULT_CONFIG: LauncherConfig = {
  gaps_proportion: 0.33,
  launcher_font: "14pt Hack Nerd Font, sans-serif",
  launcher_icon_size_multiplayer: 1.25,
  height_mode: "full",
  fancy_speed: 0.05,
  commands: {
    c: {
      type: "calc",
      name: "Calculator",
      icon: "accessories-calculator"
    },
    ym: {
      type: "launch",
      exec: "xdg-open https://music.yandex.ru",
      name: "Yandex Music",
      icon: "applications-internet"
    },
    w: {
      type: "launch",
      exec: "select-wallpaper",
      name: "Wallpaper Selector",
      icon: "background"
    }
  }
}

function loadConfig(): LauncherConfig {
  try {
    const file = Gio.File.new_for_path(configPath)
    if (file.query_exists(null)) {
      const content = readFile(file)
      const parsed = JSON.parse(content)
      return {
        gaps_proportion: typeof parsed.gaps_proportion === "number" ? parsed.gaps_proportion : DEFAULT_CONFIG.gaps_proportion,
        launcher_font: typeof parsed.launcher_font === "string" ? parsed.launcher_font : DEFAULT_CONFIG.launcher_font,
        launcher_icon_size_multiplayer: typeof parsed.launcher_icon_size_multiplayer === "number" ? parsed.launcher_icon_size_multiplayer : DEFAULT_CONFIG.launcher_icon_size_multiplayer,
        height_mode: typeof parsed.height_mode === "string" && (parsed.height_mode === "fancy" || parsed.height_mode === "full") ? parsed.height_mode : DEFAULT_CONFIG.height_mode,
        fancy_speed: typeof parsed.fancy_speed === "number" ? parsed.fancy_speed : DEFAULT_CONFIG.fancy_speed,
        commands: parsed.commands && typeof parsed.commands === "object" ? parsed.commands : DEFAULT_CONFIG.commands
      }
    }
  } catch (e) {
    console.error("[settingsParser] Error loading config:", e)
  }
  return DEFAULT_CONFIG
}

const [config, setConfig] = createState(loadConfig())
export const configState = config

// Monitor configuration file for updates
try {
  const file = Gio.File.new_for_path(configPath)
  if (file.query_exists(null)) {
    monitorFile(configPath, () => {
      console.log("[settingsParser] Config file changed, reloading...")
      const newConfig = loadConfig()
      setConfig(newConfig)
    })
  } else {
    // Check periodically/setup monitor if created later
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 5000, () => {
      if (Gio.File.new_for_path(configPath).query_exists(null)) {
        monitorFile(configPath, () => {
          console.log("[settingsParser] Config file changed, reloading...")
          const newConfig = loadConfig()
          setConfig(newConfig)
        })
        return GLib.SOURCE_REMOVE
      }
      return GLib.SOURCE_CONTINUE
    })
  }
} catch (e) {
  console.error("[settingsParser] Failed to monitor config file:", e)
}

export function getHyprOption(option: string, defaultValue: number): number {
  try {
    const output = exec(`hyprctl getoption ${option} -j`)
    const configVal = JSON.parse(output)
    return configVal.int !== undefined ? configVal.int : defaultValue
  } catch (e) {
    return defaultValue
  }
}

export function getHyprGapsOut(): GapsOut {
  const defaultGaps = { top: 16, right: 16, bottom: 16, left: 16 }
  try {
    const output = exec("hyprctl getoption general:gaps_out -j")
    const configVal = JSON.parse(output)

    const gapsString = configVal.custom || configVal.str || configVal.css || ""
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

export const hyprRounding = getHyprOption("decoration:rounding", 10)
export const hyprBorder = getHyprOption("general:border_size", 2)
export const rawGaps = getHyprGapsOut()
export const eraserRadius = hyprRounding + hyprBorder

const activeConfig = configState.peek()
export const GAPS_PROPORTION = activeConfig.gaps_proportion
export const launcherFont = activeConfig.launcher_font
export const launcherIconSizeMultiplayer = activeConfig.launcher_icon_size_multiplayer

export function computeIconSize(font: string, multiplayer: number): number {
  const match = font.match(/(\d+)(pt|px)/)
  if (match) {
    const val = parseInt(match[1])
    const unit = match[2]
    const px = unit === "pt" ? val * 1.333 : val
    return Math.round(px * 1.5 * multiplayer)
  }
  return 24
}

export const launcherIconSize = computeIconSize(launcherFont, launcherIconSizeMultiplayer)
export const heightMode = activeConfig.height_mode
export const fancySpeed = activeConfig.fancy_speed

export function computeGaps(proportion: number): GapsOut {
  return {
    top: Math.round(rawGaps.top * proportion),
    right: Math.round(rawGaps.right * proportion),
    bottom: Math.round(rawGaps.bottom * proportion),
    left: Math.round(rawGaps.left * proportion),
  }
}

export const gaps = computeGaps(GAPS_PROPORTION)

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
