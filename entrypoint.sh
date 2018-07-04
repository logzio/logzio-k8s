#!/bin/sh
set -e
if test -z $FLUENTD_CONFIG_URI; then
  echo "Using default fluent.conf"
else
  echo "Pulling flent.conf from $FLUENTD_CONFIG_URI"
  wget $FLUENTD_CONFIG_URI -O /fluentd/etc/fluent.conf
fi
exec fluentd -c /fluentd/etc/${FLUENTD_CONF} --gemfile /fluentd/Gemfile ${FLUENTD_OPT}