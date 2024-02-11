#!/usr/bin/env sh

set -e

CONF_DIR="/etc/ruvmeshnet-network"

if [ ! -f "$CONF_DIR/config.conf" ]; then
  echo "generate $CONF_DIR/config.conf"
  ruvmeshnet --genconf > "$CONF_DIR/config.conf"
fi

ruvmeshnet --useconf < "$CONF_DIR/config.conf"
exit $?
