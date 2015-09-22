#!/bin/bash

set -e
set -x

if test "$RS_SET" != ""; then
  bundle exec rake acceptance
else
  bundle exec rake test
fi

df -h