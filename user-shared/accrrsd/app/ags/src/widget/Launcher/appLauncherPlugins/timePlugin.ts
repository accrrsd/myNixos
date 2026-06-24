import { execAsync } from "ags/process"
import { LauncherItem } from "../index"
import { CommandConfig } from "../../../settingsParser"
import { AppLauncherPlugin, AppLauncherPluginContext } from "./types"
import GLib from "gi://GLib"

export const TimeLauncherPlugin: AppLauncherPlugin = {
  type: "time",
  execute(args: string, cmd: CommandConfig, ctx: AppLauncherPluginContext): LauncherItem[] {
    const now = GLib.DateTime.new_now_local()
    const formatted = now.format("%H:%M - %d.%m.%y") || ""

    return [{
      id: `time-${cmd.name || "time"}-${formatted}`,
      name: formatted,
      iconName: cmd.icon || "preferences-system-time",
      action: () => {
        execAsync(["wl-copy", formatted]).catch(console.error)
        ctx.win.visible = false
      }
    }]
  }
}
