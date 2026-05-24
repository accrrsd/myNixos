#!/usr/bin/env bash
swww-daemon &

change_wallpaper &

sleep 0.1
waybar &
dunst &