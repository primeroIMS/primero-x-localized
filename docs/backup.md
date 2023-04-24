# Primero Database Backup

These instructions need to be executed on the machine that already runs a Dockerized Primero v2.5+. It is assumed that this machine was provisioned using Ansible, therefore it is assumed that there is:
- A `primero` system user with uid=1100
- A Docker Compose virtualenv. Confirm that the file `/opt/docker/bin/activate` exists.

The resulting backup file will have the following file name format `primero_backup.YYYYMMDD.HHMM.tar.gz`. Inside you will find:
-  The PostgreSQL backup (a file with `.dump` extension)
-  Binary document attachments (photos, PDFs, audio, file exports, agency logos) in the folder `backup-attachments` and the Ruby scripts to load them.

1. If you haven't already, clone this repository in the home directory

        cd ~/
        git clone https://github.com/primeroIMS/primero-x-localized.git

2. Select a target location for your backups. Make sure that your location will have plenty of storage space!
   We recommend either:
   - An external volume mounted as a local directory on your machine.
   - A remote server accessible over SSH.

    Before the backup is started, check the current number of records. This will help us to verify that everything was restored correctly.

    ```
    $ rails r ~/primero-x-localized/scripts/table_row_counter.rb
    ```

    By default, backups will be stored under `~/backups` but this is not recommended.
    The backup location is passed as an argument to the backup script. For example:

        $ ./primero-x-localized/scripts/backup.sh /mnt/primero-backups/

    In case you need to execute the script using sudo, you need to specify **$HOME_DIR** variable to indicate the home path where primero-x-localized is located

        $ sudo HOME_DIR="/home/ubuntu" ./primero-x-localized/scripts/backup.sh

    If you are backing up to a remote SSH server, you will need to generate an SSH key pair on the Primero application server and paste the public key in the `~/.ssh/authorized_keys` file on the backup server.

    To generate the SSH key pair:

        $ ssh-keygen -t ed25519 -C "primero.application.prod"
        $ ssh-add ~/.ssh/id_ed25519
        $ cat ~/.ssh/id_ed25519.pub # print the public key to screen

    The param that you will need to pass to the backup script will look like:

        $ ./primero-x-localized/scripts/backup.sh <user>@<remote-host>:/home/<user>/backups

    Ensure that the backup directory on the remote machine exists.

    If you are using a different port to connect to the remote machine, you can create an alias in the `~/.ssh/config` where you can specify all the required information (port, identity file).


3. Create a cron job that will run the backup according to your backup strategy. For example if you want to run it every day at 1 am:

        $ crontab -e

      Enter the following (modify the user and destination!):

        0 1 * * * /home/<user>/primero-x-localized/scripts/backup.sh /dir/where/the/backup/will/be/saved

      and save the file. Every day at 1 am, the script wil be executed and will create a file in the `/dir/where/the/backup/will/be/saved` folder.

The first time that the script is executed, it will create a file called `.last_time_attachment_backup_executed.lock` in the cloned repo under the `scripts` folder. That file saved the last time that the attachment were backed up. If you want to ensure that every single attachment is in your backup, you can delete `.last_time_attachment_backup_executed.lock` and run the script again.

## Restore a Primero backup ##

The `scripts/restore.sh` file will load Primero data and attachments in a Primero database.
Before starting a restore, make sure that you have an empty PostgreSQL Primero database and schema, with the database role permission to load a PostgreSQL backup.

Execute the restore script. For example:

    $ ./primero-x-localized/scripts/restore.sh ~/primero_backup.20221201.0007.tar.gz

By default, this script will load only data (using [*pg_restore* flags](https://www.postgresql.org/docs/current/app-pgrestore.html) "pg_restore options"): `--data-only --disable-triggers`). If you wants to (re)create the schema, you can override the options setting the environment variable `OPTIONS_PGRESTORE`

    $ OPTIONS_PGRESTORE="" ./primero-x-localized/scripts/restore.sh ~/primero_backup.20221201.0007.tar.gz

After restore a backup you need to do extra steps:
1. Reset primary key sequence for all the tables in a rails console:

```
    $ rails r ~/primero-x-localized/scripts/reset_pk_sequence.rb
``` 

2. Regenerate *Locations* options running a rails task in the worker container:
```
    $ rails location_files:generate
```
  then copy the new files to the other containers
```
    $ cp -rv "$APP_ROOT/public/"* "$APP_SHARE_DIR"
```

3. Verifiy the number of generated records:
```
$ rails r ~/primero-x-localized/scripts/table_row_counter.rb
```
