#!/usr/bin/env bash

set -e

## To keep the screen on, go to http://192.168.69.133, then Admin Settings > Audio/Video > Sleep > 8 hours

# needed for cut to work
export LC_ALL=C
export LANG=C

IP=192.168.69.133
DATE=$(date +"%Y%m%d-%H%M%S")
LOGS="./${DATE}.log"
PASSWORD="admin"
MARKER="Syan"

# Start the adb session
echo "Connecting to adb..."
adb connect $IP:5555

# Clear up logs
adb logcat -c

# Start recording logs
echo "Recording logs..."
(adb shell busybox tail -F /data/log/messages | cut -c 12- | egrep "(PCon|SMan|$MARKER)" > "${LOGS}" &) &
LOGS_PID=$!
sleep 1

# Choose mode (scripted, vs manual)
read -p "Do you want to use the scripted command? [Y/N] " -n 1 -r
echo ""
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    declare -a COMMANDS=(
#            "sleep"
#            "wake"
            "camera near getposition"
#            "sleep"
#            "wake"
#            "camera near setposition 0 0 0"
#            "camera near getposition"
        )

    declare -a DIRECTIONS=( left right left right up down up down zoom- zoom+ zoom- zoom+ )
#    for dir in "${DIRECTIONS[@]}"; do
#        COMMANDS+=("camera near move $dir")
#        COMMANDS+=("camera near move stop")
#        COMMANDS+=("camera near getposition")
#    done

    POSITIONS=($(seq -50000 1000 50000))
    for pos in "${POSITIONS[@]}"; do
        COMMANDS+=("camera near setposition $pos 0 0")
        COMMANDS+=("camera near getposition")
    done

    for pos in "${POSITIONS[@]}"; do
        COMMANDS+=("camera near setposition 0 $pos 0")
        COMMANDS+=("camera near getposition")
    done

    for pos in "${POSITIONS[@]}"; do
        COMMANDS+=("camera near setposition 0 0 $pos")
        COMMANDS+=("camera near getposition")
    done

    for cmd in "${COMMANDS[@]}"; do
        echo "> $cmd..."
        adb shell log -p e -t "$MARKER" "________________ $cmd ________________"

        # running command ssh
        # (brew tap esolitos/ipa && brew install esolitos/ipa/sshpass)
        ( echo $PASSWORD; echo $cmd; sleep 1; ) | telnet $IP 24 > /dev/null 2>&1 || true

        if [[ "$cmd" == *"wake"* ]] || [[ "$cmd" == *"sleep"* ]]; then
            sleep 30
        fi

        sleep 1
    done
else
    # Ask user for info
    echo "Write manual logs below, keep empty to stop the capture"
    INPUT="Starting capture"
    while [ -n "$INPUT" ]; do
        adb shell log -p e -t "$MARKER" "________________ $INPUT ________________"
        read -p "> " INPUT
    done
fi

echo "Stopping..."
killall adb

echo "Splitting logs..."
mkdir -p "$DATE"
gcsplit -z -f "$DATE/output_" --suffix-format="%02d.txt" -s "$LOGS" "/$MARKER/" '{*}'

echo "Done"
