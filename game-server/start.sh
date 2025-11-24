#!/bin/bash

# COORDINATED STARTUP SYSTEM
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

echo "🎮 Server: $SERVER_NUMBER | Region: $WORLD_REGION"
echo "💾 COORDINATED STARTUP: Only 2 servers can start simultaneously"

# Start health server
echo "🔄 Server $SERVER_NUMBER - Requesting startup permission" > /app/index.html
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# COORDINATION SYSTEM
COORDINATOR_URL="https://mc-management.onrender.com"
MAX_RETRIES=30
RETRY_DELAY=30

echo "📞 Contacting coordinator at $COORDINATOR_URL..."

for i in $(seq 1 $MAX_RETRIES); do
    RESPONSE=$(curl -s "$COORDINATOR_URL/request_start/game-$SERVER_NUMBER" || echo '{"status":"error"}')
    
    if echo "$RESPONSE" | grep -q '"status":"approved"'; then
        echo "✅ PERMISSION GRANTED: Starting server $SERVER_NUMBER"
        break
    elif echo "$RESPONSE" | grep -q '"status":"queued"'; then
        POSITION=$(echo "$RESPONSE" | grep -o '"position":[0-9]*' | cut -d: -f2)
        echo "⏳ IN QUEUE: Position $POSITION - Waiting ${RETRY_DELAY}s..."
        sleep $RETRY_DELAY
    else
        echo "🔄 Coordinator unavailable (attempt $i/$MAX_RETRIES) - Waiting ${RETRY_DELAY}s..."
        sleep $RETRY_DELAY
    fi
    
    if [ $i -eq $MAX_RETRIES ]; then
        echo "⚠️  Coordinator timeout - Starting anyway with ULTRA-LOW memory"
    fi
done

# ULTRA-LOW MEMORY FOR ALL SERVERS (GUARANTEED WORKING)
echo "🚀 STARTING WITH ULTRA-LOW MEMORY: 200MB heap"

# Download PaperMC
if [ ! -f "/app/paper.jar" ]; then
    echo "📥 Downloading PaperMC..."
    wget -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

# EXTREME LOW MEMORY CONFIG
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=2
simulation-distance=1
max-players=8
online-mode=false
motd=Coordinated-$SERVER_NUMBER
level-name=world
level-type=flat
max-world-size=300
spawn-protection=0
network-compression-threshold=16
entity-broadcast-range-percentage=5
max-entity-collisions=1
max-tick-time=240000
allow-nether=false
allow-end=false
enable-rcon=false
allow-flight=false
enable-command-block=false
generate-structures=false
difficulty=peaceful
max-build-height=64
EOF

echo "eula=true" > /app/eula.txt
mkdir -p /app/world

echo "✅ Configured for 200MB operation"

# Notify coordinator we're starting
curl -s "$COORDINATOR_URL/finished/game-$SERVER_NUMBER" > /dev/null 2>&1 || true

# GUARANTEED MEMORY LIMITS
echo "🚀 Starting with 180MB heap (ABSOLUTE MINIMUM)..."
java -Xmx180M -Xms120M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=400 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+DisableExplicitGC \
     -XX:MaxMetaspaceSize=40M \
     -XX:+UseStringDeduplication \
     -XX:MaxRAM=350M \
     -jar paper.jar nogui

# Notify coordinator we're done
curl -s "$COORDINATOR_URL/finished/game-$SERVER_NUMBER" > /dev/null 2>&1 || true

kill $HEALTH_PID 2>/dev/null
