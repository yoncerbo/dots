let fcitx_profile = "/f/fcitx5/profile"
let ime_state = "/f/tmp/ime_state"

def "ime all" [] {
  rg Name= $fcitx_profile | lines | skip 1 | each {str substring 5..}
}

def "ime switch" [] {
  let ime = (open $ime_state | lines | first 2)
  fcitx5-remote -s $ime.0
  $"($ime.1)\n($ime.0)" | save -f $ime_state
}

def "ime choose" [] {
  let ime = (open $ime_state | lines | first 2)

  fcitx5-remote -s keyboard-pl
  let choice = (ime all | str join "\n" | fuzzel --path=/s/dot/fuzzel.ini --dmenu | str trim)
  let choice = (if $choice == "" {$ime.1} else {$choice})
  fcitx5-remote -s $choice

  $"($ime.0)\n($choice)" | save -f $ime_state
}
