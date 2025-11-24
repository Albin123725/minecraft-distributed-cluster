#!/usr/bin/env python3
from flask import Flask, jsonify, request
import requests
import time
import json

app = Flask(__name__)

# Store player data
player_data = {}

class PlayerManager:
    def __init__(self):
        self.players = {}
    
    def update_player_data(self, server_id, players):
        """Update player data for a specific server"""
        self.players[server_id] = {
            'players': players,
            'last_update': time.time(),
            'count': len(players)
        }
    
    def get_online_players(self):
        """Get all online players across all servers"""
        online_players = []
        total_count = 0
        
        for server_id, data in self.players.items():
            online_players.extend([
                {
                    'name': player,
                    'server': server_id,
                    'region': data.get('region', 'unknown')
                }
                for player in data['players']
            ])
            total_count += data['count']
        
        return {
            'total_players': total_count,
            'players': online_players
        }
    
    def get_player_distribution(self):
        """Get player distribution across servers"""
        distribution = {}
        
        for server_id, data in self.players.items():
            distribution[server_id] = {
                'count': data['count'],
                'region': data.get('region', 'unknown'),
                'last_update': data['last_update']
            }
        
        return distribution

player_manager = PlayerManager()

@app.route('/api/players/update', methods=['POST'])
def update_players():
    """Update player data from a game server"""
    data = request.json
    server_id = data.get('server_id')
    players = data.get('players', [])
    region = data.get('region', 'unknown')
    
    if server_id and players is not None:
        player_data = {
            'players': players,
            'region': region,
            'last_update': time.time()
        }
        player_manager.update_player_data(server_id, players)
        
        # Store in global player_data for health checks
        player_data[server_id] = player_data
        
        return jsonify({'status': 'updated'})
    
    return jsonify({'error': 'Invalid data'}), 400

@app.route('/api/players/online')
def get_online_players():
    """Get all online players"""
    return jsonify(player_manager.get_online_players())

@app.route('/api/players/distribution')
def get_player_distribution():
    """Get player distribution across servers"""
    return jsonify(player_manager.get_player_distribution())

@app.route('/api/players/count')
def get_player_count():
    """Get total player count"""
    online_data = player_manager.get_online_players()
    return jsonify({
        'total_players': online_data['total_players'],
        'timestamp': time.time()
    })

@app.route('/api/servers/<server_id>/players')
def get_server_players(server_id):
    """Get players for a specific server"""
    server_data = player_manager.players.get(server_id)
    if server_data:
        return jsonify({
            'server_id': server_id,
            'players': server_data['players'],
            'count': server_data['count'],
            'last_update': server_data['last_update']
        })
    else:
        return jsonify({'error': 'Server not found'}), 404

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5004)
