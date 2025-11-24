#!/bin/bash
# Health check for proxy server
curl -f http://localhost:25565/health || exit 1
