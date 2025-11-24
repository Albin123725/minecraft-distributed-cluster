#!/usr/bin/env python3
import os
import pickle
import argparse
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build
from googleapiclient.http import MediaFileUpload, MediaIoBaseDownload
import io

class GoogleDriveManager:
    def __init__(self, credentials_file='credentials.json', token_file='token.pickle'):
        self.credentials_file = credentials_file
        self.token_file = token_file
        self.service = self.authenticate()
    
    def authenticate(self):
        """Authenticate with Google Drive API"""
        creds = None
        
        # Load existing token
        if os.path.exists(self.token_file):
            with open(self.token_file, 'rb') as token:
                creds = pickle.load(token)
            print(f"✅ Loaded authentication token from {self.token_file}")
        
        # If there are no (valid) credentials available, let the user log in.
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                print("🔄 Refreshing expired token...")
                creds.refresh(Request())
                print("✅ Token refreshed successfully")
            else:
                if not os.path.exists(self.credentials_file):
                    raise FileNotFoundError(f"Credentials file not found: {self.credentials_file}")
                
                print("🌐 Starting OAuth flow...")
                flow = InstalledAppFlow.from_client_secrets_file(
                    self.credentials_file, 
                    ['https://www.googleapis.com/auth/drive.file']
                )
                creds = flow.run_local_server(port=0)
                print("✅ OAuth authentication successful")
            
            # Save the credentials for the next run
            with open(self.token_file, 'wb') as token:
                pickle.dump(creds, token)
            print(f"✅ Saved authentication token to {self.token_file}")
        
        return build('drive', 'v3', credentials=creds)
    
    def get_folder_id(self, folder_name, parent_id=None):
        """Find a folder by name"""
        query = f"name='{folder_name}' and mimeType='application/vnd.google-apps.folder' and trashed=false"
        if parent_id:
            query += f" and '{parent_id}' in parents"
        
        results = self.service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
        files = results.get('files', [])
        return files[0]['id'] if files else None
    
    def ensure_folder_structure(self):
        """Ensure the required folder structure exists"""
        print("📁 Ensuring folder structure...")
        
        # Check if main folder exists
        main_id = self.get_folder_id('minecraft-cluster')
        if not main_id:
            folder_metadata = {
                'name': 'minecraft-cluster',
                'mimeType': 'application/vnd.google-apps.folder',
                'description': 'Minecraft Distributed Cluster Files'
            }
            main_folder = self.service.files().create(body=folder_metadata, fields='id').execute()
            main_id = main_folder['id']
            print(f"✅ Created main folder: {main_id}")
        else:
            print(f"✅ Using existing main folder: {main_id}")
        
        # Create subfolders
        folders = {
            'main': main_id,
            'plugins': self.get_or_create_folder('plugins', main_id, 'Minecraft Server Plugins'),
            'worlds': self.get_or_create_folder('worlds', main_id, 'Minecraft World Backups'),
            'configs': self.get_or_create_folder('configs', main_id, 'Server Configuration Files'),
            'backups': self.get_or_create_folder('backups', main_id, 'Automatic Server Backups'),
            'logs': self.get_or_create_folder('logs', main_id, 'Server Log Files')
        }
        
        return folders
    
    def get_or_create_folder(self, folder_name, parent_id, description=""):
        """Get existing folder or create new one"""
        folder_id = self.get_folder_id(folder_name, parent_id)
        if folder_id:
            print(f"✅ Found {folder_name} folder: {folder_id}")
            return folder_id
        else:
            folder_metadata = {
                'name': folder_name,
                'mimeType': 'application/vnd.google-apps.folder',
                'parents': [parent_id],
                'description': description
            }
            folder = self.service.files().create(body=folder_metadata, fields='id').execute()
            print(f"✅ Created {folder_name} folder: {folder['id']}")
            return folder['id']
    
    def upload_file(self, file_path, folder_id, file_name=None):
        """Upload a file to Google Drive"""
        if not file_name:
            file_name = os.path.basename(file_path)
        
        if not os.path.exists(file_path):
            raise FileNotFoundError(f"File not found: {file_path}")
        
        # Check if file already exists
        query = f"name='{file_name}' and '{folder_id}' in parents and trashed=false"
        existing_files = self.service.files().list(q=query, fields='files(id)').execute().get('files', [])
        
        file_metadata = {
            'name': file_name,
            'parents': [folder_id]
        }
        
        media = MediaFileUpload(file_path, resumable=True)
        
        try:
            if existing_files:
                # Update existing file
                file_id = existing_files[0]['id']
                file = self.service.files().update(
                    fileId=file_id,
                    body=file_metadata,
                    media_body=media
                ).execute()
                print(f"📤 Updated: {file_name} -> {file_id}")
            else:
                # Create new file
                file = self.service.files().create(
                    body=file_metadata,
                    media_body=media,
                    fields='id'
                ).execute()
                print(f"📤 Uploaded: {file_name} -> {file.get('id')}")
            
            return file.get('id')
            
        except Exception as e:
            print(f"❌ Failed to upload {file_name}: {e}")
            raise
    
    def download_file(self, file_name, folder_id, download_path):
        """Download a file from Google Drive"""
        query = f"name='{file_name}' and '{folder_id}' in parents and trashed=false"
        results = self.service.files().list(q=query, fields='files(id, name)').execute()
        files = results.get('files', [])
        
        if not files:
            print(f"❌ File not found: {file_name}")
            return False
        
        file_id = files[0]['id']
        
        try:
            request = self.service.files().get_media(fileId=file_id)
            fh = io.BytesIO()
            downloader = MediaIoBaseDownload(fh, request)
            done = False
            
            while not done:
                status, done = downloader.next_chunk()
                if status:
                    print(f"📥 Downloading {file_name}: {int(status.progress() * 100)}%")
            
            # Ensure directory exists
            os.makedirs(os.path.dirname(download_path), exist_ok=True)
            
            with open(download_path, 'wb') as f:
                f.write(fh.getvalue())
            
            print(f"✅ Downloaded: {file_name} -> {download_path}")
            return True
            
        except Exception as e:
            print(f"❌ Failed to download {file_name}: {e}")
            return False
    
    def list_files(self, folder_id):
        """List all files in a folder"""
        results = self.service.files().list(
            q=f"'{folder_id}' in parents and trashed=false",
            fields='files(id, name, mimeType, size, modifiedTime)',
            orderBy='name'
        ).execute()
        return results.get('files', [])
    
    def download_folder_contents(self, folder_id, local_path):
        """Download all files from a folder"""
        files = self.list_files(folder_id)
        
        if not files:
            print(f"📁 No files found in folder")
            return
        
        print(f"📥 Downloading {len(files)} files to {local_path}")
        
        downloaded_count = 0
        for file in files:
            if file['mimeType'] != 'application/vnd.google-apps.folder':  # Skip subfolders
                local_file_path = os.path.join(local_path, file['name'])
                if self.download_file(file['name'], folder_id, local_file_path):
                    downloaded_count += 1
        
        print(f"✅ Downloaded {downloaded_count} files")

def main():
    parser = argparse.ArgumentParser(description='Google Drive Manager for Minecraft Cluster')
    parser.add_argument('--setup', action='store_true', help='Setup folder structure')
    parser.add_argument('--upload', help='Upload a file')
    parser.add_argument('--download', help='Download a file')
    parser.add_argument('--download-folder', help='Download entire folder contents')
    parser.add_argument('--list', help='List files in folder')
    parser.add_argument('--folder', help='Folder name (plugins, worlds, configs, backups, logs)')
    
    args = parser.parse_args()
    
    try:
        manager = GoogleDriveManager()
        
        if args.setup:
            folders = manager.ensure_folder_structure()
            print("\n📁 Folder structure complete:")
            for name, fid in folders.items():
                print(f"   {name}: {fid}")
        
        elif args.upload and args.folder:
            folders = manager.ensure_folder_structure()
            if args.folder in folders:
                file_id = manager.upload_file(args.upload, folders[args.folder])
                print(f"✅ Uploaded to {args.folder}: {file_id}")
            else:
                print(f"❌ Unknown folder: {args.folder}")
        
        elif args.download and args.folder:
            folders = manager.ensure_folder_structure()
            if args.folder in folders:
                success = manager.download_file(args.download, folders[args.folder], args.download)
                if success:
                    print(f"✅ Downloaded: {args.download}")
            else:
                print(f"❌ Unknown folder: {args.folder}")
        
        elif args.download_folder and args.folder:
            folders = manager.ensure_folder_structure()
            if args.folder in folders:
                print(f"📥 Downloading entire {args.folder} folder...")
                manager.download_folder_contents(folders[args.folder], f"./{args.folder}")
                print(f"✅ Downloaded {args.folder} folder contents")
            else:
                print(f"❌ Unknown folder: {args.folder}")
        
        elif args.list and args.folder:
            folders = manager.ensure_folder_structure()
            if args.folder in folders:
                files = manager.list_files(folders[args.folder])
                print(f"📁 Files in {args.folder} ({len(files)} total):")
                for file in files:
                    size = f"{int(file.get('size', 0) / 1024):.1f}KB" if file.get('size') else "N/A"
                    print(f"   📄 {file['name']} ({size}) - {file['id']}")
            else:
                print(f"❌ Unknown folder: {args.folder}")
        
        else:
            parser.print_help()
    
    except Exception as e:
        print(f"❌ Error: {e}")
        exit(1)

if __name__ == '__main__':
    main()
