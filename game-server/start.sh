#!/bin/bash

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 350MB (Part of 5.6GB Cluster)"
echo "🔧 Configuration:"
echo "   - Server Port: $SERVER_PORT"
echo "   - Management URL: $MANAGEMENT_URL"
echo "   - Proxy URL: $PROXY_URL"
echo "   - World Region: $WORLD_REGION"
echo "   - Google Drive Folder: $GDRIVE_FOLDER_ID"

# Wait based on server number to stagger startup
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 60 ))  # Increased to 60 seconds
echo "⏰ Staggered startup: waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

# Skip plugin downloads initially
echo "📥 Skipping plugin downloads for memory optimization..."
mkdir -p /app/plugins
rm -f /app/plugins/*.jar

# Use ultra-low memory settings for initial startup
echo "⚡ ULTRA-LOW MEMORY MODE for $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "👀 View Distance: 4"
echo "🎯 Simulation Distance: 2"

# Create server.properties with ULTRA-optimized settings
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=4
simulation-distance=2
max-players=20
online-mode=false
white-list=false
motd=PaperMC Cluster - $WORLD_REGION
level-name=world
level-type=minecraft:normal
generator-settings=
hardcore=false
enable-command-block=false
max-world-size=5000
max-build-height=256
spawn-protection=0
entity-broadcast-range-percentage=50
sync-chunk-writes=false
EOF

# Set RCON
RCON_PORT=$((SERVER_PORT + 10000))
RCON_PASSWORD="${NODE_ID}-$(openssl rand -hex 10)"
echo "🔌 RCON Port: $RCON_PORT"
echo "🔑 RCON Password: $RCON_PASSWORD"

echo "rcon.port=$RCON_PORT" >> /app/server.properties
echo "rcon.password=$RCON_PASSWORD" >> /app/server.properties
echo "enable-rcon=true" >> /app/server.properties

echo "✅ Server configured for ultra-low memory mode!"

# Start server with EXTREMELY reduced memory
echo "🚀 Starting PaperMC server (ULTRA-LOW MEMORY MODE)..."
exec java -Xmx280M -Xms200M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=150 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+DisableExplicitGC \
     -XX:+AlwaysPreTouch \
     -jar paper.jar nogui
