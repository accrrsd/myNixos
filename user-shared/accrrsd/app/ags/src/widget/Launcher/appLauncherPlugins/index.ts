import { CalcLauncherPlugin } from "./calcPlugin"
import { LaunchLauncherPlugin } from "./launchPlugin"
import { TimeLauncherPlugin } from "./timePlugin"
import { AppLauncherPlugin } from "./types"

export * from "./types"

export const appLauncherPlugins: Record<string, AppLauncherPlugin> = {
  calc: CalcLauncherPlugin,
  launch: LaunchLauncherPlugin,
  time: TimeLauncherPlugin,
}
