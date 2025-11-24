#!/usr/bin/env python3
import time
import requests
import os
from datetime import datetime

class HealthMonitor:
    def __init__(self):
        self.management_url = os.environ.get('MANAGEMENT_URL', 'http://mc-management.onrender.com')
    
    def report_health(self, node_id, region, status, details=None):
        health_data = {
            'node_id': node_id,
            'region': region,
            'status': status,
            'timestamp': datetime.now().isoformat(),
            'details': details or {}
        }
        
        try:
            response = requests.post(
                f"{self.management_url}/api/health-report",
                json=health_data,
                timeout=10
            )
            return response.status_code == 200
        except:
            return False
    
    def monitor_loop(self):
        node_id = os.environ.get('NODE_ID', 'unknown')
        region = os.environ.get('WORLD_REGION', 'unknown')
        
        while True:
            health_status = "healthy"
            details = {
                'disk_usage': self.check_disk_usage(),
                'service_running': self.check_service_running()
            }
            
            self.report_health(node_id, region, health_status, details)
            time.sleep(60)
    
    def check_disk_usage(self):
        try:
            stat = os.statvfs('/app')
            total = stat.f_blocks * stat.f_frsize
            used = (stat.f_blocks - stat.f_bfree) * stat.f_frsize
            return f"{(used/total)*100:.1f}%"
        except:
            return "unknown"
    
    def check_service_running(self):
        try:
            import subprocess
            result = subprocess.run(['pgrep', '-f', 'paper.jar'], capture_output=True)
            return result.returncode == 0
        except:
            return False

if __name__ == '__main__':
    monitor = HealthMonitor()
    monitor.monitor_loop()
