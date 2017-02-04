#!/bin/bash
RSYNC_MODULE_NAME=${RSYNC_MODULE_NAME="module"}
HOSTS_ALLOW=${HOSTS_ALLOW="*"}
USER_ID=${USER_ID=1000}
GROUP_ID=${GROUP_ID=1000}

UNDEFINED="undefined"
USERNAME=${USERNAME=$UNDEFINED}
PASSWORD=${PASSWORD=$UNDEFINED}
RSYNC_USERNAME=${RSYNC_USERNAME=$UNDEFINED}
RSYNC_PASSWORD=${RSYNC_PASSWORD=$UNDEFINED}

check_if_parameter_missing () {
  if [ $1 == $UNDEFINED ]; then
    echo "ERROR: Missing $2 parameter!"
    exit 1
  fi
}

check_if_parameter_missing $USERNAME "USERNAME"
check_if_parameter_missing $PASSWORD "PASSWORD"
check_if_parameter_missing $RSYNC_USERNAME "RSYNC_USERNAME"
check_if_parameter_missing $RSYNC_PASSWORD "RSYNC_PASSWORD"

# Add user
groupadd --gid $GROUP_ID $USERNAME
useradd --uid $USER_ID --gid $GROUP_ID --create-home $USERNAME
echo "${USERNAME}:${PASSWORD}" | chpasswd

# Write Rsync secrets
echo "$RSYNC_USERNAME:$RSYNC_PASSWORD" > /etc/rsyncd.secrets
chgrp $USERNAME /etc/rsyncd.secrets
chmod 0440 /etc/rsyncd.secrets

# Write Rsync config
[ -f /etc/rsyncd.conf ] || cat <<EOF > /etc/rsyncd.conf
pid file = /var/run/rsyncd.pid
log file = /logs/rsync

[${RSYNC_MODULE_NAME}]
  hosts deny = *
  hosts allow = $HOSTS_ALLOW
  read only = false
  path = /data
  auth users = $RSYNC_USERNAME
  secrets file = /etc/rsyncd.secrets
  use chroot = false
EOF

# Symlink to config file to give the single-user Rsync daemon access to it
ln -s /etc/rsyncd.conf /home/${USERNAME}/

# Start SSH server
[ -d /var/run/sshd ] || mkdir -p /var/run/sshd
/usr/sbin/sshd &

# Start Rsync daemon
exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"
