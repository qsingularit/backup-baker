#! /bin/sh

set -e

find . -type d -maxdepth 1 -mindepth 1 -exec tar cf /backup/{}-$(date +%F-%H-%M-%S-%Z).tar.gz {}  \;

