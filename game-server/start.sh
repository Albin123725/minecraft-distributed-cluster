#!/bin/bash

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 512MB (Part of 8GB Cluster)"

SERVER_PORT=${SERVER_PORT:-25565}
MANAGEMENT_URL=${MANAGEMENT_URL:-"mc-management.onrender.com"}
PROXY_URL=${PROXY_URL:-"mc-proxy-main.onrender.com"}
NODE_ID=${NODE_ID:-"game-unknown"}
WORLD_REGION=${WORLD_REGION:-"default"}
GDRIVE_FOLDER_ID=${GDRIVE_FOLDER_ID:-""}

echo "🔧 Configuration:"
echo "   - Server Port: $SERVER_PORT"
echo "   - Management URL: $MANAGEMENT_URL"
echo "   - Proxy URL: $PROXY_URL"
echo "   - World Region: $WORLD_REGION"
echo "   - Google Drive Folder: $GDRIVE_FOLDER_ID"

# Download files from Google Drive
echo "📥 Downloading files from Google Drive..."
/app/gdrive-downloader.sh

# Optimize server settings
/app/server-optimizer.sh

# Calculate RCON port
RCON_PORT=$((SERVER_PORT + 10000))
echo "🔌 RCON Port: $RCON_PORT"

# Generate RCON password
RCON_PASSWORD="${NODE_ID}-$(date +%s | sha256sum | base64 | head -c 16)"
echo "🔑 RCON Password: $RCON_PASSWORD"
echo $RCON_PASSWORD > /app/rcon_password.txt

# Create server.properties
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
max-players=25
online-mode=false
motd=PaperMC $WORLD_REGION - 1.21.10
view-distance=8
simulation-distance=6
level-name=world-$WORLD_REGION
enable-rcon=true
rcon.port=$RCON_PORT
rcon.password=$RCON_PASSWORD
EOF

echo "✅ Server configured!"

# Start background services
/app/sync-worlds.sh &
/app/health-monitor.sh &

# Start PaperMC server
exec java -Xmx400M -Xms256M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=50 \
     -XX:+UnlockExperimentalVMOptions \
     -jar paper.jar nogui
