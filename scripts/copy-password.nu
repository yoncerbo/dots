$env.GNUPGHOME = "/a/gnupg/"

cd /a/pass
let selection = (fd -t file | str replace -a ".gpg" "" | try { fuzzel --config=/s/dot/fuzzel.ini --dmenu })
if $selection != null {pass show $selection -c}
