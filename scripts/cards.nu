
def card [] {
  let card = {
    due: (date now) 
    stability: .0 
    difficulty: .0 
    reps: 0 
    lapses: 0 
    state: 0 
    id: (random uuid) 
    key: /res/test/srs-note
  }
  $card
}

def cards [] {[(card) (card) (card) (card) (card) (card) (card)]}

