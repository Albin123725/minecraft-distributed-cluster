#!/bin/bash

# DUAL STRATEGY BASED ON SERVER NUMBER
if [[ $RENDER_SERVICE_NAME == *"game-1"* ]]; then SERVER_NUMBER=1; SERVER_PORT=25566; WORLD_REGION="spawn"
elif [[ $RENDER_SERVICE_NAME == *"game-2"* ]]; then SERVER_NUMBER=2; SERVER_PORT=25567; WORLD_REGION="nether"
elif [[ $RENDER_SERVICE_NAME == *"game-3"* ]]; then SERVER_NUMBER=3; SERVER_PORT=25568; WORLD_REGION="end"
elif [[ $RENDER_SERVICE_NAME == *"game-4"* ]]; then SERVER_NUMBER=4; SERVER_PORT=25569; WORLD_REGION="wilderness-1"
elif [[ $RENDER_SERVICE_NAME == *"game-5"* ]]; then SERVER_NUMBER=5; SERVER_PORT=25570; WORLD_REGION="wilderness-2"
elif [[ $RENDER_SERVICE_NAME == *"game-6"* ]]; then SERVER_NUMBER=6; SERVER_PORT=25571; WORLD_REGION="wilderness-3"
elif [[ $RENDER_SERVICE_NAME == *"game-7"* ]]; then SERVER_NUMBER=7; SERVER_PORT=25572; WORLD_REGION="wilderness-4"
elif [[ $RENDER_SERVICE_NAME == *"game-8"* ]]; then SERVER_NUMBER=8; SERVER_PORT=25573; WORLD_REGION="ocean-1"
elif [[ $RENDER_SERVICE_NAME == *"game-9"* ]]; then SERVER_NUMBER=9; SERVER_PORT=25574; WORLD_REGION="ocean-2"
elif [[ $RENDER_SERVICE_NAME == *"game-10"* ]]; then SERVER_NUMBER=10; SERVER_PORT=25575; WORLD_REGION="mountain-1"
elif [[ $RENDER_SERVICE_NAME == *"game-11"* ]]; then SERVER_NUMBER=11; SERVER_PORT=25576; WORLD_REGION="mountain-2"
elif [[ $RENDER_SERVICE_NAME == *"game-12"* ]]; then SERVER_NUMBER=12; SERVER_PORT=25577; WORLD_REGION="desert-1"
elif [[ $RENDER_SERVICE_NAME == *"game-13"* ]]; then SERVER_NUMBER=13; SERVER_PORT=25578; WORLD_REGION="desert-2"
elif [[ $RENDER_SERVICE_NAME == *"game-14"* ]]; then SERVER_NUMBER=14; SERVER_PORT=25579; WORLD_REGION="forest-1"
elif [[ $RENDER_SERVICE_NAME == *"game-15"* ]]; then SERVER_NUMBER=15; SERVER_PORT=25580; WORLD_REGION="forest-2"
elif [[ $RENDER_SERVICE_NAME == *"game-16"* ]]; then SERVER_NUMBER=16; SERVER_PORT=25581; WORLD_REGION="village-1"
else SERVER_NUMBER=1; SERVER_PORT=25566; WORLD_REGION="spawn"
fi

echo "🎮 Server: $SERVER_NUMBER | Region: $WORLD_REGION | Port: $SERVER_PORT"

# STRATEGY SELECTION
if [ $SERVER_NUMBER -le 9 ]; then
    # SERVERS 1-9: NORMAL STRATEGY (already working)
    echo "💾 STRATEGY: NORMAL (350MB) - Servers 1-9 are stable"
    MEMORY="320M"
    VIEW_DISTANCE="4"
    SIMULATION_DISTANCE="2"
    MAX_PLAYERS="20"
    LEVEL_TYPE="default"
    MAX_WORLD_SIZE="2000"
else
    # SERVERS 10-16: ULTRA-LOW STRATEGY (fix memory issues)
    echo "💾 STRATEGY: ULTRA-LOW (250MB) - Fixing servers 10-16"
    MEMORY="220M"
    VIEW_DISTANCE="2"
    SIMULATION_DISTANCE="1"
    MAX_PLAYERS="10"
    LEVEL_TYPE="flat"
    MAX_WORLD_SIZE="500"
fi

# Start health server
echo "✅ Server $SERVER_NUMBER - Starting" > /app/index.html
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &

# Stagger based on server number
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 300 ))  # 5 minutes between servers
echo "⏰ Stagger: Waiting ${WAIT_TIME}s..."
sleep $WAIT_TIME

echo "🚀 Starting server $SERVER_NUMBER with $MEMORY heap"

# Download PaperMC if not exists
if [ ! -f "/app/paper.jar" ]; then
    echo "📥 Downloading PaperMC..."
    wget -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

# Server configuration
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=$VIEW_DISTANCE
simulation-distance=$SIMULATION_DISTANCE
max-players=$MAX_PLAYERS
online-mode=false
motd=Server-$SERVER_NUMBER-$WORLD_REGION
level-name=world
level-type=$LEVEL_TYPE
max-world-size=$MAX_WORLD_SIZE
spawn-protection=0
network-compression-threshold=64
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=pass-$SERVER_NUMBER
allow-flight=false
enable-command-block=false
EOF

echo "eula=true" > /app/eula.txt
mkdir -p /app/world

echo "✅ Configured: $MEMORY heap, View: $VIEW_DISTANCE, Players: $MAX_PLAYERS"

# Start server with appropriate memory
if [ $SERVER_NUMBER -le 9 ]; then
    # Servers 1-9: Normal memory
    java -Xmx$MEMORY -Xms200M \
         -XX:+UseG1GC \
         -XX:MaxGCPauseMillis=150 \
         -XX:+UnlockExperimentalVMOptions \
         -jar paper.jar nogui
else
    # Servers 10-16: Ultra-low memory
    echo "🔧 ULTRA-LOW MODE: Extra memory optimizations for servers 10-16"
    java -Xmx$MEMORY -Xms150M \
         -XX:+UseG1GC \
         -XX:MaxGCPauseMillis=250 \
         -XX:+UnlockExperimentalVMOptions \
         -XX:+DisableExplicitGC \
         -XX:MaxMetaspaceSize=48M \
         -XX:+UseStringDeduplication \
         -jar paper.jar nogui
fi
