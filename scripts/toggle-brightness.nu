let current = (brightnessctl g | into int)
let max = (brightnessctl m | into int)

if $current <= ($max / 2) {
  brightnessctl s $max
} else {
  brightnessctl s 0
}
