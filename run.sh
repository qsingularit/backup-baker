#! /bin/sh

set -e

if [ "${SCHEDULE}" = "null" ]; then
  sh backup.sh
else
  exec go-cron "$SCHEDULE" /bin/sh backup.sh
fi