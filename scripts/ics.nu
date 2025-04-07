
def "ics fmt-date" [] {
  date format "%Y%m%dT%H%M%S"
}

def "ics event" [] {
  let event = $in
  let summary = $event.task
  let uid = (random uuid)
  let dtstart = ($event.start | ics fmt-date)
  let dtend = $dtstart
  let dtstamp = (date now | ics fmt-date)
  $"
BEGIN:VEVENT
SUMMARY:($summary)
UID:($uid)
DTSTART:($dtstart)
DTEND:($dtend)
DTSTAMP:($dtstamp)
X-SMT-CATEGORY-COLOR:-3049362
CATEGORIES:Regular event
TRANSP:OPAQUE
X-SMT-MISSING-YEAR:0
STATUS:CONFIRMED
BEGIN:VALARM
DESCRIPTION:Reminder
ACTION:DISPLAY
TRIGGER:-P0DT0H0M0S
END:VALARM
END:VEVENT"
}

def "ics calendar" [] {
  let events = $in
$"BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//PIMUTILS.ORG//NONSGML khal / icalendar //EN
($events | filter {|it| not ($it.task starts-with "nap")}
| each {ics event} | str join "\n")

END:VCALENDAR"
}

def "ics push" [name="tasks.ics" path="/storage/emulated/0"] {
  ics calendar | save /tmp/tasks.ics -f
  adb push /tmp/tasks.ics $"($path)/($name)"
}
