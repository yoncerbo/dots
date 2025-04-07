def task [start duration end] {
  let start = (if $start != null {
    (1hr * ($start // 100)) + (1min * ($start mod 100))
  } else { null })
  let duration = (if $duration != null { $duration * 1min } else { null })
  let end = (if $end != null {
    (1hr * ($end // 100)) + (1min * ($end mod 100))
  } else { null })
  match [$start $duration $end] {
    [null null null] => null
    [$start null null] => {start: $start}
    [null $duration null] => {duration: $duration}
    [null null $end] => {end: $end}

    [$start $duration null] => {task: {start: $start duration: $duration
      end: ($start + $duration)}}
    [$start null $end] => {task: {start: $start end: $end
      duration: (Send - $start)}}
    [null $duration $end] => {task: {start: ($end - $duration)
      duration: $duration end: $end}}
    [$start $duration $end] => {task: {start: $start duration: $duration
      end: $end}}
  }
}

let file = "/tmp/calendar"

let letters = ("fjdksl" | split chars)

let selectors = ($letters | prepend "" | each {|first|
  $letters | each {|second|
    $"($first)($second)"
  }
} | flatten)

def c [...cmds] {
  let edits = (try { open $file | lines } catch { return [] })
  if $cmds != [] { $"($cmds | str join ' ')\n" | save $file -a }

  $edits | each {split row " "} | append [$cmds]
  | reduce -f [] {|it, acc| $acc 
  | process-input ($it | each {str trim})}
}

def process-input [input: list] {
  let tasks = $in
  match $input {
    [] => { return $tasks }
    [clear] | [cl] => { return [] }
    [- $n] => {}
    [- $n $s] => {}
    [+ $n] => {}
    [+ $n $s] => {}
    [d $s $e] => {}
    [d $s] => {}
    $rest => { 
      let len = ($tasks | length)
      return ($tasks | append {index: ($selectors | get $len) 
      item: ($input | str join " ")})
    }
  }
  $tasks
}

def new-task [input: string] {
  let tasks = $in
  let selector = "^[asdfghjkl;]{1,2}$"
  let time = "^/d{4}"
  let duration = "^/d{1,3}$"

  $tasks | append ($input | str join " ")
}

def "parse task" [] {
  let task = ($in | str trim)

  let time = ($task | try-parsing-time)
  if $time != null {
    let duration = ($time.rest | try-parsing-duration)
    if $duration != null {
      # start duration task
      return {start: $time.time duration: $duration.duration task: $duration.rest}
    }
    # start task
    return {start: $time.time duration: null task: $time.rest}
  }

  let duration = ($task | try-parsing-duration)
  if $duration != null {
    let time = ($duration.rest | try-parsing-time)
    if $time != null {
      # duration end task
      let dur = $duration.duration
      return {start: ($time.time - $dur) duration: $dur task: $time.rest}
    }
    # duration task
    return {start: null duration: $duration.duration task: $duration.rest}
  }

  # task
  {start: null duration: null task: $task}
}

def parse-word [] {
  str trim | parse '{value} {rest}' | get 0
}

def try-parsing-duration [] {
  try { parse-word | update value {|value|
    if ($value | length) <= 3 {
      $value | into int
    }
  }}
}

def try-parsing-time [] {
  try {
    let it = (parse-word)
    print ($it.value)
    if ($it.value | length) == 4 {
      let hour = ($it.value | str substring ..2 | into int)
      let minute = ($it.value | str substring 2.. | into int)
      ($hour * 1hr) + ($minute * 1min)
    }
  }
}

def "calendar parse" [] {
  let lines = ($in | lines | enumerate)
  let comments = ($lines | filter {$in.item starts-with " " or $in.item == ""})

  let tasks = ($lines | filter {not ($in.item starts-with " " or $in.item == "")} 
  | each {|it|
    let type = ($it.item | str substring 0..1 | str trim)

    let start = (if $type == @ {
      let time = ($it.item | str substring 2..7
      | split column ":" hr min | get 0)
      (($time.hr | into int) * 1hr + ($time.min | into int) * 1min)
    } else { null })

    let rest = ($it.item | str substring 8.. | str trim
    | parse "{duration} {task}" | get 0)
    let task = ($rest.task | str trim)

    let duration = if $type != . {
      $rest.duration | into int | $in * 1min
    } else { 0sec }

    {type: $type start: $start duration: $duration task: $task line: $it.index}
  })

  # calculate additional duration
  let additional_tasks = ($tasks | where type == : | reject start type)
  let tasks = ($tasks | filter {$in.type != :})

  {tasks: $tasks additional: $additional_tasks comments: $comments}
}

def "calendar eval-tasks" [] {
  let tasks = $in
  let initial = {duration: 0min start: 0min groups: []}
  let acc = ($tasks | reduce -f $initial {|it, acc|
    if $it.type == @ {
      let rest = ($it.start - $acc.start - $acc.duration)
      # TODO: add error handling when the tasks_duration is higher
      {
        duration: $it.duration
        start: $it.start
        groups: ($acc.groups | append $rest)
      }
    } else {
      $acc | upsert duration ($acc.duration + $it.duration)
    }
  }) 
  let groups = ($acc.groups 
  | append (24hr - $acc.start - $acc.duration) | skip 1)

  let initial = {index: 0 rest: 0min tasks: [] start: 0min}
  $tasks | reduce -f $initial {|it, acc| match $it.type {
    @ => {
      index: ($acc.index + 1)
      start: ($it.start + $it.duration)
      rest: ($groups | get $acc.index)
      tasks: ($acc.tasks | append $it)
    },
    . => {
      index: $acc.index
      start: ($acc.start + $acc.rest)
      rest: 0min
      tasks: ($acc.tasks | append ($it
      | upsert start $acc.start
      | upsert duration $acc.rest
      ))
    },
    | => {
      index: $acc.index
      start: ($acc.start + $it.duration)
      rest: $acc.rest
      tasks: ($acc.tasks | append ($it | upsert start $acc.start))
    },
  }} | get tasks
}

def "calendar into-text" [] {
  let data = $in
  $data.additional | upsert type : | append $data.tasks | each {|it|
    let start = (if $it.start? == null {"     "} else {
      0 | into datetime | $in + $it.start | date format "%H:%M"
    })
    let duration = ($it.duration / 1min | math floor)

    {index: $it.line item: $"($it.type) ($start) ($duration) ($it.task)"}
  } | append $data.comments | sort-by index | get item | str join "\n"
}

def "calendar review" [name: string path="/res/calendar"] {
  let path = $"($path)/($name)"
  open $path | calendar parse | update tasks {calendar eval-tasks}
  | calendar into-text | save -f $path
}

def "calendar tasks" [date: string path="/res/calendar"] {
  let path = $"($path)/($date)"
  let date = ($date | into datetime)
  open $path | calendar parse | update tasks {calendar eval-tasks}
  | get tasks | update start {$date + $in}
}
