#!/bin/bash
#
# https://regolith-desktop.com/docs/using-regolith/install/
#

wget -qO - https://regolith-desktop.org/regolith.key \
  | gpg --dearmor \
  | sudo tee /usr/share/keyrings/regolith-archive-keyring.gpg \
  > /dev/null
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/regolith-archive-keyring.gpg] https://archive.regolith-desktop.com/ubuntu/stable noble v3.2" \
  | sudo tee /etc/apt/sources.list.d/regolith.list

# policykit-1-gnome: https://github.com/orgs/regolith-linux/discussions/1030
sudo apt update \
  && sudo apt install regolith-desktop regolith-session-flashback regolith-look-solarized-dark policykit-1-gnome

