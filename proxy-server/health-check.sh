#!/bin/bash
# Simple health check - just verify BungeeCord process is running
pgrep -f "bungee.jar" > /dev/null
exit $?
