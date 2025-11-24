#!/bin/bash

echo "🔐 Google Drive Setup for Minecraft Cluster v2.0"
echo "================================================"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📝 Google Drive API Setup Instructions${NC}"
echo ""

echo -e "${YELLOW}Step 1: Enable Google Drive API${NC}"
echo "   • Go to: https://console.developers.google.com/"
echo "   • Create project 'termux-479006' or select existing"
echo "   • Enable Google Drive API"
echo ""

echo -e "${YELLOW}Step 2: Create OAuth 2.0 Credentials${NC}"
echo "   • APIs & Services → Credentials"
echo "   • Create Credentials → OAuth 2.0 Client IDs"
echo "   • Application Type: Desktop Application"
echo "   • Name: Minecraft-Cluster-Manager"
echo ""

echo -e "${YELLOW}Step 3: Save Credentials${NC}"
echo "   • Save JSON file as: server-files/credentials.json"
echo ""

echo -e "${YELLOW}Step 4: Authenticate${NC}"
echo "   • Run: cd server-files && python3 gdrive-auth.py"
echo "   • Browser will open for authentication"
echo "   • Follow authorization prompts"
echo ""

echo -e "${YELLOW}Step 5: Set Render Secrets${NC}"
echo "   • Get folder ID from authentication output"
echo "   • Encode token: python3 -c \"import base64; print(base64.b64encode(open('server-files/token.pickle','rb').read()).decode())\""
echo "   • Set in Render dashboard:"
echo "     - GDRIVE_FOLDER_ID"
echo "     - GDRIVE_CREDENTIALS_JSON"
echo "     - GDRIVE_TOKEN_PICKLE"
echo ""

# Check current setup
if [ -f "server-files/credentials.json" ]; then
    echo -e "${GREEN}✅ credentials.json found${NC}"
    echo ""
    echo -e "${BLUE}🚀 Ready to authenticate! Run:${NC}"
    echo "cd server-files && python3 gdrive-auth.py"
else
    echo -e "${YELLOW}📁 Place credentials.json in server-files/ directory${NC}"
fi

echo ""
echo -e "${GREEN}💡 Your Client ID: 740511594522-ofu7utfiedtpemu0cg9ghommdqoicbjf.apps.googleusercontent.com${NC}"
