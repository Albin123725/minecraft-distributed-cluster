#!/usr/bin/env python3
import os
import shutil
import json
from datetime import datetime

class WorldManager:
    def __init__(self):
        self.worlds_dir = '/app/worlds'
        self.backup_dir = '/app/backups'
        
    def list_worlds(self):
        """List all available worlds"""
        if not os.path.exists(self.worlds_dir):
            return []
        
        worlds = []
        for item in os.listdir(self.worlds_dir):
            world_path = os.path.join(self.worlds_dir, item)
            if os.path.isdir(world_path):
                size = self.get_folder_size(world_path)
                worlds.append({
                    'name': item,
                    'path': world_path,
                    'size': size,
                    'modified': datetime.fromtimestamp(os.path.getmtime(world_path))
                })
        return worlds
    
    def get_folder_size(self, folder_path):
        """Calculate folder size in MB"""
        total_size = 0
        for dirpath, dirnames, filenames in os.walk(folder_path):
            for filename in filenames:
                filepath = os.path.join(dirpath, filename)
                total_size += os.path.getsize(filepath)
        return round(total_size / (1024 * 1024), 2)
    
    def create_world_backup(self, world_name):
        """Create a backup of a specific world"""
        world_path = os.path.join(self.worlds_dir, world_name)
        if not os.path.exists(world_path):
            return False, "World not found"
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        backup_name = f"{world_name}_backup_{timestamp}"
        backup_path = os.path.join(self.backup_dir, backup_name)
        
        try:
            shutil.copytree(world_path, backup_path)
            return True, f"Backup created: {backup_name}"
        except Exception as e:
            return False, f"Backup failed: {str(e)}"
    
    def restore_world(self, backup_name, world_name):
        """Restore world from backup"""
        backup_path = os.path.join(self.backup_dir, backup_name)
        world_path = os.path.join(self.worlds_dir, world_name)
        
        if not os.path.exists(backup_path):
            return False, "Backup not found"
        
        try:
            # Remove existing world
            if os.path.exists(world_path):
                shutil.rmtree(world_path)
            
            # Restore from backup
            shutil.copytree(backup_path, world_path)
            return True, f"World restored: {world_name}"
        except Exception as e:
            return False, f"Restore failed: {str(e)}"

if __name__ == '__main__':
    manager = WorldManager()
    worlds = manager.list_worlds()
    print("🌍 Available Worlds:")
    for world in worlds:
        print(f"   📁 {world['name']} ({world['size']} MB)")
