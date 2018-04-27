#! /bin/sh

set -e

if [ "${SCHEDULE}" = "null" ]; then
    echo "No schedule, running once."
  sh /usr/share/backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh /usr/share/backup.sh

  if [ $? == 0 ]; then
        echo "Retention startng with leaving only ${RETENTION}"
        exec go-cron "$SCHEDULE" /bin/sh /usr/share/rotate.sh
  fi

fi
