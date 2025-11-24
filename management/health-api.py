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
