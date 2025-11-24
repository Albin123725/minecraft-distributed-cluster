#!/usr/bin/env python3
import os
import glob
from gdrive_manager import GoogleDriveManager

def main():
    plugin_dir = './plugins'
    
    if not os.path.exists(plugin_dir):
        print(f"❌ Plugin directory not found: {plugin_dir}")
        os.makedirs(plugin_dir, exist_ok=True)
        return
    
    manager = GoogleDriveManager()
    
    try:
        folders = manager.ensure_folder_structure()
        plugin_files = glob.glob(os.path.join(plugin_dir, "*.jar"))
        
        if not plugin_files:
            print("❌ No .jar files found in plugins directory")
            return
        
        print(f"📤 Uploading {len(plugin_files)} plugins...")
        
        for plugin_path in plugin_files:
            plugin_name = os.path.basename(plugin_path)
            try:
                file_id = manager.upload_file(plugin_path, folders['plugins'], plugin_name)
                print(f"✅ Uploaded: {plugin_name} -> {file_id}")
            except Exception as e:
                print(f"❌ Failed to upload {plugin_name}: {e}")
        
        print("🎉 Plugin upload completed!")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == '__main__':
    main()
