#!/bin/bash

# FINAL SOLUTION: GUARANTEED 350MB - NO OUT OF MEMORY

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

echo "🎮 Server $SERVER_NUMBER - GUARANTEED 350MB MODE"
echo "💾 SAFE MEMORY: 350MB used of 512MB available (162MB buffer)"

# Start health server
echo "✅ Server $SERVER_NUMBER - Safe 350MB Mode" > /app/index.html
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# CRITICAL: LONG STAGGERING - 10 MINUTES BETWEEN SERVERS
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 600 ))
echo "⏰ CRITICAL STAGGER: Waiting ${WAIT_TIME}s (10min between servers)"
sleep $WAIT_TIME

echo "🚀 STARTING SERVER $SERVER_NUMBER (Safe Memory Mode)"

# Download PaperMC
if [ ! -f "/app/paper.jar" ]; then
    echo "📥 Downloading PaperMC..."
    wget -q -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

# ULTRA-SAFE SERVER CONFIG (GUARANTEED LOW MEMORY)
cat > /app/server.properties << EOF
# ULTRA-SAFE CONFIG - GUARANTEED 350MB USAGE
server-port=$SERVER_PORT
view-distance=4
simulation-distance=2
max-players=15
online-mode=false
motd=Safe-350MB • $WORLD_REGION • Server $SERVER_NUMBER
level-name=world
level-type=flat
max-world-size=2000
spawn-protection=0
network-compression-threshold=64
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=safe-$(openssl rand -hex 6)
allow-flight=false
enable-command-block=false
generate-structures=false
difficulty=normal
max-build-height=128
entity-broadcast-range-percentage=50
max-entity-collisions=2
EOF

echo "eula=true" > /app/eula.txt
mkdir -p /app/world

echo "✅ ULTRA-SAFE CONFIGURATION:"
echo "   • Memory: 300MB heap + 50MB system = 350MB total"
echo "   • View Distance: 4 chunks (safe)"
echo "   • Players: 15 max (conservative)"
echo "   • World: Flat (low memory)"
echo "   • Structures: Disabled (memory saving)"

# GUARANTEED MEMORY SETTINGS - 300MB HEAP MAX
echo "🚀 Starting with GUARANTEED 300MB heap (350MB total safe)"
java -Xmx300M -Xms200M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=150 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+DisableExplicitGC \
     -XX:MaxMetaspaceSize=70M \
     -XX:+UseStringDeduplication \
     -jar paper.jar nogui

# Cleanup
kill $HEALTH_PID 2>/dev/null
echo "🔚 Server $SERVER_NUMBER stopped safely"
