#!/bin/bash

echo "💾 Starting World Backup for $NODE_ID"
echo "===================================="

# Configuration
BACKUP_DIR="/app/backups"
WORLDS_DIR="/app/worlds"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
BACKUP_NAME="world_backup_${NODE_ID}_${TIMESTAMP}.tar.gz"

echo "📁 Backup: $BACKUP_NAME"
echo "🌍 Worlds directory: $WORLDS_DIR"
echo "💾 Backup directory: $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Check if worlds exist
if [ ! -d "$WORLDS_DIR" ] || [ -z "$(ls -A $WORLDS_DIR)" ]; then
    echo "❌ No worlds found to backup"
    exit 1
fi

echo "🌍 Found worlds:"
ls -la "$WORLDS_DIR"

# Create backup
echo "📦 Creating backup archive..."
tar -czf "$BACKUP_DIR/$BACKUP_NAME" -C "/app" "worlds"

# Check if backup was successful
if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_NAME" | cut -f1)
    echo "✅ Backup created successfully: $BACKUP_NAME ($BACKUP_SIZE)"
    
    # Upload to Google Drive if configured
    if [ ! -z "$GDRIVE_FOLDER_ID" ] && [ -f "/app/credentials.json" ]; then
        echo "☁️ Uploading to Google Drive..."
        python3 /app/gdrive-manager.py --upload "$BACKUP_DIR/$BACKUP_NAME" --folder backups
    fi
    
    # Clean up old backups (keep last 5)
    echo "🧹 Cleaning up old backups..."
    ls -t "$BACKUP_DIR"/*.tar.gz | tail -n +6 | xargs rm -f
    
else
    echo "❌ Backup failed"
    exit 1
fi

echo "🎉 Backup process completed!"
