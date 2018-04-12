#! /bin/sh

set -e

find . -type f -mtime -$RETENTION_DEPTH ! -mtime -$RETENTION -exec rm -rf {} \;
