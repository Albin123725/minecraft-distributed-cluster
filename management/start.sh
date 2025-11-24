#!/bin/bash

echo "🖥️ Starting Management Dashboard v2.0"
echo "===================================="
echo "🔧 Service: $NODE_ID"
echo "🌐 Port: $DASHBOARD_PORT"

echo "✅ Management Dashboard is healthy" > /app/health

# Start all management services
python3 /app/rcon-manager.py &
python3 /app/management-dashboard.py &
python3 /app/file-manager.py &
python3 /app/health-api.py &

echo "✅ All management services started"
echo "📊 Services:"
echo "   • RCON Manager: http://0.0.0.0:10000"
echo "   • Main Dashboard: http://0.0.0.0:5000"
echo "   • File Manager: http://0.0.0.0:5001"
echo "   • Health API: http://0.0.0.0:5002"

wait
