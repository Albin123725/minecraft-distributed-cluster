#!/bin/bash

echo "🔄 Starting World Sync for $NODE_ID ($WORLD_REGION)"

RCON_PORT=$((SERVER_PORT + 10000))
SERVICE_URL="${RENDER_SERVICE_URL:-mc-${NODE_ID}.onrender.com}"

echo "📡 Service URL: $SERVICE_URL"
echo "🔌 RCON Port: $RCON_PORT"

while true; do
    echo "📝 Registering with RCON manager..."
    
    curl -X POST -H "Content-Type: application/json" \
         -d "{
             \"server_id\": \"$NODE_ID\",
             \"host\": \"$SERVICE_URL\",
             \"rcon_port\": $RCON_PORT,
             \"region\": \"$WORLD_REGION\"
         }" \
         http://mc-management.onrender.com/server/register && break
    
    echo "❌ Failed to register, retrying in 30 seconds..."
    sleep 30
done

echo "✅ Successfully registered!"

while true; do
    if [ ! -z "$GDRIVE_FOLDER_ID" ] && [ -f "/app/credentials.json" ]; then
        echo "🔄 Syncing worlds with Google Drive..."
        python3 /app/gdrive-manager.py --download-folder worlds --folder worlds
    fi
    sleep 300
done
