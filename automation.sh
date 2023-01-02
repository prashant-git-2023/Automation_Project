#!/bin/bash

##Read the list packages available for upgrade if any put them in variable
updates=$(apt list upgradeable |& grep -Ev '^(Listing|WARNING)')
##If the variable is not empty, then upgrades are available and apt should upgrade them
if [ -n "${updates}" ] ; then
        apt update -y
        apt upgrade -y
fi

##Check apache installed and enabled, if not then install and enable.
apache=$(apt list --installed | grep -i apache)
if [ -n "${apache}" ] ; then
        apt install apache2
        systemctl enable --now apache2
else
        apache_enabled=$(systemctl is-enabled apache2 | grep -i enabled)
        if [ -n "${apache_enabled}" ]; then
                systemctl enable --now apache2
        fi
fi

##Take timestamp, student and bucket name
timestamp=$(date '+%d%m%Y-%H%M%S')
myname='prashant'
s3_bucket='upgrad-prashant'
##Tar only .log files and copy them to s3 bucket
tar -cvf /tmp/${myname}-httpd-logs-${timestamp}.tar /var/log/apache2/*.log
aws s3 cp /tmp/${myname}-httpd-logs-${timestamp}.tar s3://${s3_bucket}/${myname}-httpd-logs-${timestamp}.tar



