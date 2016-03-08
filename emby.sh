#! /bin/sh

# Start MediaBrowser Server
exec /usr/bin/mono /opt/emby/MediaBrowser.Server.Mono.exe \
  -programdata /config \
  -ffmpeg /usr/bin/ffmpeg \
  -ffprobe /usr/bin/ffprobe
