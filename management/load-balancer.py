from flask import Flask, jsonify
import time
import requests

app = Flask(__name__)

# Server status tracking
server_capacity = {}
server_tasks = {}
task_queue = []

# Capacity levels (0-100)
def calculate_server_capacity(server_id):
    # Simulate checking server health (in real implementation, ping servers)
    if server_id in server_tasks:
        current_load = len(server_tasks[server_id])
        capacity = max(0, 100 - (current_load * 25))  # Each task uses 25% capacity
    else:
        capacity = 100  # No tasks = full capacity
    return capacity

@app.route('/assign_task/<task_type>/<server_id>')
def assign_task(task_type, server_id):
    # Check if server can handle more work
    capacity = calculate_server_capacity(server_id)
    
    if capacity >= 25:  # Need at least 25% capacity for a task
        if server_id not in server_tasks:
            server_tasks[server_id] = []
        server_tasks[server_id].append(task_type)
        return jsonify({
            "status": "assigned", 
            "task": task_type,
            "assigned_to": server_id,
            "capacity_remaining": capacity - 25
        })
    else:
        # Find another server with capacity
        for other_server in ['game-1', 'game-2', 'game-3', 'game-4', 'game-5', 'game-6', 'game-7', 'game-8', 
                           'game-9', 'game-10', 'game-11', 'game-12', 'game-13', 'game-14', 'game-15', 'game-16']:
            if other_server != server_id and calculate_server_capacity(other_server) >= 25:
                server_tasks[other_server].append(task_type)
                return jsonify({
                    "status": "redirected", 
                    "task": task_type,
                    "assigned_to": other_server,
                    "original_server": server_id,
                    "reason": "Low capacity"
                })
        
        # No servers available, add to queue
        task_queue.append({"task": task_type, "requested_by": server_id})
        return jsonify({
            "status": "queued",
            "position": len(task_queue),
            "reason": "No servers with capacity"
        })

@app.route('/task_completed/<server_id>/<task_type>')
def task_completed(server_id, task_type):
    if server_id in server_tasks and task_type in server_tasks[server_id]:
        server_tasks[server_id].remove(task_type)
    
    # Process queued tasks if any
    if task_queue:
        next_task = task_queue.pop(0)
        # Try to assign to any available server
        for server in ['game-1', 'game-2', 'game-3', 'game-4', 'game-5', 'game-6', 'game-7', 'game-8', 
                      'game-9', 'game-10', 'game-11', 'game-12', 'game-13', 'game-14', 'game-15', 'game-16']:
            if calculate_server_capacity(server) >= 25:
                if server not in server_tasks:
                    server_tasks[server] = []
                server_tasks[server].append(next_task['task'])
                break
    
    return jsonify({"status": "completed", "tasks_remaining": len(task_queue)})

@app.route('/server_status')
def server_status():
    status = {}
    for server in ['game-1', 'game-2', 'game-3', 'game-4', 'game-5', 'game-6', 'game-7', 'game-8', 
                  'game-9', 'game-10', 'game-11', 'game-12', 'game-13', 'game-14', 'game-15', 'game-16']:
        status[server] = {
            "capacity": calculate_server_capacity(server),
            "current_tasks": server_tasks.get(server, []),
            "can_accept_work": calculate_server_capacity(server) >= 25
        }
    return jsonify(status)

@app.route('/')
def dashboard():
    return """
    <h1>🎮 Minecraft Cluster Load Balancer</h1>
    <p><a href="/server_status">View Server Status</a></p>
    <p>Auto-distribution: Work automatically moves from overloaded to available servers</p>
    """
