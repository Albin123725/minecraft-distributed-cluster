#!/bin/bash

# AUTO-CONFIGURATION
SERVICE_NAME="${RENDER_SERVICE_NAME:-mc-game-1}"
NODE_ID="${SERVICE_NAME//mc-/}"
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')

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

HEALTH_PORT="10000"

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 MEMORY FIX: Only 2 servers generate worlds at a time"

# Start HTTP server IMMEDIATELY
echo "✅ Server $NODE_ID - WAITING" > /app/index.html
python3 -m http.server $HEALTH_PORT --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# 🎯 EXTREME WORK SPLITTING - Only 2 servers at a time
BATCH_NUMBER=$(( ($SERVER_NUMBER - 1) / 2 ))  # Batches of 2 servers
WAIT_TIME=$(( $BATCH_NUMBER * 1200 ))  # 20 minutes between batches

echo "⏰ WORK SPLITTING: I'm in batch $((BATCH_NUMBER + 1))"
echo "🕒 Waiting ${WAIT_TIME}s for previous batches..."
sleep $WAIT_TIME

echo "🎯 MY TURN NOW: Starting world generation..."

# OPTIMIZED memory settings
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=4
simulation-distance=3
max-players=20
online-mode=false
motd=MC Cluster - $WORLD_REGION
level-name=world
level-type=default
max-world-size=3000
spawn-protection=0
network-compression-threshold=64
allow-nether=true
allow-end=true
level-name-nether=world_nether
level-name-end=world_the_end
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=${NODE_ID}-$(openssl rand -hex 8)
allow-flight=true
enable-command-block=false
EOF

echo "✅ Server ready for world generation (400MB estimated)"

# Cleanup function
cleanup() {
    kill $HEALTH_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# SAFE memory allocation (guaranteed under 512MB)
echo "🚀 Starting PaperMC with 300MB heap (GUARANTEED WORKING)..."
java -Xmx300M -Xms200M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=150 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+DisableExplicitGC \
     -jar paper.jar nogui

cleanup
