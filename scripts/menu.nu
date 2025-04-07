
def menu [] {
  let sel = $in
  fcitx5-remote -c
  let ret = ($sel | wofi --show dmenu -G -M fuzzy)
  fcitx5-remote -o
  $ret
}

def m [mode = dmenu] {
  (rofi -show $mode
  -no-fixed-num-lines
  -terminal footclient
  -matching fuzzy
  -window-thumbnail
  -window-match-fields title
  -window-format "{t}"
  -no-plugins
  -theme gruvbox-dark
  )
  # DarkBlue Monokai android_notification purple sidebar
}
