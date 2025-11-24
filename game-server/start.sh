#!/bin/bash

# AUTO-CONFIGURATION - No manual environment variables needed!
SERVICE_NAME="${RENDER_SERVICE_NAME:-mc-game-1}"
NODE_ID="${SERVICE_NAME//mc-/}"
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')

# Auto-assign ports and regions
case $SERVER_NUMBER in
    1) SERVER_PORT="25566"; WORLD_REGION="spawn" ;;
    2) SERVER_PORT="25567"; WORLD_REGION="nether" ;;
    3) SERVER_PORT="25568"; WORLD_REGION="end" ;;
    4) SERVER_PORT="25569"; WORLD_REGION="wilderness-1" ;;
    5) SERVER_PORT="25570"; WORLD_REGION="wilderness-2" ;;
    6) SERVER_PORT="25571"; WORLD_REGION="wilderness-3" ;;
    7) SERVER_PORT="25572"; WORLD_REGION="wilderness-4" ;;
    8) SERVER_PORT="25573"; WORLD_REGION="ocean-1" ;;
    9) SERVER_PORT="25574"; WORLD_REGION="ocean-2" ;;
    10) SERVER_PORT="25575"; WORLD_REGION="mountain-1" ;;
    11) SERVER_PORT="25576"; WORLD_REGION="mountain-2" ;;
    12) SERVER_PORT="25577"; WORLD_REGION="desert-1" ;;
    13) SERVER_PORT="25578"; WORLD_REGION="desert-2" ;;
    14) SERVER_PORT="25579"; WORLD_REGION="forest-1" ;;
    15) SERVER_PORT="25580"; WORLD_REGION="forest-2" ;;
    16) SERVER_PORT="25581"; WORLD_REGION="village-1" ;;
    *) SERVER_PORT="25566"; WORLD_REGION="spawn" ;;
esac

HTTP_PORT=$((8080 + $SERVER_NUMBER))
MANAGEMENT_URL="https://mc-management.onrender.com"
PROXY_URL="https://mc-proxy-main.onrender.com"

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 375MB (Part of 6GB Cluster)"
echo "🔧 Auto-configured:"
echo "   - Server Port: $SERVER_PORT"
echo "   - HTTP Health Port: $HTTP_PORT"
echo "   - Management URL: $MANAGEMENT_URL"
echo "   - Proxy URL: $PROXY_URL"

# 🚨 CRITICAL: Start HTTP server IMMEDIATELY (before any wait)
echo "Starting HTTP health server on port $HTTP_PORT"
echo "✅ Minecraft Server $NODE_ID - Region: $WORLD_REGION - Status: STARTING" > /app/health.html
python3 -m http.server $HTTP_PORT --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# Minimal wait for staggered startup (only 5 seconds between servers)
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 5 ))
echo "⏰ Minimal staggered startup: waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

# Update health status
echo "✅ Minecraft Server $NODE_ID - Region: $WORLD_REGION - Status: ONLINE" > /app/health.html

# Create server.properties with auto-configured settings
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=5
simulation-distance=3
max-players=20
online-mode=false
motd=PaperMC Cluster - $WORLD_REGION
level-name=world
level-type=default
max-world-size=5000
spawn-protection=0
network-compression-threshold=256
entity-broadcast-range-percentage=50
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=${NODE_ID}-$(openssl rand -hex 8)
EOF

echo "✅ Server auto-configured for 375MB operation"

# Function to cleanup processes
cleanup() {
    echo "🛑 Shutting down..."
    kill $HEALTH_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start Minecraft server
echo "🚀 Starting PaperMC Server..."
java -Xmx300M -Xms200M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=100 \
     -XX:+UnlockExperimentalVMOptions \
     -jar paper.jar nogui

# Cleanup after Minecraft exits
cleanup
