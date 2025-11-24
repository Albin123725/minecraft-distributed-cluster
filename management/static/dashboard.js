// Minecraft Cluster Dashboard JavaScript

class ClusterDashboard {
    constructor() {
        this.autoRefresh = true;
        this.refreshInterval = 30000; // 30 seconds
        this.init();
    }

    init() {
        this.loadDashboardData();
        this.setupEventListeners();
        this.startAutoRefresh();
        
        // Show welcome notification
        this.showNotification('Dashboard loaded successfully!', 'success');
    }

    setupEventListeners() {
        // Auto-refresh toggle
        const refreshToggle = document.getElementById('autoRefreshToggle');
        if (refreshToggle) {
            refreshToggle.addEventListener('change', (e) => {
                this.autoRefresh = e.target.checked;
                if (this.autoRefresh) {
                    this.startAutoRefresh();
                } else {
                    this.stopAutoRefresh();
                }
            });
        }

        // Manual refresh button
        const refreshBtn = document.getElementById('refreshBtn');
        if (refreshBtn) {
            refreshBtn.addEventListener('click', () => {
                this.loadDashboardData();
            });
        }

        // Server action buttons
        document.addEventListener('click', (e) => {
            if (e.target.classList.contains('server-action')) {
                this.handleServerAction(e.target);
            }
        });
    }

    async loadDashboardData() {
        try {
            // Show loading state
            this.setLoadingState(true);

            // Fetch data from multiple endpoints
            const [healthData, playerData, analyticsData] = await Promise.all([
                this.fetchHealthData(),
                this.fetchPlayerData(),
                this.fetchAnalyticsData()
            ]);

            this.updateDashboard(healthData, playerData, analyticsData);
            this.setLoadingState(false);

        } catch (error) {
            console.error('Error loading dashboard data:', error);
            this.showNotification('Failed to load dashboard data', 'error');
            this.setLoadingState(false);
        }
    }

    async fetchHealthData() {
        const response = await fetch('/api/health-status');
        return await response.json();
    }

    async fetchPlayerData() {
        const response = await fetch('/api/players/online');
        return await response.json();
    }

    async fetchAnalyticsData() {
        const response = await fetch('/api/analytics/data');
        return await response.json();
    }

    updateDashboard(healthData, playerData, analyticsData) {
        this.updateHealthStats(healthData);
        this.updatePlayerStats(playerData);
        this.updateServerList(healthData);
        this.updateCharts(analyticsData);
    }

    updateHealthStats(healthData) {
        // Update total servers
        const totalServersEl = document.getElementById('totalServers');
        if (totalServersEl) {
            totalServersEl.textContent = healthData.total_servers || 0;
        }

        // Update healthy servers
        const healthyServersEl = document.getElementById('healthyServers');
        if (healthyServersEl) {
            healthyServersEl.textContent = healthData.healthy_servers || 0;
        }

        // Update overall status
        const statusEl = document.getElementById('overallStatus');
        if (statusEl) {
            const allHealthy = healthData.healthy_servers === healthData.total_servers;
            statusEl.textContent = allHealthy ? 'All Systems Normal' : 'Issues Detected';
            statusEl.className = allHealthy ? 'status-healthy' : 'status-warning';
        }
    }

    updatePlayerStats(playerData) {
        // Update total players
        const totalPlayersEl = document.getElementById('totalPlayers');
        if (totalPlayersEl) {
            totalPlayersEl.textContent = playerData.total_players || 0;
        }

        // Update player distribution
        this.updatePlayerDistribution(playerData.players || []);
    }

    updatePlayerDistribution(players) {
        const distribution = {};
        players.forEach(player => {
            const server = player.server;
            distribution[server] = (distribution[server] || 0) + 1;
        });

        // Update distribution chart or list
        const distributionEl = document.getElementById('playerDistribution');
        if (distributionEl) {
            distributionEl.innerHTML = Object.entries(distribution)
                .map(([server, count]) => `
                    <div class="distribution-item">
                        <span class="server-name">${server}</span>
                        <span class="player-count">${count} players</span>
                    </div>
                `).join('');
        }
    }

    updateServerList(healthData) {
        const serverListEl = document.getElementById('serverList');
        if (!serverListEl) return;

        const servers = healthData.reports || {};
        
        serverListEl.innerHTML = Object.entries(servers)
            .map(([serverId, serverData]) => {
                const isHealthy = serverData.status === 'healthy';
                const playerCount = serverData.details?.player_count || 0;
                const region = serverData.region || 'unknown';
                
                return `
                    <div class="server-item">
                        <div class="server-info">
                            <div class="server-status ${isHealthy ? 'online' : 'offline'}"></div>
                            <div>
                                <div class="server-name">${serverId}</div>
                                <div class="server-region">${region}</div>
                            </div>
                        </div>
                        <div class="server-stats">
                            <div class="player-count">${playerCount}</div>
                            <div class="performance-indicator">
                                ${isHealthy ? '🟢 Online' : '🔴 Offline'}
                            </div>
                        </div>
                        <div class="server-actions">
                            <button class="btn btn-secondary server-action" data-server="${serverId}" data-action="restart">
                                Restart
                            </button>
                        </div>
                    </div>
                `;
            }).join('');
    }

    updateCharts(analyticsData) {
        // This would update various charts on the dashboard
        // Implementation depends on the charting library used
        console.log('Updating charts with:', analyticsData);
    }

    async handleServerAction(button) {
        const serverId = button.dataset.server;
        const action = button.dataset.action;

        try {
            button.disabled = true;
            button.textContent = 'Processing...';

            let endpoint = '';
            let method = 'POST';

            switch (action) {
                case 'restart':
                    endpoint = `/api/servers/${serverId}/restart`;
                    break;
                case 'stop':
                    endpoint = `/api/servers/${serverId}/stop`;
                    break;
                case 'start':
                    endpoint = `/api/servers/${serverId}/start`;
                    break;
            }

            const response = await fetch(endpoint, { method });
            const result = await response.json();

            if (response.ok) {
                this.showNotification(`Server ${action} initiated for ${serverId}`, 'success');
            } else {
                throw new Error(result.error || 'Action failed');
            }

        } catch (error) {
            this.showNotification(`Failed to ${action} server: ${error.message}`, 'error');
        } finally {
            button.disabled = false;
            button.textContent = this.getActionText(action);
        }
    }

    getActionText(action) {
        const actions = {
            'restart': 'Restart',
            'stop': 'Stop', 
            'start': 'Start'
        };
        return actions[action] || 'Action';
    }

    startAutoRefresh() {
        if (this.refreshTimer) {
            clearInterval(this.refreshTimer);
        }
        
        this.refreshTimer = setInterval(() => {
            if (this.autoRefresh) {
                this.loadDashboardData();
            }
        }, this.refreshInterval);
    }

    stopAutoRefresh() {
        if (this.refreshTimer) {
            clearInterval(this.refreshTimer);
            this.refreshTimer = null;
        }
    }

    setLoadingState(loading) {
        const loadingEl = document.getElementById('loadingIndicator');
        if (loadingEl) {
            loadingEl.style.display = loading ? 'block' : 'none';
        }

        const contentEl = document.getElementById('dashboardContent');
        if (contentEl) {
            contentEl.style.opacity = loading ? '0.5' : '1';
        }
    }

    showNotification(message, type = 'info') {
        // Create notification element
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <div class="notification-content">
                <span class="notification-message">${message}</span>
                <button class="notification-close">&times;</button>
            </div>
        `;

        // Add to page
        document.body.appendChild(notification);

        // Show notification
        setTimeout(() => notification.classList.add('show'), 100);

        // Close button handler
        notification.querySelector('.notification-close').addEventListener('click', () => {
            notification.classList.remove('show');
            setTimeout(() => notification.remove(), 300);
        });

        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (notification.parentNode) {
                notification.classList.remove('show');
                setTimeout(() => notification.remove(), 300);
            }
        }, 5000);
    }

    // Utility function for making API calls
    async apiCall(endpoint, options = {}) {
        const defaultOptions = {
            headers: {
                'Content-Type': 'application/json',
            },
        };

        const response = await fetch(endpoint, { ...defaultOptions, ...options });
        
        if (!response.ok) {
            throw new Error(`API call failed: ${response.statusText}`);
        }

        return await response.json();
    }
}

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new ClusterDashboard();
});

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ClusterDashboard;
}
