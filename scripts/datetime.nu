def dtfmt [end=""] {
  format date $"%Y-%m-%d($end)"
}

def tmfmt [] {
  format date "%H:%M"
}

def today [end=""] {date now | dtfmt $end}

def tomorrow [end=""] {
  (date now) + 1day | dtfmt $end
}

def yesterday [end=""] {
  (date now) - 1day | dtfmt $end
}

def time [] {
  date now | tmfmt
}

def now [] {
  date now | format date "%Y-%m-%d-%H:%M"
}
