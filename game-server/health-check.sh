#!/bin/bash
# Simple process-based health check
pgrep -f "paper.jar" > /dev/null
