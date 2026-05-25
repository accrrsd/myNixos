import app from "ags/gtk4/app"
import ScreenBorder from "./widget/ScreenBorder"

app.start({
  main() {
    app.get_monitors().map(monitor=>{
      ScreenBorder(monitor)
    })
  },
})
