
let ranges = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p, q, r, s, t, u, v, w, x, y, z]

def to-text [number] {
  let len = ($ranges | length)
  $ranges | get ($number mod 36)
}

random int (0)..1000 | fill -a r -w 4 -c "0"
