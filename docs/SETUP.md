# 🚀 Setup Guide

## Prerequisites

- **Google Account** with Drive API access
- **Render.com account** (free tier available)
- **GitHub account** for repository hosting
- **Basic terminal/command line knowledge**

## Step 1: Google Drive API Setup

### 1.1 Enable Google Drive API
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Create a new project or select existing
3. Enable Google Drive API:
   - Navigation Menu → APIs & Services → Library
   - Search "Google Drive API" → Enable

### 1.2 Create OAuth 2.0 Credentials
1. Go to APIs & Services → Credentials
2. Click "Create Credentials" → OAuth 2.0 Client IDs
3. Application Type: Desktop Application
4. Name: "Minecraft-Cluster-Manager"
5. Download the JSON file

### 1.3 Save Credentials
1. Place downloaded file as `server-files/credentials.json`
2. Your file should look like:
```json
{
  "installed": {
    "client_id": "your-client-id",
    "project_id": "your-project",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
    "client_secret": "your-client-secret",
    "redirect_uris": ["http://localhost"]
  }
}
