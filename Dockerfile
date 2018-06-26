FROM microsoft/dotnet:2.1-runtime-alpine
LABEL maintainer="Stephen Hibit <sdhibit@gmail.com>"

# set arguments for s6 overlay
ARG APP_PATH="/app"
ARG CONFIG_PATH="/config"
ARG OVERLAY_VERSION="1.21.4.0"
ARG OVERLAY_URL="https://github.com/just-containers/s6-overlay/releases/download/v${OVERLAY_VERSION}/s6-overlay-amd64.tar.gz"

# set environment for s6 overlay
ENV APP_PATH=${APP_PATH} \
    CONFIG_PATH=${CONFIG_PATH} \
    LANG='en_US.UTF-8' \
    LANGUAGE='en_US.UTF-8' \
    TERM='xterm' \
    S6_KEEP_ENV=1

# Install base packages
RUN apk --update upgrade \
 && apk add --no-cache --virtual=build-dependencies \
    curl \
 && apk --no-cache add \
    ca-certificates \
    tzdata \
 && apk --no-cache add \
    --repository http://dl-cdn.alpinelinux.org/alpine/edge/community \
    shadow \  
 && curl -sSL ${OVERLAY_URL} | tar xfz - -C / \
# Create app user
 && addgroup -g 666 -S appuser \
 && adduser -u 666 -SHG appuser appuser \
 && apk del --purge \
    build-dependencies \
 && mkdir -p ${APP_PATH} \
    ${CONFIG_PATH} \
 && chown -R appuser:appuser ${APP_PATH} \
    ${CONFIG_PATH}

ARG APP_NAME=embyserver
ARG APP_VERSION=3.4.1.21
ARG APP_BASEURL="https://github.com/MediaBrowser/Emby.Releases/releases/download"
ARG APP_PKGNAME="${APP_VERSION}/${APP_NAME}-netcore-${APP_VERSION}.zip"
ARG APP_URL="${APP_BASEURL}/${APP_PKGNAME}"

RUN apk --update upgrade \
 && apk add --no-cache --virtual=build-dependencies \
    curl \
    unzip \ 
 && apk --no-cache add \
    ffmpeg \
    sqlite \
    sqlite-libs \
    imagemagick \ 
 && curl -sSL ${APP_URL} -o /tmp/emby.zip \
 && unzip /tmp/emby.zip -d /tmp \
 && mv /tmp/system/* ${APP_PATH} \
 && rm -rf /tmp/* \
# Symbolic link for imagemagick & sqlite
# https://emby.media/community/index.php?/topic/50012-emby-server-for-net-core/?p=485490
 && libMagickWand=$(find / -iname "libMagickWand-*.*.so.*" -type f | head -1) \
 && ln -s $libMagickWand ${APP_PATH}/CORE_RL_Wand_.so \ 
 && libsqlite=$(find / -iname "libsqlite*.so.*" -type f | head -1) \
 && sqlitepath=$(dirname $(realpath $libsqlite)) \ 
 && sqlitename=$(basename $(realpath $libsqlite) | cut -d'.' -f1) \
 && ln -s $libsqlite $sqlitepath/$sqlitename.so \  
 && apk del --purge \
    build-dependencies

WORKDIR ${APP_PATH}

COPY root /
RUN chmod +x /etc/cont-init.d/*

ENTRYPOINT [ "/init" ]
CMD []
