# Rsync daemon docker

A simple Rsync daemon docker at your service. Inspired by https://github.com/thomfab/docker-rsyncd

## Usage

### Minimal Example

Launch the container with:

```
$ docker run -d --name <container-name> \
                -e USERNAME=<username> \
                -e PASSWORD=<password> \
                -v <volume>:/volume \
                -p <port>:873 \
                ehannes/rsyncd
```

* `<port>` - host port (probably `873`)
* `<container-name` - name of the container
* `<volume>` - volume to share with your container
* `<username>` & `<password> `- sets the login credentials for the Rsync module

Sync with:

`rsync -avP <path/to/sync> rsync://<username>@<ip>:<port>/module`

* `<path/to/sync>` - path to sync with Rsync
* `<username>` - Rsync username you provided when the container was launched
* `<ip>` - IP number to your container
* `<port` - the port you provided when the container was launched

### Example with all parameters

```
$ docker run --name <container-name> \
             -e MODULE_NAME=<module_name> \
			 -e USER_ID=<user_id> \
			 -e GROUP_ID=<group_id> \
             -e USERNAME=<username> \
             -e PASSWORD=<password> \
             -v <volume>:/volume \
             -p <port>:873 \
             ehannes/rsyncd
```

* `<module_name>` - name of the Rsync module. This changes the last part of the rsync command to something like `rsync://<username>@<ip>:<port>/module_name `.
* `<user_id>` - user id to use for the files that are being synced
* `<group_id>` - group id to use for the files that are being synced
* The rest of the parameters are described in the earlier example

### Working Example

A working example, assuming that you have:

1. a map called `/data`
2. port `873` is free to use
3. you have a file called `baz.txt` in the current directory
4. user `nobody` or group `nobody` (default user and group for the script) has write access to your `/data` directory

```
$ docker run -d --name rsyncd \
                -e USERNAME=foo \
                -e PASSWORD=bar \
                -v /data:/volume \
                -p 873:873 \
                ehannes/rsyncd
8fb396eca421bc580f2219b2d108917991b103859f3b4a68b2ce0e1687017873
$ rsync -avP baz.txt rsync://foo@localhost:873/module
Password: 
sending incremental file list

sent 65 bytes  received 12 bytes  30.80 bytes/sec
total size is 289  speedup is 3.75
$ ls /data/
baz.txt
```