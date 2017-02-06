#!/bin/bash

. /etc/<%= @product %>/<%= @product %>.conf

if [ "x$JBOSS_HOME" = "x" ]; then
    JBOSS_HOME="/usr/lib/<%= @product %>-<%= @version %>"
fi

let count=0
let max_count=$(($STARTUP_WAIT * 5))

until [ $count -gt $max_count ]; do
  grep -q '.*started in' $JBOSS_CONSOLE_LOG
  if [ $? -eq 0 ] ; then
    exit 0
  fi
  sleep 0.2
  let count=$count+1;
done

exit 1
