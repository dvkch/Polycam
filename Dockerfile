FROM swift:latest

WORKDIR /app

# the build script would install those as well, but installing them here allows us to have a cached build step when iterating on the rest
RUN apt update && apt install -y ffmpeg build-essential git iproute2 curl wget rsync jq lighttpd v4l-utils gettext-base

COPY Package.* .
COPY Sources Sources
COPY Tests Tests
COPY Onvif Onvif
COPY --chmod=700 onvif.sh .
RUN ./onvif.sh --install-deps --no-start

VOLUME /app/config
EXPOSE 8080

CMD ["./onvif.sh"]
