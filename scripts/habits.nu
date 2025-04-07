def split [dir = /res/habit] {
  mkdir $dir
  cd $dir
  open /res/habits.yml | reverse | enumerate | each {|item|
    let date = (2023-07-21T00:00:00+02:00 - ($item.index * 1day))
    $item.item | to yaml | save ($date | date format "%Y-%m-%d.yml")
  }
}

def streak [name: string] {
  let table = (open /res/habits.yml | drop 1 | reverse )
  mut i = 0
  loop { try {
    $table | get $i | get $name
    $i = ($i + 1)
  } catch { break }}
  $i
}

def streaks [] {
  open /res/habits.yml | columns | each {|name| {
    index: $name
    streak: (streak $name)
  }}
}
