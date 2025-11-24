#!/usr/bin/env python3
from flask import Flask, render_template_string, jsonify
import time
from datetime import datetime, timedelta

app = Flask(__name__)

# Mock analytics data (in production, this would come from a database)
analytics_data = {
    'player_activity': {
        'last_24_hours': [45, 52, 48, 61, 55, 58, 62, 59, 53, 49, 56, 60],
        'last_7_days': [320, 345, 298, 367, 312, 389, 401]
    },
    'server_performance': {
        'cpu_usage': [45, 52, 48, 61, 55, 58, 62],
        'memory_usage': [65, 68, 62, 71, 66, 69, 72],
        'player_counts': [45, 52, 48, 61, 55, 58, 62]
    },
    'region_distribution': {
        'spawn': 15,
        'nether': 8,
        'end': 6,
        'wilderness': 25,
        'ocean': 12,
        'mountain': 10,
        'desert': 9,
        'forest': 10,
        'village': 5
    }
}

ANALYTICS_HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Cluster Analytics</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #1a1a1a; color: white; }
        .dashboard { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 20px; }
        .chart-container { background: #2a2a2a; padding: 20px; border-radius: 8px; }
        .stat-card { background: #2a2a2a; padding: 15px; border-radius: 8px; text-align: center; }
        .stat-value { font-size: 2em; font-weight: bold; color: #4CAF50; }
        .stat-label { color: #ccc; }
    </style>
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
</head>
<body>
    <h1>📊 Cluster Analytics Dashboard</h1>
    
    <div style="display: grid; grid-template-columns: repeat(4, 1fr); gap: 15px; margin-bottom: 20px;">
        <div class="stat-card">
            <div class="stat-value" id="totalPlayers">0</div>
            <div class="stat-label">Total Players</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="activeServers">0</div>
            <div class="stat-label">Active Servers</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="avgPerformance">0%</div>
            <div class="stat-label">Avg Performance</div>
        </div>
        <div class="stat-card">
            <div class="stat-value" id="uptime">99.9%</div>
            <div class="stat-label">Uptime</div>
        </div>
    </div>

    <div class="dashboard">
        <div class="chart-container">
            <h3>👥 Player Activity (24h)</h3>
            <canvas id="playerChart" width="400" height="200"></canvas>
        </div>
        
        <div class="chart-container">
            <h3>🌍 Region Distribution</h3>
            <canvas id="regionChart" width="400" height="200"></canvas>
        </div>
        
        <div class="chart-container">
            <h3>⚡ Server Performance</h3>
            <canvas id="performanceChart" width="400" height="200"></canvas>
        </div>
        
        <div class="chart-container">
            <h3>📈 Player Trends (7 days)</h3>
            <canvas id="trendChart" width="400" height="200"></canvas>
        </div>
    </div>

    <script>
    async function loadAnalytics() {
        const response = await fetch('/api/analytics/data');
        const data = await response.json();
        
        // Update stats
        document.getElementById('totalPlayers').textContent = data.total_players || 0;
        document.getElementById('activeServers').textContent = data.active_servers || 0;
        document.getElementById('avgPerformance').textContent = data.avg_performance || '0%';
        
        // Player activity chart
        new Chart(document.getElementById('playerChart'), {
            type: 'line',
            data: {
                labels: ['12AM', '2AM', '4AM', '6AM', '8AM', '10AM', '12PM', '2PM', '4PM', '6PM', '8PM', '10PM'],
                datasets: [{
                    label: 'Players Online',
                    data: data.player_activity.last_24_hours,
                    borderColor: '#4CAF50',
                    backgroundColor: 'rgba(76, 175, 80, 0.1)',
                    tension: 0.4
                }]
            }
        });
        
        // Region distribution chart
        new Chart(document.getElementById('regionChart'), {
            type: 'doughnut',
            data: {
                labels: Object.keys(data.region_distribution),
                datasets: [{
                    data: Object.values(data.region_distribution),
                    backgroundColor: [
                        '#4CAF50', '#2196F3', '#9C27B0', '#FF9800',
                        '#009688', '#795548', '#607D8B', '#E91E63'
                    ]
                }]
            }
        });
        
        // Performance chart
        new Chart(document.getElementById('performanceChart'), {
            type: 'bar',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [
                    {
                        label: 'CPU Usage %',
                        data: data.server_performance.cpu_usage,
                        backgroundColor: '#2196F3'
                    },
                    {
                        label: 'Memory Usage %',
                        data: data.server_performance.memory_usage,
                        backgroundColor: '#4CAF50'
                    }
                ]
            }
        });
        
        // Trend chart
        new Chart(document.getElementById('trendChart'), {
            type: 'line',
            data: {
                labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
                datasets: [{
                    label: 'Daily Players',
                    data: data.player_activity.last_7_days,
                    borderColor: '#FF9800',
                    backgroundColor: 'rgba(255, 152, 0, 0.1)',
                    tension: 0.4
                }]
            }
        });
    }
    
    // Load analytics on page load
    loadAnalytics();
    
    // Refresh every 30 seconds
    setInterval(loadAnalytics, 30000);
    </script>
</body>
</html>
'''

@app.route('/analytics')
def analytics_dashboard():
    return render_template_string(ANALYTICS_HTML)

@app.route('/api/analytics/data')
def get_analytics_data():
    """Get analytics data for charts"""
    # In production, this would fetch real data from databases/APIs
    return jsonify({
        'total_players': 62,
        'active_servers': 16,
        'avg_performance': '87%',
        'player_activity': analytics_data['player_activity'],
        'region_distribution': analytics_data['region_distribution'],
        'server_performance': analytics_data['server_performance']
    })

@app.route('/api/analytics/player-count')
def get_player_count_history():
    """Get historical player count data"""
    # Mock data - in production, this would come from a time-series database
    history = []
    base_time = time.time() - (24 * 3600)  # Last 24 hours
    
    for i in range(24):
        history.append({
            'timestamp': base_time + (i * 3600),
            'player_count': analytics_data['player_activity']['last_24_hours'][i % 12]
        })
    
    return jsonify({'history': history})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5005)
