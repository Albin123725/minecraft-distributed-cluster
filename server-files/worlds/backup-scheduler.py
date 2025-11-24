#!/usr/bin/env python3
import schedule
import time
import subprocess
from datetime import datetime

def backup_job():
    """Scheduled backup job"""
    print(f"🕒 Running scheduled backup at {datetime.now()}")
    
    try:
        # Run backup manager
        result = subprocess.run([
            'python3', '/app/backup-manager.py', '--backup-worlds'
        ], capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✅ Backup completed successfully")
        else:
            print(f"❌ Backup failed: {result.stderr}")
            
    except Exception as e:
        print(f"❌ Backup error: {e}")

def main():
    """Main backup scheduler"""
    print("⏰ Starting Backup Scheduler")
    
    # Schedule backups
    schedule.every(6).hours.do(backup_job)  # Every 6 hours
    schedule.every().day.at("02:00").do(backup_job)  # Daily at 2 AM
    
    print("📅 Backup schedule:")
    print("   - Every 6 hours")
    print("   - Daily at 2:00 AM")
    
    while True:
        schedule.run_pending()
        time.sleep(60)  # Check every minute

if __name__ == '__main__':
    main()
