#! /bin/bash

set -ex

backup_file=$1
script_dir=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

: "${APP_ROOT:=/srv/primero}"
: "${POSTGRES_VERSION:=14}"
: "${PRIMERO_VERSION:=latest}"
: "${OPTIONS_PGRESTORE:=--data-only --disable-triggers }"

if [ $# -eq 0 ]; then
    echo "Backup argument required"
    exit 1
fi

echo "Unpacking primero backup"
backup_dir=$(sudo tar -xvzf $backup_file | sed "s|/.*$||" | uniq)
cd $backup_dir
backup_file=$(find . -name '*.dump' -printf "%f\n")
backup_dir_path=$(pwd)
echo $backup_dir_path

cd ${APP_ROOT}/docker
source /opt/docker/bin/activate

echo "Starting postgres restore"

PRIMERO_TAG="${PRIMERO_VERSION}" PRIMERO_POSTGRES_VERSION="${POSTGRES_VERSION}" ./compose.prod.sh run \
--rm -v ${backup_dir_path}:/tmp/backup/ -e DATA_ONLY_OPTION="${OPTIONS_PGRESTORE}" -e BACKUP_NAME="${backup_file}" \
 postgres bash -c '
   echo ${POSTGRES_HOSTNAME}:5432:${POSTGRES_DATABASE}:${POSTGRES_USER}:${POSTGRES_PASSWORD} >> ~/.pgpass; \
   chmod 0600 ~/.pgpass; \
   export PGPASSFILE=~/.pgpass; \
   pg_restore \
   ${DATA_ONLY_OPTION} \
   -h ${POSTGRES_HOSTNAME} -U ${POSTGRES_USER} -d ${POSTGRES_DATABASE} \
  /tmp/backup/${BACKUP_NAME}' || true

echo "Postgres restore done"

./compose.prod.sh run --rm -v ${script_dir}/restore_attachment.rb:/srv/primero/application/restore_attachment.rb \
-v ${backup_dir_path}/backup-attachments:/tmp/backup-attachments/ \
application bash -c 'rails r ./restore_attachment.rb; rails sunspot:reindex '
