#!/bin/bash
AIRTRUK=airtruk.example.com
HOSTNAME=`hostname`
CONFIG_URL=http://$AIRTRUK/autoscript/$HOSTNAME

curl -s $CONFIG_URL > /tmp/autoconfig.sh
/bin/bash /tmp/autoconfig.sh

