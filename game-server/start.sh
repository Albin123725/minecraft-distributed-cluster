#!/bin/bash

# ULTRA-OPTIMIZED 400MB - MAX PERFORMANCE WITHIN 500MB LIMIT

# Get server info
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

echo "🎮 Server $SERVER_NUMBER - ULTRA OPTIMIZED 400MB"
echo "💾 BUDGET: 500MB Available | 400MB Used | 100MB Safety"

# Start health server immediately
echo "✅ Server $SERVER_NUMBER - Optimized 400MB" > /app/index.html
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# MINIMAL STAGGER - 90 seconds between servers
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 90 ))
echo "⏰ Quick stagger: ${WAIT_TIME}s..."
sleep $WAIT_TIME

echo "🚀 STARTING OPTIMIZED SERVER $SERVER_NUMBER"

# Download PaperMC (optimized URL - faster download)
if [ ! -f "/app/paper.jar" ]; then
    echo "📥 Downloading optimized PaperMC..."
    wget -q --timeout=30 -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
    echo "✅ PaperMC downloaded"
fi

# ULTRA-OPTIMIZED SERVER PROPERTIES
cat > /app/server.properties << EOF
# Performance Optimized - 400MB Budget
server-port=$SERVER_PORT
view-distance=6
simulation-distance=4
max-players=25
online-mode=false
motd=🚀 400MB-Optimized • $WORLD_REGION • 25 Players
level-name=world
level-type=default
max-world-size=6000
spawn-protection=16
network-compression-threshold=256
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=pass-$(openssl rand -hex 8)
allow-flight=true
enable-command-block=true
generate-structures=true
announce-player-achievements=true
player-idle-timeout=0
entity-broadcast-range-percentage=100
max-tick-time=60000
sync-chunk-writes=true
EOF

echo "eula=true" > /app/eula.txt
mkdir -p /app/world /app/plugins

echo "✅ ULTRA-OPTIMIZED CONFIG:"
echo "   • View Distance: 6 chunks"
echo "   • Simulation: 4 chunks"
echo "   • Max Players: 25"
echo "   • World Size: 6000 blocks"
echo "   • Structures: Enabled"
echo "   • Nether/End: Enabled"

# OPTIMIZED JVM FLAGS FOR 400MB
echo "🚀 Starting with OPTIMIZED 370MB heap + 30MB system = 400MB total"
java -Xmx370M -Xms256M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=50 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+ParallelRefProcEnabled \
     -XX:+DisableExplicitGC \
     -XX:+AlwaysPreTouch \
     -XX:MaxMetaspaceSize=80M \
     -XX:InitiatingHeapOccupancyPercent=35 \
     -XX:G1HeapRegionSize=8M \
     -XX:G1NewSizePercent=30 \
     -XX:G1MaxNewSizePercent=40 \
     -XX:G1ReservePercent=15 \
     -XX:G1HeapWastePercent=5 \
     -XX:G1MixedGCCountTarget=4 \
     -XX:+PerfDisableSharedMem \
     -XX:+OptimizeStringConcat \
     -XX:+UseFastAccessorMethods \
     -jar paper.jar nogui

# Cleanup
kill $HEALTH_PID 2>/dev/null
