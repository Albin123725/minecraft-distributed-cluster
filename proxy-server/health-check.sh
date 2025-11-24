#!/bin/bash
# Health check for proxy server
curl -f http://localhost:25575/ || exit 1
