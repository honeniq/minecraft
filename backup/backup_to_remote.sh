#!/bin/bash

BASEDIR=$(cd $(dirname -- $0) && pwd)

. ${BASEDIR}/config

facility=${SYSLOG_FACILITY:-syslog}

logger -p ${facility}.notice -t $0 "[$$] minecraft backup start."

if [[ ! -d $BACKUP_ROOT_PATH ]]; then
  logger -p ${facility}.err -t $0 "[$$] backup path dose not exist."
  exit 1
fi

if [[ -z $RCLONE_DEST_PATH ]];then
  logger -p ${facility}.err -t $0 "[$$] rclone_dest_path is required."
  exit 1
fi

paths=(${BACKUP_ROOT_PATH//\// })
let i=${#paths[@]}-1
key=${paths[i]}

# create temp directory
temp_dir=${key}_$(date "+%Y%m%d%H%M%S")
mkdir -p ${temp_dir}

for f in $(cat ${BASEDIR}/backup_list);do
  source_file=${BACKUP_ROOT_PATH}/${f}
  if [[ -d $source_file ]];then
    cp_arg="-r "
  fi
  cp ${cp_arg} ${source_file} ${temp_dir}
done

tar czf ${temp_dir}.tar.gz ${temp_dir}

rclone copy -P ${temp_dir}.tar.gz ${RCLONE_DEST_PATH} 2>&1 | logger -p ${facility}.notice -t $0
end_code=${PIPESTATUS[0]}

rm ${temp_dir}.tar.gz
rm -r ${temp_dir}

if [[ ${end_code} != "0" ]]; then
  logger -p ${facility}.notice -t $0 "[$$] minecraft backup failed.endcode: ${end_code}"
  exit ${end_code}
fi

logger -p ${facility}.notice -t $0 "[$$] minecraft backup success."
