import app from "ags/gtk4/app"
import ScreenBorder from "./widget/ScreenBorder"
import Applauncher from "./widget/Launcher"
import { Gtk } from "ags/gtk4"

let appLauncher: Gtk.Window

app.start({
  requestHandler(request, res) {    
    if (!request || request.length === 0) return res("no arguments provided")

    switch (request[0]) {
      case "toggle":
        appLauncher.visible = !appLauncher.visible
        return res("ok")
      default:
        return res("unknown command")
    }
  },
  main() {
    appLauncher = Applauncher() as Gtk.Window
    app.add_window(appLauncher) 
    appLauncher.visible = false 

    app.get_monitors().map(monitor => {
      ScreenBorder(monitor)
    })
  },
})