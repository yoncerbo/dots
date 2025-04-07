let workspaces = (swaymsg -t get_workspaces -p | split row "\n\n"
| parse "{a} {id} {state} {b}" | reject a b)

swaymsg workspace new

$workspaces | enumerate | reduce -f 0 {|it, modifier|
  let new_id = ($it.index + $modifier)
  let it = $it.item
  if $new_id != $it.id {
    swaymsg rename workspace $it.id to $new_id
  }
  if $it.state == "(focused)\n" {
    swaymsg rename workspace new to ($new_id + 1)
    1
  } else { $modifier }
}
null
