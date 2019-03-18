#!/bin/sh

set -e

DUMPDATE=$(date +%F-%H-%M-%S-%Z)

find $DPATH -type f -mtime -$RETENTION_DEPTH ! -mtime -$RETENTION -exec rm -rf {} \;

echo "${DUMPDATE} Cleaned" >> /var/log/bb.log;

exit 0
