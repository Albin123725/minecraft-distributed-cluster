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
        creds = None
        if os.path.exists(self.token_file):
            with open(self.token_file, 'rb') as token:
                creds = pickle.load(token)
        
        if not creds or not creds.valid:
            if creds and creds.expired and creds.refresh_token:
                creds.refresh(Request())
            else:
                flow = InstalledAppFlow.from_client_secrets_file(
                    self.credentials_file, 
                    ['https://www.googleapis.com/auth/drive.file']
                )
                creds = flow.run_local_server(port=0)
            
            with open(self.token_file, 'wb') as token:
                pickle.dump(creds, token)
        
        return build('drive', 'v3', credentials=creds)
    
    def get_folder_id(self, folder_name, parent_id=None):
        query = f"name='{folder_name}' and mimeType='application/vnd.google-apps.folder' and trashed=false"
        if parent_id:
            query += f" and '{parent_id}' in parents"
        
        results = self.service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
        files = results.get('files', [])
        return files[0]['id'] if files else None
    
    def ensure_folder_structure(self):
        main_id = self.get_folder_id('minecraft-cluster')
        if not main_id:
            folder_metadata = {
                'name': 'minecraft-cluster',
                'mimeType': 'application/vnd.google-apps.folder'
            }
            main_folder = self.service.files().create(body=folder_metadata, fields='id').execute()
            main_id = main_folder['id']
        
        folders = {'main': main_id}
        for folder_name in ['plugins', 'worlds', 'configs', 'backups', 'logs']:
            folder_id = self.get_folder_id(folder_name, main_id)
            if not folder_id:
                folder_metadata = {
                    'name': folder_name,
                    'mimeType': 'application/vnd.google-apps.folder',
                    'parents': [main_id]
                }
                folder = self.service.files().create(body=folder_metadata, fields='id').execute()
                folder_id = folder['id']
            folders[folder_name] = folder_id
        
        return folders
    
    def upload_file(self, file_path, folder_id, file_name=None):
        if not file_name:
            file_name = os.path.basename(file_path)
        
        query = f"name='{file_name}' and '{folder_id}' in parents and trashed=false"
        existing_files = self.service.files().list(q=query, fields='files(id)').execute().get('files', [])
        
        file_metadata = {'name': file_name, 'parents': [folder_id]}
        media = MediaFileUpload(file_path, resumable=True)
        
        if existing_files:
            file = self.service.files().update(
                fileId=existing_files[0]['id'],
                body=file_metadata,
                media_body=media
            ).execute()
            print(f"📤 Updated: {file_name}")
        else:
            file = self.service.files().create(
                body=file_metadata,
                media_body=media,
                fields='id'
            ).execute()
            print(f"📤 Uploaded: {file_name}")
        
        return file.get('id')
    
    def download_file(self, file_name, folder_id, download_path):
        query = f"name='{file_name}' and '{folder_id}' in parents and trashed=false"
        results = self.service.files().list(q=query, fields='files(id, name)').execute()
        files = results.get('files', [])
        
        if not files:
            print(f"❌ File not found: {file_name}")
            return False
        
        file_id = files[0]['id']
        request = self.service.files().get_media(fileId=file_id)
        fh = io.BytesIO()
        downloader = MediaIoBaseDownload(fh, request)
        done = False
        
        while not done:
            status, done = downloader.next_chunk()
            print(f"📥 Downloading {file_name}: {int(status.progress() * 100)}%")
        
        with open(download_path, 'wb') as f:
            f.write(fh.getvalue())
        
        print(f"✅ Downloaded: {file_name}")
        return True
    
    def list_files(self, folder_id):
        results = self.service.files().list(
            q=f"'{folder_id}' in parents and trashed=false",
            fields='files(id, name, mimeType, size, modifiedTime)'
        ).execute()
        return results.get('files', [])
    
    def download_folder_contents(self, folder_id, local_path):
        os.makedirs(local_path, exist_ok=True)
        files = self.list_files(folder_id)
        
        for file in files:
            if file['mimeType'] != 'application/vnd.google-apps.folder':
                local_file_path = os.path.join(local_path, file['name'])
                self.download_file(file['name'], folder_id, local_file_path)

def main():
    parser = argparse.ArgumentParser(description='Google Drive Manager')
    parser.add_argument('--setup', action='store_true', help='Setup folder structure')
    parser.add_argument('--upload', help='Upload a file')
    parser.add_argument('--download', help='Download a file')
    parser.add_argument('--download-folder', help='Download entire folder')
    parser.add_argument('--list', help='List files in folder')
    parser.add_argument('--folder', help='Folder name')
    
    args = parser.parse_args()
    manager = GoogleDriveManager()
    
    if args.setup:
        folders = manager.ensure_folder_structure()
        print("📁 Folder structure:")
        for name, fid in folders.items():
            print(f"   {name}: {fid}")
    
    elif args.upload and args.folder:
        folders = manager.ensure_folder_structure()
        if args.folder in folders:
            file_id = manager.upload_file(args.upload, folders[args.folder])
            print(f"✅ Uploaded to {args.folder}: {file_id}")
    
    elif args.download and args.folder:
        folders = manager.ensure_folder_structure()
        if args.folder in folders:
            success = manager.download_file(args.download, folders[args.folder], args.download)
            if success:
                print(f"✅ Downloaded: {args.download}")
    
    elif
