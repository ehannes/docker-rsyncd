#!/bin/bash
DEFAULT_USER_ID=65534 # nobody
DEFAULT_GROUP_ID=65534 # nogroup

MODULE_NAME=${MODULE_NAME:-"module"}
ALLOW=${ALLOW:-*}
USER_ID=${USER_ID:-${DEFAULT_USER_ID}}
GROUP_ID=${GROUP_ID:-${DEFAULT_GROUP_ID}}

if [ $USER_ID != $DEFAULT_USER_ID ]; then
  useradd -u $USER_ID -G rsyncdgroup rsyncduser
fi

if [ $GROUP_ID != $DEFAULT_GROUP_ID ]; then
  groupadd -g $GROUP_ID rsyncdgroup
fi

echo "$USERNAME:$PASSWORD" > /etc/rsyncd.secrets
chmod 0400 /etc/rsyncd.secrets

[ -f /etc/rsyncd.conf ] || cat <<EOF > /etc/rsyncd.conf
uid = $USER_ID
gid = $GROUP_ID
use chroot = yes
pid file = /var/run/rsyncd.pid
log file = /dev/stdout

[${MODULE_NAME}]
  hosts deny = *
  hosts allow = $ALLOW
  read only = false
  path = /volume
  auth users = $USERNAME
  secrets file = /etc/rsyncd.secrets
EOF

exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
