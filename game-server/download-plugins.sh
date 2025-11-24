#!/bin/bash
echo "📥 Downloading default plugins for $NODE_ID..."
mkdir -p /app/plugins

# Use reliable plugin sources
DEFAULT_PLUGINS=(
    "https://cdn.modrinth.com/data/U6oOTGTt/versions/gzEC9sT6/auto-reload-1.0.0.jar"
    "https://cdn.modrinth.com/data/K1Uc1ZUL/versions/7.2.15/worldedit-bukkit-7.2.15.jar"
)

for plugin_url in "${DEFAULT_PLUGINS[@]}"; do
    plugin_name=$(basename $plugin_url)
    echo "📥 Downloading $plugin_name..."
    wget --timeout=30 -q -O "/app/plugins/$plugin_name" "$plugin_url" && echo "✅ Downloaded $plugin_name" || echo "❌ Failed to download $plugin_name"
done

echo "✅ Plugin download attempt completed"
ls -la /app/plugins/
