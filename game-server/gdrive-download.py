#!/usr/bin/env python3
import os
import sys
import argparse

# Import from current directory
from gdrive_manager import GoogleDriveManager

def main():
    parser = argparse.ArgumentParser(description='Download files from Google Drive')
    parser.add_argument('--type', required=True, choices=['plugins', 'worlds', 'configs'])
    parser.add_argument('--folder-id', required=True)
    parser.add_argument('--output', required=True)
    
    args = parser.parse_args()
    
    os.makedirs(args.output, exist_ok=True)
    
    try:
        manager = GoogleDriveManager('/app/credentials.json', '/app/token.pickle')
        
        folders = manager.ensure_folder_structure()
        target_folder_id = folders.get(args.type)
        
        if not target_folder_id:
            print(f"❌ Folder not found: {args.type}")
            return
        
        files = manager.list_files(target_folder_id)
        print(f"📁 Found {len(files)} files in {args.type} folder")
        
        downloaded_count = 0
        for file in files:
            if file['mimeType'] != 'application/vnd.google-apps.folder':
                output_path = os.path.join(args.output, file['name'])
                print(f"📥 Downloading: {file['name']}")
                if manager.download_file(file['name'], target_folder_id, output_path):
                    downloaded_count += 1
        
        print(f"✅ Download completed: {downloaded_count} files for {args.type}")
        
    except Exception as e:
        print(f"❌ Error downloading {args.type}: {e}")

if __name__ == '__main__':
    main()
