#!/bin/bash

# HYBRID SYSTEM: SPLIT + TRANSFER

# Get server info
if [[ $RENDER_SERVICE_NAME == *"game-1"* ]]; then SERVER_NUMBER=1; SERVER_PORT=25566; WORLD_REGION="spawn"
# ... (same mapping for all 16 servers)
fi

echo "🎮 Server $SERVER_NUMBER - HYBRID MODE: Split + Transfer"

# PHASE 1: INITIAL WORK SPLIT
if [ $SERVER_NUMBER -le 4 ]; then
    # SERVERS 1-4: HEAVY WORK (Initial split)
    INITIAL_WORKLOAD="heavy"
    TASK="world_generation"
    MEMORY="280M"
    echo "🏋️ PHASE 1: Assigned HEAVY work (world generation)"
    
elif [ $SERVER_NUMBER -le 8 ]; then
    # SERVERS 5-8: MEDIUM WORK (Initial split)  
    INITIAL_WORKLOAD="medium"
    TASK="plugin_setup"
    MEMORY="250M"
    echo "⚖️ PHASE 1: Assigned MEDIUM work (plugin setup)"
    
else
    # SERVERS 9-16: LIGHT WORK (Initial split)
    INITIAL_WORKLOAD="light" 
    TASK="ready_server"
    MEMORY="220M"
    echo "⚡ PHASE 1: Assigned LIGHT work (ready server)"
fi

CURRENT_WORKLOAD=$INITIAL_WORKLOAD
CURRENT_TASK=$TASK

# WORK TRANSFER COORDINATOR
COORDINATOR_URL="https://mc-management.onrender.com"

# FUNCTION: Transfer work to another server
transfer_work_out() {
    echo "🔄 TRANSFERING WORK OUT: This server is overloaded"
    
    # Find a light server to transfer to
    for candidate in 9 10 11 12 13 14 15 16; do
        RESPONSE=$(curl -s "$COORDINATOR_URL/can_accept_work/game-$candidate")
        if echo "$RESPONSE" | grep -q '"can_accept":true'; then
            echo "📤 Transferring $CURRENT_TASK to Server $candidate"
            curl -s "$COORDINATOR_URL/transfer_work/game-$SERVER_NUMBER/game-$candidate/$CURRENT_TASK"
            
            # Switch to light mode
            CURRENT_WORKLOAD="light"
            CURRENT_TASK="ready_server" 
            MEMORY="220M"
            apply_light_settings
            echo "✅ Now in LIGHT mode (work transferred to Server $candidate)"
            return
        fi
    done
    echo "⚠️ No available servers for transfer - reducing workload instead"
    reduce_workload
}

# FUNCTION: Accept transferred work
accept_transferred_work() {
    echo "🔄 ACCEPTING TRANSFERRED WORK"
    CURRENT_WORKLOAD="heavy"
    CURRENT_TASK="transferred_work"
    MEMORY="280M"
    apply_heavy_settings
    echo "✅ Now handling TRANSFERRED work"
}

# FUNCTION: Monitor and manage work transfers
work_transfer_manager() {
    while true; do
        # Check if we should transfer work out (if heavy/medium and struggling)
        if [[ "$CURRENT_WORKLOAD" == "heavy" || "$CURRENT_WORKLOAD" == "medium" ]]; then
            # Simulate memory check - in real system, use actual memory monitoring
            MEM_USAGE=$((RANDOM % 100))
            if [ $MEM_USAGE -gt 75 ]; then
                echo "🚨 High memory usage detected: ${MEM_USAGE}%"
                transfer_work_out
            fi
        fi
        
        # Check if we can accept transferred work (if light and available)
        if [[ "$CURRENT_WORKLOAD" == "light" ]]; then
            RESPONSE=$(curl -s "$COORDINATOR_URL/has_pending_transfers")
            if echo "$RESPONSE" | grep -q '"pending_transfers":true'; then
                accept_transferred_work
            fi
        fi
        
        sleep 30
    done
}

# Apply settings based on current workload
apply_heavy_settings() {
    cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=4
simulation-distance=3
max-players=20
online-mode=false
motd=HEAVY-$SERVER_NUMBER-$WORLD_REGION
level-name=world
level-type=default
max-world-size=3000
spawn-protection=0
network-compression-threshold=128
allow-nether=true
allow-end=true
enable-rcon=true
generate-structures=true
EOF
}

apply_medium_settings() {
    cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=3
simulation-distance=2
max-players=15
online-mode=false
motd=MEDIUM-$SERVER_NUMBER-$WORLD_REGION
level-name=world
level-type=flat
max-world-size=1500
spawn-protection=0
network-compression-threshold=64
allow-nether=true
allow-end=true
enable-rcon=true
generate-structures=false
EOF
}

apply_light_settings() {
    cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=2
simulation-distance=1
max-players=10
online-mode=false
motd=LIGHT-$SERVER_NUMBER-$WORLD_REGION
level-name=world
level-type=flat
max-world-size=500
spawn-protection=0
network-compression-threshold=32
allow-nether=false
allow-end=false
enable-rcon=false
generate-structures=false
EOF
}

# Reduce workload without transferring
reduce_workload() {
    echo "🔻 Reducing workload (no transfer available)"
    if [ "$CURRENT_WORKLOAD" = "heavy" ]; then
        CURRENT_WORKLOAD="medium"
        MEMORY="250M"
        apply_medium_settings
    elif [ "$CURRENT_WORKLOAD" = "medium" ]; then
        CURRENT_WORKLOAD="light" 
        MEMORY="220M"
        apply_light_settings
    fi
}

# Start health server
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &

# Apply initial settings based on split
case $INITIAL_WORKLOAD in
    "heavy") apply_heavy_settings ;;
    "medium") apply_medium_settings ;;
    "light") apply_light_settings ;;
esac

echo "eula=true" > /app/eula.txt
mkdir -p /app/world

# Download PaperMC if needed
if [ ! -f "/app/paper.jar" ]; then
    echo "📥 Downloading PaperMC..."
    wget -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

echo "✅ HYBRID SYSTEM READY: Split=$INITIAL_WORKLOAD, Memory=$MEMORY"

# Start work transfer manager in background
work_transfer_manager &
TRANSFER_PID=$!

# Start Minecraft
echo "🚀 Starting with $MEMORY heap"
java -Xmx$MEMORY -Xms150M \
     -XX:+UseG1GC \
     -XX:MaxGCPauseMillis=200 \
     -jar paper.jar nogui

# Cleanup
kill $TRANSFER_PID 2>/dev/null
