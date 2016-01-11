#!/bin/bash
API_URL="http://localhost:8086"

echo "INFO: starting InfluxDB setup script"

#wait for the startup of influxdb
RET=1
while [[ RET -ne 0 ]]; do
    echo "INFO: Waiting for confirmation of InfluxDB service startup ..."
    sleep 3 
    curl -k ${API_URL}/ping 2> /dev/null
    RET=$?
done
echo ""

if [ -z "$INFLUXDB_USERNAME" ]
then
    INFLUXDB_USERNAME="root"
fi

if [ -z "$INFLUXDB_PASSWORD" ]
then
    INFLUXDB_PASSWORD="root"
fi

echo "INFO: Creating user $INFLUXDB_USERNAME with password"
influx -host=localhost -execute "CREATE USER $INFLUXDB_USERNAME WITH PASSWORD '$INFLUXDB_PASSWORD' WITH ALL PRIVILEGES"

if [ -n "${PRE_CREATE_DB}" ]
then
    echo "INFO: About to create the following database: ${PRE_CREATE_DB}"
    if [ -f "/tmp/.pre_db_created" ]
    then
        echo "INFO: Database had been created before, skipping ..."
    else
        arr=$(echo ${PRE_CREATE_DB} | tr ";" "\n")

        for x in $arr
        do
            echo "INFO: Creating database: ${x}"
            influx -host=localhost -port=8086 -username="$INFLUXDB_USERNAME" -password="$INFLUXDB_PASSWORD" -execute="CREATE DATABASE ${x}"
        done
        echo ""

        touch "/tmp/.pre_db_created"
        fg
        exit 0
    fi
else
    echo "INFO: No database needs to be pre-created"
fi

echo "INFO: all setup tasks are finished"
