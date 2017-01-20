#!/bin/sh

. /etc/<%= @product %>/<%= @product %>.conf

if [ "x$JBOSS_HOME" = "x" ]; then
    JBOSS_HOME="/opt/<%= @product %>"
fi

if [[ "$1" == "domain" ]]; then
    $JBOSS_HOME/bin/domain.sh -c $2
else
    $JBOSS_HOME/bin/standalone.sh -c $2
fi
