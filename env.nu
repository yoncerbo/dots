# Nushell Environment Config File
#
# version = 0.80.1

def create_left_prompt [] {
    let home = $env.HOME
    let dir = ($env.PWD | str replace $home ~)

    let path_color = (if (is-admin) { ansi red_bold } else { ansi green_bold })
    let separator_color = (ansi white)
    let path_segment = ($"($path_color)($dir)" | str replace --all (char path_sep) $"($separator_color)/($path_color)")

    let dt = (date now | format date "%Y-%m-%d %R" | split column " " date time | get 0)

    let date_color = (ansi red)
    let time_color = (ansi magenta)

    $"($date_color)($dt.date)(ansi reset) ($time_color)($dt.time)(ansi reset) ($path_segment)"
}


# Use nushell functions to define your right and left prompt
$env.PROMPT_COMMAND = {|| create_left_prompt }
$env.PROMPT_COMMAND_RIGHT = {null}

# The prompt indicators are environmental variables that represent
# the state of the prompt
$env.PROMPT_INDICATOR = {|| "> " }
$env.PROMPT_INDICATOR_VI_INSERT = {|| "> " }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| "= " }
$env.PROMPT_MULTILINE_INDICATOR = {|| ": " }

# Specifies how environment variables are:
# - converted from a string to a value on Nushell startup (from_string)
# - converted from a value back to a string when running external commands (to_string)
# Note: The conversions happen *after* config.nu is loaded
$env.ENV_CONVERSIONS = {
  "PATH": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
  "Path": {
    from_string: { |s| $s | split row (char esep) | path expand --no-symlink }
    to_string: { |v| $v | path expand --no-symlink | str join (char esep) }
  }
}

# Directories to search for scripts when calling source or use
#
# By default, <nushell-config-dir>/scripts is added
$env.NU_LIB_DIRS = [
    ($nu.default-config-dir | path join 'scripts')
]

# Directories to search for plugin binaries when calling register
#
# By default, <nushell-config-dir>/plugins is added
$env.NU_PLUGIN_DIRS = [
    ($nu.default-config-dir | path join 'plugins')
]

# To add entries to PATH (on Windows you might use Path), you can use the following pattern:
# let-env PATH = ($env.PATH | split row (char esep) | prepend '/some/path')

alias n = nvim

def gc [message: string] {
  git commit -am $message
}

alias gs = git status -suno

alias mpv = mpv --save-position-on-quit --ytdl-format=ytdl-format=bestvideo[height<=?720][fps<=?30]+bestaudio/best

alias mk = make
alias mb = make build
alias mr = make run

def nd [path?: string] {
  if ($path != null) {
    cd $"/s/($path)"
  }
  nix develop -c nu
}

alias fzf = fzf --height 50% --layout reverse

alias ... = ../..

def install [name: string] {
  nix profile install $"nixpkgs#($name)"
}

def mcd [name: string] {
  mkdir $name
  commandline edit $"cd ($name)\n"
}

def new-project [name: string] {
  cd /s
  mkdir $name
  cd $name
  cp /n/flake.nix .
  git init
  commandline edit $"cd /s/($name)"
}

alias np = new-project

alias ce = config env

alias i = imv
alias ia = imv *

alias dn = date now

# Pkm

def new-daily [] {
  cd /n
  let old_file = ((date now) - 1day | format date "/n/daily/%Y-%m-%d.md")
  print $"Old path: ($old_file)"
  if ($old_file | path exists) {
    print "Old file already exists!"
    return
  }
  cp today.md $old_file
  sd "^- [x] " "" $old_file
  cp daily-template.md today.md
}

alias dream = nvim $"/n/dreams/((date now) + 1day | format date '%Y-%m-%d.md')" +ZenMode

$env.GNUPGHOME = "/a/gnupg/"

def select-password [] {
  cd /a/pass
  fd -t file | str replace -a ".gpg" "" | try {fzf}
}

def eps [] {
  let selection = select-password
  if $selection != null { pass edit $selection }
}

def sps [] {
  let selection = select-password
  if $selection != null { pass show $selection }
}

def cps [] {
  let selection = select-password
  if $selection != null { pass show -c $selection }
}

def gps [name: string] {
  pass generate $name 32
}

def new-id [] {
  cd /n
  loop {
    let id = (random int (0)..10000 | fill -a r -w 4 -c "0")
    if (glob $id | length) == 0 { return $id }
  }
}

def new [filename] {
  cd /n
  let path = $"(new-id)-($filename)"
  touch $path
  $path | wl-copy
}

alias o = xdg-open
alias n = nvim

alias ncd = nvim --server /tmp/nvim.pipe --remote-send $":cd (pwd)<CR>"

def e [path] {
  nvim --server /tmp/nvim.pipe --remote ($path | path expand)
}
