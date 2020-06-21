
function check_zerotier() {
  if ! zerotier-cli info | grep -q ONLINE ; then
    echo "starting ZeroTier"
    sudo service zerotier-one start
  fi
}

function seedbox_tunnel() {
  sudo openvpn --config ~/.config/rapidseedbox/full-tunnel.ovpn
}

function backup() {
  $HOME/bin/duplicacy -log backup -stats
}
function backup-offsite() {
  check_zerotier
  $HOME/bin/duplicacy -log copy -id nomia-home -to metis -threads ${1:-5}
}

function chiron() {
  gcloud compute --project "perfect-trilogy-461" ssh --zone "us-central1-a" "chiron"
}

