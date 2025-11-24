#!/bin/bash

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 375MB (Part of 6GB Cluster)"
echo "🔧 HTTP Health Port: 8080 + server number"

# Calculate HTTP health port (8081 to 8096)
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')
HTTP_PORT=$((8080 + $SERVER_NUMBER))
echo "🌐 HTTP Health Port: $HTTP_PORT"

# Wait based on server number to stagger startup
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 60 ))
echo "⏰ Staggered startup: waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

# Start HTTP health server FIRST (before Minecraft)
echo "Starting HTTP health server on port $HTTP_PORT"
echo "✅ Minecraft Server $NODE_ID - Region: $WORLD_REGION - Status: ONLINE" > /app/health.html
python3 -m http.server $HTTP_PORT --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# Create optimized server.properties
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
EOF

# Set RCON
RCON_PORT=$((SERVER_PORT + 10000))
echo "rcon.port=$RCON_PORT" >> /app/server.properties
echo "rcon.password=${NODE_ID}-$(openssl rand -hex 8)" >> /app/server.properties
echo "enable-rcon=true" >> /app/server.properties

echo "✅ Server configured for 375MB operation"

# Function to cleanup processes
cleanup() {
    echo "🛑 Shutting down Minecraft server..."
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
     -XX:+ParallelRefProcEnabled \
     -jar paper.jar nogui

# Cleanup after Minecraft exits
cleanup
