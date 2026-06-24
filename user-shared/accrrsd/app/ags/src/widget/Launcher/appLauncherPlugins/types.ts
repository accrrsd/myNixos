import { Astal } from "ags/gtk4"
import { LauncherItem } from "../index"
import { CommandConfig } from "../../../settingsParser"

export interface AppLauncherPluginContext {
  queryId: number
  currentQueryIdRef: { value: number }
  win: Astal.Window
  setList: (items: LauncherItem[]) => void
}

export interface AppLauncherPlugin {
  type: string
  execute(args: string, cmd: CommandConfig, ctx: AppLauncherPluginContext): LauncherItem[]
}
