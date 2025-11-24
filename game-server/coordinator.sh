#!/bin/bash

# DISTRIBUTED WORKLOAD - Each server has ONE specific job
SERVICE_NAME="${RENDER_SERVICE_NAME:-mc-game-1}"
NODE_ID="${SERVICE_NAME//mc-/}"
SERVER_NUMBER=$(echo $NODE_ID | sed 's/game-//')

case $SERVER_NUMBER in
    1) SERVER_PORT="25566"; WORLD_REGION="spawn"; JOB="download_paper" ;;
    2) SERVER_PORT="25567"; WORLD_REGION="nether"; JOB="apply_patches" ;;
    3) SERVER_PORT="25568"; WORLD_REGION="end"; JOB="setup_plugins" ;;
    4) SERVER_PORT="25569"; WORLD_REGION="wilderness-1"; JOB="setup_world" ;;
    5) SERVER_PORT="25570"; WORLD_REGION="wilderness-2"; JOB="light_server" ;;
    6) SERVER_PORT="25571"; WORLD_REGION="wilderness-3"; JOB="light_server" ;;
    7) SERVER_PORT="25572"; WORLD_REGION="wilderness-4"; JOB="light_server" ;;
    8) SERVER_PORT="25573"; WORLD_REGION="ocean-1"; JOB="light_server" ;;
    9) SERVER_PORT="25574"; WORLD_REGION="ocean-2"; JOB="light_server" ;;
    10) SERVER_PORT="25575"; WORLD_REGION="mountain-1"; JOB="light_server" ;;
    11) SERVER_PORT="25576"; WORLD_REGION="mountain-2"; JOB="light_server" ;;
    12) SERVER_PORT="25577"; WORLD_REGION="desert-1"; JOB="light_server" ;;
    13) SERVER_PORT="25578"; WORLD_REGION="desert-2"; JOB="light_server" ;;
    14) SERVER_PORT="25579"; WORLD_REGION="forest-1"; JOB="light_server" ;;
    15) SERVER_PORT="25580"; WORLD_REGION="forest-2"; JOB="light_server" ;;
    16) SERVER_PORT="25581"; WORLD_REGION="village-1"; JOB="light_server" ;;
    *) SERVER_PORT="25566"; WORLD_REGION="spawn"; JOB="light_server" ;;
esac

echo "🎯 SERVER $NODE_ID - JOB: $JOB"
echo "🌍 Region: $WORLD_REGION"
echo "💾 DISTRIBUTED WORKLOAD: Each server does ONE small task"

# Start health server
python3 -m http.server 10000 --directory /app > /dev/null 2>&1 &

# Execute specific job based on server number
case $JOB in
    "download_paper")
        echo "📥 JOB 1: Downloading PaperMC (Heavy - 400MB)"
        download_papermc
        ;;
    "apply_patches") 
        echo "🔧 JOB 2: Applying patches (Medium - 350MB)"
        apply_patches
        ;;
    "setup_plugins")
        echo "📦 JOB 3: Setting up plugins (Light - 300MB)"
        setup_plugins
        ;;
    "setup_world")
        echo "🌍 JOB 4: Setting up world (Medium - 350MB)"
        setup_world
        ;;
    "light_server")
        echo "⚡ JOB 5-16: Light server (Ultra-light - 250MB)"
        light_server
        ;;
esac
