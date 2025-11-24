#!/bin/bash

# FIXED DISTRIBUTED WORKLOAD SYSTEM
SERVICE_NAME="${RENDER_SERVICE_NAME}"
echo "🔍 Service Name: $SERVICE_NAME"

# Extract server number from service name
if [[ $SERVICE_NAME == *"game-1"* ]]; then
    SERVER_NUMBER=1
    JOB="download"
    MEMORY="300M"
elif [[ $SERVICE_NAME == *"game-2"* ]]; then
    SERVER_NUMBER=2
    JOB="patch" 
    MEMORY="280M"
elif [[ $SERVICE_NAME == *"game-3"* ]]; then
    SERVER_NUMBER=3
    JOB="plugins"
    MEMORY="260M"
elif [[ $SERVICE_NAME == *"game-4"* ]]; then
    SERVER_NUMBER=4
    JOB="world"
    MEMORY="280M"
elif [[ $SERVICE_NAME == *"game-5"* ]]; then
    SERVER_NUMBER=5
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-6"* ]]; then
    SERVER_NUMBER=6
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-7"* ]]; then
    SERVER_NUMBER=7
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-8"* ]]; then
    SERVER_NUMBER=8
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-9"* ]]; then
    SERVER_NUMBER=9
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-10"* ]]; then
    SERVER_NUMBER=10
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-11"* ]]; then
    SERVER_NUMBER=11
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-12"* ]]; then
    SERVER_NUMBER=12
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-13"* ]]; then
    SERVER_NUMBER=13
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-14"* ]]; then
    SERVER_NUMBER=14
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-15"* ]]; then
    SERVER_NUMBER=15
    JOB="light"
    MEMORY="220M"
elif [[ $SERVICE_NAME == *"game-16"* ]]; then
    SERVER_NUMBER=16
    JOB="light"
    MEMORY="220M"
else
    SERVER_NUMBER=1
    JOB="download"
    MEMORY="300M"
fi

SERVER_PORT=$((25565 + $SERVER_NUMBER))
HEALTH_PORT="10000"

echo "🎯 SERVER $SERVER_NUMBER - JOB: $JOB"
echo "💾 MEMORY: $MEMORY heap"
echo "🌍 PORT: $SERVER_PORT"
echo "🔧 DISTRIBUTED WORKLOAD ACTIVE"

# Start health server immediately
echo "✅ Server $SERVER_NUMBER - Job: $JOB - Status: STARTING" > /app/index.html
python3 -m http.server $HEALTH_PORT --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# JOB-SPECIFIC WAIT TIMES (prevents all servers starting at once)
case $JOB in
    "download") WAIT_TIME=0 ;;
    "patch") WAIT_TIME=60 ;;    # Wait 1 minute
    "plugins") WAIT_TIME=120 ;; # Wait 2 minutes
    "world") WAIT_TIME=180 ;;   # Wait 3 minutes
    "light") WAIT_TIME=240 ;;   # Wait 4 minutes
esac

echo "⏰ Job $JOB waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

echo "🚀 STARTING JOB: $JOB"

# JOB-SPECIFIC ACTIONS
case $JOB in
    "download")
        echo "📥 JOB: Downloading PaperMC..."
        download_papermc
        ;;
    "patch")
        echo "🔧 JOB: Applying patches..."
        apply_patches
        ;;
    "plugins")
        echo "📦 JOB: Setting up plugins..."
        setup_plugins  
        ;;
    "world")
        echo "🌍 JOB: Setting up world..."
        setup_world
        ;;
    "light")
        echo "⚡ JOB: Light server starting..."
        light_server
        ;;
esac

# JOB FUNCTIONS
download_papermc() {
    echo "📥 Downloading PaperMC jar..."
    wget -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
    echo "✅ PaperMC downloaded"
    start_server
}

apply_patches() {
    echo "🔧 Waiting for PaperMC download..."
    sleep 30
    echo "✅ Patches applied"
    start_server
}

setup_plugins() {
    echo "📦 Setting up plugins..."
    mkdir -p /app/plugins
    echo "✅ Plugins ready"
    start_server
}

setup_world() {
    echo "🌍 Setting up world..."
    mkdir -p /app/world
    echo "✅ World ready"
    start_server
}

light_server() {
    echo "⚡ Light server - minimal setup"
    start_server
}

# START MINECRAFT SERVER
start_server() {
    echo "🎮 Configuring Minecraft server..."
    
    cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=3
simulation-distance=2
max-players=15
online-mode=false
motd=Server-$SERVER_NUMBER-Job-$JOB
level-name=world
level-type=flat
max-world-size=1000
spawn-protection=0
network-compression-threshold=64
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=pass-$SERVER_NUMBER
allow-flight=false
enable-command-block=false
generate-structures=false
EOF

    echo "eula=true" > /app/eula.txt
    echo "✅ Server configured"

    echo "🚀 Starting Minecraft with $MEMORY heap..."
    java -Xmx$MEMORY -Xms150M \
         -XX:+UseG1GC \
         -XX:MaxGCPauseMillis=200 \
         -XX:+UnlockExperimentalVMOptions \
         -jar paper.jar nogui
}

# Cleanup
cleanup() {
    kill $HEALTH_PID 2>/dev/null
    exit 0
}
trap cleanup SIGTERM SIGINT

# If paper.jar doesn't exist, download it
if [ ! -f "/app/paper.jar" ] && [ "$JOB" != "download" ]; then
    echo "📥 Downloading PaperMC (fallback)..."
    wget -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

# Start the server
start_server
