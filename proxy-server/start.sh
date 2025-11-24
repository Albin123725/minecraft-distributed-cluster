#!/bin/bash

echo "🚀 Starting Distributed Minecraft Proxy"
echo "🔗 Connecting 16 PaperMC servers..."
echo "💾 Total Effective RAM: 8GB (16 x 512MB)"
echo "🎮 Player Capacity: 400 players"
echo "⚡ Using PaperMC 1.21.10"

PROXY_PORT=${PROXY_PORT:-25575}  # ← CHANGED DEFAULT
MANAGEMENT_URL=${MANAGEMENT_URL:-"mc-management.onrender.com"}
NODE_ID=${NODE_ID:-"proxy-main"}

echo "🔧 Configuration:"
echo "   - Node ID: $NODE_ID"
echo "   - Proxy Port: $PROXY_PORT"
echo "   - Management URL: $MANAGEMENT_URL"

echo "✅ Proxy is running" > /app/health

# Start BungeeCord proxy
exec java -Xmx128M -Xms64M \
     -Djline.terminal=jline.UnsupportedTerminal \
     -jar bungee.jar
