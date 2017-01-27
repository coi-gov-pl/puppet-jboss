#!/bin/bash

. /etc/<%= @product %>/<%= @product %>.conf

set -x

if [ "x$JBOSS_HOME" = "x" ]; then
    JBOSS_HOME="/usr/lib/<%= @product %>-<%= @version %>"
fi

$JBOSS_HOME/bin/$JBOSS_MODE.sh -c "${1}" | tee $JBOSS_CONSOLE_LOG
