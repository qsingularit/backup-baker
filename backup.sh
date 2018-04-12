#! /bin/sh

set -e

if [ "${$DPATH}" = "null" ]; then
  exit 1
else
  find $SPATH -type d -maxdepth 1 -mindepth 1 -exec tar cf $DPATH/{}-$(date +%F-%H-%M-%S-%Z).tar.gz {}  \;
fi
