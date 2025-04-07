source /f/pueue.nu
source /f/menu.nu

let editor = {spawn editor $"footclient nvim ($in)"; null}
let mpv = {spawn mpv $"mpv ($in)"}

let cmds = {
  text: $editor
  unknown: $editor
  javascript: $editor
  json: $editor
  image: {spawn swayimg $"swayimg ($in)"}
  pdf: {spawn zathura $"zathura ($in)"}
  video: $mpv
  audio: $mpv
  dir: {spawn terminal $"cd ($in); footclient"}
  # zip
  # epub
  # font
}

def mime [path] {
  ls -mD $path | get 0.type
}

def "open mime" [path=""] {
  let path = (if $path == "" { $in } else { $path })
  if not ($path | path exists) { return "Path does not exist!" }

  let mime = (ls -mD $path | get 0.type | split row "/")

  try {
    ($path | do ($cmds | get $mime.1))
  }
  try {
    ($path | do ($cmds | get $mime.0))
  }
}

def file-menu [] {
  ls -s /f/ | sort-by modified | reverse | get name | str join "\n" | menu | str trim
}

def "open path" [path: string] {
  if ($path | path exists) {
    open mime $path
  } else {
    $path | do $editor
  }
}

def main [] {
  let path = (file-menu)
  if $path != "" {open path ($"/f/($path)")}
}
