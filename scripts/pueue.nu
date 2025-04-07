def spawn [label: string cmd: string] {
  let cmd = $"nu -c '($cmd)' --env-config \"($nu.env-path)\" --config \"($nu.config-path)\""
  pueue add -i -l $label -p $cmd | into int
}

def log [id?: int] {
  let args = [-f --json]
  let args = (if $id != null { $args | prepend $id } else { $args })
  pueue log $args
  | from json
  | transpose -i info
  | flatten --all
  | flatten --all
  | flatten status
}

def output [id: int] {
  log $id | get output.0
}

alias restart = pueue restart
alias pkill = pueue kill
alias clean = pueue clean
alias follow = pueue follow
