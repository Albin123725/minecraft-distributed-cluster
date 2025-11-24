#!/bin/bash

echo "🔄 Google Drive Sync Service"
echo "==========================="
echo "📁 Folder ID: $GDRIVE_FOLDER_ID"
echo "⏰ Sync Interval: $SYNC_INTERVAL seconds"
echo "🎮 Node ID: $NODE_ID"
echo "🌍 Region: $WORLD_REGION"

mkdir -p /app/plugins /app/worlds /app/config /app/backups

# Initial sync
echo "🔄 Performing initial sync..."
python3 /app/gdrive-download.py --type plugins --folder-id $GDRIVE_FOLDER_ID --output /app/plugins

while true; do
    echo "$(date): Starting sync cycle..."
    
    # Sync plugins
    echo "📦 Syncing plugins..."
    python3 /app/gdrive-manager.py --download-folder plugins --folder plugins
    
    # Sync configs every 30 minutes
    if [ $(($(date +%s) % 1800)) -eq 0 ]; then
        echo "⚙️ Syncing configs..."
        python3 /app/gdrive-manager.py --download-folder configs --folder configs
    fi
    
    # Backup worlds every hour
    if [ $(($(date +%s) % 3600)) -eq 0 ]; then
        echo "💾 Backing up worlds..."
        python3 /app/backup-manager.py --backup-worlds
    fi
    
    echo "✅ Sync completed. Sleeping for $SYNC_INTERVAL seconds..."
    sleep $SYNC_INTERVAL
done
