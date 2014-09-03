#!/bin/bash
############## start-cacheable #################
# Description: crontab ready loop to run fio
#
# Authored by Dan Perkins (@DanielRPerkins) &
# Matt Brender (@mjbrender)
#
# Requires cacheable.fio profile in user's home directory

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games"

while true; do
    export RUNTIME=$(((RANDOM % 7) * 100))
    fio cacheable.fio > /tmp/cacheable.log
    sleep 100
done

