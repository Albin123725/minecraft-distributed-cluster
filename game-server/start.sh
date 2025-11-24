#!/bin/bash

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 375MB (Part of 6GB Cluster)"
echo "👥 Capacity: 20 players per server"
echo "🔧 Total Cluster: 16 servers × 375MB = 6GB RAM"

# Wait based on server number to stagger startup
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 60 ))  # 60 seconds between servers
echo "⏰ Staggered startup: waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

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

# Start with 300MB heap (375MB total with system)
echo "🚀 Starting PaperMC Server..."
exec java -Xmx300M -Xms200M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=100 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+ParallelRefProcEnabled \
     -jar paper.jar nogui
