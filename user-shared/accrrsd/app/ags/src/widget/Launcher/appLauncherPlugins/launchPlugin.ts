import { execAsync } from "ags/process"
import { LauncherItem } from "../index"
import { CommandConfig } from "../../../settingsParser"
import { AppLauncherPlugin, AppLauncherPluginContext } from "./types"

export const LaunchLauncherPlugin: AppLauncherPlugin = {
  type: "launch",
  execute(args: string, cmd: CommandConfig, ctx: AppLauncherPluginContext): LauncherItem[] {
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

    return [{
      id: `launch-${cmd.name || "launch"}-${args || "empty"}`,
      name: `${cmd.name || "Launch"}${args ? ` (${args})` : ""}`,
      iconName: cmd.icon || "system-run",
      action: () => {
        if (commandToRun) {
          execAsync(["setsid", "-f", "sh", "-c", commandToRun]).catch(console.error)
        }
        ctx.win.visible = false
      }
    }]
  }
}
