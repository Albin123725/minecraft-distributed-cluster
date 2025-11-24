#!/usr/bin/env python3
from flask import Flask, request, jsonify
import tempfile
import os
from gdrive_manager import GoogleDriveManager

app = Flask(__name__)

@app.route('/api/upload/plugin', methods=['POST'])
def upload_plugin():
    """Upload plugin to Google Drive via web interface"""
    if 'file' not in request.files:
        return jsonify({'error': 'No file provided'}), 400
    
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No file selected'}), 400
    
    if not file.filename.endswith('.jar'):
        return jsonify({'error': 'File must be a .jar plugin'}), 400
    
    # Create temporary file
    temp_dir = tempfile.mkdtemp()
    temp_path = os.path.join(temp_dir, file.filename)
    
    try:
        # Save uploaded file
        file.save(temp_path)
        
        # Upload to Google Drive
        manager = GoogleDriveManager()
        folders = manager.ensure_folder_structure()
        
        file_id = manager.upload_file(temp_path, folders['plugins'])
        
        return jsonify({
            'message': f'Plugin {file.filename} uploaded successfully!',
            'file_id': file_id,
            'download_url': f'https://drive.google.com/file/d/{file_id}/view'
        })
    
    except Exception as e:
        return jsonify({'error': f'Upload failed: {str(e)}'}), 500
    
    finally:
        # Clean up
        if os.path.exists(temp_path):
            os.remove(temp_path)
        if os.path.exists(temp_dir):
            os.rmdir(temp_dir)

@app.route('/api/plugins/list')
def list_plugins():
    """List all plugins in Google Drive"""
    try:
        manager = GoogleDriveManager()
        folders = manager.ensure_folder_structure()
        
        plugins = manager.list_files(folders['plugins'])
        
        plugin_list = []
        for plugin in plugins:
            plugin_list.append({
                'name': plugin['name'],
                'id': plugin['id'],
                'size': plugin.get('size', 0),
                'modified': plugin.get('modifiedTime', '')
            })
        
        return jsonify({'plugins': plugin_list})
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/backups/create', methods=['POST'])
def create_backup():
    """Trigger manual backup"""
    try:
        import subprocess
        result = subprocess.run([
            'python3', '/app/backup-manager.py', '--backup-worlds'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            return jsonify({'message': 'Backup created successfully'})
        else:
            return jsonify({'error': result.stderr}), 500
    
    except Exception as e:
        return jsonify({'error': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5003)
