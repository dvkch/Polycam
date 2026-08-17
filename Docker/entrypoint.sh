#!/usr/bin/env bash
set -euo pipefail

export SERVER_IP="${SERVER_IP:-$(ip -o -4 addr show | awk '{print $4}' | grep -oP '((192\.168)|(10)|(172\.(1[6-9]|2[0-9]|3[01])))\.[0-9]+\.[0-9]+' | head -n 1)}"
export PTZ="/app/ptz"
export PTZ_CONFIG="${PTZ_CONFIG:-/app/config/ptz.json}"
export VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"

echo "Starting: SERVER_IP=$SERVER_IP PTZ_CONFIG=$PTZ_CONFIG VIDEO_DEVICE=$VIDEO_DEVICE"

envsubst < /app/templates/onvif_simple_server.conf.template > /usr/local/etc/onvif_simple_server.conf
envsubst < /app/templates/mediamtx.yml.template > /app/mediamtx.yml

touch /var/log/onvif_simple_server.log /tmp/onvif_simple_server.debug
chmod a+rw /var/log/onvif_simple_server.log /tmp/onvif_simple_server.debug

exec 3>&1
/usr/local/bin/lighttpd -D -f /usr/local/etc/lighttpd.conf &
tail -F /var/log/onvif_simple_server.log &
tail -F /tmp/onvif_simple_server.debug &
exec /app/mediamtx /app/mediamtx.yml
