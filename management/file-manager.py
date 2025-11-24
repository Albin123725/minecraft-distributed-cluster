#!/usr/bin/env python3
from flask import Flask, render_template_string, jsonify

app = Flask(__name__)

FILE_MANAGER_HTML = '''
<!DOCTYPE html>
<html>
<head>
    <title>Minecraft File Manager</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #1a1a1a; color: white; }
        .file-manager { background: #2a2a2a; padding: 20px; border-radius: 8px; }
        .upload-area { border: 2px dashed #444; padding: 20px; text-align: center; margin: 10px 0; }
        .btn { padding: 10px 15px; background: #4CAF50; color: white; border: none; border-radius: 4px; cursor: pointer; margin: 5px; }
    </style>
</head>
<body>
    <h1>📁 Minecraft File Manager</h1>
    
    <div class="file-manager">
        <h3>📤 Upload Plugin to Google Drive</h3>
        <div class="upload-area">
            <input type="file" id="pluginFile" accept=".jar">
            <button class="btn" onclick="uploadPlugin()">Upload Plugin</button>
        </div>
        <p>📦 Plugins will be automatically downloaded by all game servers</p>
    </div>

    <script>
    async function uploadPlugin() {
        const fileInput = document.getElementById('pluginFile');
        if (!fileInput.files.length) {
            alert('Please select a plugin file (.jar)');
            return;
        }
        
        const formData = new FormData();
        formData.append('plugin', fileInput.files[0]);
        
        try {
            const response = await fetch('/api/gdrive/upload-plugin', {
                method: 'POST',
                body: formData
            });
            
            const result = await response.json();
            alert(result.message || 'Upload successful!');
            fileInput.value = '';
        } catch (error) {
            alert('Upload failed: ' + error);
        }
    }
    </script>
</body>
</html>
'''

@app.route('/file-manager')
def file_manager():
    return render_template_string(FILE_MANAGER_HTML)

@app.route('/api/gdrive/upload-plugin', methods=['POST'])
def upload_plugin():
    return jsonify({'message': 'Plugin upload would be processed via Google Drive'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
