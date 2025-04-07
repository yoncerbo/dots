let split_char = ""

def "apkg map" [path = "."] {
  let db = (open $"($path)/collection.anki2")
  let models = $db.col.models.0
  ($db.notes | group-by mid 
  | transpose mid notes | each {apkg notes $models})
}

def "apkg notes" [models] {
  let it = $in
  let notes = ($it.notes | get flds | split column $split_char)

  let models = ($models | from json)
  let fields = ($models | get $"($it.mid)"
  | get flds.name | each {str kebab-case})

  let notes = ($fields | enumerate | reduce -f $notes {|it, notes|
    $notes | rename -c [$"column($it.index + 1)" $it.item]
  })
  {mid: $it.mid notes: $notes}
}

def "apkg db" [] {
  apkg map | get notes.0 | into sqlite notes.db
}

def "apkg media" [destination: string path = "."] {
  open $"($path)/media" | from json | transpose current new | each {|it|
    mv $"($path)/($it.current)" $"($destination)/($it.new)"
  }
}

def "apkg extract" [name path = "."] {
  if ($name | path exists) {
    print $"Directory ($name) already exists."
    return
  }
  print $"Extracting ($name)"
  let file = $"($name).apkg"
  let destination = $"/tmp/($name)"
  unzip $file -d $destination
  mkdir $name
  apkg map $destination | get notes.0 | into sqlite $"($name)/notes.db"
  apkg media $"($name)" $destination
  rm -r $destination
}

def "apkg extract-all" [path = "."] {
  ls $"($path)/*.apkg" | get name | each {|name|
    $name | path basename | str substring ..-5 | apkg extract $in $path
  }
}
