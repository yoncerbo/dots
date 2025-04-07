brightnessctl i -m | from csv -n | get 0.column4
| $"($in | str substring ..-1) brightness\n" 
| save -a /tmp/wob
