#!/bin/bash
# Simple process-based health check for game server
pgrep -f "paper.jar" > /dev/null
