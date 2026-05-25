import app from "ags/gtk4/app"
import { Astal, Gdk } from "ags/gtk4"
import style from "./style.scss"

export default function ScreenBorder(monitor: Gdk.Monitor) {
  const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
  
  // ==========================================
  // ГЛАВНЫЙ ПУЛЬТ УПРАВЛЕНИЯ РАЗМЕРАМИ
  // ==========================================
  const size = 8          // Толщина линий (px)
  const borderSize = size * 2    // Базовый размер для маржинов углов (px)
  const innerRadius = "50%"
  const outerRadius = "0"
  // ==========================================

  const doubleBorderSize = borderSize * 4

  app.apply_css(style)

  function createSide(anchor: Astal.WindowAnchor, isHorizontal: boolean) {
    return (
      <window
        visible
        class="screen-border-line"
        name={`border-line-${anchor}-${monitor.get_description()}`}
        gdkmonitor={monitor}
        layer={Astal.Layer.TOP}
        exclusivity={Astal.Exclusivity.IGNORE}
        anchor={anchor}
        widthRequest={isHorizontal ? 1 : size}
        heightRequest={isHorizontal ? size : 1}
      />
    )
  }

  function createCorner(anchor: Astal.WindowAnchor, className: string, customCss: string) {
    return (
      <window
        visible
        class={`screen-border-corner-window ${className}`}
        name={`border-corner-${className}-${monitor.get_description()}`}
        gdkmonitor={monitor}
        layer={Astal.Layer.TOP}
        exclusivity={Astal.Exclusivity.IGNORE}
        anchor={anchor}
        widthRequest={doubleBorderSize}
        heightRequest={doubleBorderSize}
      >
        <box 
          class="corner-cutter" 
          widthRequest={doubleBorderSize} 
          heightRequest={doubleBorderSize}
          // Прокидываем сгенерированный CSS прямо в инлайн-стиль виджета
          css={customCss} 
        />
      </window>
    )
  }

  // Генерируем специфичный CSS для каждого угла на основе TS-переменных
  const c = {
    topLeft: `
      border-width: ${size * 2}px;
      margin-top: -${size}px;
      margin-left: -${size}px;
      margin-bottom: -${borderSize}px;
      margin-right: -${borderSize}px;
      border-radius: ${innerRadius} ${outerRadius} 0 ${outerRadius};
    `,
    topRight: `
      border-width: ${size * 2}px;
      margin-top: -${size}px;
      margin-right: -${size}px;
      margin-bottom: -${borderSize}px;
      margin-left: -${borderSize}px;
      border-radius: ${outerRadius} ${innerRadius} ${outerRadius} 0;
    `,
    bottomRight: `
      border-width: ${size * 2}px;
      margin-bottom: -${size}px;
      margin-right: -${size}px;
      margin-top: -${borderSize}px;
      margin-left: -${borderSize}px;
      border-radius: 0 ${outerRadius} ${innerRadius} ${outerRadius};
    `,
    bottomLeft: `
      border-width: ${size * 2}px;
      margin-bottom: -${size}px;
      margin-left: -${size}px;
      margin-top: -${borderSize}px;
      margin-right: -${borderSize}px;
      border-radius: ${outerRadius} 0 ${outerRadius} ${innerRadius};
    `
  }

  return [
    // Линии (они автоматически подхватят переменную `size`)
    createSide(TOP | LEFT | RIGHT, true),
    createSide(BOTTOM | LEFT | RIGHT, true),
    createSide(LEFT | TOP | BOTTOM, false),
    createSide(RIGHT | TOP | BOTTOM, false),

    // Углы с динамическим CSS
    createCorner(TOP | LEFT, "top-left", c.topLeft),
    createCorner(TOP | RIGHT, "top-right", c.topRight),
    createCorner(BOTTOM | RIGHT, "bottom-right", c.bottomRight),
    createCorner(BOTTOM | LEFT, "bottom-left", c.bottomLeft),
  ]
}