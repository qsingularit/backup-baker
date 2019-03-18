#!/bin/sh

touch /var/log/bb.log;

set -e

    if [[ "${SCHEDULE}" = "null" ]]; then

        echo "No schedule, running once" >> /var/log/bb.log
        sh /usr/share/backup.sh

    else

        exec go-cron  -s "$SCHEDULE" -- /bin/sh /usr/share/backup.sh

    fi

exit 0
