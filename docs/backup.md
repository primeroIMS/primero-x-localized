# Primero Database Backup

This instructions needs to be executed in the machine that runs a Dockerized Primero, it is assumed that this machine was provisioned using ansible, therefore it is assumed that there is a user first and a virtualenv created in `/opt/docker/bin/activate`. The resulting backup file will have the following file name format `primero_backup.YYYYMMDD.HHMM.tar.gz`.
Inside you will find the PostgreSQL backup (a file with `dump` extension) and also a folder called `backup-attachments` where you will find the attachments and its ruby scripts to load them

1. Clone this repository in home directory

        git clone git@bitbucket.org:quoin/primero-x-localized.git

2. Define where your backups will be storaged, this path will be the param that the backup script recieve.

        $ ./primero-x-localized/scripts/backup.sh /mnt/primero-backups/


    The default place will be:

        /home/<user>/backups

    In case you want to copy the backup in a remote site you need to generate a ssh key and paste the public key in the ~/.ssh/authorized_keys file in the destination server. The param that you will need to pass to the backup script will be:

        $ ssh-add ~/.ssh/key_to_access_to_remote_host
        $ ./primero-x-localized/scripts/backup.sh <user>@<remote-host>:/home/<user>/


3. Create a cron job that will run the backup as often as required. For example if we wanted to run it every day at 1am:

        $ crontab -e

      put the follow line:

        0 1 * * * /home/ubuntu/primero-x-localized/scripts/backup.sh /dir/where/the/backup/will/be/saved

      save the file. Every day at 1am the script wil be executed and will create a file in the `/dir/where/the/backup/will/be/saved` folder

The first time that the script is executed it will created a file called `.last_time_attachment_backup_executed.lock` in the cloned repo under `scripts` folder. That file saved the last time that the attachment were backed up. If you want to do a full attachment backup from the beginning of time, you can delete that file and run the script again


## Restore a primero backup ##

The `scripts/restore.sh` file will load primero data and attachments in a primero database.
Before start a restore make sure that you have an empty database with the the permission to load a postgres backup. Execute the restore script:

    $ ./primero-x-localized/scripts/restore.sh ~/primero_backup.20221201.0007.tar.gz

This script by default will load only data (using [*pg_restore* flags](https://www.postgresql.org/docs/current/app-pgrestore.html "pg_restore options"): `--data-only --disable-triggers`) in the primero database, in case that you wants to create the schema you can override the options setting the enviroment variable `OPTIONS_PGRESTORE`

    $ OPTIONS_PGRESTORE="" ./primero-x-localized/scripts/restore.sh ~/primero_backup.20221201.0007.tar.gz