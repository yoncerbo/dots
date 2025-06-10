
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
}

let selection = ($actions | columns | str join "\n" | fuzzel --config=/s/dot/fuzzel.ini --dmenu)
if $selection == "" { exit }
do ($actions | get $selection)
