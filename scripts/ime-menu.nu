let all_ime = (rg Name= /a/fcitx5/profile | lines | skip 1 | each {str substring 5..})
fcitx5-remote -c
let choice = ($all_ime | str join "\n" | fuzzel --config=/s/dot/fuzzel.ini --dmenu | str trim)
if $choice == "" { fcitx5-remote -o } else { fcitx5-remote -s $choice }
