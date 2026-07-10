#!/bin/bash

/usr/bin/env > /tmp/env.log 2>&1

# Create FIFO for eNB metric output
mkfifo /tmp/enb_report.json

# create detached screen session

/usr/bin/screen -dm -S LTE -s /bin/sh

# Start compactor in its own window
/usr/bin/screen -S LTE -X screen -t COMPACTOR /usr/local/bin/compactor.sh

# Start Evolved Packet Core in its own window
/usr/bin/screen -S LTE -X screen -t EPC /usr/local/bin/epc.sh

# Start eNobeB in its own window
/usr/bin/screen -S LTE -X screen -t ENB /usr/local/bin/enb.sh

# Start masquerading
/usr/local/bin/srsepc_if_masq.sh wlp0s20f3

while sleep 5
do
sleep 1
done


