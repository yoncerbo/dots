def nodes [] {
  cd /n
  ls | each {|it| {id: $it.name}}
}

def links [] {
  let nodes = (nodes | reduce -f {} {|it, acc]
    $acc | insert $it.id true
  })
  cd /n
  let links = (rg "\\[\\[[\\w-]+]]" -wo)
  $links | lines | each {|it|
    let sp = ($it | split column ":" source target)
    let target = ($sp.target.0 | str trim | str substring 2..-3)
    try {
      let _ = ($nodes | get $target)
      return {
        source: $sp.source.0
        target: $target
      }
    } catch { return null }
  }
}
