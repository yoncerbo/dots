
let to_cbz = {|name| ^zip $"($name).cbz" $"($name)/*" -q}

def to-cbz [] {
  let item = $in
  if ($item | describe) == string {
    do $to_cbz $item
  } else {
    $item | par-each $to_cbz
  }
}

def unpack [] {
  ls 
}

def rename [items target_width = 2 destination_width = 2 --extension (-e) = ""] {
  let ext = (if $extension == "" {""} else {$".($extension)"})
  $items | each {|i|
    let target = ($i | fill -a r -w $target_width -c 0)
    let destination = ($i | fill -a r -w $destination_width -c 0)
    mv $"*($target)*" $"($destination)($ext)"
  }
}

def extract [items] {
  $items | par-each {|name| unzip $name -d $"($name | str substring ..-4)"}
}
