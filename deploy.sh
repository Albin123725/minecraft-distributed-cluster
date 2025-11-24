#!/bin/bash

echo "🚀 Minecraft Distributed Cluster Deployer v2.0"
echo "=============================================="

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠️${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_info() { echo -e "${BLUE}ℹ️${NC} $1"; }

check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v git &> /dev/null; then
        print_error "Git is required but not installed"
        exit 1
    fi
    
    if ! command -v docker &> /dev/null; then
        print_warning "Docker not found, but Render will handle Docker builds"
    fi
    
    print_status "Dependencies checked"
}

validate_config() {
    print_status "Validating configuration..."
    
    if [ ! -f "render.yaml" ]; then
        print_error "render.yaml not found!"
        exit 1
    fi
    
    if [ ! -f "server-files/credentials.json" ]; then
        print_warning "credentials.json not found in server-files/"
    fi
    
    if [ ! -f "game-server/Dockerfile" ]; then
        print_error "Game server Dockerfile not found!"
        exit 1
    fi
    
    print_status "Configuration validated"
}

check_gdrive_setup() {
    print_status "Checking Google Drive setup..."
    
    if [ ! -f "server-files/credentials.json" ]; then
        print_warning "Google Drive credentials not found"
        echo ""
        print_info "Before deploying, please complete:"
        echo "  1. Run: ./gdrive-setup.sh"
        echo "  2. Download credentials.json to server-files/"
        echo "  3. Run: cd server-files && python3 gdrive-auth.py"
        echo "  4. Set secrets in Render dashboard"
        echo ""
        read -p "Continue without Google Drive? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_error "Deployment cancelled"
            exit 1
        fi
    else
        print_status "Google Drive credentials found"
    fi
}

deploy_to_render() {
    print_status "Starting deployment to Render..."
    
    if command -v render &> /dev/null; then
        print_status "Using Render CLI"
        render deploy
    else
        print_warning "Render CLI not found"
        echo ""
        print_info "Manual deployment steps:"
        echo "  1. Push to GitHub:"
        echo "     git add ."
        echo "     git commit -m 'Deploy Minecraft Cluster v2.0'"
        echo "     git push origin main"
        echo "  2. Connect repository to Render"
        echo "  3. Set secrets in Render dashboard:"
        echo "     - GDRIVE_FOLDER_ID"
        echo "     - GDRIVE_CREDENTIALS_JSON"
        echo "     - GDRIVE_TOKEN_PICKLE"
        echo "  4. Deploy services"
        echo ""
        echo "🔗 Render Dashboard: https://dashboard.render.com"
    fi
}

main() {
    echo ""
    echo "🎮 Minecraft Distributed Cluster v2.0"
    echo "=============================================="
    echo "This will deploy:"
    echo "   • 1 Proxy Server (BungeeCord)"
    echo "   • 16 Game Servers (PaperMC 1.21.10)"
    echo "   • 1 Management Dashboard"
    echo "   • Google Drive Integration"
    echo ""
    
    check_dependencies
    validate_config
    check_gdrive_setup
    
    echo ""
    read -p "🚀 Start deployment? (y/n): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        deploy_to_render
        
        echo ""
        print_status "Deployment initiated!"
        echo ""
        echo "📊 Monitor at: https://dashboard.render.com"
        echo "🎮 Connect to: mc-proxy-main.onrender.com:25565"
        echo "🖥️  Dashboard: mc-management.onrender.com"
        echo ""
        echo "⏰ Services will be available in 5-10 minutes"
    else
        print_error "Deployment cancelled"
    fi
}

main "$@"
