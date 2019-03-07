
alias zt=/usr/sbin/zerotier-cli

function check_auth() {
  local AUTH=false
  local LOG=/tmp/check_auth.log
  local SSO_COOKIE=/var/run/ccache/sso-$USER/cookie
 
  echo "$(date +%Y%m%d%H%M%S) START" >> $LOG
  # check SSO_COOKIE is newer than 20hrs, gcertstatus doesn't care but corp_ssh_helper does
  if [[ -n "$(find /var/run/ccache/sso-$USER/cookie -cmin -$((20*60)) )" ]] ; then
    if [ -r "$SSO_COOKIE" ] ; then
      SSO_COOKIE_EXPIRY="$(sed -zne 's/^.*expires=\([^,]*\).*$/\1/p' $SSO_COOKIE)"
      EXPIRY_IN_HOURS="$(( ($SSO_COOKIE_EXPIRY - $(date +%s)) / 3600))"
      echo SSO cookie expires in "$EXPIRY_IN_HOURS" hours >> $LOG
    fi
  else
    echo "current SSO cookie [$SSO_COOKIE] not found" >&2
    echo "current SSO cookie [$SSO_COOKIE] not found" >> $LOG
    glogin || exit 1
  fi
      
  local RESULT="$(gcertstatus 2>&1 ; echo "RETURN:$?")"
  local RETURN="$(echo $RESULT | sed -ne 's/^.*RETURN:\([0-9]*\).*$/\1/p')"
  echo "$(date +%Y%m%d%H%M%S) $RESULT" | xargs >> $LOG

  case "$RETURN" in
    0)
      # in theory this return code means we're good to go but sometimes not
      if echo "$RESULT" | grep -qE 'expired' ; then
        echo gcertstatus returned true but reports cert expired >> $LOG
        AUTH=false
      else
        AUTH=true
      fi
      ;;
    9)
      echo gcertstatus: No SSO cookie or cookie expired >> $LOG
      AUTH=false
      ;;
    *)
      echo gcertstatus returned "$RETURN". good luck. >&2
      echo gcertstatus returned "$RETURN". good luck. >> $LOG
      ;;
  esac

  if [ "$AUTH" == "false" ] ; then
    echo no current certs found >&2
    echo no current certs found >> $LOG
    gcert
  fi
  echo "$(date +%Y%m%d%H%M%S) END" >> $LOG
}

function kumo() {
  check_auth
  ssh kumo.c.googlers.com "$@"
}

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

function mosh() {
  /usr/bin/mosh --ssh="ssh -o ProxyUseFdpass=no -o UseProxyIf=true -o GSSAPITrustDns=no" "$@"
}

