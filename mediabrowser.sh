#!/bin/bash

cd /opt/mediabrowser/
exec /sbin/setuser nobody mono /opt/mediabrowser/MediaBrowser.Server.Mono.exe -programdata /config
