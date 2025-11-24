from flask import Flask, jsonify
import time
import threading

app = Flask(__name__)

# Global coordination state
active_servers = 0
max_concurrent = 2  # Only allow 2 servers to generate worlds at once
server_queue = []
server_status = {}

@app.route('/request_start/<server_id>')
def request_start(server_id):
    global active_servers
    
    if active_servers < max_concurrent:
        active_servers += 1
        server_status[server_id] = "approved"
        return jsonify({"status": "approved", "message": "You can start"})
    else:
        server_queue.append(server_id)
        server_status[server_id] = "queued"
        return jsonify({"status": "queued", "message": "Wait your turn", "position": len(server_queue)})

@app.route('/finished/<server_id>')
def finished(server_id):
    global active_servers
    
    if server_id in server_status:
        del server_status[server_id]
    
    active_servers = max(0, active_servers - 1)
    
    # Notify next in queue
    if server_queue:
        next_server = server_queue.pop(0)
        server_status[next_server] = "approved"
    
    return jsonify({"status": "ok"})

@app.route('/status')
def status():
    return jsonify({
        "active_servers": active_servers,
        "max_concurrent": max_concurrent,
        "queue": server_queue,
        "server_status": server_status
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000)
