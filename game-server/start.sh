#!/bin/bash

# INTELLIGENT AUTO-DISTRIBUTION SYSTEM
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

SERVER_ID="game-$SERVER_NUMBER"
LOAD_BALANCER="https://mc-management.onrender.com"

echo "🎮 Server: $SERVER_NUMBER | Region: $WORLD_REGION"
echo "💾 INTELLIGENT AUTO-DISTRIBUTION: Workload automatically balances across cluster"

# Start health server
echo "🔄 $SERVER_ID - Contacting load balancer" > /app/index.html
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# MEMORY MONITORING FUNCTION
monitor_memory() {
    while true; do
        MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2 }')
        if [ $MEM_USAGE -gt 80 ]; then
            echo "🚨 HIGH MEMORY USAGE: ${MEM_USAGE}% - Requesting workload redistribution"
            # Signal load balancer to redistribute work
            curl -s "$LOAD_BALANCER/task_completed/$SERVER_ID/emergency_redistribute" > /dev/null 2>&1
            # Reduce own workload
            reduce_workload
        fi
        sleep 10
    done
}

reduce_workload() {
    echo "🔻 Reducing workload due to high memory..."
    # Emergency measures: reduce view distance, kick some players, etc.
    if [ -f "/app/server.properties" ]; then
        sed -i 's/view-distance=.*/view-distance=2/' /app/server.properties
        sed -i 's/simulation-distance=.*/simulation-distance=1/' /app/server.properties
        echo "✅ Emergency: Reduced view distance to 2"
    fi
}

# REQUEST WORKLOAD ASSIGNMENT
echo "📞 Requesting workload assignment from load balancer..."

TASK_ASSIGNMENT=$(curl -s "$LOAD_BALANCER/assign_task/world_generation/$SERVER_ID")
echo "📋 Load Balancer Response: $TASK_ASSIGNMENT"

if echo "$TASK_ASSIGNMENT" | grep -q '"status":"assigned"'; then
    echo "✅ ASSIGNED: This server will handle world generation"
    TASK_LEVEL="heavy"
elif echo "$TASK_ASSIGNMENT" | grep -q '"status":"redirected"'; then
    ASSIGNED_TO=$(echo "$TASK_ASSIGNMENT" | grep -o '"assigned_to":"[^"]*"' | cut -d'"' -f4)
    echo "🔄 REDIRECTED: World generation assigned to $ASSIGNED_TO (this server is light)"
    TASK_LEVEL="light"
else
    echo "⏳ QUEUED: Waiting for available capacity"
    TASK_LEVEL="light"  # Start light while waiting
fi

# Start memory monitoring in background
monitor_memory &
MONITOR_PID=$!

# CONFIGURE BASED ON ASSIGNED WORKLOAD
if [ "$TASK_LEVEL" = "heavy" ]; then
    echo "🏋️ HEAVY WORKLOAD: This server handles world generation"
    MEMORY="280M"
    VIEW_DISTANCE="4"
    SIMULATION_DISTANCE="2"
    MAX_PLAYERS="15"
else
    echo "⚡ LIGHT WORKLOAD: Minimal resource usage"
    MEMORY="220M" 
    VIEW_DISTANCE="2"
    SIMULATION_DISTANCE="1"
    MAX_PLAYERS="8"
fi

# Download PaperMC
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
motd=AutoBalanced-$SERVER_NUMBER-$TASK_LEVEL
level-name=world
level-type=flat
max-world-size=1000
spawn-protection=0
network-compression-threshold=32
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=pass-$SERVER_NUMBER
allow-flight=false
enable-command-block=false
generate-structures=true
EOF

echo "eula=true" > /app/eula.txt
mkdir -p /app/world

echo "✅ Configured: $MEMORY heap, $TASK_LEVEL workload"

# Start server
echo "🚀 Starting with intelligent memory management..."
java -Xmx$MEMORY -Xms150M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -XX:+UnlockExperimentalVMOptions \
     -XX:+DisableExplicitGC \
     -jar paper.jar nogui

# Cleanup
kill $MONITOR_PID 2>/dev/null
kill $HEALTH_PID 2>/dev/null

# Notify load balancer we're done
curl -s "$LOAD_BALANCER/task_completed/$SERVER_ID/world_generation" > /dev/null 2>&1
