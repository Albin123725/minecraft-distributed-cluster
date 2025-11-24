
### **19. docs/TROUBLESHOOTING.md**
```markdown
# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### Service Deployment Issues

#### Services Not Starting
**Symptoms**: Services stuck in "Building" or "Failed" state

**Solutions**:
1. Check Render build logs
2. Verify Dockerfile syntax
3. Ensure all required files are present
4. Check environment variable formatting

```bash
# Check service status
curl https://mc-management.onrender.com/health

# View build logs in Render dashboard
