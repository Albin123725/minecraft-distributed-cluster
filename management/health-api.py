#!/usr/bin/env python3
from flask import Flask, jsonify, request
import time

app = Flask(__name__)

health_reports = {}

@app.route('/health')
def health():
    return jsonify({
        'status': 'healthy',
        'service': 'health-api',
        'timestamp': time.time(),
        'reports_received': len(health_reports)
    })

@app.route('/api/health-report', methods=['POST'])
def receive_health_report():
    data = request.json
    node_id = data.get('node_id')
    
    if node_id:
        health_reports[node_id] = {
            **data,
            'last_update': time.time()
        }
        return jsonify({'status': 'received'})
    
    return jsonify({'error': 'Invalid data'}), 400

@app.route('/api/health-status')
def get_health_status():
    current_time = time.time()
    expired_nodes = [
        node_id for node_id, report in health_reports.items()
        if current_time - report['last_update'] > 300
    ]
    
    for node_id in expired_nodes:
        del health_reports[node_id]
    
    return jsonify({
        'total_servers': len(health_reports),
        'healthy_servers': len([r for r in health_reports.values() if r['status'] == 'healthy']),
        'reports': health_reports
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5002)
