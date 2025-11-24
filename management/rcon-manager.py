#!/usr/bin/env python3
from flask import Flask, render_template_string, request, jsonify
import socket
import struct
import time
import os
import threading

app = Flask(__name__)

class RCONClient:
    def __init__(self):
        self.timeout = int(os.environ.get('RCON_TIMEOUT', 10))
    
    def send_command(self, host, port, password, command):
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(self.timeout)
            sock.connect((host, port))
            
            login_packet = self._create_packet(3, password)
            sock.send(login_packet)
            
            response = self._receive_packet(sock)
            if not response or response['request_id'] == -1:
                return "❌ RCON Authentication failed"
            
            command_packet = self._create_packet(2, command)
            sock.send(command_packet)
            
            response = self._receive_packet(sock)
            sock.close()
            
            if response:
                return response['payload'].strip()
            else:
                return "No response from server"
                
        except socket.timeout:
            return "⏰ Connection timeout"
        except ConnectionRefusedError:
            return "🔌 Connection refused"
        except Exception as e:
            return f"❌ Error: {str(e)}"
    
    def _create_packet(self, packet_type, payload):
        payload_encoded = payload.encode('utf-8')
        packet = struct.pack('<ii', 0, packet_type) + payload_encoded + b'\x00\x00'
        packet_length = len(packet) - 4
        packet = struct.pack('<i', packet_length) + packet
        return packet
    
    def _receive_packet(self, sock):
        try:
            length_data = sock.recv(4)
            if not length_data:
                return None
            
            packet_length = struct.unpack('<i', length_data)[0]
            packet_data = sock.recv(packet_length)
            
            if len(packet_data) < 8:
                return None
            
            request_id = struct.unpack('<i', packet_data[0:4])[0]
            packet_type = struct.unpack('<i', packet_data[4:8])[0]
            payload = packet_data[8:-2].decode('utf-8')
            
            return {
                'request_id': request_id,
                'packet_type': packet_type,
                'payload': payload
            }
        except:
            return None

rcon_client = RCONClient()
SERVERS = {}
server_lock = threading.Lock()

@app.route('/')
def rcon_dashboard():
    return render_template_string('''
<!DOCTYPE html>
<html>
<head>
    <title>RCON Server Manager</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #1a1a1a; color: white; }
        .server-card { background: #2a2a2a; padding: 15px; margin: 10px; border-radius: 8px; }
        .command-input { width: 60%; padding: 10px; background: #2a2a2a; color: white; border: 1px solid #444; margin: 5px; }
        .server-select { padding: 10px; background: #2a2a2a; color: white; border: 1px solid #444; margin: 5px; width: 300px; }
        .send-btn { padding: 10px 20px; background: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
        .quick-btn { padding: 8px 15px; background: #2196F3; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 2px; }
    </style>
</head>
<body>
    <h1>🎮 RCON Server Manager</h1>
    
    <div class="server-card">
        <h3>🔌 Server Selection</h3>
        <select class="server-select" id="serverSelect">
            <option value="">Select a server...</option>
            {% for server_id, server in servers.items() %}
            <option value="{{ server_id }}">{{ server_id }} - {{ server.region }}</option>
            {% endfor %}
        </select>
        <input type="password" class="command-input" id="rconPassword" placeholder="RCON Password">
        <button class="send-btn" onclick="testConnection()">Test Connection</button>
    </div>

    <div class="server-card">
        <h3>⚡ Quick Commands</h3>
        <button class="quick-btn" onclick="sendQuickCommand('list')">👥 List Players</button>
        <button class="quick-btn" onclick="sendQuickCommand('save-all')">💾 Save All</button>
        <button class="quick-btn" onclick="sendQuickCommand('time set day')">🌞 Time: Day</button>
        <button class="quick-btn" onclick="sendQuickCommand('say Hello from RCON!')">📢 Broadcast</button>
    </div>

    <div class="server-card">
        <h3>⌨️ Custom Command</h3>
        <input type="text" class="command-input" id="customCommand" placeholder="Enter custom command...">
        <button class="send-btn" onclick="sendCustomCommand()">Send Command</button>
    </div>

    <div class="server-card">
        <h3>📊 Response</h3>
        <div id="responseConsole">Select a server and enter RCON password to start...</div>
    </div>

    <script>
    async function sendCommand(command) {
        const serverId = document.getElementById('serverSelect').value;
        const password = document.getElementById('rconPassword').value;
        
        if (!serverId || !password) {
            alert('Please select a server and enter RCON password');
            return;
        }
        
        const response = await fetch('/api/send-command', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({
                server_id: serverId,
                password: password,
                command: command
            })
        });
        
        const result = await response.json();
        document.getElementById('responseConsole').innerHTML = 
            `<strong>Command:</strong> ${command}<br><strong>Response:</strong><br>${result.response}`;
    }
    
    function testConnection() {
        sendCommand('list');
    }
    
    function sendQuickCommand(command) {
        sendCommand(command);
    }
    
    function sendCustomCommand() {
        const command = document.getElementById('customCommand').value;
        if (command) {
            sendCommand(command);
            document.getElementById('customCommand').value = '';
        }
    }
    </script>
</body>
</html>
''', servers=SERVERS)

@app.route('/server/register', methods=['POST'])
def register_server():
    server_data = request.json
    server_id = server_data.get('server_id')
    
    with server_lock:
        SERVERS[server_id] = {
            'host': server_data.get('host'),
            'rcon_port': server_data.get('rcon_port'),
            'region': server_data.get('region'),
            'last_seen': time.time()
        }
    
    print(f"✅ Registered server: {server_id}")
    return jsonify({'status': 'success'})

@app.route('/api/send-command', methods=['POST'])
def send_command():
    data = request.json
    server_id = data.get('server_id')
    password = data.get('password')
    command = data.get('command')
    
    if server_id not in SERVERS:
        return jsonify({'error': 'Server not found'}), 404
    
    server = SERVERS[server_id]
    result = rcon_client.send_command(server['host'], server['rcon_port'], password, command)
    
    return jsonify({
        'server': server_id,
        'command': command,
        'response': result
    })

@app.route('/health')
def health_check():
    return jsonify({
        'status': 'healthy',
        'service': 'rcon-manager',
        'servers_registered': len(SERVERS),
        'timestamp': time.time()
    })

if __name__ == '__main__':
    port = int(os.environ.get('DASHBOARD_PORT', 10000))
    app.run(host='0.0.0.0', port=port, debug=False)
