

let metadata_file = "__metadata.json"
let game_directory = "/f/games"

cd $game_directory
let selection = (ls | get name | str join "\n" | fuzzel --config=/s/dot/fuzzel.ini --dmenu)
if $selection == "" { exit }
cd $selection
print $selection

if not (($metadata_file | path exists) and ($metadata_file | open | path exists)) {
  let selection = (fd .exe | fuzzel --config=/s/dot/fuzzel.ini --dmenu)
  if $selection == "" { exit }
  echo $selection | save $metadata_file -f
  print $selection
}

wine $"(open $metadata_file)"
