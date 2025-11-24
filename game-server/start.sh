#!/bin/bash

# AUTO-CONFIGURATION - No manual setup needed!
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

HEALTH_PORT="10000"
WORLD_URL="https://drive.google.com/uc?export=download&id=1qrjjE9z0714DlgY5HZTO6eSxud_Yq7yk"
PLUGINS_URL="https://drive.google.com/uc?export=download&id=1-6Tmy7g4bUTFovBgxQc43yGyqqMJbufy"
MANAGEMENT_URL="https://mc-management.onrender.com"
PROXY_URL="https://mc-proxy-main.onrender.com"

echo "🎮 Starting PaperMC Server: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"
echo "💾 RAM: 380MB (Part of 6.47GB Cluster)"
echo "🔧 Features: Your World + Your Plugins + Auto Dimensions"
echo "🔧 Auto-configured:"
echo "   - Server Port: $SERVER_PORT"
echo "   - Health Port: $HEALTH_PORT"
echo "   - Management: $MANAGEMENT_URL"
echo "   - Proxy: $PROXY_URL"

# Start HTTP server IMMEDIATELY
echo "🌐 Starting health server on port $HEALTH_PORT"
echo "✅ Server $NODE_ID - DOWNLOADING CONTENT" > /app/index.html
python3 -m http.server $HEALTH_PORT --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# Create directories
mkdir -p /app/plugins /app/world

# DOWNLOAD AND INSTALL PLUGINS
echo "📦 Downloading your plugins..."
if curl -L -o "/app/plugins.zip" "$PLUGINS_URL"; then
    echo "✅ Plugins download successful!"
    if unzip -q "/app/plugins.zip" -d /app/plugins-temp; then
        find /app/plugins-temp -name "*.jar" -exec cp {} /app/plugins/ \;
        PLUGIN_COUNT=$(ls /app/plugins/*.jar 2>/dev/null | wc -l)
        echo "✅ $PLUGIN_COUNT plugins installed"
        rm -rf /app/plugins-temp /app/plugins.zip
    else
        echo "❌ Plugin extraction failed"
    fi
else
    echo "❌ Plugin download failed"
fi

# DOWNLOAD AND INSTALL YOUR WORLD
echo "📥 Downloading your custom world..."
if curl -L -o "/app/world.zip" "$WORLD_URL"; then
    echo "✅ World download successful!"
    if unzip -q "/app/world.zip" -d /app/world-temp; then
        if [ -d "/app/world-temp/world" ]; then
            cp -r /app/world-temp/world /app/
        elif [ -d "/app/world-temp/World" ]; then
            cp -r /app/world-temp/World /app/world
        else
            mv /app/world-temp/* /app/ 2>/dev/null || true
        fi
        echo "✅ Your custom world installed"
        rm -rf /app/world-temp /app/world.zip
    else
        echo "❌ World extraction failed"
    fi
else
    echo "❌ World download failed"
fi

echo "🔮 Nether and End will auto-generate fresh"

# Minimal staggered startup
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 5 ))
echo "⏰ Quick staggered startup: waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

echo "✅ Server $NODE_ID - READY" > /app/index.html

# Server configuration
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=6
simulation-distance=4
max-players=25
online-mode=false
motd=Your World & Plugins - $WORLD_REGION
level-name=world
level-type=default
max-world-size=10000
spawn-protection=0
network-compression-threshold=256
allow-nether=true
allow-end=true
level-name-nether=world_nether
level-name-end=world_the_end
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=${NODE_ID}-$(openssl rand -hex 8)
allow-flight=true
enable-command-block=true
EOF

echo "✅ Server configured with:"
echo "   - Your Custom World"
echo "   - $(ls /app/plugins/*.jar 2>/dev/null | wc -l) Plugins"
echo "   - Auto Nether/End Dimensions"

# Cleanup function
cleanup() {
    echo "🛑 Shutting down..."
    kill $HEALTH_PID 2>/dev/null
    exit 0
}

trap cleanup SIGTERM SIGINT

# Start Minecraft server
echo "🚀 Starting PaperMC with Your World & Plugins..."
java -Xmx320M -Xms220M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=100 \
     -XX:+UnlockExperimentalVMOptions \
     -jar paper.jar nogui

cleanup
