#!/bin/bash
echo "📥 Downloading minimal plugins for $NODE_ID..."
mkdir -p /app/plugins

# Skip plugin downloads initially to fix memory issues
echo "⚠️  Skipping plugin downloads during initial setup (memory optimization)"
echo "🔧 Plugins can be added later via Google Drive sync"

# Remove any corrupted plugin files that might exist
rm -f /app/plugins/*.jar

# Create empty plugin directory for now
touch /app/plugins/.keep

echo "✅ Plugin system ready for manual setup"
