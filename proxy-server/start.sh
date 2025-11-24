#!/bin/bash

# Auto-configuration
MANAGEMENT_URL="https://mc-management.onrender.com"
NODE_ID="proxy-main"
PROXY_PORT="25575"
HEALTH_PORT="10000"

echo "🚀 Starting Distributed Minecraft Proxy"
echo "🔗 Connecting 16 PaperMC servers..."
echo "💾 Total Cluster RAM: 6.47GB"
echo "🎮 Player Capacity: 400 players"
echo "🌍 Features: Custom World + Plugins"
echo "⚡ Using PaperMC 1.21.10"
echo "🔧 Auto-configured:"
echo "   - Node ID: $NODE_ID"
echo "   - Proxy Port: $PROXY_PORT"
echo "   - Management URL: $MANAGEMENT_URL"

# Start HTTP health server
echo "✅ Proxy Health Server - Port: $HEALTH_PORT" > /app/index.html
python3 -m http.server $HEALTH_PORT --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# Function to cleanup processes
cleanup() {
    echo "🛑 Shutting down..."
    kill $HEALTH_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start BungeeCord proxy
echo "🔌 Starting BungeeCord on port $PROXY_PORT"
java -Xmx128M -Xms64M \
     -Djline.terminal=jline.UnsupportedTerminal \
     -jar bungee.jar

# Cleanup after BungeeCord exits
cleanup
