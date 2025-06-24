let screenshot_dir = "/f/images/screenshots/"

let actions = {
  Hibernate: { systemctl hibernate }
  Sleep: { systemctl sleep }
  Shutdown: { shutdown now }
  Reboot: { reboot }
  "Reboot into firmware": { systemctl reboot --firmware-setup }
  "Game menu": { source /s/dot/scripts/game-menu.nu }
  "Copy password": { source /s/dot/scripts/copy-password.nu }
  "Tablet normal mode": { otd applypreset normal }
  "Tablet osu mode": { otd applypreset osu }
  "Rescan wifi": { nmcli d w r }
  "Rebuild nixos": { sudo nixos-rebuild switch; notify-send "Finished rebuilding nixos" -t 1000}
  "Select sink": {
    let sinks = (pactl list sinks short | lines | split column "\t" index name)
    let index = ($sinks.name | str join "\n" | fuzzel --dmenu --index)
    if $index == "" { exit }
    let sink = ($sinks.name | get ($index | into int))
    pactl set-default-sink $sink
  }
  "Toggle right monitor": { wlr-randr --output DP-2 --toggle }
  "Toggle left monitor": { wlr-randr --output DP-1 --toggle }
  "Rotate right monitor": { 
    let current = (wlr-randr --json | from json | get 0 | get transform)
    wlr-randr --output DP-2 --transform (if $current == "90" { "normal" } else { "90" })
  }
  "Lock": { hyprlock }
  "Screenshot all": { cd $screenshot_dir; grim }
  "Screenshot selection": { cd $screenshot_dir; grim -g (slurp) }
  "Screenshot left": { cd $screenshot_dir; grim -o DP-1 }
  "Screenshot right": { cd $screenshot_dir; grim -o DP-2 }
  "Monitor brightness zero": { 
    job spawn { ddcutil setvcp 10 0 --display 1 }
    job spawn { ddcutil setvcp 10 0 --display 2 }
  }
  "Monitor brightness hundred": { 
    job spawn { ddcutil setvcp 10 100 --display 1 }
    job spawn { ddcutil setvcp 10 100 --display 2 }
  }
}

let selection = ($actions | columns | str join "\n" | fuzzel --dmenu)
if $selection == "" { exit }
do ($actions | get $selection)
