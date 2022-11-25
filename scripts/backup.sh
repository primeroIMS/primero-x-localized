#! /bin/bash

# APP_ROOT=/home/aespinoza/workspace/primero-v2/ ./backup.sh

set -ex

backup_destination=$1
current_date=`date +%Y%m%d.%H%M`
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
default_backup_name="primero_backup_postgres_${current_date}.dump"

: "${APP_ROOT:=/srv/primero}"

default_backup_dir="${HOME}/backups/"
default_backup_attachment_dir="${HOME}/backups/backup-attachments"

: "${BACKUP_DIR:=${default_backup_dir}}"
: "${BACKUP_ATTACHMENT_DIR:=${default_backup_attachment_dir}}"
: "${BACKUP_NAME:=${default_backup_name}}"
: "${POSTGRES_VERSION:=14}"
: "${PRIMERO_VERSION:=latest}"
: "${PRIMERO_STORAGE:=storage}"

sudo mkdir -p $BACKUP_ATTACHMENT_DIR
sudo chown -R primero:primero $BACKUP_DIR

cd ${APP_ROOT}/docker
source /opt/docker/bin/activate

echo "Starting postgres backup"

PRIMERO_TAG="${PRIMERO_VERSION}" PRIMERO_POSTGRES_VERSION="${POSTGRES_VERSION}" ./compose.prod.sh run \
  -v ${HOME}/backups/:/tmp/ -e BACKUP_NAME="${BACKUP_NAME}" postgres bash -c 'pg_dump \
  --dbname=postgresql://${POSTGRES_USER}:${POSTGRES_PASSWORD}@${POSTGRES_HOSTNAME}:5432/${POSTGRES_DATABASE} \
  -Z 9 -Fc > /tmp/${BACKUP_NAME}'

echo "Finishing postgres backup"

echo "Starting attachment backup"

sudo touch ${script_dir}/.last_time_attachment_backup_executed.lock
sudo chown primero:primero ${script_dir}/.last_time_attachment_backup_executed.lock

SCRIPT_DIR="${script_dir}" PRIMERO_STORAGE="${PRIMERO_STORAGE}" ./compose.prod.sh  -f ${script_dir}/docker-compose.backup.yml run --rm backup bash -c 'rails r backup_attachment.rb'

echo "Finishing postgres backup"

cd ${BACKUP_DIR}

primero_backup="primero_backup.${current_date}"
primero_backup_file="${primero_backup}.tar.gz"

sudo mkdir -p ${primero_backup}
sudo chown -R primero:primero $primero_backup
sudo mv ${BACKUP_NAME} backup-attachments ${primero_backup}

sudo tar czvf ${primero_backup_file} ${primero_backup}
sudo chown -R primero:primero $primero_backup_file
echo "Primero backup compressed"

ls -al *.tar.gz

if [[ -f "$primero_backup_file" ]]; then
  sudo rm -rf ${primero_backup}
fi

if [ ! -z "${backup_destination}" ]
  then
  echo "Rsync to ${backup_destination}"
  rsync -avzh --progress ${primero_backup_file} ${backup_destination}
fi
