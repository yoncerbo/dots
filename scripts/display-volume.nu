pulsemixer --get-volume | parse "{a} {b}" | get 0.a
| $"($in) volume\n" 
| save -a /tmp/wob
