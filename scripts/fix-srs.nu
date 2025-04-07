use assert

def fix [file] {
  let data = (open $file)
  let note = {
    term: ($data.word | str trim) 
    context: ($data.sentence | str replace -as $data.word "{}"
    | str replace "\n" " " | str trim)
    image: ($data.image | str substring 10..-4)
    audio: ($data.audio | str substring 7..-1)
    reading: $data.reading
    meaning: ($data.meaning | str replace "\n" "," | str trim)
    memo: null
    extra: (if $data.extra == ​ { null } else { $data.extra })
  }
  assert ($"media/($note.audio)" | path exists) $"($file)\n($note.audio)"
  assert ($"media/($note.image)" | path exists) $"($file)\n($note.image)"
  $note
}

def "fix all" [path] {
  mkdir res
  ls $path | get name | each {|name|
    fix $name | to yaml | save $"res/($name | path basename)"
  }
}
