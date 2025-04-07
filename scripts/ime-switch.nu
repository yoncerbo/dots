let ime_file = "/f/ime-state";
let new = (try {open $ime_file} catch { "keyboard-pl" })
fcitx5-remote -o # activate ime
let current = (fcitx5-remote -n)
fcitx5-remote -s $new
$current | save -f $ime_file
