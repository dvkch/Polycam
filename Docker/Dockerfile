# BUILD
FROM debian:bookworm-slim AS builder

WORKDIR /app

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        build-essential git rsync ca-certificates curl wget unzip \
        libmbedtls-dev libjson-c-dev zlib1g-dev

# Mediamtx (RPi4/arm64)
ARG MEDIAMTX_VERSION=1.9.3
ARG MEDIAMTX_URL="https://github.com/bluenviron/mediamtx/releases/download/v${MEDIAMTX_VERSION}/mediamtx_v${MEDIAMTX_VERSION}_linux_arm64v8.tar.gz"
RUN curl -L ${MEDIAMTX_URL} | tar -xz -C /app mediamtx

# onvif_simple_server
RUN git clone --depth 1 https://github.com/roleoroleo/onvif_simple_server.git /tmp/onvif_simple_server \
    && cd /tmp/onvif_simple_server/extras \
    && ./build.sh \
    && cp lighttpd-1.4.73/src/.libs/mod_accesslog.so _install/lib/ \
    && mkdir -p /opt/onvif_simple_server \
    && rsync -a _install/ /opt/onvif_simple_server/

# PTZ
ADD https://github.com/dvkch/Polycam/releases/latest/download/linux-arm64.zip /app/ptz.zip
RUN unzip -o /app/ptz.zip -d /app \
    && mv /app/build/linux-arm64/ptz /app/ptz \
    && rm -rf /app/ptz.zip /app/build

# FINAL
FROM debian:bookworm-slim

WORKDIR /app

RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    --mount=type=cache,target=/var/lib/apt,sharing=locked \
    apt-get update && apt-get install -y --no-install-recommends \
        ffmpeg iproute2 jq v4l-utils gettext-base \
        libncurses-dev libmbedtls-dev libjson-c-dev

COPY --from=builder /app/ptz ./ptz
COPY --from=builder /app/mediamtx ./mediamtx
COPY --from=builder /opt/onvif_simple_server /usr/local
COPY Docker/templates ./templates
COPY Docker/entrypoint.sh ./entrypoint.sh

RUN chmod +x ptz mediamtx entrypoint.sh \
    && echo 'server.modules += ( "mod_accesslog" )' >> /usr/local/etc/lighttpd.conf \
    && echo 'accesslog.filename = "/dev/fd/3"' >> /usr/local/etc/lighttpd.conf

VOLUME /app/config
EXPOSE 8080 8554 3702

ENTRYPOINT ["./entrypoint.sh"]
