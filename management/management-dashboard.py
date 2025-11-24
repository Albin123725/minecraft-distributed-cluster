#!/usr/bin/env python3
from flask import Flask, render_template_string, jsonify
import requests

app = Flask(__name__)

DASHBOARD_HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Minecraft Cluster Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #1a1a1a; color: white; }
        .dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .server-card { background: #2a2a2a; padding: 15px; border-radius: 8px; border-left: 4px solid #4CAF50; }
        .stats { background: #333; padding: 15px; border-radius: 8px; margin-bottom: 20px; }
    </style>
</head>
<body>
    <h1>🎮 Minecraft Distributed Cluster Dashboard</h1>
    
    <div class="stats">
        <h3>📊 Cluster Overview</h3>
        <p>🖥️ Total Servers: {{ server_count }}</p>
        <p>💾 Total RAM: 8GB (16 × 512MB)</p>
        <p>👥 Max Players: 400</p>
        <p>🔗 Proxy: mc-proxy-main.onrender.com:25565</p>
        <p>🖥️ Management: mc-management.onrender.com</p>
    </div>

    <div class="dashboard">
        {% for server_id, server in servers.items() %}
        <div class="server-card">
            <h3>🖥️ {{ server_id }}</h3>
            <p><strong>Region:</strong> {{ server.region }}</p>
            <p><strong>Host:</strong> {{ server.host }}</p>
            <p><strong>RCON Port:</strong> {{ server.rcon_port }}</p>
        </div>
        {% endfor %}
    </div>

    <script>
    setTimeout(() => location.reload(), 30000);
    </script>
</body>
</html>
'''

@app.route('/')
def dashboard():
    try:
        response = requests.get('http://localhost:10000/health')
        health_data = response.json() if response.status_code == 200 else {}
        servers = health_data.get('servers', {})
    except:
        servers = {}
    
    return render_template_string(DASHBOARD_HTML, 
                                servers=servers, 
                                server_count=len(servers))

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
