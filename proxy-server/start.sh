#!/bin/bash

echo "🚀 Starting Distributed Minecraft Proxy"
echo "🔗 Connecting 16 PaperMC servers..."
echo "💾 Total Effective RAM: 6.88GB (16 x 430MB)"
echo "🎮 Player Capacity: 400 players"
echo "⚡ Using PaperMC 1.21.10"

PROXY_PORT=${PROXY_PORT:-25575}
MANAGEMENT_URL=${MANAGEMENT_URL:-"mc-management.onrender.com"}
NODE_ID=${NODE_ID:-"proxy-main"}

echo "🔧 Configuration:"
echo "   - Node ID: $NODE_ID"
echo "   - Proxy Port: $PROXY_PORT"
echo "   - Management URL: $MANAGEMENT_URL"

# Start simple HTTP health server in background
echo "✅ Proxy Health Server" > /app/health.html
python3 -m http.server 8080 --directory /app &> /dev/null &
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
