source /scr/files.nu
source /scr/open.nu

# alias menu = wofi --show dmenu -M fuzzy -G
# let choice = (files | menu | str trim)
# if $choice != "" {open mime $choice}

let width = (term size | get columns | $in - 4)
let choice = (files | lines | each {str substring 0..$width} | input list -f)

if $choice != "" {open mime $choice}
