#!/usr/bin/env sh

INITSYSTEM='<%= @initsystem %>'
SERVICENAME='<%= @servicename %>'

set -x

if [ "${INITSYSTEM}" = 'SystemD' ]; then
  systemctl stop "${SERVICENAME}"
else
  service "${SERVICENAME}" stop
fi
sleep 5
pgrep -f 'java.*<%= @home %>' | xargs -r kill -9
if [ "${INITSYSTEM}" = 'SystemD' ]; then
  systemctl start "${SERVICENAME}"
else
  service "${SERVICENAME}" start
fi
