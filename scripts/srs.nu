source /f/env.nu

let media = "/f/srs-media"
let term_file = "/f//terms.yml"
let review_file = "/f/reviews.csv"
let new_history = "/f/new-history.yml"
let kanji_file = "/f/kanji.yml"
let immersion_file = "/f/immersion.yml"

def image [path] {
  if ($path | path exists) {
    print (img2sixel $path -h 300)
  }
}

def audio [paths: list] {
  let args = ($paths | each {|path|
    if $path == null {return null}
    let path = $"($media)/($path)"
    if ($path | path exists) {$path} else {null}
  } | str join " ")
  if ($args | str trim) == "" {null} else {
    (sh -c $"mpg123 ($args) &> /dev/null &\necho $!") | into int
  }
}

def "srs card" [data: record] {
  let is_vocab = ($data.sentence? == null)
  if $is_vocab {print $data.term} else {
    let sentence = ($data.sentence
    | str replace "{" ""
    | str replace "}" "")
    print $"($sentence)"
  }
  if (not $data.view) {input -n 1}
  if (not $is_vocab) {print $"\n($data.term)"}
  try {
    let color = (ansi yellow_bold)
    let reading = ($data.reading | str replace "<" $color
    | str replace ">" (ansi reset))
    print $reading
  }
  try {print $data.meaning}
  print ""
  try {
    let color = (ansi red)
    let example = ($data.example
    | str replace "{" $color
    | str replace "}" (ansi reset))
    print $"($example)\n"
  }
  try {image $"($media)/($data.image)"}
  try {image $"($media)/($data.cimage)"}
  try {print $data.extra}
  try {print $data.memo}
  try {print $data.connection}
  audio [$data.audio? $data.caudio?]
}

def "srs view" [start = 0 --new(-n)] {
  mut terms = (open $term_file)
  let len = ($terms | length)
  mut i = (if $new {open $review_file | length} else {$start})
  mut view = true
  loop {
    if $i < 0 { $i = ($len + $i) }
    if $i >= $len { $i = ($i - $len) }

    clear
    print $"($i)\n"
    let id = (srs card ($terms | get $i | upsert view $view))

    match (input -n 1) {
      "" | " " | n => ($i = ($i + 1))
      p => ($i = ($i - 1))
      q => break,
      r => {},
      l => {$terms = (open $term_file)}
      v => {$view = (not $view)}
    }
    if $id != null {try {kill $id}}
  }
}

let card_states = [
  new learning review relearning suspended
]

let states = {
  new: 0
  learning: 1
  review: 2
  relearning: 3
  suspended: 4
}

let state_colors = {
  new: (ansi purple_dimmed)
  review: (ansi yellow_dimmed)
  learning: (ansi green_dimmed)
  relearning: (ansi red_dimmed)
}

def transform_review [] {
  let review = $in
  let update_date = {(0 | into datetime) + ($in * 1sec)}
  let update_state = {let state = $in; $card_states | get $state} 
  $review
  | select due elapsed-days repetitions state last-review previous-state
  | update due $update_date | update last-review $update_date
  | update state $update_state | update previous-state $update_state
}

def "srs new" [number: int --no-save(-n)] {
  let res = (1..$number | each {new-card})
  print $"Added ($number) cards!"
  if $no_save {return $res}
  $res | to csv -n | save -a $review_file
# TODO: append to new history
}

def "srs" [--debug(-d) --no-save(-n) --review(-r) --stats(-s)] {
  mut debug = $debug
  let terms = (open $term_file)
  mut reviews = (open $review_file)

  let terms_count = ($terms | length)
  let rev_count = ($reviews | length)
  if $terms_count < $rev_count {print "The number of terms is less than the number of reviews!"; return}

  let rev = ($reviews | enumerate | each {|it| {
    index: $it.index due: $it.item.due state: $it.item.state
  }})

  mut new_cards =  ($rev | where state == $states.new | get index)
  mut learning_cards =  ($rev | where state == $states.learning | sort-by due | reject state)
  mut relearning_cards = ($rev | where state == $states.relearning | get index)

  let tomorrow = (tomorrow | into datetime | format date "%s" | into int)
  mut rev_cards = ($rev | where state == $states.review
  | sort-by due | where due < $tomorrow)

  if $stats { return {
    cards: ($reviews | length)
    new-terms: (($terms | length) - ($reviews | length))
    immersion: (open $immersion_file | length)
    new: ($new_cards | length)
    learning: ($learning_cards | length)
    relearning: ($relearning_cards | length)
    reviews: ($rev | where state == $states.review | length)
    reviews-today: ($rev_cards | length)
    reviews-tomorrow: ($rev | where state == $states.review
    | where due < (today | into datetime | $in + 2day | format date "%s" | into int)
    | length)
    suspended: ($rev | where state > 3 | length)
  }}

  mut again_or_hard = 0
  loop {
    mut extra = ""
    let index = (if $review {
      if $rev_cards != [] {
        $extra = $"($state_colors.review)($rev_cards | length)(ansi reset)"
        if $again_or_hard != 0 {
          $extra += $":(ansi red_bold)($again_or_hard)(ansi reset)"
        }
        let index = ($rev_cards | first | get index)
        $rev_cards = ($rev_cards | skip 1)
        $index
      } else {null}
    } else {
      $extra = ({new: $new_cards learning: $learning_cards relearning: $relearning_cards}
      | transpose name table | each {|it|
        let number = ($it.table | length)
        if $number == 0 {""} else {
          $"($state_colors | get $it.name)($number)(ansi reset)"
        }
      } | filter {$in != ""} | str join " ")

      let now = (date now | format date "%s" | into int)
      let is_learning = (($learning_cards != []) and (
        (($learning_cards.due | first) < $now) or
        (($relearning_cards == []) and ($new_cards == []))
      ))

      if $is_learning {
        let card = ($learning_cards | first)
        $learning_cards = ($learning_cards | skip 1)
        $card.index
      } else if ($relearning_cards != []) {
        let index = ($relearning_cards | first)
        $relearning_cards = ($relearning_cards | skip 1)
        $index
      } else if ($new_cards != []) {
        let index = ($new_cards | first)
        $new_cards = ($new_cards | skip 1)
        $index
      } else {null}
    })

    if $index == null {print "No more cards!"; break}
    let card = ($reviews | get $index)
    if $debug {print ($card | transform_review)} else {clear}
# TODO: print due time properly
    let due = ($card | transform_review | get due | date humanize)
    let color = ($state_colors | get ($card_states | get $card.state))
    print $"($color)($index)(ansi reset) [($extra)] ($due)\n"

    let term = ($terms | get $index)
    srs card ($term | upsert view false)
    print $"(ansi green_dimmed)easy(ansi reset) (ansi green)good(ansi reset) (ansi yellow)hard(ansi reset) (ansi red)again(ansi reset) " -n

# TODO: play audio again
# TODO: suspend
# TODO: undo
# TODO: better keybindings
    mut quit = false
    mut rating = ""
    loop {
      let input = (input -n 1)
      match $input {
        j => {$rating = g; break}
        k => {$rating = a; $again_or_hard += 1; break}
        l => {$rating = e; break}
        ; => {$rating = h; $again_or_hard += 1; break}
        u => {}
        i => {kanji show $term.term $terms}
        o => {nvim /f/terms.yml $"+/($term.term)"}
        p => ($quit = true; break)
        c => {$term.term | wl-copy}
        d => {$debug = (not $debug)}
      }
    }
    (ps | where name =~ mpg123 | each {kill $in.pid})
    if $quit == true {break}

    # update card
    let rating = $rating
    let response = (schedule ($reviews | get $index) (date now) $rating)
    $reviews = ($reviews | update $index $response)

    if $response.state == $states.relearning {
      $relearning_cards = ($relearning_cards | append $index)
    } else if $response.state == $states.learning {
      $learning_cards = ($learning_cards | append 
      {index: $index due: $response.due} | sort-by due)
    } else if ($response.state == $states.review) and ($response.due < $tomorrow) {
      $rev_cards = ($rev_cards | append 
      {index: $index due: $response.due} | sort-by due)
    }

    if $debug {
      print "\n"
      print ($response | transform_review)
      input -n 1
      print "\n"
    }
  }
  # save cards
  if $no_save {return $reviews}
  $reviews | to csv | save -f $review_file
}

def schedule [card: record date: datetime rating] {
    let date = ($date | format date "%s")
    let input = ($card
    | select due stability difficulty elapsed-days scheduled-days repetitions lapses state last-review previous-state
    | to csv -n
    | $"($rating),($date),($in)" | str trim)

    $input | /f/fsrs/target/release/srs
    | from csv -n | get 0
    | rename due stability difficulty elapsed-days scheduled-days repetitions lapses state last-review previous-state
}

def new-card [] {
  let date = (date now | format date "%s" | into int)
  {
    due: $date
    stability: 0
    difficulty: 0
    elapsed-days: 0
    scheduled-days: 0
    repetitions: 0
    lapses: 0
    state: 0
    last-review: $date
    previous-state: 0
  }
}
def "kanji vocab" [kanji: string] {
  open $term_file | where term =~ $kanji
  | select term reading meaning
}

def "kanji info" [kanji: string] {
  let info = (try {
    (open $kanji_file | where kanji == $kanji) | get 0
  } catch {none})

  if $info == null {
    print "Not in db!"
  } else {
    print $"(ansi yellow_dimmed)($kanji)(ansi reset)"
    print $info.memo
  }

  print (kanji vocab $kanji)
}

def "kanji show" [term: string terms] {
  print ""
  let kanji = ($term | split chars
  | filter {$in =~ "\\p{Han}"} | uniq)

  $kanji | each {|kanji|
    let terms = ($terms | where term =~ $kanji |
    | filter {$in.term != $term})
    if $terms == [] {return}
    print $"\n(ansi yellow_dimmed)($kanji)(ansi reset)"
    $terms | each {|it|
      let term = ($it.term | str replace $kanji $"(ansi yellow)($kanji)(ansi reset)")
      print $"($term) [($it.reading)]"
    }
  }
  null
}
