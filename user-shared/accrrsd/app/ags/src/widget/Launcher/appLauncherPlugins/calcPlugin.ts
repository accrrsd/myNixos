import { execAsync } from "ags/process"
import { LauncherItem } from "../index"
import { CommandConfig } from "../../../settingsParser"
import { AppLauncherPlugin, AppLauncherPluginContext } from "./types"

export const CalcLauncherPlugin: AppLauncherPlugin = {
  type: "calc",
  execute(args: string, cmd: CommandConfig, ctx: AppLauncherPluginContext): LauncherItem[] {
    let evalResult = ""

    if (args.trim()) {
      execAsync(["qalc", "-terse", args])
        .then((stdout) => {
          if (ctx.queryId === ctx.currentQueryIdRef.value) {
            const res = stdout.trim()
            if (res) {
              evalResult = res
              const display = `${args} = ${res}`
              const updatedItem: LauncherItem = {
                id: `calc-${cmd.name || "calc"}-${display}`,
                name: display,
                iconName: cmd.icon || "accessories-calculator",
                action: () => {
                  execAsync(["wl-copy", res]).catch(console.error)
                  ctx.win.visible = false
                }
              }
              ctx.setList([updatedItem])
            }
          }
        })
        .catch(() => {
          if (ctx.queryId === ctx.currentQueryIdRef.value) {
            const updatedItem: LauncherItem = {
              id: `calc-${cmd.name || "calc"}-${args}-err`,
              name: args,
              iconName: cmd.icon || "accessories-calculator",
              action: () => {
                ctx.win.visible = false
              }
            }
            ctx.setList([updatedItem])
          }
        })
    }

    return [{
      id: `calc-${cmd.name || "calc"}-${args || "empty"}`,
      name: args.trim() ? args : "Type expression...",
      iconName: cmd.icon || "accessories-calculator",
      action: () => {
        if (evalResult) {
          execAsync(["wl-copy", evalResult]).catch(console.error)
        }
        ctx.win.visible = false
      }
    }]
  }
}
