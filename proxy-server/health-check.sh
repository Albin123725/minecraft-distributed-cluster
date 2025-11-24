#!/bin/bash
curl -f http://localhost:8080/health.html > /dev/null 2>&1 || exit 1
