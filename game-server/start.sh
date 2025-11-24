#!/bin/bash

# DISTRIBUTED WORKLOAD - EACH SERVER DOES ONE SMALL TASK
SERVICE_NAME="${RENDER_SERVICE_NAME:-mc-game-1}"
NODE_ID="${SERVICE_NAME//mc-/}"
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')

case $SERVER_NUMBER in
    1) JOB="download"; MEMORY="300M" ;;
    2) JOB="patch"; MEMORY="280M" ;;
    3) JOB="plugins"; MEMORY="260M" ;;
    4) JOB="world"; MEMORY="280M" ;;
    *) JOB="light"; MEMORY="220M" ;; # Servers 5-16
esac

HEALTH_PORT="10000"
SERVER_PORT=$((25565 + $SERVER_NUMBER))

echo "🎯 SERVER $NODE_ID - JOB: $JOB"
echo "💾 MEMORY: $MEMORY heap"
echo "🔧 DISTRIBUTED: Heavy work split across 4 servers"

# Health server
python3 -m http.server $HEALTH_PORT --directory /app > /dev/null 2>&1 &

# Each server waits different times based on job
case $JOB in
    "download") sleep 0; ;;
    "patch") sleep 120; ;;     # Wait 2 minutes
    "plugins") sleep 240; ;;   # Wait 4 minutes  
    "world") sleep 360; ;;     # Wait 6 minutes
    "light") sleep 480; ;;     # Wait 8 minutes
esac

# Server configuration
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=3
simulation-distance=2
max-players=15
online-mode=false
motd=Job-$JOB - Server$SERVER_NUMBER
level-name=world
level-type=flat
max-world-size=1000
spawn-protection=0
network-compression-threshold=32
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=${NODE_ID}-pass
EOF

# Download PaperMC if this is the download server
if [ "$JOB" = "download" ]; then
    echo "📥 Downloading PaperMC..."
    wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

echo "🚀 Starting with $MEMORY heap..."
java -Xmx$MEMORY -Xms150M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -jar paper.jar nogui
