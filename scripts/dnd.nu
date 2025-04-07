def roll [n: int] {
  random integer 0..$n
}

def d [n: int modifier = 1 -a -d] {
  # Roll normal if both or neither
  if not ($a xor $d) {roll $n} else {
    [(roll $n) (roll $n)] |
    if $a {math max} else {math min}
  } | $in + $modifier
}

def get_modifier [] {
  ($in - 10) // 2
}

def choose [] {
  # str join "\n" | fzf | str trim
  input list
}
def choose-module [from: record] {
  let type = ($from | columns | choose)
  let module = ($from | get $type)
  do $module.options | merge {type: $type}
}

def choice [from: record options: record] {
  let module = ($from | get $options.type)
  [$module $options]
}

def make-module [module: record options: record data: record] {
  $data | merge (do $module.make $options $data)
}

def make-modules [list: list data: record] {
  $list | reduce -f $data {|item, acc|
    make-module $item.0 $item.1 $acc
  }
}

let abilities = [str dex con int wis cha]

let race_modules = {
  elf: {
    options: {
      let a1 = ($abilities | filter {$in != cha} | choose)
      let a2 = ($abilities |
        filter {$in != cha and $in != $a1} | choose)
      {
        first-ability: $a1
        second-ability: $a2
      }
    }
    make: {|opt, data|
      let abilities = {
        $opt.first-ability: (($data.abilities | get $opt.first-ability) + 1)
        $opt.second-ability: (($data.abilities | get $opt.first-ability) + 1)
        cha: ($data.abilities.cha + 2)
      }
      {
        race: Elf
        size: Medium
        speed: 30
        abilities: ($data.abilities | merge $abilities)
      }
    }
  }
}

let ability_modules = {
  pool: {
    options: {{
      str: (print -n "str: "; input | into int)
      dex: (print -n "dex: "; input | into int)
      con: (print -n "con: "; input | into int)
      int: (print -n "int: "; input | into int)
      wis: (print -n "wis: "; input | into int)
      cha: (print -n "cha: "; input | into int)
    }}
    make: {|opt, data|{abilities: {
      str: (8 + $opt.str)
      dex: (8 + $opt.dex)
      con: (8 + $opt.con)
      int: (8 + $opt.int)
      wis: (8 + $opt.wis)
      cha: (8 + $opt.cha)
    }}}
  }
}

let new_abilites_mod = {
  options: {{
    str: (print -n "str: "; input | into int)
  }}
  make: {{
    str: (field str +1)
  }}
}

let appearance_module = {
  options: {{
    age: (print -n "age: "; input | into int)
    feet: (print -n "feet: "; input | into int)
    inches: (print -n "inches: "; input | into int)
    pounds: (print -n "pounds: "; input | into int)
    eye-color: (print -n "eye-color: "; input | str trim)
  }}
  make: {|opt, data| $opt}
}

let modifiers_module = {
  make: {|opt, data|{
    modifiers: ($abilities | reduce -f {} {|name, acc|
      $acc | insert $name ($data.abilities | get $name | get_modifier)
    })
  }}
}
let character = {
  options: {
    {
      abilities: (choose-module $ability_modules)
      race: (choose-module $race_modules)
      appearance: (do $appearance_module.options)
    }
  }
  make: {|opt, data|
    let modules = [
      (choice $ability_modules $opt.abilities)
      (choice $race_modules $opt.race)
      [$appearance_module $opt.appearance]
      [$modifiers_module {}]
    ]
    # make-modules $modules $data
  }
}

def field [input action] {{
  input: $input
  action: $action
}}

def template [make options] {{
  make: $make
  options: $options
}}

let actions = {
  "+1": {$in + 1}
}

let new_abilites_mod = {
  options: {{
    str: (print -n "str: "; input | into int)
  }}
  make: {{
    str: (field str +1)
  }}
}

def combine [data = {}] { reduce -f data {|item, acc|
  $acc | merge ($item | each {|v|
   print ($v | table -e)
    let input = ($acc | get $v.input)
    let action = ($actions | get $v.action)
    do $action $input
  })
}}

def eval-module [data] {transpose key value | readuce -f {} {|item, acc|
  $acc | upsert $item.key $item.value
}}

def eval-field [data] {
  let field = $in
  let input = $field.input
  let action = $field.action

  let input = if ($input | describe) == "list<string>" {
    $input | reduce -f {} {|name, acc|
      $acc | upsert $name ($data | get $name)
    }} else {$data | get $input}
  let action = if ($action | describe) == string {
    ($actions | get $action)} else {$action}
  $input | do $action
}

def build [] { each {|val|
  let make = $val.make
  let opts = $val.options
  $opts | do $make
}}

# do we need to pass data
# combining options
# flake like appraoch for every option
# list of merged modules

def make [options: record] {
  do $character.make $options {}
}

def ch [name: string] {
  let file = $"/res/characters/($name).yml"
  open $file | get appearance notes |
  $"($in.1)($in.0 | table -e)"
}
