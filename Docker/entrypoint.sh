#!/usr/bin/env bash
set -euo pipefail

DETECTED_IF_IP=$(ip -o -4 addr show | awk '{print $2, $4}' | grep -E '((192\.168)|(10)|(172\.(1[6-9]|2[0-9]|3[01])))\.[0-9]+\.[0-9]+/' | head -n 1)
export SERVER_IF="${SERVER_IF:-$(echo "$DETECTED_IF_IP" | awk '{print $1}')}"
export SERVER_IP="${SERVER_IP:-$(echo "$DETECTED_IF_IP" | awk '{print $2}' | cut -d/ -f1)}"
export PTZ="/app/ptz"
export PTZ_CONFIG="${PTZ_CONFIG:-/app/config/ptz.json}"
export VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"
export MODEL="${MODEL:-Polycam}"
export MANUFACTURER="${MANUFACTURER:-Syan}"

echo "Starting: SERVER_IP=$SERVER_IP SERVER_IF=$SERVER_IF PTZ_CONFIG=$PTZ_CONFIG VIDEO_DEVICE=$VIDEO_DEVICE"

envsubst < /app/templates/onvif_simple_server.conf.template > /usr/local/etc/onvif_simple_server.conf
envsubst < /app/templates/mediamtx.yml.template > /app/mediamtx.yml

touch /var/log/onvif_simple_server.log /tmp/onvif_simple_server.debug
chmod a+rw /var/log/onvif_simple_server.log /tmp/onvif_simple_server.debug

exec 3>&1
/app/ttyd -W -p 80 "$PTZ" interactive &
/usr/local/bin/lighttpd -D -f /usr/local/etc/lighttpd.conf &
/usr/local/bin/wsd_simple_server -f -i "$SERVER_IF" -x "http://%s:8080/onvif/device_service" -m "$MODEL" -n "$MANUFACTURER" -p /var/run/wsd_simple_server.pid &
tail -F /var/log/onvif_simple_server.log &
tail -F /tmp/onvif_simple_server.debug &
exec /app/mediamtx /app/mediamtx.yml
