#!/bin/bash
set -e

if [ "$1" = 'influxdb' ]
then
    /influxdb-setup.sh &
    /influxdb-start.sh
fi

exec "$@"
