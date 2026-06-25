import { createState, createComputed, createEffect } from "ags"
import { Astal, Gtk } from "ags/gtk4"
import app from "ags/gtk4/app"
import GLib from "gi://GLib"
import AstalNotifd from "gi://AstalNotifd"
import style from "./style.scss"
import {
  gaps,
  eraserRadius,
  hyprRounding,
  createCornerWidget,
  configState,
  applyStyle
} from "../../settingsParser"

// ---------------------------------------------------------------------------
// Fillet helpers
// ---------------------------------------------------------------------------

/**
 * Creates a concave corner widget with the `notification-fillet` CSS class.
 * halign is applied after construction because createCornerWidget only accepts valign.
 */
function createNotificationFillet(
  cx: number,
  cy: number,
  valign?: Gtk.Align,
  halign?: Gtk.Align
) {
  const da = createCornerWidget(
    eraserRadius,
    eraserRadius,
    cx,
    cy,
    eraserRadius,
    "notification-fillet",
    valign
  )
  if (halign !== undefined) {
    da.halign = halign
  }
  return da
}

// ---------------------------------------------------------------------------
// Fillet / radius helpers (depend only on corner, not reactive state)
// ---------------------------------------------------------------------------

/**
 * Returns corner-radius CSS for the notification card based on which screen
 * corner it occupies and whether it is the "corner card" (touching the edge).
 */
function getContentStyle(corner: string, isCorner: boolean): string {
  if (isCorner) {
    switch (corner) {
      case "top-left":
        return `
          border-top-left-radius: ${hyprRounding}px;
          border-bottom-right-radius: ${hyprRounding}px;
          border-top-right-radius: 0px;
          border-bottom-left-radius: 0px;
        `
      case "top-right":
        return `
          border-top-right-radius: ${hyprRounding}px;
          border-bottom-left-radius: ${hyprRounding}px;
          border-top-left-radius: 0px;
          border-bottom-right-radius: 0px;
        `
      case "bottom-left":
        return `
          border-bottom-left-radius: ${hyprRounding}px;
          border-top-right-radius: ${hyprRounding}px;
          border-bottom-right-radius: 0px;
          border-top-left-radius: 0px;
        `
      case "bottom-right":
        return `
          border-bottom-right-radius: ${hyprRounding}px;
          border-top-left-radius: ${hyprRounding}px;
          border-bottom-left-radius: 0px;
          border-top-right-radius: 0px;
        `
    }
  }

  // Side-only card (not touching the screen corner)
  const isLeftBorder = corner === "top-left" || corner === "bottom-left"
  if (isLeftBorder) {
    return `
      border-top-right-radius: ${hyprRounding}px;
      border-bottom-right-radius: ${hyprRounding}px;
      border-top-left-radius: 0px;
      border-bottom-left-radius: 0px;
    `
  }
  return `
    border-top-left-radius: ${hyprRounding}px;
    border-bottom-left-radius: ${hyprRounding}px;
    border-top-right-radius: 0px;
    border-bottom-right-radius: 0px;
  `
}

/**
 * Wraps `contentWidget` with the appropriate concave corner fillets so that
 * the notification card visually "snaps into" the screen corner.
 */
function wrapWithFillets(
  contentWidget: Gtk.Widget,
  corner: string,
  isCorner: boolean
): Gtk.Widget {
  if (isCorner) {
    switch (corner) {
      case "top-left": {
        const topRightFillet = createNotificationFillet(eraserRadius, eraserRadius, Gtk.Align.START, Gtk.Align.END)
        const bottomLeftFillet = createNotificationFillet(eraserRadius, eraserRadius, Gtk.Align.START, Gtk.Align.START)
        return (
          <box orientation={Gtk.Orientation.VERTICAL}>
            <box orientation={Gtk.Orientation.HORIZONTAL}>
              {contentWidget}
              {topRightFillet}
            </box>
            <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.START}>
              {bottomLeftFillet}
            </box>
          </box>
        )
      }
      case "top-right": {
        const topLeftFillet = createNotificationFillet(0, eraserRadius, Gtk.Align.START, Gtk.Align.START)
        const bottomRightFillet = createNotificationFillet(0, eraserRadius, Gtk.Align.START, Gtk.Align.END)
        return (
          <box orientation={Gtk.Orientation.VERTICAL}>
            <box orientation={Gtk.Orientation.HORIZONTAL}>
              {topLeftFillet}
              {contentWidget}
            </box>
            <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.END}>
              {bottomRightFillet}
            </box>
          </box>
        )
      }
      case "bottom-left": {
        const topLeftFillet = createNotificationFillet(eraserRadius, 0, Gtk.Align.END, Gtk.Align.START)
        const bottomRightFillet = createNotificationFillet(0, 0, Gtk.Align.END, Gtk.Align.END)
        return (
          <box orientation={Gtk.Orientation.VERTICAL}>
            <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.START}>
              {topLeftFillet}
            </box>
            <box orientation={Gtk.Orientation.HORIZONTAL}>
              {contentWidget}
              {bottomRightFillet}
            </box>
          </box>
        )
      }
      case "bottom-right": {
        const topRightFillet = createNotificationFillet(0, 0, Gtk.Align.END, Gtk.Align.END)
        const bottomLeftFillet = createNotificationFillet(eraserRadius, 0, Gtk.Align.END, Gtk.Align.START)
        return (
          <box orientation={Gtk.Orientation.VERTICAL}>
            <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.END}>
              {topRightFillet}
            </box>
            <box orientation={Gtk.Orientation.HORIZONTAL}>
              {bottomLeftFillet}
              {contentWidget}
            </box>
          </box>
        )
      }
    }
  }

  // Side-only (subsequent cards in single mode)
  const isLeftBorder = corner === "top-left" || corner === "bottom-left"
  if (isLeftBorder) {
    const topLeftFillet = createNotificationFillet(eraserRadius, 0, Gtk.Align.END, Gtk.Align.START)
    const bottomLeftFillet = createNotificationFillet(eraserRadius, eraserRadius, Gtk.Align.START, Gtk.Align.START)
    return (
      <box orientation={Gtk.Orientation.VERTICAL}>
        <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.START}>
          {topLeftFillet}
        </box>
        {contentWidget}
        <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.START}>
          {bottomLeftFillet}
        </box>
      </box>
    )
  } else {
    const topRightFillet = createNotificationFillet(0, 0, Gtk.Align.END, Gtk.Align.END)
    const bottomRightFillet = createNotificationFillet(0, eraserRadius, Gtk.Align.START, Gtk.Align.END)
    return (
      <box orientation={Gtk.Orientation.VERTICAL}>
        <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.END}>
          {topRightFillet}
        </box>
        {contentWidget}
        <box orientation={Gtk.Orientation.HORIZONTAL} halign={Gtk.Align.END}>
          {bottomRightFillet}
        </box>
      </box>
    )
  }

  // Fallback (should never reach here, but keeps TS happy)
  return contentWidget
}

// ---------------------------------------------------------------------------
// NotificationCard
// ---------------------------------------------------------------------------

interface NotificationCardProps {
  notification: AstalNotifd.Notification
  corner: string
  isCorner: boolean
}

function NotificationCard({ notification, corner, isCorner }: NotificationCardProps) {
  const isIconPath = (icon: string | null) =>
    icon && (icon.startsWith("/") || icon.startsWith("file://"))

  const iconFile = notification.image || (isIconPath(notification.app_icon) ? notification.app_icon : null)
  const iconName = !iconFile ? (notification.app_icon || "dialog-information") : null

  const urgencyClass = (() => {
    switch (notification.urgency) {
      case AstalNotifd.Urgency.LOW:      return "urgency-low"
      case AstalNotifd.Urgency.CRITICAL: return "urgency-critical"
      default:                           return "urgency-normal"
    }
  })()

  return (
    <box
      class={`notification-card ${urgencyClass}`}
      css={getContentStyle(corner, isCorner)}
      widthRequest={360}
    >
      <box orientation={Gtk.Orientation.HORIZONTAL} spacing={12} valign={Gtk.Align.START} hexpand>
        {/* Icon / avatar */}
        {iconFile
          ? <image file={iconFile} widthRequest={44} heightRequest={44} valign={Gtk.Align.START} class="app-icon" />
          : <image iconName={iconName || "dialog-information"} pixelSize={44} valign={Gtk.Align.START} class="app-icon" />
        }

        {/* Content */}
        <box orientation={Gtk.Orientation.VERTICAL} hexpand>
          <box orientation={Gtk.Orientation.HORIZONTAL} valign={Gtk.Align.CENTER}>
            <label
              label={notification.app_name || "Notification"}
              class="app-name"
              halign={Gtk.Align.START}
              hexpand
            />
            <button
              onClicked={() => notification.dismiss()}
              class="close-button"
              halign={Gtk.Align.END}
            >
              <image iconName="window-close-symbolic" />
            </button>
          </box>

          <label
            label={notification.summary}
            class="summary-text"
            halign={Gtk.Align.START}
            wrap
          />
          <label
            label={notification.body}
            class="body-text"
            halign={Gtk.Align.START}
            wrap
            useMarkup
          />

          {notification.actions && notification.actions.length > 0 && (
            <box orientation={Gtk.Orientation.HORIZONTAL} class="actions-box" spacing={8}>
              {notification.actions.map(action => (
                <button onClicked={() => notification.invoke(action.id)}>
                  <label label={action.label} />
                </button>
              ))}
            </box>
          )}
        </box>
      </box>
    </box>
  )
}

// ---------------------------------------------------------------------------
// NotificationItem — one item in the list (Revealer + fillets + card)
// ---------------------------------------------------------------------------

interface NotificationItemProps {
  notif: AstalNotifd.Notification
  revealed: boolean
  corner: string
  isCorner: boolean
  transitionType: Gtk.RevealerTransitionType
  halign: Gtk.Align
}

function NotificationItem({ notif, revealed, corner, isCorner, transitionType, halign }: NotificationItemProps) {
  const card = (
    <NotificationCard
      notification={notif}
      corner={corner}
      isCorner={isCorner}
    />
  )
  return (
    <Gtk.Revealer
      revealChild={revealed}
      transitionType={transitionType}
      transitionDuration={250}
      halign={halign}
    >
      {wrapWithFillets(card, corner, isCorner)}
    </Gtk.Revealer>
  )
}

// ---------------------------------------------------------------------------
// Main Notifications widget
// ---------------------------------------------------------------------------

export default function Notifications() {
  applyStyle(style)

  const notifd = AstalNotifd.get_default()

  const corner = createComputed(() => configState().notifications.corner || "top-right")
  const mode   = createComputed(() => configState().notifications.mode   || "single")

  // Seed with already-active notifications
  const initialNotifs = notifd.get_notifications().map(n => ({ notif: n, revealed: true }))
  const [list, setList] = createState(initialNotifs)

  // -------------------------------------------------------------------------
  // Incoming notification
  // -------------------------------------------------------------------------
  notifd.connect("notified", (_, id) => {
    const n = notifd.get_notification(id)
    if (!n) return

    const current = list.peek()
    const existingIndex = current.findIndex(item => item.notif.id === id)

    if (existingIndex !== -1) {
      // Update existing entry in-place
      const updated = [...current]
      updated[existingIndex] = { notif: n, revealed: true }
      setList(updated)
    } else {
      // Insert with revealed=false, then flip to true on the next idle tick
      const isTop = corner.peek() === "top-left" || corner.peek() === "top-right"
      const next = isTop
        ? [{ notif: n, revealed: false }, ...current]
        : [...current, { notif: n, revealed: false }]
      setList(next)

      GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
        setList(list.peek().map(item =>
          item.notif.id === id ? { ...item, revealed: true } : item
        ))
        return GLib.SOURCE_REMOVE
      })
    }

    // Auto-dismiss timer for non-critical notifications
    const configTimeout = configState.peek().notifications.timeout ?? 5000
    if (configTimeout > 0 && n.urgency !== AstalNotifd.Urgency.CRITICAL) {
      GLib.timeout_add(GLib.PRIORITY_DEFAULT, configTimeout, () => {
        const currentNotif = notifd.get_notification(id)
        if (currentNotif) {
          currentNotif.dismiss()
        }
        return GLib.SOURCE_REMOVE
      })
    }
  })

  // -------------------------------------------------------------------------
  // Dismissed / resolved notification — animate out, then remove
  // -------------------------------------------------------------------------
  notifd.connect("resolved", (_, id) => {
    GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
      const current = list.peek()
      const index = current.findIndex(item => item.notif.id === id)
      if (index === -1) return GLib.SOURCE_REMOVE

      // Collapse the revealer first
      const updated = [...current]
      updated[index] = { ...updated[index], revealed: false }
      setList(updated)

      // Remove from list after the transition finishes
      GLib.timeout_add(GLib.PRIORITY_DEFAULT, 260, () => {
        setList(list.peek().filter(item => item.notif.id !== id))
        return GLib.SOURCE_REMOVE
      })
      return GLib.SOURCE_REMOVE
    })
  })

  // -------------------------------------------------------------------------
  // Computed layout properties
  // -------------------------------------------------------------------------
  const alignProps = createComputed(() => {
    const c = corner()
    switch (c) {
      case "top-left":
        return { valign: Gtk.Align.START, halign: Gtk.Align.START, marginTop: gaps.top,    marginBottom: 0,           marginStart: gaps.left,  marginEnd: 0 }
      case "top-right":
        return { valign: Gtk.Align.START, halign: Gtk.Align.END,   marginTop: gaps.top,    marginBottom: 0,           marginStart: 0,          marginEnd: gaps.right }
      case "bottom-left":
        return { valign: Gtk.Align.END,   halign: Gtk.Align.START, marginTop: 0,           marginBottom: gaps.bottom, marginStart: gaps.left,  marginEnd: 0 }
      case "bottom-right":
        return { valign: Gtk.Align.END,   halign: Gtk.Align.END,   marginTop: 0,           marginBottom: gaps.bottom, marginStart: 0,          marginEnd: gaps.right }
      default:
        return { valign: Gtk.Align.START, halign: Gtk.Align.END,   marginTop: gaps.top,    marginBottom: 0,           marginStart: 0,          marginEnd: gaps.right }
    }
  })

  const windowAnchor = createComputed(() => {
    const { TOP, BOTTOM, LEFT, RIGHT } = Astal.WindowAnchor
    switch (corner()) {
      case "top-left":    return TOP | LEFT
      case "top-right":   return TOP | RIGHT
      case "bottom-left": return BOTTOM | LEFT
      case "bottom-right":return BOTTOM | RIGHT
      default:            return TOP | RIGHT
    }
  })

  const transitionType = createComputed(() => {
    const c = corner()
    return c === "top-left" || c === "bottom-left"
      ? Gtk.RevealerTransitionType.SLIDE_RIGHT
      : Gtk.RevealerTransitionType.SLIDE_LEFT
  })

  // -------------------------------------------------------------------------
  // Reactive content: built dynamically inside createEffect and appended to listBox
  // This executes inside Gnim's active effect tracking context, allowing proper
  // signal cleanup and preventing the "out of tracking context" warning.
  // -------------------------------------------------------------------------
  const listBox = <box orientation={Gtk.Orientation.VERTICAL} spacing={8} />

  createEffect(() => {
    const currentList  = list()
    const activeCorner = corner()
    const activeMode   = mode()
    const tt           = transitionType()
    const hal          = alignProps().halign

    // Clear existing children
    let child = listBox.get_first_child()
    while (child) {
      const next = child.get_next_sibling()
      listBox.remove(child)
      child = next
    }

    if (currentList.length === 0) {
      return
    }

    if (activeMode === "monolithic") {
      const containerBox = (
        <box
          orientation={Gtk.Orientation.VERTICAL}
          class="notifications-monolithic-container"
          css={getContentStyle(activeCorner, true)}
          widthRequest={360}
        >
          {currentList.map(({ notif, revealed }) => (
            <Gtk.Revealer
              revealChild={revealed}
              transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
              transitionDuration={250}
            >
              <NotificationCard
                notification={notif}
                corner={activeCorner}
                isCorner={false}
              />
            </Gtk.Revealer>
          ))}
        </box>
      )
      const wrapped = wrapWithFillets(containerBox, activeCorner, true)
      listBox.append(wrapped)
    } else {
      const isTop = activeCorner === "top-left" || activeCorner === "top-right"
      const singleBox = (
        <box orientation={Gtk.Orientation.VERTICAL} spacing={8}>
          {currentList.map(({ notif, revealed }, idx) => {
            const isCorner = isTop ? idx === 0 : idx === currentList.length - 1
            return (
              <NotificationItem
                notif={notif}
                revealed={revealed}
                corner={activeCorner}
                isCorner={isCorner}
                transitionType={tt}
                halign={hal}
              />
            )
          })}
        </box>
      )
      listBox.append(singleBox)
    }
  })

  // -------------------------------------------------------------------------
  // Window
  // -------------------------------------------------------------------------
  return (
    <window
      visible={createComputed(() => list().length > 0)}
      name="notifications"
      class="notifications-window"
      namespace="notifications"
      anchor={windowAnchor}
      exclusivity={Astal.Exclusivity.IGNORE}
      layer={Astal.Layer.OVERLAY}
    >
      <box
        orientation={Gtk.Orientation.VERTICAL}
        valign={createComputed(() => alignProps().valign)}
        halign={createComputed(() => alignProps().halign)}
        marginTop={createComputed(() => alignProps().marginTop)}
        marginBottom={createComputed(() => alignProps().marginBottom)}
        marginStart={createComputed(() => alignProps().marginStart)}
        marginEnd={createComputed(() => alignProps().marginEnd)}
      >
        {listBox}
      </box>
    </window>
  )
}
