#!/bin/bash
set -e

if [ "$1" = 'influxdb' ]
then
    # Pre create database on the initiation of the container
    CONFIG_FILE="/etc/influxdb/config.toml"
    PID_FILE="/var/run/influxdb/influxdb.pid"

    mkdir -p /var/lib/influxdb/meta
    mkdir -p /var/lib/influxdb/data
    mkdir -p /var/lib/influxdb/hh
    chown -R influxdb:influxdb /var/lib/influxdb

    /setup.sh &
    
    echo "INFO: Executing envplate to replace environment variables in configuration file"
    /usr/local/bin/ep -v "${CONFIG_FILE}"

    echo "INFO: Starting InfluxDB ..."
    exec /usr/local/bin/gosu influxdb:influxdb /usr/bin/influxd -config "${CONFIG_FILE}" -pidfile "${PID_FILE}"
fi

exec "$@"
