FROM phusion/baseimage:0.9.16
MAINTAINER Steve Hibit <sdhibit@gmail.com>

# Fix a Debianism of the nobody's uid being 65534
RUN usermod -u 99 nobody
RUN usermod -g 100 nobody

# Disable SSH
RUN rm -rf /etc/service/sshd /etc/my_init.d/00_regen_ssh_host_keys.sh

# Add extra repositories
RUN add-apt-repository ppa:mc3man/trusty-media \
  && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF \
  && echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list

# Install Apt Packages
RUN apt-get update && apt-get install --no-install-recommends -y \
  build-essential \
  ca-certificates \
  ffmpeg \
  libjpeg-dev \
  libmono-cil-dev \
  libpng12-dev \
  libsqlite3-dev \
  libwebp-dev \
  locales \
  mediainfo \
  mono-devel \
  unzip \
  wget \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/* \ 
     /tmp/* \ 
     /var/tmp/* \
     /usr/share/man \ 
     /usr/share/groff \ 
     /usr/share/info \
     /usr/share/lintian \ 
     /usr/share/linda \ 
     /var/cache/man \
  && (( find /usr/share/doc -depth -type f ! -name copyright|xargs rm || true )) \
  && (( find /usr/share/doc -empty|xargs rmdir || true )) 


# Set correct environment variables
ENV DEBIAN_FRONTEND noninteractive
ENV HOME            /root
ENV LC_ALL          C.UTF-8
ENV LANG            en_US.UTF-8
ENV LANGUAGE        en_US.UTF-8

ENV PKG_NAME      MediaBrowser
ENV PKG_VERSION   3.0.5588.1

# Set Locale
RUN locale-gen $LANG

# Download and Compile ImageMagick
RUN mkdir -p /tmp/imagemagick \
 && wget -O /tmp/imagemagick/ImageMagick.tar.gz http://www.imagemagick.org/download/ImageMagick.tar.gz \
 && tar -xvf /tmp/imagemagick/ImageMagick.tar.gz -C /tmp/imagemagick --strip-components=1 \
 && cd /tmp/imagemagick \
 && ./configure --with-quantum-depth=8 \
 && make \
 && make install \
 && ldconfig /usr/local/lib \
 && rm -rf /tmp/* 

# Install Emby
RUN mkdir -p /opt/emby \
  && mkdir -p /config \
  && wget -O /opt/emby/emby.zip https://github.com/MediaBrowser/MediaBrowser.Releases/raw/master/Server/${PKG_NAME}-${PKG_VERSION}.zip \
  && unzip /opt/emby/emby.zip -d /opt/emby \
  && chown -R nobody:users /opt/emby \
  && chmod -R 755 /opt/emby \
  && chown -R nobody:users /config \
  && chmod -R 755 /config \
  && rm /opt/emby/emby.zip

# Add services to runit
ADD emby.sh /etc/service/emby/run
RUN chmod +x /etc/service/*/run

#http port
EXPOSE 8096
#https port
EXPOSE 8920
EXPOSE 7359/udp
EXPOSE 1900/udp

VOLUME /config

# Use baseimage-docker's init system
CMD ["/sbin/my_init"]

