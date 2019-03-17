#!/bin/sh

touch /var/log/bb.log;

set -e

    if [[ "${SCHEDULE}" = "null" ]]; then

        echo "No schedule, running once" >> /var/log/bb.log
        sh /usr/share/backup.sh

    else

      exec go-cron "$SCHEDULE" /bin/sh /usr/share/backup.sh;
        echo "Set schedule for backup at ${SCHEDULE}" >> /var/log/bb.log;
      exec go-cron "$SCHEDULE" /bin/sh /usr/share/rotate.sh
        echo "Set schedule for cleanup at ${SCHEDULE}" >> /var/log/bb.log;
    fi

exit 0
