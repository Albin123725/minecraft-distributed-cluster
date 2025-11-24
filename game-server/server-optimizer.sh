#!/bin/bash

echo "⚡ Server Optimizer for $NODE_ID"

case $WORLD_REGION in
    "spawn")
        VIEW_DISTANCE=10
        SIMULATION_DISTANCE=8
        ;;
    "nether"|"end")
        VIEW_DISTANCE=6
        SIMULATION_DISTANCE=4
        ;;
    *)
        VIEW_DISTANCE=8
        SIMULATION_DISTANCE=6
        ;;
esac

echo "🌍 Region: $WORLD_REGION"
echo "👀 View Distance: $VIEW_DISTANCE"
echo "🎯 Simulation Distance: $SIMULATION_DISTANCE"

if [ -f "/app/server.properties" ]; then
    sed -i "s/^view-distance=.*/view-distance=$VIEW_DISTANCE/" /app/server.properties
    sed -i "s/^simulation-distance=.*/simulation-distance=$SIMULATION_DISTANCE/" /app/server.properties
    echo "✅ Server properties optimized"
fi

cat > /app/jvm-optimized.flags << EOF
-Xmx400M
-Xms256M
-XX:+UseG1GC
-XX:MaxGCPauseMillis=50
-XX:+UnlockExperimentalVMOptions
-XX:+UseStringDeduplication
EOF

echo "✅ JVM flags optimized"
