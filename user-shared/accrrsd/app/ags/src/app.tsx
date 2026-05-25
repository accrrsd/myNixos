import app from "ags/gtk4/app"
import { Window, WindowAnchor, Exclusivity } from "ags/gtk4/widget"
import { exec } from "ags/io"
import Gdk from "gi://Gdk?version=4.0"
import Gtk from "gi://Gtk?version=4.0"

// Функция для получения скругления из Hyprland
function getHyprlandRounding(): number {
    try {
        // Вызываем hyprctl для получения текущего скругления
        const output = exec("hyprctl getoption decoration:rounding -j")
        const data = JSON.parse(output)
        return data.int ?? 0
    } catch (e) {
        console.error("Не удалось прочитать скругление из Hyprland:", e)
        return 12 // Дефолтное значение, если что-то пошло не так
    }
}

function ScreenCorners(monitor: Gdk.Monitor): Gtk.Window {
    const rounding = getHyprlandRounding()

    return new Window({
        monitor,
        name: `corners-${monitor.get_description()}`,
        className: "screen-corners", 
        // В AGS v2 побитовые маски (TOP | BOTTOM) часто заменены на массивы или строки,
        // но если используется перечисление, то синтаксис выглядит так:
        anchor: WindowAnchor.TOP | WindowAnchor.BOTTOM | WindowAnchor.LEFT | WindowAnchor.RIGHT,
        exclusivity: Exclusivity.IGNORE,
        visible: true,
        css: `border-radius: ${rounding}px;`,
        child: new Gtk.Box()
    }) as Gtk.Window
}

app.start({
    instanceName: "shell",
    main() {
        // Создаем рамку на каждом мониторе
        // Обратите внимание: в зависимости от версии, мониторы могут быть в app.monitors
        app.monitors.map(ScreenCorners)
    },
})