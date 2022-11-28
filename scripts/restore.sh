#! /bin/bash

set -ex

backup_file=$1
: "${APP_ROOT:=/srv/primero}"
: "${POSTGRES_VERSION:=14}"
: "${PRIMERO_VERSION:=latest}"

if [ $# -eq 0 ]; then
    echo "Backup argument required"
    exit 1
fi

echo "Unpacking primero backup"
backup_dir=$(sudo tar -xvzf $backup_file | sed "s|/.*$||" | uniq)
cd $backup_dir
backup_file=$(find . -name '*.dump' -printf "%f\n")
backup_dir_path=$(pwd)

cd ${APP_ROOT}/docker
source /opt/docker/bin/activate


echo "Starting postgres restore"

PRIMERO_TAG="${PRIMERO_VERSION}" PRIMERO_POSTGRES_VERSION="${POSTGRES_VERSION}" ./compose.prod.sh run \
  --rm -v ${backup_dir_path}:/tmp/backup/ -e BACKUP_NAME="${backup_file}" postgres bash -c sh
  'pg_restore \
   -U ${POSTGRES_USER} -d ${POSTGRES_DATABASE} ${BACKUP_NAME}'
