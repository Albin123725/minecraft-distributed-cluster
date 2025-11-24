#!/bin/bash
# Health check for game server - check if PaperMC process is running
pgrep -f "paper.jar" > /dev/null
