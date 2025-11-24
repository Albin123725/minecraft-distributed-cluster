#!/bin/bash
# Health check for proxy server - check if process is running
if pgrep -f "bungee.jar" > /dev/null; then
    exit 0
else
    exit 1
fi
