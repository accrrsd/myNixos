import { createState } from "ags"
import { readFile, monitorFile } from "ags/file"
import { exec } from "ags/process"
import { Gdk, Gtk } from "ags/gtk4"
import Cairo from "cairo"
import GLib from "gi://GLib"
import Gio from "gi://Gio"
import app from "ags/gtk4/app"

try {
  const display = Gdk.Display.get_default()
  if (display) {
    const theme = Gtk.IconTheme.get_for_display(display)
    theme.add_search_path(`${GLib.get_home_dir()}/.config/ags/assets`)
    theme.add_search_path(`${GLib.get_home_dir()}/.config/ags/src/assets`)
  }
} catch (e) {
  console.error("[settingsParser] Failed to add icon search path:", e)
}

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

export interface FancySettings {
  speed: number
  fold_type: "sequential" | "simultaneous" | "simultaneous-debounce"
  transition_duration?: number | null
}

export interface LauncherConfig {
  gaps_proportion: number
  "launcher.font": string
  "launcher.icon_size_multiplayer": number
  height_mode: "fancy" | "full"
  fancy_settings: FancySettings
  commands: Record<string, CommandConfig>
}

export interface NotificationsConfig {
  corner: "top-left" | "top-right" | "bottom-left" | "bottom-right"
  mode: "monolithic" | "single"
  timeout: number
  collapsed_by_default: boolean
  summary_max_length: number
  monolithic_spacing: number
  icon_size: number
}

export interface AppConfig {
  app_launcher: LauncherConfig
  notifications: NotificationsConfig
}

const configPath = `${GLib.get_home_dir()}/.config/ags-settings.json`

export const DEFAULT_CONFIG: AppConfig = {
  app_launcher: {
    gaps_proportion: 0.33,
    "launcher.font": "14pt Hack Nerd Font, sans-serif",
    "launcher.icon_size_multiplayer": 1.25,
    height_mode: "full",
    fancy_settings: {
      speed: 0.05,
      fold_type: "simultaneous-debounce",
      transition_duration: null
    },
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
  },
  notifications: {
    corner: "top-right",
    mode: "single",
    timeout: 5000,
    collapsed_by_default: true,
    summary_max_length: 50,
    monolithic_spacing: 6,
    icon_size: 44
  }
}

function loadConfig(): AppConfig {
  try {
    const file = Gio.File.new_for_path(configPath)
    if (file.query_exists(null)) {
      const content = readFile(file)
      const parsed = JSON.parse(content)
      const parsedLauncher = parsed.app_launcher || {}
      const parsedFancy = parsedLauncher.fancy_settings || {}
      const fancy_settings: FancySettings = {
        speed: typeof parsedFancy.speed === "number" ? parsedFancy.speed : DEFAULT_CONFIG.app_launcher.fancy_settings.speed,
        fold_type: typeof parsedFancy.fold_type === "string" && ["sequential", "simultaneous", "simultaneous-debounce"].includes(parsedFancy.fold_type)
          ? parsedFancy.fold_type as any
          : DEFAULT_CONFIG.app_launcher.fancy_settings.fold_type,
        transition_duration: typeof parsedFancy.transition_duration === "number" ? parsedFancy.transition_duration : null
      }

      const parsedNotifs = parsed.notifications || {}
      const notifications: NotificationsConfig = {
        corner: typeof parsedNotifs.corner === "string" && ["top-left", "top-right", "bottom-left", "bottom-right"].includes(parsedNotifs.corner)
          ? parsedNotifs.corner as any
          : DEFAULT_CONFIG.notifications.corner,
        mode: typeof parsedNotifs.mode === "string" && ["monolithic", "single"].includes(parsedNotifs.mode)
          ? parsedNotifs.mode as any
          : DEFAULT_CONFIG.notifications.mode,
        timeout: typeof parsedNotifs.timeout === "number" ? parsedNotifs.timeout : DEFAULT_CONFIG.notifications.timeout,
        collapsed_by_default: typeof parsedNotifs.collapsed_by_default === "boolean"
          ? parsedNotifs.collapsed_by_default
          : DEFAULT_CONFIG.notifications.collapsed_by_default,
        summary_max_length: typeof parsedNotifs.summary_max_length === "number"
          ? parsedNotifs.summary_max_length
          : DEFAULT_CONFIG.notifications.summary_max_length,
        monolithic_spacing: typeof parsedNotifs.monolithic_spacing === "number"
          ? parsedNotifs.monolithic_spacing
          : DEFAULT_CONFIG.notifications.monolithic_spacing,
        icon_size: typeof parsedNotifs.icon_size === "number"
          ? parsedNotifs.icon_size
          : DEFAULT_CONFIG.notifications.icon_size
      }

      return {
        app_launcher: {
          gaps_proportion: typeof parsedLauncher.gaps_proportion === "number" ? parsedLauncher.gaps_proportion : DEFAULT_CONFIG.app_launcher.gaps_proportion,
          "launcher.font": typeof parsedLauncher["launcher.font"] === "string" ? parsedLauncher["launcher.font"] : DEFAULT_CONFIG.app_launcher["launcher.font"],
          "launcher.icon_size_multiplayer": typeof parsedLauncher["launcher.icon_size_multiplayer"] === "number" ? parsedLauncher["launcher.icon_size_multiplayer"] : DEFAULT_CONFIG.app_launcher["launcher.icon_size_multiplayer"],
          height_mode: typeof parsedLauncher.height_mode === "string" && (parsedLauncher.height_mode === "fancy" || parsedLauncher.height_mode === "full") ? parsedLauncher.height_mode : DEFAULT_CONFIG.app_launcher.height_mode,
          fancy_settings,
          commands: parsedLauncher.commands && typeof parsedLauncher.commands === "object" ? parsedLauncher.commands : DEFAULT_CONFIG.app_launcher.commands
        },
        notifications
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

const activeConfig = configState.peek().app_launcher
export const GAPS_PROPORTION = activeConfig.gaps_proportion
export const launcherFont = activeConfig["launcher.font"]
export const launcherIconSizeMultiplayer = activeConfig["launcher.icon_size_multiplayer"]

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
export const fancySpeed = activeConfig.fancy_settings.speed
export const fancySettings = activeConfig.fancy_settings

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
  da.add_css_class(className)
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

  // Redraw on first show (picks up CSS if already applied)
  da.connect("realize", () => {
    GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
      da.queue_draw()
      return GLib.SOURCE_REMOVE
    })
    // Second pass after a short delay — ensures the color is correct even when
    // app.apply_css() is called after realize (GTK4 has no style-change signal)
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
      da.queue_draw()
      return GLib.SOURCE_REMOVE
    })
  })


  return da
}

export function applyStyle(styleCss: string) {
  let colorsCss = ""
  const path = `${GLib.get_home_dir()}/.cache/matugen/colors-gtk4.css`
  try {
    const file = Gio.File.new_for_path(path)
    if (file.query_exists(null)) {
      colorsCss = readFile(file)
    }
  } catch (e) {
    console.error("[settingsParser] Error reading colors.css:", e)
  }
  app.apply_css(colorsCss + "\n" + styleCss)
}
