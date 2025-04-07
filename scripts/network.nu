def network-status [] {
  nmcli -t d | lines | split column ":" device type state connection
}

def wifi-reboot [] { 
  nmcli r wifi off; nmcli r wifi on
}

def scan-network [] {
  nmcli d wifi rescan
}
