#!/bin/bash

echo "📥 Google Drive Downloader for $NODE_ID"

mkdir -p /app/plugins /app/worlds /app/config

if [ ! -z "$GDRIVE_CREDENTIALS_JSON" ] && [ ! -z "$GDRIVE_TOKEN_PICKLE" ]; then
    echo "🔐 Google Drive credentials detected"
    
    echo "$GDRIVE_CREDENTIALS_JSON" > /app/credentials.json
    echo "$GDRIVE_TOKEN_PICKLE" | base64 -d > /app/token.pickle
    
    echo "🔄 Downloading files from Google Drive..."
    
    python3 /app/gdrive-download.py --type plugins --folder-id $GDRIVE_FOLDER_ID --output /app/plugins
    
    python3 /app/gdrive-download.py --type worlds --folder-id $GDRIVE_FOLDER_ID --output /app
    
    python3 /app/gdrive-download.py --type configs --folder-id $GDRIVE_FOLDER_ID --output /app
    
    echo "✅ Google Drive download completed"
else
    echo "⚠️  Google Drive credentials not found, using default plugins..."
    /app/download-plugins.sh
fi

echo "📦 Downloaded plugins:"
ls -la /app/plugins/
