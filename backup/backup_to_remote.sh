#!/bin/bash

. config

if [[ ! -d $BACKUP_ROOT_PATH ]]; then
  echo backup path dose not exist.
  exit 1
fi

if [[ -z $RCLONE_DEST_PATH ]];then
  echo rclone_dest_path is required.
  exit 1
fi

if [[ ! -d $LOG_PATH ]]; then
  mkdir -p $LOG_PATH
fi

paths=(${BACKUP_ROOT_PATH//\// })
let i=${#paths[@]}-1
key=${paths[i]}

# create temp directory
temp_dir=${key}_$(date "+%Y%m%d%H%M%S")
mkdir -p ${temp_dir}

for f in $(cat backup_list);do
  source_file=${BACKUP_ROOT_PATH}/${f}
  if [[ -d $source_file ]];then
    cp_arg="-r "
  fi
  cp ${cp_arg} ${source_file} ${temp_dir}
done

tar czf ${temp_dir}.tar.gz ${temp_dir}

rclone copy -P --log-file ${LOG_PATH}/rclone.log ${temp_dir}.tar.gz ${RCLONE_DEST_PATH}
end_code=$?

rm ${temp_dir}.tar.gz
rm -r ${temp_dir}

