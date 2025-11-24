#!/bin/bash

echo "📥 Downloading default plugins for $NODE_ID..."

mkdir -p /app/plugins

DEFAULT_PLUGINS=(
    "https://github.com/monun/auto-reload/releases/latest/download/auto-reload-1.0.0.jar"
    "https://github.com/EngineHub/WorldEdit/releases/latest/download/worldedit-bukkit-7.2.15.jar"
)

for plugin_url in "${DEFAULT_PLUGINS[@]}"; do
    plugin_name=$(basename $plugin_url)
    echo "📥 Downloading $plugin_name..."
    wget -q -O "/app/plugins/$plugin_name" "$plugin_url" || echo "❌ Failed to download $plugin_name"
done

echo "✅ Default plugins downloaded"
ls -la /app/plugins/
