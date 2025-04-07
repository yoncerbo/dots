
let media = /res/clear/srs/media
let id = (random uuid)

cp /tmp/mpv-screenshot.jpg $"($media)/($id)"
$id | wl-copy
