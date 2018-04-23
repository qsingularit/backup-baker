#! /bin/sh

set -e

<<<<<<< HEAD
find $DPATH -type f -mtime -$RETENTION_DEPTH ! -mtime -$RETENTION -exec rm -rf {} \;
=======
find $SPATH -type f -mtime -$RETENTION_DEPTH ! -mtime -$RETENTION -exec rm -rf {} \;
>>>>>>> master
