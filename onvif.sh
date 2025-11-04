#!/usr/bin/env bash

set -e

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "This script wasn't designed to function on `uname -s`, aborting."
    exit 1
fi

SUDO=`which sudo || true`

declare -A requirements
requirements['ffmpeg']='ffmpeg'
# requirements['swift']='swiftlang'
requirements['gcc']='build-essential'
requirements['make']='build-essential'
requirements['git']='git'
requirements['ip']='iproute2'
requirements['curl']='curl'
requirements['wget']='wget'
requirements['rsync']='rsync'
requirements['jq']='jq'
requirements['lighttpd']='lighttpd'
requirements['v4l2-ctl']='v4l-utils'
requirements['envsubst']='gettext-base'

echo "Checking dependencies"
declare -a missing_requirements
for requirement_binary in "${!requirements[@]}"; do
    requirement_name=${requirements[$requirement_binary]}
    if ! which $requirement_binary > /dev/null; then
        missing_requirements+=($requirement_name)
    fi
done

if [ -n "$missing_requirements" ]; then
    if [[ " $* " == *"--install-deps"* ]]; then
        missing_requirements=$(IFS=' ' ; echo "${missing_requirements[*]}")
        echo "Installing ${missing_requirements}"
        $SUDO apt update
        $SUDO apt install -y ${missing_requirements}

        # $SUDO apt install -y curl libncurses-dev
        #curl -O https://download.swift.org/swiftly/linux/swiftly-$(uname -m).tar.gz && \
        #tar zxf swiftly-$(uname -m).tar.gz && \
        #./swiftly init --quiet-shell-followup && \
        #. "${SWIFTLY_HOME_DIR:-$HOME/.local/share/swiftly}/env.sh" && hash -r
    else
        echo "Please install ${missing_requirements}"
        exit 1
    fi
fi
echo "Depencencies are met"

if [ ! -f mediamtx ]; then
    echo "Downloading mediamtx"
    wget https://github.com/bluenviron/mediamtx/releases/download/v1.9.3/mediamtx_v1.9.3_linux_arm64v8.tar.gz
    tar -xzvf mediamtx_v1.9.3_linux_arm64v8.tar.gz
    rm mediamtx_v1.9.3_linux_arm64v8.tar.gz
else
    echo "mediamtx is present"
fi

if [ ! -f ptz ]; then
    # Since Swift-curses doesn't always work depending on the current OS version, we will install the latest release instead of compiling by hand

    # echo "Building PTZ"
    # swift build --build-path .swift # -c release # -Xswiftc -O

    # TRIPLE=`swiftc -print-target-info | jq -r '.target.unversionedTriple'`
    # cp .swift/$TRIPLE/debug/ptz .
    # rm -rf .swift

    curl -L -o ptz.zip "https://github.com/dvkch/Polycam/releases/download/1.4.1/linux-$(dpkg --print-architecture).zip"
    unzip -o ptz.zip
    mv "build/linux-$(dpkg --print-architecture)/ptz" ptz
fi

if [ ! -d onvif_simple_server ]; then
    echo "Downloading onvif_simple_server"
    git clone https://github.com/roleoroleo/onvif_simple_server.git
fi

if [ ! -f onvif_simple_server/extras/_install/www/onvif/ptz_service ]; then
    $SUDO apt install libmbedtls-dev libjson-c-dev zlib1g-dev
    echo "Building onvif_simple_server"
    cd onvif_simple_server/extras
    ./build.sh
    cp lighttpd-1.4.73/src/.libs/mod_accesslog.so _install/lib/
    $SUDO rsync -a _install/ /usr/local/
    cd ../..
fi

if ! grep 'log-request-handling' /usr/local/etc/lighttpd.conf > /dev/null; then
    echo "Configuring lighttpd"

    # echo 'debug.log-request-handling = "enable"' | $SUDO tee -a /usr/local/etc/lighttpd.conf > /dev/null

    if ! grep 'mod_accesslog' /usr/local/etc/lighttpd.conf > /dev/null; then
        echo 'server.modules += ( "mod_accesslog" )' | $SUDO tee -a /usr/local/etc/lighttpd.conf > /dev/null
    fi
    if ! grep 'accesslog.filename' /usr/local/etc/lighttpd.conf > /dev/null; then
        echo 'accesslog.filename = "/dev/fd/3"' | $SUDO tee -a /usr/local/etc/lighttpd.conf > /dev/null
    fi

    $SUDO sed -i 's/server.port\s*=\s*8080/server.port = 80/' /usr/local/etc/lighttpd.conf

    echo "---------"
    cat /usr/local/etc/lighttpd.conf
    echo "---------"
fi

if [[ " $* " == *"--no-start"* ]]; then
    echo "Not starting"
    exit 0
fi

# Find IP and adjust configuration files
export SERVER_IP=`ip -o -4 addr show | awk '{print $4}' |  grep -oP '192\.168\.\d+\.\d+' | head -n 1`
export PTZ="`pwd`/ptz"
export PTZ_CONFIG="${PTZ_CONFIG:-"`pwd`/ptz.json"}"
export VIDEO_DEVICE="${VIDEO_DEVICE:-/dev/video0}"
echo "Updating configuration files to use SERVER_IP=$SERVER_IP, PTZ=$PTZ, PTZ_CONFIG=$PTZ_CONFIG, VIDEO_DEVICE=$VIDEO_DEVICE"
envsubst < Onvif/template_onvif_simple_server.conf | $SUDO tee /usr/local/etc/onvif_simple_server.conf > /dev/null
envsubst < Onvif/template_mediamtx.yml > mediamtx.yml

# Making log files accessible so 'tail' can start
$SUDO touch /var/log/onvif_simple_server.log
$SUDO chmod a+rw /var/log/onvif_simple_server.log
$SUDO touch /tmp/onvif_simple_server.debug
$SUDO chmod a+rw /tmp/onvif_simple_server.debug

# Allow access to serial device
$SUDO usermod -aG dialout "$USER" || true

# Starting
exec 3>&1 # https://serverfault.com/a/1114322
/usr/local/bin/lighttpd -D -f /usr/local/etc/lighttpd.conf \
  & tail -F /var/log/onvif_simple_server.log \
  & tail -F /tmp/onvif_simple_server.debug \
  & ./mediamtx ./mediamtx.yml
