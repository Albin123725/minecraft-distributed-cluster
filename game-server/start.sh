#!/bin/bash

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 430MB (Part of 6.88GB Cluster)"
echo "🔧 Configuration:"
echo "   - Server Port: $SERVER_PORT"
echo "   - Management URL: $MANAGEMENT_URL"
echo "   - Proxy URL: $PROXY_URL"
echo "   - World Region: $WORLD_REGION"
echo "   - Google Drive Folder: $GDRIVE_FOLDER_ID"

# Wait based on server number to stagger startup
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 30 ))
echo "⏰ Staggered startup: waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

# Skip plugin downloads initially (fixes memory and corruption issues)
echo "📥 Skipping plugin downloads for initial stability..."
mkdir -p /app/plugins
rm -f /app/plugins/*.jar  # Remove any corrupted plugins

# Optimize server with reduced memory
echo "⚡ Server Optimizer for $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "👀 View Distance: 6"
echo "🎯 Simulation Distance: 4"

# Create server.properties with optimized settings
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=6
simulation-distance=4
max-players=25
online-mode=false
white-list=false
motd=PaperMC Distributed Cluster - $WORLD_REGION
level-name=world
level-type=minecraft:normal
generator-settings=
hardcore=false
enable-command-block=true
max-world-size=10000
EOF

# Set RCON
RCON_PORT=$((SERVER_PORT + 10000))
RCON_PASSWORD="${NODE_ID}-$(openssl rand -hex 10)"
echo "🔌 RCON Port: $RCON_PORT"
echo "🔑 RCON Password: $RCON_PASSWORD"

echo "rcon.port=$RCON_PORT" >> /app/server.properties
echo "rcon.password=$RCON_PASSWORD" >> /app/server.properties
echo "enable-rcon=true" >> /app/server.properties

echo "✅ Server configured!"

# Start server with reduced memory (NO PLUGINS = MORE MEMORY FOR MINECRAFT)
echo "🚀 Starting PaperMC server (vanilla mode - no plugins)..."
exec java -Xmx350M -Xms256M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=100 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+ParallelRefProcEnabled \
     -jar paper.jar nogui
