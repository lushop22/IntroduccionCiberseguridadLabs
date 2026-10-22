#!/bin/sh
set -eu
mkdir -p /run/sshd /var/lib/sshkeys
for kind in ed25519 rsa ecdsa; do
  file="/var/lib/sshkeys/ssh_host_${kind}_key"
  if [ ! -f "$file" ]; then
    ssh-keygen -q -t "$kind" -N '' -f "$file"
  fi
done
/usr/sbin/sshd -t
exec /usr/sbin/sshd -D -e
