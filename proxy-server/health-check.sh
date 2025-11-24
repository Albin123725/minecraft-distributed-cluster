#!/bin/bash
# Health check for proxy - check HTTP health endpoint
curl -f http://localhost:8080/health.html > /dev/null 2>&1 || exit 1
