#!/bin/bash
[ "$UID" -eq 0 ] || exec sudo bash "$0" "$@"
docker build --compress --force-rm -t dbof/android-re .
