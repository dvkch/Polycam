# syntax=docker/dockerfile:1

# Mediamtx (RPi4/arm64)
FROM debian:trixie-slim AS mediamtx
ARG MEDIAMTX_VERSION=1.9.3
ADD https://github.com/bluenviron/mediamtx/releases/download/v${MEDIAMTX_VERSION}/mediamtx_v${MEDIAMTX_VERSION}_linux_arm64v8.tar.gz /tmp/mediamtx.tar.gz
RUN mkdir /out && tar -xzf /tmp/mediamtx.tar.gz -C /out mediamtx && chmod 755 /out/mediamtx

# ttyd (RPi4/arm64)
FROM debian:trixie-slim AS ttyd
ARG TTYD_VERSION=1.7.7
ADD --chmod=755 https://github.com/tsl0922/ttyd/releases/download/${TTYD_VERSION}/ttyd.aarch64 /out/ttyd
ADD https://raw.githubusercontent.com/tsl0922/ttyd/${TTYD_VERSION}/src/html.h /tmp/ttyd-html.h
COPY Docker/ttyd-keys.html /tmp/ttyd-keys.html
RUN perl -ne 'print pack("H2", $1) while /0x(..)/g' /tmp/ttyd-html.h | gunzip | cat - /tmp/ttyd-keys.html > /out/ttyd-index.html

# PTZ
FROM debian:trixie-slim AS ptz
RUN apt-get update && apt-get install -y --no-install-recommends unzip && rm -rf /var/lib/apt/lists/*
ADD https://github.com/dvkch/Polycam/releases/latest/download/linux-arm64.zip /tmp/ptz.zip
RUN unzip -o /tmp/ptz.zip -d /tmp/ptz \
    && mkdir /out && mv /tmp/ptz/build/linux-arm64/ptz /out/ptz && chmod 755 /out/ptz

# onvif_simple_server, built and cleaned up in a single layer to keep the build cache small
# set ONVIF_SIMPLE_SERVER_REF to a branch or a full commit hash
FROM debian:trixie-slim AS onvif
ARG ONVIF_SIMPLE_SERVER_REF=master
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential git rsync ca-certificates curl wget \
        libmbedtls-dev libjson-c-dev zlib1g-dev \
    && git init -q /tmp/onvif_simple_server && cd /tmp/onvif_simple_server \
    && git fetch --depth 1 https://github.com/roleoroleo/onvif_simple_server.git "${ONVIF_SIMPLE_SERVER_REF}" \
    && git checkout -q FETCH_HEAD \
    && cd extras && MAKEFLAGS="-j$(nproc)" ./build.sh \
    && cp lighttpd-1.4.73/src/.libs/mod_accesslog.so _install/lib/ \
    && mkdir -p /opt/onvif_simple_server && rsync -a _install/ /opt/onvif_simple_server/ \
    && echo 'server.modules += ( "mod_accesslog" )' >> /opt/onvif_simple_server/etc/lighttpd.conf \
    && echo 'accesslog.filename = "/dev/fd/3"' >> /opt/onvif_simple_server/etc/lighttpd.conf \
    && cd / && rm -rf /tmp/onvif_simple_server \
    && apt-get purge -y --auto-remove build-essential git rsync curl wget libmbedtls-dev libjson-c-dev zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

# GStreamer extras: only a few files from -bad and -rtsp are needed, not their heavy dependencies (GTK, GL, ML runtimes...)
FROM debian:trixie-slim AS gstextras
RUN apt-get update && cd /tmp \
    && apt-get download gstreamer1.0-plugins-bad libgstreamer-plugins-bad1.0-0 gstreamer1.0-rtsp libgstrtspserver-1.0-0 \
    && for d in *.deb; do dpkg-deb -x "$d" /tmp/x; done \
    && L=/tmp/x/usr/lib/aarch64-linux-gnu && mkdir -p /out/lib/gstreamer-1.0 \
    && cp $L/gstreamer-1.0/libgstjpegformat.so $L/gstreamer-1.0/libgstvideoparsersbad.so $L/gstreamer-1.0/libgstrtspclientsink.so /out/lib/gstreamer-1.0/ \
    && cp -P $L/libgstcodecparsers-1.0.so.0* $L/libgstrtspserver-1.0.so.0* /out/lib/ \
    && rm -rf /tmp/* /var/lib/apt/lists/*

# FINAL
FROM debian:trixie-slim

WORKDIR /app

ENV LANG=C.UTF-8

RUN apt-get update && apt-get install -y --no-install-recommends \
        iproute2 jq v4l-utils gettext-base \
        gstreamer1.0-tools gstreamer1.0-plugins-good \
        libncurses6 libncursesw6 libmbedtls21 libmbedcrypto16 libmbedx509-7 libjson-c5 \
    && rm -rf /var/lib/apt/lists/*

ARG GST_LIB=/usr/lib/aarch64-linux-gnu
COPY --from=gstextras /out/lib/ ${GST_LIB}/
COPY --from=onvif /opt/onvif_simple_server /usr/local
COPY --from=mediamtx /out/mediamtx ./mediamtx
COPY --from=ttyd /out/ ./
COPY --from=ptz /out/ptz ./ptz
COPY Docker/templates ./templates
COPY --chmod=755 Docker/entrypoint.sh ./entrypoint.sh

VOLUME /app/config
EXPOSE 80 8080 8554 3702

ENTRYPOINT ["./entrypoint.sh"]
