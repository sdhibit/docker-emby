#!/bin/bash

cd /opt/emby/
exec /sbin/setuser nobody mono /opt/emby/MediaBrowser.Server.Mono.exe -programdata /config
