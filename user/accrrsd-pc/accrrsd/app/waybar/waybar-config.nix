{ ... }:
{
  # make via home.file instead of nix syntax or extraConfig because i want to experement with it without rebuild.
  home.file.".config/waybar/config".text = ''
  
    {
    "layer": "top",
    "position": "bottom",
    "modules-left": [
      "custom/logo",
      "clock",
      "disk",
      "memory",
      "cpu",
      "temperature",
      "custom/powerDraw"
    ],
    "modules-center": [
      "hyprland/workspaces",
      "mpd"
    ],
    "modules-right": [
      "hyprland/window",
      "tray",
      "custom/updates",
      "custom/clipboard",
      "group/blight",
      "idle_inhibitor",
      "custom/colorpicker",
      "bluetooth",
      "group/audio",
      "custom/hotspot",
      "group/networking",
      "battery"
    ],
    "reload_style_on_change": true,
    "custom/logo": {
      "format": "󰊠",
      "tooltip": false,
      "on-click": "~/.config/rofi/scripts/powermenu.sh"
    },
    "clock": {
      "format": "{:%I:%M:%S %p}",
      "interval": 1,
      "tooltip-format": "\n<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>",
      "calendar-weeks-pos": "right",
      "today-format": "<span color='#7645AD'><b><u>{}</u></b></span>",
      "format-calendar": "<span color='#aeaeae'><b>{}</b></span>",
      "format-calendar-weeks": "<span color='#aeaeae'><b>W{:%V}</b></span>",
      "format-calendar-weekdays": "<span color='#aeaeae'><b>{}</b></span>"
    },
    "hyprland/language": {
      "format": "Lang: {long}",
      "format-en": "AMERICA, HELL YEAH!",
      "format-tr": "As bayrakları",
      "keyboard-name": "at-translated-set-2-keyboard"
    },
    "disk": {
      "interval": 30,
      "format": " {percentage_used}%",
      "path": "/"
    },
    "memory": {
      "format": " {percentage}%"
    },
    "cpu": {
      "interval": 1,
      "format": " {usage}%",
      "format-icons": [
        "▁",
        "▂",
        "▃",
        "▄",
        "▅",
        "▆",
        "▇",
        "█"
      ]
    },
    "temperature": {
      "format": " {temperatureC}°C",
      "format-critical": " {temperatureC}°C",
      "interval": 1,
      "critical-threshold": 80,
      "on-click": "foot btop"
    },
    "custom/powerDraw": {
      "format": "{}",
      "interval": 1,
      "exec": "~/.config/waybar/scripts/powerdraw.sh",
      "return-type": "json"
    },
    "hyprland/workspaces": {
      "format": "<span font='18px'>{icon}</span>",
      "format-icons": {
        "1": "१",
        "2": "२",
        "3": "३",
        "4": "४",
        "5": "५",
        "6": "६",
        "default": ""
      },
      "persistent-workspaces": {
        "*": [
          1,
          2,
          3,
          4,
          5,
          6
        ]
      }
    },
    "hyprland/window": {
      "format": "( {class} )",
      "rewrite": {
        "(.*) - Mozilla Firefox": "🌎 $1",
        "org.telegram.desktop": "> [$1]",
        "org.gnome.Nautilus": "> [$1]",
        "(.*) - zsh": "> [$1]"
      }
    },
    "tray": {
      "icon-size": 14,
      "spacing": 10
    },
    "custom/updates": {
      "format": "{}",
      "interval": 60,
      "exec": "~/.config/waybar/scripts/checkupdate.sh",
      "return-type": "json",
      "exec-if": "exit 0"
    },
    "custom/clipboard": {
      "interval": 5,
      "tooltip": true,
      "on-click": "sh -c 'cliphist list | rofi -dmenu | cliphist decode | wl-copy'"
    },
    "group/blight": {
      "orientation": "horizontal",
      "drawer": {
        "transition-duration": 500,
        "transition-left-to-right": false
      },
      "modules": [
        "backlight",
        "backlight/slider"
      ]
    },
    "backlight": {
      "device": "intel_backlight",
      "format": "<span font='12'>{icon}</span>",
      "format-icons": [
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        "",
        ""
      ],
      "on-scroll-down": "light -U 10",
      "on-scroll-up": "light -A 10",
      "smooth-scrolling-threshold": 1
    },
    "backlight/slider": {
      "min": 0,
      "max": 100,
      "orientation": "horizontal",
      "device": "intel_backlight"
    },
    "idle_inhibitor": {
      "format": "<span font='12'>{icon}</span>",
      "format-icons": {
        "activated": "󰾪",
        "deactivated": "󰅶"
      }
    },
    "custom/colorpicker": {
      "format": "{}",
      "return-type": "json",
      "interval": "once",
      "exec": "~/.config/waybar/scripts/colorpicker.sh -j",
      "on-click": "sleep 1 && ~/.config/waybar/scripts/colorpicker.sh"
    },
    "bluetooth": {
      "format-on": "󰂰",
      "format-off": "",
      "format-disabled": "󰂲",
      "format-connected": "󰂴",
      "format-connected-battery": "{device_battery_percentage}% 󰂴",
      "tooltip-format": "{controller_alias}\t{controller_address}\n\n{num_connections} connected",
      "tooltip-format-connected": "{controller_alias}\t{controller_address}\n\n{num_connections} connected\n\n{device_enumerate}",
      "tooltip-format-enumerate-connected": "{device_alias}\t{device_address}",
      "tooltip-format-enumerate-connected-battery": "{device_alias}\t{device_address}\t{device_battery_percentage}%",
      "on-click": "rofi-bluetooth"
    },
    "pulseaudio": {
      "format": "{icon}",
      "format-bluetooth": "󰂰",
      "format-muted": "",
      "tooltip-format": "{volume}% {icon}",
      "format-icons": {
        "headphones": "",
        "bluetooth": "󰥰",
        "handsfree": "",
        "headset": "󱡬",
        "phone": "",
        "portable": "",
        "car": "",
        "default": [
          "🕨",
          "🕩",
          "🕪"
        ]
      },
      "scroll-step": 5,
      "justify": "center",
      "on-click": "amixer sset Master toggle",
      "on-click-right": "pavucontrol",
      "tooltip-format": "{volume}%  {icon}",
      "on-scroll-up": "pactl set-sink-volume @DEFAULT_SINK@ +5%",
      "on-scroll-down": "pactl set-sink-volume @DEFAULT_SINK@ -5%"
    },
    "pulseaudio#mic": {
      "format": "{format_source}",
      "format-source": "",
      "format-source-muted": "",
      "tooltip-format": "{volume}% {format_source} ",
      "on-click": "pactl set-source-mute 0 toggle",
      "on-scroll-down": "pactl set-source-volume 0 -1%",
      "on-scroll-up": "pactl set-source-volume 0 +1%"
    },
    "group/audio": {
      "orientation": "horizontal",
      "drawer": {
        "transition-duration": 500,
        "transition-left-to-right": false
      },
      "modules": [
        "pulseaudio",
        "pulseaudio#mic",
        "pulseaudio/slider"
      ]
    },
    "pulseaudio/slider": {
      "min": 0,
      "max": 140,
      "orientation": "horizontal"
    },
    "custom/hotspot": {
      "format": "{icon}",
      "interval": 1,
      "tooltip": true,
      "return-type": "json",
      "format-icons": {
        "active": "󱜠",
        "notactive": "󱜡"
      },
      "exec": "waybar-hotspot -a watch",
      "on-click": "waybar-hotspot -a toggle"
    },
    "network": {
      "format-wifi": " ",
      "format-ethernet": "󰈀",
      "format-disconnected": "󱐅",
      "tooltip-format": "{ipaddr}",
      "tooltip-format-wifi": "{essid} ({signalStrength}%)  | {ipaddr}",
      "tooltip-format-ethernet": "{ifname} 🖧 | {ipaddr}",
      "tooltip-format-ethernet": "{bandwidthTotalBytes}",
      "on-click": "networkmanager_dmenu"
    },
    "network#speed": {
      "format": "{bandwidthDownBits}",
      "interval": 1,
      "tooltip-format": "{ipaddr}",
      "tooltip-format-wifi": "{essid} ({signalStrength}%)   \n{ipaddr} | {frequency} MHz{icon} ",
      "tooltip-format-ethernet": "{ifname} 󰈀 \n{ipaddr} | {frequency} MHz{icon} ",
      "tooltip-format-disconnected": "Not Connected to any type of Network",
      "tooltip": true,
      "on-click": "pgrep -x rofi &>/dev/null && notify-send rofi || networkmanager_dmenu"
    },
    "group/networking": {
      "orientation": "horizontal",
      "drawer": {
        "transition-duration": 500,
        "transition-left-to-right": false
      },
      "modules": [
        "network",
        "network#speed"
      ]
    },
    "battery": {
      "interval": 1,
      "states": {
        "good": 95,
        "warning": 30,
        "critical": 20
      },
      "tooltip": true,
      "format": "{capacity}% <span font='16px'>{icon}</span>",
      "format-time": "{H}h {M}min",
      "tooltip": "{time}",
      "format-charging": "{capacity}% <span font='16px'>{icon}</span>",
      "format-plugged": "{capacity}% 󰠠",
      "format-icons": [
        "󰪞",
        "󰪟",
        "󰪠",
        "󰪡",
        "󰪢",
        "󰪣",
        "󰪤",
        "󰪥"
      ],
      "on-click": "~/.config/rofi/scripts/powermenu.sh"
    },
    "mpd": {
      "format": "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) <U+F001>",
      "format-disconnected": "Disconnected <U+F001>",
      "format-stopped": "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped <U+F001>",
      "interval": 2,
      "consume-icons": {
        "on": "<U+F0C4> " 
      },
      "random-icons": {
        "off": "<span color=\"#f53c3c\"><U+F074></span> ", 
        "on": "<U+F074> "
      },
      "repeat-icons": {
        "on": "<U+F01E> "
      },
      "single-icons": {
        "on": "<U+F01E>1 "
      },
      "state-icons": {
        "paused": "<U+F04C>",
        "playing": "<U+F04B>"
      },
      "tooltip-format": "MPD (connected)",
      "tooltip-format-disconnected": "MPD (disconnected)"
    }
  }

    
  '';
}