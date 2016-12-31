#!/bin/bash
MODULE_NAME=${RSYNC_MODULE_NAME="module"}
HOSTS_ALLOW=${HOSTS_ALLOW="localhost"}

# check_if_parameter_missing () {
#   if [ -z $1 ]; then
#     echo "ERROR: Missing $2 parameter!"
#     exit 1
#   fi
# }
#
# check_if_parameter_missing $USERNAME, "USERNAME"
# check_if_parameter_missing $PASSWORD, "PASSWORD"
# check_if_parameter_missing $USER_ID, "USER_ID"
# check_if_parameter_missing $GROUP_ID, "GROUP_ID"
# check_if_parameter_missing $RSYNC_USERNAME, "RSYNC_USERNAME"
# check_if_parameter_missing $RSYNC_PASSWORD, "RSYNC_PASSWORD"

# Add user
useradd $USERNAME --uid $USER_ID --create-home
echo "${USERNAME}:${PASSWORD}" | chpasswd

# Write Rsync secrets
echo "$RSYNC_USERNAME:$RSYNC_PASSWORD" > /etc/rsyncd.secrets
chmod 0400 /etc/rsyncd.secrets

# Write Rsync config
[ -f /etc/rsyncd.conf ] || cat <<EOF > /etc/rsyncd.conf
pid file = /var/run/rsyncd.pid
log file = /dev/stdout

[${RSYNC_MODULE_NAME}]
  hosts deny = *
  hosts allow = $HOSTS_ALLOW
  read only = false
  path = /volume
  auth users = $RSYNC_USERNAME
  secrets file = /etc/rsyncd.secrets
EOF

# Symlink to config file to give the single-user Rsync daemon access to it
ln -s /etc/rsyncd.conf /home/${USERNAME}/

# Start Rsync daemon
exec /usr/bin/rsync --no-detach --daemon --config /etc/rsyncd.conf "$@"

# Start SSH server
[ -d /var/run/sshd ] || mkdir -p /var/run/sshd
exec /usr/sbin/sshd -D -e
