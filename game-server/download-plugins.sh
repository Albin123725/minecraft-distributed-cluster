#!/bin/bash
echo "📥 Downloading minimal plugins for $NODE_ID (memory optimized)..."
mkdir -p /app/plugins

# Minimal plugin set for memory efficiency
MINIMAL_PLUGINS=(
    "https://cdn.modrinth.com/data/U6oOTGTt/versions/gzEC9sT6/auto-reload-1.0.0.jar"
)

for plugin_url in "${MINIMAL_PLUGINS[@]}"; do
    plugin_name=$(basename $plugin_url)
    echo "📥 Downloading $plugin_name..."
    wget --timeout=30 -q -O "/app/plugins/$plugin_name" "$plugin_url" && echo "✅ Downloaded $plugin_name" || echo "❌ Failed to download $plugin_name (skipping)"
done

echo "✅ Minimal plugin setup completed"
ls -la /app/plugins/
