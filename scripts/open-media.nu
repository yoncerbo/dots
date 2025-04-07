
cd /m
let choice = (ls | get name | str join "\n" | wofi --show dmenu -Gm fuzzy | str trim)

zathura --fork $choice
