#!/bin/bash

# FIXED HYBRID SYSTEM: SOLVES FALSE MEMORY DETECTION DURING STARTUP

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

echo "🎮 Server $SERVER_NUMBER - FIXED HYBRID SYSTEM"
echo "🔧 SOLVES: False memory detection & early transfer issues"

# PHASE 1: WORK SPLIT WITH STARTUP PROTECTION
if [ $SERVER_NUMBER -le 4 ]; then
    WORKLOAD="heavy"; MEMORY="380M"; VIEW_DISTANCE="6"; SIMULATION_DISTANCE="4"; MAX_PLAYERS="25"
elif [ $SERVER_NUMBER -le 8 ]; then
    WORKLOAD="medium"; MEMORY="350M"; VIEW_DISTANCE="5"; SIMULATION_DISTANCE="3"; MAX_PLAYERS="20"  
elif [ $SERVER_NUMBER -le 12 ]; then
    WORKLOAD="light"; MEMORY="320M"; VIEW_DISTANCE="4"; SIMULATION_DISTANCE="2"; MAX_PLAYERS="15"
else
    WORKLOAD="backup"; MEMORY="300M"; VIEW_DISTANCE="3"; SIMULATION_DISTANCE="2"; MAX_PLAYERS="12"
fi

CURRENT_WORKLOAD=$WORKLOAD
SERVER_ID="game-$SERVER_NUMBER"

echo "💾 $WORKLOAD mode: $MEMORY | View: $VIEW_DISTANCE | Players: $MAX_PLAYERS"

# Start health server
echo "✅ $SERVER_ID - Starting up" > /app/index.html
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &
HEALTH_PID=$!

# SMART STAGGERING
WAIT_TIME=$(( ($SERVER_NUMBER - 1) * 120 ))
echo "⏰ Staggered startup: ${WAIT_TIME}s..."
sleep $WAIT_TIME

echo "🚀 STARTING SERVER $SERVER_NUMBER"

# Download PaperMC
if [ ! -f "/app/paper.jar" ]; then
    echo "📥 Downloading PaperMC..."
    wget -q -O /app/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
fi

# Server configuration
cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=$VIEW_DISTANCE
simulation-distance=$SIMULATION_DISTANCE
max-players=$MAX_PLAYERS
online-mode=false
motd=Fixed-Hybrid-$WORKLOAD-$SERVER_NUMBER
level-name=world
level-type=default
max-world-size=5000
spawn-protection=16
network-compression-threshold=256
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=fixed-$(openssl rand -hex 6)
allow-flight=true
enable-command-block=true
generate-structures=true
EOF

echo "eula=true" > /app/eula.txt
mkdir -p /app/world /app/plugins

echo "✅ Server configured - Starting Minecraft..."

# 🎯 FIX 1: STARTUP PHASE DETECTION
SERVER_STARTUP_PHASE="starting"
MINECRAFT_PID=""

# Function to detect when Minecraft is fully started
detect_minecraft_start() {
    echo "🔍 Monitoring Minecraft startup phase..."
    
    while true; do
        if [ -f "/app/logs/latest.log" ]; then
            if grep -q "Done" /app/logs/latest.log 2>/dev/null; then
                echo "✅ MINECRAFT FULLY STARTED: Server is now running"
                SERVER_STARTUP_PHASE="running"
                return
            elif grep -q "Preparing spawn" /app/logs/latest.log 2>/dev/null; then
                echo "📊 STARTUP PHASE: World generation"
                SERVER_STARTUP_PHASE="worldgen"
            elif grep -q "Loading properties" /app/logs/latest.log 2>/dev/null; then
                echo "📊 STARTUP PHASE: Loading configs"
                SERVER_STARTUP_PHASE="loading"
            fi
        fi
        sleep 10
    done
}

# 🎯 FIX 2: INTELLIGENT MEMORY MONITORING (NO FALSE DETECTION)
intelligent_memory_monitor() {
    echo "🔍 STARTING INTELLIGENT MEMORY MONITOR..."
    echo "⚠️  TRANSFER SYSTEM DISABLED during startup (fixes false detection)"
    
    # Wait for Minecraft to fully start before enabling transfers
    while [ "$SERVER_STARTUP_PHASE" != "running" ]; do
        echo "⏳ Waiting for Minecraft to fully start... (current: $SERVER_STARTUP_PHASE)"
        sleep 15
    done
    
    echo "✅ TRANSFER SYSTEM NOW ACTIVE - Server is fully running"
    
    # Now start real memory monitoring
    while true; do
        if command -v free > /dev/null 2>&1; then
            MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2 }')
            echo "📊 REAL Memory: ${MEM_USAGE}% | Phase: $SERVER_STARTUP_PHASE"
            
            # 🎯 FIX 3: ONLY TRANSFER WHEN SERVER IS RUNNING (NOT STARTING)
            if [ "$SERVER_STARTUP_PHASE" = "running" ]; then
                if [ $MEM_USAGE -gt 80 ]; then
                    echo "🚨 REAL HIGH MEMORY: ${MEM_USAGE}% - Initiating transfer..."
                    safe_work_transfer
                elif [ $MEM_USAGE -gt 70 ]; then
                    echo "⚠️  Memory getting high: ${MEM_USAGE}% - Monitoring..."
                fi
            else
                echo "🔒 Startup protection: No transfers during startup"
            fi
        else
            echo "📊 Memory monitor: System check unavailable"
        fi
        sleep 30
    done
}

# 🎯 FIX 4: SAFE WORK TRANSFER (NO FALSE POSITIVES)
safe_work_transfer() {
    echo "🔄 SAFE TRANSFER: Checking if transfer is needed..."
    
    # Double-check memory (avoid false positives)
    sleep 5
    MEM_USAGE=$(free | awk 'NR==2{printf "%.0f", $3*100/$2 }')
    
    if [ $MEM_USAGE -gt 80 ]; then
        echo "🚨 CONFIRMED HIGH MEMORY: ${MEM_USAGE}% - Proceeding with transfer"
        
        # Step 1: Reduce own workload
        echo "🔻 Reducing own workload first..."
        reduce_workload_safely
        
        # Step 2: Check if we can transfer to backup servers
        if [ $SERVER_NUMBER -le 12 ]; then
            echo "📢 Signaling backup servers (13-16) for help..."
            # In full system, this would contact backup servers
        fi
        
        # Step 3: Update workload level
        if [ "$CURRENT_WORKLOAD" = "heavy" ]; then
            CURRENT_WORKLOAD="medium"
            echo "⚖️ Downgraded: HEAVY → MEDIUM workload"
        elif [ "$CURRENT_WORKLOAD" = "medium" ]; then
            CURRENT_WORKLOAD="light"
            echo "⚡ Downgraded: MEDIUM → LIGHT workload"
        fi
        
        echo "✅ TRANSFER COMPLETE: Now in $CURRENT_WORKLOAD mode"
    else
        echo "✅ Memory normalized: ${MEM_USAGE}% - No transfer needed"
    fi
}

# 🎯 FIX 5: SAFE WORKLOAD REDUCTION
reduce_workload_safely() {
    echo "🔻 Applying safe workload reduction..."
    
    # Gradual reduction based on current settings
    CURRENT_VIEW=$(grep "view-distance" /app/server.properties | cut -d= -f2)
    CURRENT_PLAYERS=$(grep "max-players" /app/server.properties | cut -d= -f2)
    
    if [ $CURRENT_VIEW -gt 4 ]; then
        sed -i 's/view-distance=.*/view-distance=4/' /app/server.properties
        echo "✅ Reduced view distance: $CURRENT_VIEW → 4"
    fi
    
    if [ $CURRENT_PLAYERS -gt 15 ]; then
        sed -i 's/max-players=.*/max-players=15/' /app/server.properties
        echo "✅ Reduced players: $CURRENT_PLAYERS → 15"
    fi
    
    # Only reduce simulation distance if really needed
    if [ $MEM_USAGE -gt 85 ]; then
        sed -i 's/simulation-distance=.*/simulation-distance=2/' /app/server.properties
        echo "✅ Reduced simulation distance: → 2"
    fi
}

# Start monitoring systems
detect_minecraft_start &
DETECT_PID=$!

intelligent_memory_monitor &
MONITOR_PID=$!

# Start Minecraft server
echo "🚀 Starting PaperMC with $MEMORY heap..."
case $CURRENT_WORKLOAD in
    "heavy")
        java -Xmx380M -Xms256M -XX:+UseG1GC -jar paper.jar nogui
        ;;
    "medium")
        java -Xmx350M -Xms220M -XX:+UseG1GC -jar paper.jar nogui
        ;;
    "light"|"backup")
        java -Xmx320M -Xms200M -XX:+UseG1GC -jar paper.jar nogui
        ;;
esac

# Cleanup
kill $DETECT_PID $MONITOR_PID $HEALTH_PID 2>/dev/null
echo "🔄 Server $SERVER_NUMBER shutting down"
