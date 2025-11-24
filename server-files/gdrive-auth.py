#!/usr/bin/env python3
import os
import pickle
import base64
import json
from google.auth.transport.requests import Request
from google.oauth2.credentials import Credentials
from google_auth_oauthlib.flow import InstalledAppFlow
from googleapiclient.discovery import build

SCOPES = ['https://www.googleapis.com/auth/drive.file']

def main():
    print("🔐 Google Drive Authentication Setup")
    print("====================================")
    print()
    
    credentials_file = 'credentials.json'
    if not os.path.exists(credentials_file):
        print("❌ credentials.json not found!")
        print("💡 Download it from Google Cloud Console and save in server-files/")
        return
    
    print("✅ credentials.json found")
    print()
    
    creds = None
    token_file = 'token.pickle'
    
    if os.path.exists(token_file):
        with open(token_file, 'rb') as token:
            creds = pickle.load(token)
        print("✅ Loaded existing token")
    
    if not creds or not creds.valid:
        if creds and creds.expired and creds.refresh_token:
            print("🔄 Refreshing token...")
            creds.refresh(Request())
        else:
            print("🌐 Opening browser for authentication...")
            flow = InstalledAppFlow.from_client_secrets_file(credentials_file, SCOPES)
            creds = flow.run_local_server(port=0)
            print("✅ Authentication successful!")
        
        with open(token_file, 'wb') as token:
            pickle.dump(creds, token)
        print("✅ Token saved to token.pickle")
    
    try:
        service = build('drive', 'v3', credentials=creds)
        
        # Create folder structure
        query = "name='minecraft-cluster' and mimeType='application/vnd.google-apps.folder' and trashed=false"
        results = service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
        items = results.get('files', [])
        
        if items:
            folder_id = items[0]['id']
            print(f"✅ Using existing folder: {folder_id}")
        else:
            folder_metadata = {
                'name': 'minecraft-cluster',
                'mimeType': 'application/vnd.google-apps.folder'
            }
            folder = service.files().create(body=folder_metadata, fields='id').execute()
            folder_id = folder['id']
            print(f"✅ Created new folder: {folder_id}")
        
        # Create subfolders
        subfolders = ['plugins', 'worlds', 'configs', 'backups', 'logs']
        for folder_name in subfolders:
            query = f"name='{folder_name}' and '{folder_id}' in parents and mimeType='application/vnd.google-apps.folder' and trashed=false"
            results = service.files().list(q=query, spaces='drive', fields='files(id, name)').execute()
            items = results.get('files', [])
            
            if not items:
                folder_metadata = {
                    'name': folder_name,
                    'mimeType': 'application/vnd.google-apps.folder',
                    'parents': [folder_id]
                }
                subfolder_file = service.files().create(body=folder_metadata, fields='id').execute()
                print(f"✅ Created {folder_name} folder: {subfolder_file['id']}")
            else:
                print(f"✅ Found {folder_name} folder: {items[0]['id']}")
        
        print()
        print("🎉 Google Drive setup completed!")
        print()
        print("📋 Next Steps:")
        print(f"   1. Set GDRIVE_FOLDER_ID = {folder_id}")
        print()
        print("   2. Encode token for Render:")
        print("      python3 -c \"import base64; print(base64.b64encode(open('token.pickle','rb').read()).decode())\"")
        print()
        print("   3. Set secrets in Render dashboard")
        
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == '__main__':
    main()
