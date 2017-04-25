FROM sdhibit/alpine-runit:3.4
MAINTAINER Steve Hibit <sdhibit@gmail.com>

# Add Testing Repository
RUN echo "@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install apk packages
RUN apk --update upgrade \
 && apk --no-cache add \
  ca-certificates \
  ffmpeg \
  imagemagick \
  mono@testing \
  sqlite \
  unzip \
  wget \
 && update-ca-certificates --fresh 

# Set Emby Package Information
ENV PKG_NAME Emby.Mono
ENV PKG_VER 3.2
ENV PKG_BUILD 13.0
ENV APP_BASEURL https://github.com/MediaBrowser/Emby/releases/download/
ENV APP_PKGNAME ${PKG_VER}.${PKG_BUILD}/${PKG_NAME}.zip
ENV APP_URL ${APP_BASEURL}/${APP_PKGNAME}
ENV APP_PATH /opt/emby

# Download & Install Emby
RUN mkdir -p ${APP_PATH} \
 && wget -O "${APP_PATH}/emby.zip" ${APP_URL} \ 
 && unzip "${APP_PATH}/emby.zip" -d ${APP_PATH} \
 && rm "${APP_PATH}/emby.zip" 

# Link libsqlite3.so library
#RUN ln -s /usr/lib/libsqlite3.so.0 /usr/lib/libsqlite3.so 
# Correct sqlite and imagemagick config
ADD config/* ${APP_PATH}/

# Create user and change ownership
RUN mkdir /config \
 && addgroup -g 666 -S emby \
 && adduser -u 666 -SHG emby emby \
 && chown -R emby:emby \
    ${APP_PATH} \
    "/config"

VOLUME ["/config"]

# Default Emby HTTP/tcp server port
EXPOSE 8096/tcp
# Default Emby HTTPS/tcp server port
EXPOSE 8920/tcp
# UDP server port
EXPOSE 7359/udp
# ssdp port for UPnP / DLNA discovery
EXPOSE 1900/udp

WORKDIR ${APP_PATH}

# Add services to runit
ADD emby.sh /etc/service/emby/run
RUN chmod +x /etc/service/*/run
