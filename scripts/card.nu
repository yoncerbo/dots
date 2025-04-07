source /f/pueue.nu

let selectors = ("qwertyuiopasdfghjklzxcvbnm"
| split chars)
let indices = ($selectors | enumerate | reduce -f {} {|it, acc|
  $acc | upsert $it.item $it.index
})
let max_length = ($selectors | length)
let terms = "/f/terms.yml"
let media = "/f/srs-media"
let immersion_file = "/f/immersion.yml"
let dict_history = "/f/dict-history.txt"

let chars = "fdsajklghtrewquiopynmvcxzb"
let chars = ($chars | split chars)
let values = ($chars | enumerate | reduce -f {} {|it, acc|
  $acc | upsert $it.item $it.index})

def image [text: string] {
    let url = $"https://duckduckgo.com/?q=($text)&iax=images&ia=images"
    spawn card-image $"qutebrowser ($url) --target tab"
}

def format-entries [] {
  update meaning {str replace -a "\n" "; "}
  | each {|it|
    let term = $"(ansi yellow_dimmed)($it.term)(ansi reset)"
    let reading = $"(ansi yellow)($it.reading)(ansi reset)"
    {key: $"($term) ($reading)" value: $it.meaning}
  } 
  | group-by key | transpose key value
  | each {|it|
    let value = ($it.value.value | enumerate | each {|it|
      $"(ansi red_dimmed)($it.index + 1):(ansi reset) ($it.item)"
    } | str join "\n")
    $"($it.key)\n($value)"
  } | str join "\n"
}

def dict [text?: string] {
  let text = (if $text == null {
    wl-paste | split chars | filter {$in =~ "[\\p{Hiragana}\\p{Katakana}\\p{Han}]"}
    | str join ""
  } else {$text})
  if ($text | str trim) == "" {return}

  ($text + "\n") | save -a $dict_history
  tango $text | split row "\n\n"
  | each {parse "{term}({reading})\n{dict}\n{meaning}"}
  | flatten | reject dict
}

def "dict serve" [] { loop {
  clear
  fcitx5-remote -s mozc
  let text = (input "> ")
  fcitx5-remote -s keyboard-pl
  if $text == "" {
    return null 
  } else {
    popup-dict $text
  }
}}

def popup-dict [text: string] {
  let res = (dict $text)
  if $res == [] {return}
  $res | format-entries | less -c --tilde
}

def serve [fifo = /tmp/mpv-immersion] {
  if ($fifo | path exists | not $in) {mkfifo $fifo}

  loop {
    open -r $fifo | from csv -n | rename path pos start end text
    | each {|it|
      ctx $it.text $it.path $it.start $it.end $it.pos
      clear
# TODO: when it's done should send a resume message
    }
    swaymsg workspace prev
  }
}

# TODO: getting other informations form mecab
# TODO: sometimes mocab isn't the best
# TODO: consider the way the dictionary is displayed
#       do we clear screen each time?
# TODO: take reading from mecab? do we need to convert it to hiragana?
# TODO: group meanings together
# TODO: option to skip dictionary lookup?
# TODO: don't scroll entries
# TODO: add multiple selection
# TODO: consider selection without mecab
def ctx [text:string path?: string start?: float end?: float pos?: float --debug(-d)] {
  let cards = (open $terms)

  let text = ($text | str replace -a "  " "　" | str replace -a " " "　")
  let terms = ($text | mecab | lines | drop 1
  | each {split column "\t" term data | get 0})
  let text = ($terms.term | str join "")

  let res = ($terms | reduce -f {terms:[] selectors:[] start:0 new_sel:0} {|it, acc|
    let len = ($it.term | str length -g)
    let start = ($acc.start + $len)
    let is_new_sel = ($it.term =~ "[\\p{Hiragana}\\p{Katakana}\\p{Han}]")

    let term = (if $is_new_sel {
      let len = ($chars | length)
      mut index = $acc.new_sel
      mut sel = ""
      loop {
        $sel += ($chars | get ($index mod $len))
        $index = ($index // $len)
        if $index == 0 {break}
      }
      let color = (ansi yellow)
      $"($color)($sel)(ansi reset)($it.term)"
    } else {$it.term})

    let selectors = (if $is_new_sel {
      let data = ($it.data | split row ",")
      let base = $data.6
      $acc.selectors | append {start: $acc.start len: $len base: $data.6}
    } else {$acc.selectors})
    let new_sel = (if $is_new_sel {$acc.new_sel + 1} else {$acc.new_sel})

    {terms: ($acc.terms | append $term) selectors: $selectors start: $start new_sel: $new_sel}
  })
  let annotated = ($res.terms | str join "")

  if $debug {print {text: $text path: $path start: $start end: $end pos: $pos}}

# TODO: buffer and undo
# TODO: opening image
# TODO: change reading
# TODO: change to base forms in multiple selection
  mut context = null
  mut base = null
  mut entries = null
  loop { clear; print $annotated; match (input | split row ";") {
    [""] => {return}
    [.] => {if $entries != null {$entries | format-entries | less -c --tilde}}
    ["" ""] => {
      if $base == null {print "No selection"; break}
      clear
      # print $annotated
      print $"(ansi yellow_dimmed)($base)(ansi reset) " -n
      let reading = (try {$entries.reading | first} catch {null})
      print $"(ansi yellow)($reading)(ansi reset)"

      mut card = { term: $base context: $context}
      let cond = (($reading != null) and ($reading != $card.term))
      if $cond {$card.reading = $reading}
      if $start != null {$card.start = $start}
      if $end != null {$card.end = $end}
      if $pos != null {$card.pos = $pos}
      if $path != null {$card.file = $path}
      if $debug {print $card}

      let is_kana = ($card.term | split chars | all {$in =~ "[\\p{Hiragana}\\p{Katakana}]"})
      if (not $is_kana) and ($entries == null) {
        fcitx5-remote -s mozc
        let reading = (input $"(ansi blue)reading:(ansi reset)\n")
        if $reading != "" {$card.reading = $reading}
        fcitx5-remote -s keyboard-pl
      }
      let meaning = (input $"(ansi purple_dimmed)meaning:(ansi reset)\n")
      if $meaning == ";" {continue}
      if $meaning != " " {$card.meaning = $meaning}
      if $debug {print $card}
      let path = $immersion_file
      open $path | append $card | to yaml | save -f $path
    }
    ["" c] => {if $base != null {$base | wl-copy; print Copied!}}
    ["" d] => {if $base != null {
      let url = $"https://jisho.org/search/{$base}"
      spawn card-dict $"qutebrowser (url) --target tab"
    }}
    [$a] => {
      let a = ($a | split chars | reduce -f 0 {|it, acc|
        let value = (try {$values | get $it} catch {coninue})
        $acc + $value
      })
      if $a > ($selectors | length) {print "Wrong selection!"; break}

      let selector = ($res.selectors | get $a)
      let selection =  ($text | str substring -g $selector.start..($selector.start + $selector.len))
      $context = ($text | str replace -a $selection $"{($selection)}")
      $base = $selector.base
      $entries = (dict $selector.base)
      if $entries == [] {$entries = null; print "No entries!"; continue}
      let cards = ($cards | where term =~ $base
      | each {|it|
        let reading = (if $it.reading? != null {$it.reading} else {$it.term})
        let reading = $"[(ansi green)($reading)(ansi reset)]"
        $"(ansi green_dimmed)($it.term)(ansi reset)($reading)"
      } 
      | str join "; ")
      (if $cards != "" {$"($cards)\n"} else {""}) + ($entries | format-entries)
      | less -c --tilde
    }
    [$a $b] => {
      let a = ($a | split chars | reduce -f 0 {|it, acc|
        let value = (try {$values | get $it} catch {coninue})
        $acc + $value
      })
      if $a > ($selectors | length) {print "Wrong selection!"; break}

      let b = ($b | split chars | reduce -f 0 {|it, acc|
        let value = (try {$values | get $it} catch {coninue})
        $acc + $value
      })
      if $b > ($selectors | length) {print "Wrong selection!"; break}

      if $a > $b {print "Wrong selection!"; break}

      let start = ($res.selectors | get $a | get start)
      let sel = ($res.selectors | get $b)
      let end = ($sel.start + $sel.len)
      let selection =  ($text | str substring -g $start..$end)
      $context = ($text | str replace -a $selection $"{($selection)}")
      $base = $selection
      $entries = (dict $selection)
      if $entries == [] {$entries = null; print "No entries!"; continue}
      let cards = ($cards | where term =~ $base
      | each {|it|
        let reading = (if $it.reading? != null {$it.reading} else {$it.term})
        let reading = $"[(ansi green)($reading)(ansi reset)]"
        $"(ansi green_dimmed)($it.term)(ansi reset)($reading)"
      } 
      | str join "; ")
      (if $cards != "" {$"($cards)\n"} else {""}) + ($entries | format-entries)
      | less -c --tilde
    }
  }}
}


def download-images [] {
  par-each {|term|
    mut term = $term

    let url = $term.image?
    if ($url != null) and ($url != "") {
      let id = (random uuid)
      let path = $"($media)/($id)"
      http get $url | save $path
      $term = ($term | upsert image $id)
    }

    let url = $term.audio?
    if ($url != null) and ($url != "") {
      let id = (random uuid)
      let path = $"($media)/($id)"
      http get $url | save $path
      $term = ($term | upsert audio $id)
    }

    $term
  }
}

# TODO: fix reading - combine furigana
def kanji [kanji?: string] {
  let kanji = (if $kanji == null {wl-paste} else {$kanji})
  let url = $"https://jisho.org/search/*($kanji)*"
  let content = (http get $url)

  $content | htmlq ".concept_light-readings" -t | lines
  | each {str trim} | filter {$in != ""}
  | group 2 | each {|it| {kanji: $it.1 furigana: $it.0}}
}

def anki-terms [path] {
  mkdir /tmp/new-srs-media
  let terms = $in
  let cp_path = {
    let path = $"($path)/($in)"
    let id = (random uuid)
    let target = $"/tmp/new-srs-media/($id)"
    print $path
    print $target
    ^cp $path $target
    $id
  }
  $terms | each {|term|
    $term | update reading {str replace -a "[^\\p{Hiragana}]" ""}
    | update audio {str substring 7..-1}
    | update audio $cp_path
    | update image {str substring 10..-4}
    | update image $cp_path
  }
  print "Moved to /tmp/new-srs-media"
}

def process-cards [delay = 0.0 path?: string] {
  let path = (if $path != null {$path} else {$immersion_file})
  let cards = (open $path)
  $cards | par-each {|card|
    let file = $card.file
    mut card = $card
    if $card.pos? != null {
      let id = (random uuid)
      let path = $"/tmp/($id).png"
      mpv --quiet $file -o $path --frames=1 $"--start=($card.pos + $delay)"
      mv $path $"($media)/($id)"
      $card.cimage = $id
    }
    if [$card.start? $card.end?] != [null null] {
      let id = (random uuid)
      let path = $"/tmp/($id).mp3"
      mpv --quiet $file -o $path --no-video $"--start=($card.start + $delay)" $"--end=($card.end + $delay)"
      mv $path $"($media)/($id)"
      $card.caudio = $id
    }
    $card
  }
}
