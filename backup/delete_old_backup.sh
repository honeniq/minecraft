#!/bin/bash

BASEDIR=$(cd $(dirname -- $0) && pwd)
. ${BASEDIR}/config

facility=${SYSLOG_FACILITY:-syslog}

logger -p ${facility}.notice -t $0 "[$$] minecraft backup delete start."

delete_files=$(rclone lsl ${RCLONE_DEST_PATH} | awk '{ if(dueDate > $2" "$3) {print dir"/"$4}}' dir=${RCLONE_DEST_PATH} dueDate="$(date "+%F %T.000000000" "--date" "-${SAVE_DAYS} days")")

for f in $delete_files;do
  rclone delete $f 2>&1 | logger -p ${facility}.notice -t $0
  end_code=${PIPESTATUS[0]}

  if [[ ${end_code} != "0" ]]; then
    logger -p ${facility}.notice -t $0 "[$$] minecraft backup delete failed.endcode: ${end_code}"
    exit ${end_code}
  fi
done

logger -p ${facility}.notice -t $0 "[$$] minecraft backup delete success."
