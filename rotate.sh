#!/bin/sh

set -e

find $DPATH -type f -mtime -$RETENTION_DEPTH ! -mtime -$RETENTION -exec rm -rf {} \;

echo "Cleaned!" >> /var/log/bb.log;

exit 0
