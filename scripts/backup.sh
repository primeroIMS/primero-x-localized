#! /bin/bash

set -ex

backup_destination=$1
current_date=`date +%Y%m%d.%H%M`
: "${HOME_DIR:=${HOME}}"

script_dir="${HOME_DIR}/primero-x-localized/scripts"
default_backup_name="primero_backup_postgres_${current_date}.dump"

: "${APP_ROOT:=/srv/primero}"

default_backup_dir="${HOME_DIR}/backups/"
default_backup_attachment_dir="${HOME_DIR}/backups/backup-attachments"

: "${BACKUP_DIR:=${default_backup_dir}}"
: "${BACKUP_ATTACHMENT_DIR:=${default_backup_attachment_dir}}"
: "${BACKUP_NAME:=${default_backup_name}}"
: "${POSTGRES_VERSION:=14}"
: "${PRIMERO_VERSION:=latest}"
: "${PRIMERO_STORAGE:=storage}"

mkdir -p $BACKUP_ATTACHMENT_DIR
chown -R primero:primero $BACKUP_DIR

chown -R primero.primero ${script_dir}

cd ${APP_ROOT}/docker
source /opt/docker/bin/activate

echo "Starting postgres backup"

PRIMERO_TAG="${PRIMERO_VERSION}" PRIMERO_POSTGRES_VERSION="${POSTGRES_VERSION}" ./compose.prod.sh run \
   --rm -v ${HOME_DIR}/backups/:/tmp/ -e BACKUP_NAME="${BACKUP_NAME}" postgres bash -c '
   echo ${POSTGRES_HOSTNAME}:5432:${POSTGRES_DATABASE}:${POSTGRES_USER}:${POSTGRES_PASSWORD} >> ~/.pgpass; \
   chmod 0600 ~/.pgpass; \
   export PGPASSFILE=~/.pgpass; \
   pg_dump \
   -h ${POSTGRES_HOSTNAME} -U ${POSTGRES_USER} ${POSTGRES_DATABASE} \
  -Z 9 -Fc > /tmp/${BACKUP_NAME}'

echo "Finishing postgres backup"

echo "Starting attachment backup"

touch ${script_dir}/.last_time_attachment_backup_executed.lock
chown primero:primero ${script_dir}/.last_time_attachment_backup_executed.lock
chown primero:primero ${script_dir}/backup_attachment.rb

SCRIPT_DIR="${script_dir}" HOME_DIR="${HOME_DIR}" PRIMERO_STORAGE="${PRIMERO_STORAGE}" ./compose.prod.sh  -f ${script_dir}/docker-compose.backup.yml run --rm backup bash -c 'ls -la && rails r backup_attachment.rb'

echo "Finishing postgres backup"

chown -R ${SUDO_USER}.${SUDO_USER} $BACKUP_DIR
cd ${BACKUP_DIR}

primero_backup="primero_backup.${current_date}"
primero_backup_file="${primero_backup}.tar.gz"

mkdir -p ${primero_backup}
chown -R primero:primero $primero_backup
mv ${BACKUP_NAME} backup-attachments ${primero_backup}

tar czvf ${primero_backup_file} ${primero_backup}
chown -R primero:primero $primero_backup_file
echo "Primero backup compressed"

ls -al *.tar.gz

if [[ -f "$primero_backup_file" ]]; then
  rm -rf ${primero_backup}
fi

if [ ! -z "${backup_destination}" ]
  then
  echo "Rsync to ${backup_destination}"
  sudo su $SUDO_USER -c "rsync -avzh --progress ${primero_backup_file} ${backup_destination}"
fi
