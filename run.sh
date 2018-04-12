#! /bin/sh

set -e

if [ "${SCHEDULE}" = "null" ]; then
  sh /usr/share/backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh /usr/share/backup.sh
  exec go-cron "$SCHEDULE" /bin/sh /usr/share/rotate.sh
fi
