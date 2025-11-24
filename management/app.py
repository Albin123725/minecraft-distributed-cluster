from flask import Flask, render_template, jsonify
import os

app = Flask(__name__)

@app.route('/')
def dashboard():
    servers = []
    
    # Auto-detect all 16 game servers
    for i in range(1, 17):
        server_name = f"mc-game-{i}"
        server_url = f"https://{server_name}.onrender.com"
        servers.append({
            'name': server_name,
            'url': server_url,
            'port': 25565 + i,
            'region': get_region_name(i),
            'status': 'Auto-configured'
        })
    
    return render_template('dashboard.html', 
                         servers=servers,
                         management_node="mc-management",
                         version="2.0.0",
                         total_ram="6GB",
                         total_players=320)

@app.route('/health')
def health():
    return jsonify({"status": "healthy", "service": "mc-management"})

# Render auto-detects health at root path
@app.route('/')
def root():
    return dashboard()

def get_region_name(server_num):
    regions = {
        1: "spawn", 2: "nether", 3: "end",
        4: "wilderness-1", 5: "wilderness-2", 6: "wilderness-3", 7: "wilderness-4",
        8: "ocean-1", 9: "ocean-2",
        10: "mountain-1", 11: "mountain-2",
        12: "desert-1", 13: "desert-2",
        14: "forest-1", 15: "forest-2",
        16: "village-1"
    }
    return regions.get(server_num, "unknown")

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=10000, debug=False)
