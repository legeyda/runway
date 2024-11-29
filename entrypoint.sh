#!/usr/bin/env sh
set -eu

#ln -s /etc/supervisor/supervisord.conf /etc/supervisord.conf

if [ -z "$*" ]; then
  exec /usr/local/bin/supervisord -c /etc/supervisor/supervisord.conf --nodaemon
else
  exec PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin "$@"
fi



