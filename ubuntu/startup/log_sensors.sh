#!/bin/bash
# Records the CPU temp and writes it to a temporary file.


TIMESTAMP=$(date +%F_%R)
LOG_FPATH="/home/joncrall/logs/sensors.$TIMESTAMP.log"

while [ 1 ]; do
    TIMESTAMP=$(date +%F_%R)
    echo $TIMESTAMP >> $LOG_FPATH
    echo '---' >> $LOG_FPATH
    sensors >> $LOG_FPATH
sleep 5;
done
