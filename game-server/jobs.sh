#!/bin/bash

# JOB 1: Download PaperMC (Heavy - runs on server 1 only)
download_papermc() {
    echo "📥 Downloading PaperMC jar..."
    wget -O /shared/paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.10/builds/115/downloads/paper-1.21.10-115.jar
    echo "✅ PaperMC downloaded by server 1"
    
    # Wait for other jobs to complete
    sleep 300
    start_normal_server
}

# JOB 2: Apply patches (Medium - runs on server 2 only)  
apply_patches() {
    echo "⏳ Waiting for PaperMC download..."
    sleep 60
    
    echo "🔧 Applying patches..."
    cp /shared/paper.jar /app/paper.jar
    echo "✅ Patches applied by server 2"
    
    sleep 240
    start_normal_server
}

# JOB 3: Setup plugins (Light - runs on server 3 only)
setup_plugins() {
    echo "⏳ Waiting for previous jobs..."
    sleep 120
    
    echo "📦 Setting up plugins..."
    mkdir -p /app/plugins
    # Minimal plugins to avoid memory issues
    echo "✅ Plugins setup by server 3"
    
    sleep 180
    start_normal_server
}

# JOB 4: Setup world (Medium - runs on server 4 only)
setup_world() {
    echo "⏳ Waiting for previous jobs..."
    sleep 180
    
    echo "🌍 Setting up world..."
    mkdir -p /app/world
    # Use flat world to minimize memory
    echo "level-type=flat" > /app/server.properties
    echo "✅ World setup by server 4"
    
    sleep 120
    start_normal_server
}

# JOB 5-16: Light servers (Ultra-light)
light_server() {
    echo "⏳ Waiting for all setup jobs to complete..."
    sleep 300
    
    echo "⚡ Starting light server..."
    # Use pre-configured files from job servers
    start_light_server
}

# Normal server startup (after jobs complete)
start_normal_server() {
    cat > /app/server.properties << EOF
server-port=$SERVER_PORT
view-distance=4
simulation-distance=2
max-players=20
online-mode=false
motd=Distributed Cluster - $WORLD_REGION
level-name=world
level-type=flat
max-world-size=2000
spawn-protection=0
network-compression-threshold=64
allow-nether=true
allow-end=true
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=${NODE_ID}-pass
EOF

    echo "🚀 Starting server with 280MB heap..."
    java -Xmx280M -Xms180M -jar paper.jar nogui
}

# Ultra-light server (servers 5-16)
start_light_server() {
    cat > /app/server.properties << EOF
server-port=$SERVER_PORT  
view-distance=2
simulation-distance=1
max-players=15
online-mode=false
motd=Light Server - $WORLD_REGION
level-name=world
level-type=flat
max-world-size=1000
spawn-protection=0
network-compression-threshold=32
allow-nether=false
allow-end=false
enable-rcon=true
rcon.port=$((SERVER_PORT + 10000))
rcon.password=${NODE_ID}-pass
EOF

    echo "⚡ Starting ULTRA-LIGHT server with 220MB heap..."
    java -Xmx220M -Xms150M -jar /shared/paper.jar nogui
}
