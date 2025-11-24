#!/bin/bash
# Health check for Minecraft server - process-based only
if pgrep -f "paper.jar" > /dev/null; then
    # Server process is running
    exit 0
else
    # Server process is not running
    exit 1
fi
