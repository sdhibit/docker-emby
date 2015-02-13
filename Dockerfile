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
  ca-certificates \
  ffmpeg \
  libgdiplus \
  libmono-cil-dev \
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

ENV PKG_NAME	    MediaBrowser
ENV PKG_VERSION	    3.0.5518.4

# Set Locale
RUN locale-gen $LANG

# Install MediaBrowser
RUN mkdir -p /opt/mediabrowser \
  && wget -O /opt/mediabrowser/mediabrowser.zip https://github.com/MediaBrowser/MediaBrowser.Releases/raw/master/Server/${PKG_NAME}-${PKG_VERSION}.zip \
  && unzip /opt/mediabrowser/mediabrowser.zip -d /opt/mediabrowser \
  && chown -R nobody:users /opt/mediabrowser \
  && chmod -R 755 /opt/mediabrowser \
  && rm /opt/mediabrowser/mediabrowser.zip

# Add services to runit
ADD mediabrowser.sh /etc/service/mediabrowser/run
RUN chmod +x /etc/service/*/run

#http port
EXPOSE 8096
#https port
EXPOSE 8920
EXPOSE 7359/udp
EXPOSE 1900/udp

VOLUME /config

# Use baseimage-docker's init system
# CMD ["/sbin/my_init"]

