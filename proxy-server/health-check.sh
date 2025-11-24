#!/bin/bash
# Simple process-based health check
pgrep -f "bungee.jar" > /dev/null
