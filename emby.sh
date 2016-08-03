#! /bin/sh
. /etc/envvars
set -e
exec 2>&1

# Start MediaBrowser Server
/sbin/su-exec emby /usr/bin/mono /opt/emby/MediaBrowser.Server.Mono.exe \
  -programdata /config \
  -ffmpeg /usr/bin/ffmpeg \
  -ffprobe /usr/bin/ffprobe
