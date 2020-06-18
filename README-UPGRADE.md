# TDMWeb upgrade process from 4.7 to 4.8

The upgrade process consists of two main steps steps:
    1. Backup orientdb and tdmweb container volumes
    2. restore volumes from backup and start version 4.8

Note: the only pre-requisite to be able to run this process is to be able to run bash script and docker. Can be linux,
docker for mac, docker machine etc. The used volumes can use any volume driver.

## Backup 4.7 volumes

On 4.7 system is see following running containers
```bash
$ docker ps

CONTAINER ID        IMAGE                                     COMMAND                  CREATED             STATUS              PORTS                                            NAMES
9fc3226587b2        tdm.packages.ca.com/tdm/tdmweb:4.7.0.14   "/opt/tdm/bin/tdmweb…"   9 seconds ago       Up 7 seconds        0.0.0.0:8080->8080/tcp, 0.0.0.0:8443->8443/tcp   upgrade_tdmweb_1
0f1f4c0769bb        tdm.packages.ca.com/tdm/orientdb:2.2.33   "/opt/tdm/bin/orient…"   10 seconds ago      Up 8 seconds        2424/tcp, 2480/tcp                               upgrade_orientdb_1
```

When you look into list of volumes you will see something like:

```
$ doker volume ls
DRIVER              VOLUME NAME
local               1ca35ea30f627c3641ae04dc213295182637b31cae2438756b5da919848b392e
local               2a301be43b1ba2a797f0bfdb788e0403c9d615580365cfb7ff9e16285ce7bc52
local               3e1bee63381383f8196677fea1897f5aa2eec3ae2da9c588b3c8d0940514b135
local               06d6198cfca771a03ec8d130411f594d3b46df2eedacff55806f49f3c854a57a
local               53e9948799e8ca952187bb88575595ce6208b34943b2b73fb58d526339f2ce55

```

these are implicitly created volumes by docker since we didn't specify named volumes in docker-compose.yml file.

What we need to do is to backup these volumes to an archive and then create named volumes from this backup.

You can find two script in docker distribution for that purpose:

```bash
$ backup-volumes-4.7.sh

Usage:
    backup-volumes-4.7.sh orientdb tdmweb [file]
    orientdb                    OrientDB container name or hash
    tdmweb                      TDMWeb container name or hash
    file                        Relative or absolute path to a file to store the tar gz output, default is tdm-volumes-backup-4.7.tar.gz
                                in working directory
```

and

```bash
$ restore-volumes-from-4.7-backup.sh 

Usage:
    restore-volumes-from-4.7-backup.sh archive
    archive                     Tar gz file created by 'backup-volumes-4.7.sh' utility
```

So let's do the backup. We need to fist stop compose services by

```bash
$ docker-compose stop

Stopping upgrade_tdmweb_1   ... done
Stopping upgrade_orientdb_1 ... done
```

now we can do backup:

```bash
$ backup-volumes-4.7.sh upgrade_orientdb_1 upgrade_tdmweb_1
...

INFO: 'tdm-volumes-backup-4.7.tar.gz' archive created

```

the `tdm-volumes-backup-4.7.tar.gz` contains archive of all the volumes used in orientdb as well as tdmweb containers.

## Restore volumes and run 4.8

4.8 version comes with brand new structure of compose files. These files are using named volumes instead of un-named
such such thous in 4.7.

First we need to create these volumes:

```bash
docker volume create volume_name
```

for all volumes: orientdb_backup, orientdb_config, orientdb_databases, tdmweb_logs, tdmweb_storage. Then you need to import
the volume data from archive using `restore-volumes-from-4.7-backup.sh`:

```bash
$ restore-volumes-from-4.7-backup.sh tdm-volumes-backup-4.7.tar.gz
```

4.8 compose files are using named volumes, but don't instruct docker-compose to use already existing volumes, but to create
new ones. To tell docker-compose to do so, you have to slightly modify `docker-compose.yml` to mark these volumes `external`.
So instead of:

```
volumes:
  orientdb_backup:
  orientdb_config:
  orientdb_databases:
  tdmweb_logs:
  tdmweb_storage:
  tdmweb_fdmconfig:
```

you should have

```bash
volumes:
  orientdb_backup:
    external: true
  orientdb_config:
    external: true
  orientdb_databases:
    external: true
  tdmweb_logs:
    external: true
  tdmweb_storage:
    external: true
  tdmweb_fdmconfig:
```

Also make sure that all the environment variables, like `GTREP_HOST`, `GTREP_USER` etc. are properly set.




