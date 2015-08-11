
function kumo() {
  if /usr/bin/network-detect > /dev/null 2>&1 ; then
    ssh -t kumo.i scrn main
  else
    echo 'You have to use SSHinaTab now :('
  fi
}

function chiron() {
  gcloud compute --project "perfect-trilogy-461" ssh --zone "us-central1-a" "chiron"
}

function mosh() {
  /usr/bin/mosh --ssh="ssh -o ProxyUseFdpass=no -o UseProxyIf=true -o GSSAPITrustDns=no" "$@"
}

