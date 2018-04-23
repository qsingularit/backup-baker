#! /bin/sh

set -e

find $SPATH -type f -mtime -$RETENTION_DEPTH ! -mtime -$RETENTION -exec rm -rf {} \;
