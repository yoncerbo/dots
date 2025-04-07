$env.GNUPGHOME = "/a/gnupg/"

cd /a/pass
let selection = (fd -t file | str replace -a ".gpg" "" | try {wofi --show dmenu -Gm fuzzy})
if $selection != null {pass show $selection -c}
