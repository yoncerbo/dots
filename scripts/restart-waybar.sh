
CONFIG=/s/dot/waybar/config.jsonc
STYLE=/s/dot/waybar/style.css

while true; do
  waybar -c $CONFIG -s $STYLE &
  inotifywait -e create,modify $CONFIG $STYLE
  pkill waybar
done
