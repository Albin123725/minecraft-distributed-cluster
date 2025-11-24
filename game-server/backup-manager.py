#!/usr/bin/env python3
import os
import zipfile
import tempfile
import argparse
from datetime import datetime

# Import from current directory
from gdrive_manager import GoogleDriveManager

def backup_worlds():
    worlds_dir = '/app/worlds'
    
    if not os.path.exists(worlds_dir):
        print("❌ Worlds directory not found")
        return
    
    manager = GoogleDriveManager()
    folders = manager.ensure_folder_structure()
    
    world_folders = [f for f in os.listdir(worlds_dir) 
                    if os.path.isdir(os.path.join(worlds_dir, f)) and f.startswith('world')]
    
    if not world_folders:
        print("🌍 No world folders found")
        return
    
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    for world_name in world_folders:
        world_path = os.path.join(worlds_dir, world_name)
        backup_name = f"{world_name}_backup_{timestamp}.zip"
        
        print(f"💾 Creating backup: {backup_name}")
        
        with tempfile.NamedTemporaryFile(suffix='.zip', delete=False) as temp_zip:
            zip_path = temp_zip.name
        
        try:
            with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
                for root, dirs, files in os.walk(world_path):
                    for file in files:
                        file_path = os.path.join(root, file)
                        arcname = os.path.relpath(file_path, worlds_dir)
                        zipf.write(file_path, arcname)
            
            file_id = manager.upload_file(zip_path, folders['backups'], backup_name)
            print(f"✅ Backup uploaded: {backup_name} -> {file_id}")
            
        except Exception as e:
            print(f"❌ Failed to backup {world_name}: {e}")
        
        finally:
            if os.path.exists(zip_path):
                os.remove(zip_path)

def main():
    parser = argparse.ArgumentParser(description='Backup Manager')
    parser.add_argument('--backup-worlds', action='store_true', help='Backup all worlds')
    
    args = parser.parse_args()
    
    if args.backup_worlds:
        backup_worlds()
    else:
        parser.print_help()

if __name__ == '__main__':
    main()
