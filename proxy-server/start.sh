#!/bin/bash

# Auto-detect management URL based on service name
if [[ $RENDER_SERVICE_NAME == *"proxy"* ]]; then
    MANAGEMENT_URL="https://mc-management.onrender.com"
    NODE_ID="proxy-main"
else
    MANAGEMENT_URL="https://mc-management.onrender.com"
    NODE_ID="proxy-${RENDER_SERVICE_NAME}"
fi

PROXY_PORT="25575"

echo "🚀 Starting Distributed Minecraft Proxy"
echo "🔗 Connecting 16 PaperMC servers..."
echo "💾 Total Effective RAM: 6GB (16 x 375MB)"
echo "🎮 Player Capacity: 320 players"
echo "⚡ Using PaperMC 1.21.10"
echo "🔧 Auto-configured:"
echo "   - Node ID: $NODE_ID"
echo "   - Proxy Port: $PROXY_PORT"
echo "   - Management URL: $MANAGEMENT_URL"

# Start HTTP health server
echo "✅ Proxy Health Server" > /app/health.html
python3 -m http.server 8080 --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# Function to cleanup processes
cleanup() {
    echo "🛑 Shutting down..."
    kill $HEALTH_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start BungeeCord proxy
java -Xmx128M -Xms64M \
     -Djline.terminal=jline.UnsupportedTerminal \
     -jar bungee.jar

# Cleanup after BungeeCord exits
cleanup
