# Rsync daemon docker

A simple Rsync daemon docker at your service. Inspired by https://github.com/thomfab/docker-rsyncd. Runs Rsync daemon via remote shell connection (SSH).

## Usage

### Minimal Example

Launch the container with:

```
$ docker run -d --name <container-name> \
                -e USERNAME=<username> \
                -e PASSWORD=<password> \
                -e RSYNC_USERNAME=<rsync_username> \
                -e RSYNC_PASSWORD=<rsync_password> \
                -v <data>:/data \
                -v <logs>:/logs \
                -p <ssh-port>:22 \
                -p <rsync-port>:873 \
                ehannes/rsyncd
```

* `<container-name` - name of the container
* `<username>` & `<password> `- sets the login credentials for SSH user
* `<rsync_username>` & `<rsync_password>` - the Rsync module login credentials
* `<data>` - data volume, the path where the container will setup the Rsync module
* `<logs>` - volume for logs
* `<ssh-port>` - SSH port to open to docker
* `<rsync-port>` - Rsync port to open to docker

Try if it works with:

```
$ rsync rsync://<ip>:<:port>
module
```

(If you are trying this on your local machine, `<ip>` is `localhost`)

(`module` is the default name of the Rsync module and can be changed. See examples below)

Sync with:

`rsync -avP <path/to/sync> rsync://<username>@<ip>:<port>/module`

* `<path/to/sync>` - path to sync with Rsync
* `<username>` - Rsync username you provided when the container was launched
* `<ip>` - IP number to your container
* `<port` - the port you provided when the container was launched

### Example with all parameters

```
$ docker run -d --name <container-name> \
                -e USER_ID=<user_id> \
                -e GROUP_ID=<group_id> \
                -e USERNAME=<username> \
                -e PASSWORD=<password> \
                -e RSYNC_USERNAME=<rsync_username> \
                -e RSYNC_PASSWORD=<rsync_password> \
                -e RSYNC_MODULE_NAME=<rsync_module_name> \
                -e HOSTS_ALLOW=<hosts_allow> \
                -v <data>:/data \
                -v <logs>:/logs \
                -p <ssh-port>:22 \
                -p <port>:873 \
                ehannes/rsyncd
```

* `<user_id>` - user id to use for the files that are being synced
* `<group_id>` - group id to use for the files that are being synced
* `<rsync_module_name>` - name of the Rsync module. This changes the last part of the rsync command to something like `rsync://<username>@<ip>:<port>/module_name `.
* `<hosts_allow>` - hosts to allow (check rsyncd.conf manual)
* The rest of the parameters are described in the earlier example

### Working Example

A working example, assuming the following:

1. A directory called `/data` that is writable by user with ID `1000` or group with id `1000` (default user and group ID for the script)
2. Logs from the docker can be put in `var/log/docker-logs`
3. Port `873` and `22` are free to use
4. A file called `baz.txt` in the current directory

```
$ docker run -d --name rsyncd \
                -e USERNAME=foo \
                -e PASSWORD=bar \
                -e RSYNC_USERNAME=rsync-foo \
                -e RSYNC_PASSWORD=rsync-password \
                -v /data:/data \
                -v /var/log/docker-logs:/logs \
                -p 22:22 \
                -p 873:873 \
                ehannes/rsyncd
8fb396eca421bc580f2219b2d108917991b103859f3b4a68b2ce0e1687017873
$ rsync rsync://localhost:873
module
$ rsync -avP baz.txt rsync://rsync-foo@localhost:873/module
Password: 
sending incremental file list

sent 65 bytes  received 12 bytes  30.80 bytes/sec
total size is 289  speedup is 3.75
$ ls /data/
baz.txt

$ rsync -e "ssh -l foo" baz.txt rsync://rsync-foo@localhost:873/module
foo@localhost's password:
Password:
```
