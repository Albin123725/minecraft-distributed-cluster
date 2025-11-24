
### **18. docs/MANAGEMENT.md**
```markdown
# 🛠️ Management Guide

## Web Dashboard

### Access Points
- **Main Dashboard**: `mc-management.onrender.com`
- **RCON Manager**: `mc-management.onrender.com:10000`
- **File Manager**: `mc-management.onrender.com/file-manager`
- **Analytics**: `mc-management.onrender.com/analytics`

### Dashboard Features

#### Server Monitoring
- Real-time server status
- Player counts per region
- Performance metrics
- Health indicators

#### RCON Control
- Execute commands on any server
- Quick command buttons
- Custom command input
- Response display

#### File Management
- Upload plugins via web interface
- Google Drive integration
- Automatic plugin distribution
- Backup management

## Common Operations

### Restarting Services

#### Individual Server
```bash
# Via RCON
./rcon-manager.py --server mc-game-1 --command "restart"

# Via Dashboard
# Use the restart button in server management
