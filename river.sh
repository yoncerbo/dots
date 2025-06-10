#!/bin/sh

# This is the example configuration file for river.
#
# If you wish to edit this, you will probably want to copy it to
# $XDG_CONFIG_HOME/river/init or $HOME/.config/river/init first.

# TODO:
# smart gaps
# no client side decorations

# source /d/scripts/startup.sh
# mako &
# foot --server &
# fcitx --enable wayland-ime -rd

export NIXOS_OZONE_WL = "1";
export GTK_IM_MODULE = "fcitx";
export QT_IM_MODULE = "fcitx";
export XMODIFIERS = "@im=fcitx";
export SDL_IM_MODULE = "fcitx";
export GLFW_IM_MODULE = "ibus";
export QT_QPA_PLATFORM = "wayland";

otd-daemon &

riverctl spawn "pkill wob || mkfifo /tmp/wob || tail -f /tmp/wob | wob &"
riverctl spawn "foot --server"
riverctl spawn "fcitx5 --enable wayland-ime -rd"
riverctl spawn "mako"

riverctl map normal Super N spawn "footclient nvim"
riverctl map normal Super T spawn "footclient"

riverctl map normal Super W spawn "nu /s/dot/scripts/action-menu.nu"
riverctl map normal Super E spawn "fuzzel --config=/s/dot/fuzzel.ini"
riverctl map normal Super Q close
riverctl map normal Super+Shift Q exit

riverctl map normal Super J focus-view next
riverctl map normal Super K focus-view previous
riverctl map normal Super L swap next
riverctl map normal Super H swap previous

# Super+Period and Super+Comma to focus the next/previous output
riverctl map normal Super Period focus-output next
riverctl map normal Super Comma focus-output previous

# Super+Shift+{Period,Comma} to send the focused view to the next/previous output
riverctl map normal Super+Shift Period send-to-output next
riverctl map normal Super+Shift Comma send-to-output previous

# Super+Return to bump the focused view to the top of the layout stack
riverctl map normal Super Return zoom

# Super+H and Super+L to decrease/increase the main ratio of rivertile(1)
# riverctl map normal Super H send-layout-cmd rivertile "main-ratio -0.05"
# riverctl map normal Super L send-layout-cmd rivertile "main-ratio +0.05"

# Super+Shift+H and Super+Shift+L to increment/decrement the main count of rivertile(1)
# riverctl map normal Super+Shift H send-layout-cmd rivertile "main-count +1"
# riverctl map normal Super+Shift L send-layout-cmd rivertile "main-count -1"

# Super+Alt+{H,J,K,L} to move views
# riverctl map normal Super+Alt H move left 100
# riverctl map normal Super+Alt J move down 100
# riverctl map normal Super+Alt K move up 100
# riverctl map normal Super+Alt L move right 100

# Super+Alt+Control+{H,J,K,L} to snap views to screen edges
riverctl map normal Super+Shift H snap left
riverctl map normal Super+Shift J snap down
riverctl map normal Super+Shift K snap up
riverctl map normal Super+Shift L snap right

# Super+Alt+Shift+{H,J,K,L} to resize views
# riverctl map normal Super+Shift H resize horizontal -100
# riverctl map normal Super+Shift J resize vertical 100
# riverctl map normal Super+Shift K resize vertical -100
# riverctl map normal Super+Shift L resize horizontal 100

# Super + Left Mouse Button to move views
riverctl map-pointer normal Super BTN_LEFT move-view

# Super + Right Mouse Button to resize views
riverctl map-pointer normal Super BTN_RIGHT resize-view

# Super + Middle Mouse Button to toggle float
riverctl map-pointer normal Super BTN_MIDDLE toggle-float

riverctl map normal Super Tab focus-previous-tags
riverctl map normal Super+Control Tab send-to-previous-tags

keys="123456789FDSA"
for (( i=0; i<${#keys}; i++ )); do
  tags=$((1 << $i))
  key=${keys:$i:1}
  riverctl map normal Super $key set-focused-tags $tags
  riverctl map normal Super+Shift $key toggle-focused-tags $tags
  riverctl map normal Super+Control $key set-view-tags $tags
  riverctl map normal Super+Alt $key toggle-view-tags $tags
done

all_tags=$(((1 << 32) - 1))
riverctl map normal Super 0 set-focused-tags $all_tags
riverctl map normal Super+Control 0 set-view-tags $all_tags

riverctl map normal Super+Alt Q spawn "fcitx5-remote -s keyboard-pl"
riverctl map normal Super+Alt W spawn "fcitx5-remote -s mozc"
riverctl map normal Super+Alt E spawn "fcitx5-remote -s hangul"

riverctl map normal Super slash spawn "makoctl dismiss -a"
riverctl map normal Super+Shift slash spawn "makoctl invoke"
riverctl map normal Super Space spawn "playerctl play-pause"
riverctl map normal Super V toggle-float
riverctl map normal Super G toggle-fullscreen

riverctl map normal Super+Shift I  spawn 'pamixer -i 5'
riverctl map normal Super I  spawn 'pamixer -d 5'
riverctl map normal Super M spawn 'pamixer --toggle-mute'
riverctl map normal Super+Alt H  spawn 'playerctl previous'
riverctl map normal Super+Alt L  spawn 'playerctl next'
riverctl map normal Super+Shift U spawn 'brightnessctl set +5%'
riverctl map normal Super U spawn 'brightnessctl set 5%-'

# Super+{Up,Right,Down,Left} to change layout orientation
riverctl map normal Super Up    send-layout-cmd rivertile "main-location top"
riverctl map normal Super Right send-layout-cmd rivertile "main-location right"
riverctl map normal Super Down  send-layout-cmd rivertile "main-location bottom"
riverctl map normal Super Left  send-layout-cmd rivertile "main-location left"

# Declare a passthrough mode. This mode has only a single mapping to return to
# normal mode. This makes it useful for testing a nested wayland compositor
riverctl declare-mode passthrough

# Super+F11 to enter passthrough mode
riverctl map normal Super F11 enter-mode passthrough

riverctl map passthrough Super F11 enter-mode normal

# Various media key mapping examples for both normal and locked mode which do
# not have a modifier
for mode in normal locked
do
    # Eject the optical drive (well if you still have one that is)
    riverctl map $mode None XF86Eject spawn 'eject -T'

    # Control pulse audio volume with pamixer (https://github.com/cdemoulins/pamixer)
    riverctl map $mode None XF86AudioRaiseVolume  spawn 'pamixer -i 5'
    riverctl map $mode None XF86AudioLowerVolume  spawn 'pamixer -d 5'
    riverctl map $mode None XF86AudioMute         spawn 'pamixer --toggle-mute'

    # Control MPRIS aware media players with playerctl (https://github.com/altdesktop/playerctl)
    riverctl map $mode None XF86AudioMedia spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPlay  spawn 'playerctl play-pause'
    riverctl map $mode None XF86AudioPrev  spawn 'playerctl previous'
    riverctl map $mode None XF86AudioNext  spawn 'playerctl next'

    # Control screen backlight brightness with brightnessctl (https://github.com/Hummer12007/brightnessctl)
    riverctl map $mode None XF86MonBrightnessUp   spawn 'brightnessctl set +5%'
    riverctl map $mode None XF86MonBrightnessDown spawn 'brightnessctl set 5%-'
done

riverctl background-color 0x000000
riverctl border-color-focused 0xbbbbbb
riverctl border-color-unfocused 0x000000
riverctl border-width 3

riverctl keyboard-layout pl

# Gamepad mappings
riverctl map normal None F13 spawn 'lutris'
riverctl map normal None F14 spawn 'steam'

# Set keyboard repeat rate
riverctl set-repeat 50 300

riverctl rule-add ssd

# Set the default layout generator to be rivertile and start it.
# River will send the process group of the init executable SIGTERM on exit.
riverctl default-layout rivertile
rivertile -view-padding 3 -outer-padding 3 -main-ratio 0.5 &
