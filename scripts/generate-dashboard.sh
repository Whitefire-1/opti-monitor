#!/bin/bash
#######################################
# Opti-Monitor Dashboard Generator
# Creates a beautiful HTML dashboard
# Author: [Your Name]
#######################################

# Directories
SCRIPT_DIR="$HOME/opti-monitor/scripts"
REPORT_DIR="$HOME/opti-monitor/reports"
LOG_FILE="$HOME/opti-monitor/logs/health.log"
ALERT_LOG="$HOME/opti-monitor/alerts/alert-history.log"

# Get current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Get system metrics
get_cpu() {
    top -bn1 | grep "Cpu(s)" | awk '{print int($2)}'
}

get_memory() {
    free | awk 'NR==2 {printf "%.0f", $3*100/$2}'
}

get_disk() {
    df -h / | awk 'NR==2 {print $5}' | tr -d '%'
}

# Collect data
CPU=$(get_cpu)
MEM=$(get_memory)
DISK=$(get_disk)
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')
HOSTNAME=$(hostname)
IP_ADDR=$(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')
UPTIME=$(uptime -p 2>/dev/null || echo 'N/A')

# Determine overall status
if [ "$CPU" -ge 90 ] || [ "$MEM" -ge 90 ] || [ "$DISK" -ge 85 ]; then
    STATUS="CRITICAL"
    STATUS_COLOR="#dc3545"
    STATUS_ICON="🚨"
    STATUS_TEXT="Critical - Immediate Action Required"
elif [ "$CPU" -ge 70 ] || [ "$MEM" -ge 75 ] || [ "$DISK" -ge 70 ]; then
    STATUS="WARNING"
    STATUS_COLOR="#ffc107"
    STATUS_ICON="⚠️"
    STATUS_TEXT="Warning - Attention Needed"
else
    STATUS="HEALTHY"
    STATUS_COLOR="#28a745"
    STATUS_ICON="✅"
    STATUS_TEXT="All Systems Operational"
fi

# Determine bar colors
get_bar_class() {
    local value=$1
    if [ "$value" -lt 50 ]; then
        echo "bar-green"
    elif [ "$value" -lt 75 ]; then
        echo "bar-yellow"
    else
        echo "bar-red"
    fi
}

CPU_BAR_CLASS=$(get_bar_class $CPU)
MEM_BAR_CLASS=$(get_bar_class $MEM)
DISK_BAR_CLASS=$(get_bar_class $DISK)

# Get recent log entries
RECENT_LOGS=""
if [ -f "$LOG_FILE" ]; then
    while IFS= read -r line; do
        if echo "$line" | grep -q "CRITICAL"; then
            RECENT_LOGS+="<div class='log-entry log-critical'>$line</div>"
        elif echo "$line" | grep -q "WARNING"; then
            RECENT_LOGS+="<div class='log-entry log-warning'>$line</div>"
        else
            RECENT_LOGS+="<div class='log-entry log-healthy'>$line</div>"
        fi
    done < <(tail -10 "$LOG_FILE")
fi

if [ -z "$RECENT_LOGS" ]; then
    RECENT_LOGS="<div class='log-entry log-healthy'>No logs yet. Run health check first!</div>"
fi

# Create the HTML dashboard
cat > "$REPORT_DIR/dashboard.html" << HTMLEOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="refresh" content="60">
    <title>👁️ Opti-Monitor Dashboard</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: linear-gradient(135deg, #0f0f1e 0%, #1a1a3e 50%, #0f0f1e 100%);
            min-height: 100vh;
            color: #ffffff;
            padding: 20px;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
        }
        
        /* Header */
        header {
            text-align: center;
            padding: 40px 20px;
            margin-bottom: 30px;
        }
        
        .logo {
            font-size: 3em;
            margin-bottom: 10px;
        }
        
        header h1 {
            font-size: 2.5em;
            font-weight: 700;
            background: linear-gradient(90deg, #00d4ff, #7c3aed, #f472b6);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
            margin-bottom: 10px;
        }
        
        .subtitle {
            color: #a0a0a0;
            font-size: 1.1em;
            margin-bottom: 5px;
        }
        
        .timestamp {
            color: #666;
            font-size: 0.9em;
        }
        
        .refresh-badge {
            display: inline-block;
            background: rgba(0, 212, 255, 0.1);
            border: 1px solid rgba(0, 212, 255, 0.3);
            padding: 8px 16px;
            border-radius: 20px;
            font-size: 0.8em;
            color: #00d4ff;
            margin-top: 15px;
        }
        
        /* Status Banner */
        .status-banner {
            background: ${STATUS_COLOR};
            padding: 30px;
            border-radius: 20px;
            text-align: center;
            margin-bottom: 30px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        
        .status-banner .icon {
            font-size: 3em;
            margin-bottom: 10px;
        }
        
        .status-banner h2 {
            font-size: 1.5em;
            font-weight: 600;
        }
        
        /* Metrics Grid */
        .metrics-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 30px;
        }
        
        .metric-card {
            background: rgba(255, 255, 255, 0.03);
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 30px;
            transition: all 0.3s ease;
        }
        
        .metric-card:hover {
            transform: translateY(-5px);
            border-color: rgba(0, 212, 255, 0.3);
            box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
        }
        
        .metric-card .icon {
            font-size: 2em;
            margin-bottom: 15px;
        }
        
        .metric-card h3 {
            color: #a0a0a0;
            font-size: 0.9em;
            font-weight: 500;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 10px;
        }
.metric-card .value {
            font-size: 3em;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .metric-card .details {
            color: #666;
            font-size: 0.9em;
            margin-bottom: 20px;
        }
        
        /* Progress Bar */
        .progress-bar {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            height: 12px;
            overflow: hidden;
        }
        
        .progress-fill {
            height: 100%;
            border-radius: 10px;
            transition: width 0.5s ease;
        }
        
        .bar-green { background: linear-gradient(90deg, #28a745, #34ce57); }
        .bar-yellow { background: linear-gradient(90deg, #ffc107, #ffda6a); }
        .bar-red { background: linear-gradient(90deg, #dc3545, #f1aeb5); }
        
        /* System Info Card */
        .system-info {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .system-info h3 {
            color: #00d4ff;
            font-size: 1.2em;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
        }
        
        .info-item {
            padding: 15px;
            background: rgba(255, 255, 255, 0.02);
            border-radius: 10px;
        }
.info-item .label {
            color: #666;
            font-size: 0.8em;
            text-transform: uppercase;
            letter-spacing: 1px;
            margin-bottom: 5px;
        }
        
        .info-item .value {
            color: #fff;
            font-size: 1.1em;
            font-weight: 500;
        }
        
        /* Logs Section */
        .logs-section {
            background: rgba(255, 255, 255, 0.03);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .logs-section h3 {
            color: #00d4ff;
            font-size: 1.2em;
            margin-bottom: 20px;
        }
        
        .log-entry {
            padding: 12px 15px;
            border-radius: 8px;
            margin-bottom: 8px;
            font-family: 'Courier New', monospace;
            font-size: 0.85em;
            border-left: 4px solid;
        }
        
        .log-healthy {
            background: rgba(40, 167, 69, 0.1);
            border-left-color: #28a745;
        }
        
        .log-warning {
            background: rgba(255, 193, 7, 0.1);
            border-left-color: #ffc107;
        }
        
        .log-critical {
            background: rgba(220, 53, 69, 0.1);
            border-left-color: #dc3545;
        }
        
        /* Footer */
        footer {
            text-align: center;
            padding: 40px 20px;
            border-top: 1px solid rgba(255, 255, 255, 0.1);
            margin-top: 40px;
        }
        
        footer p {
            color: #666;
            margin-bottom: 10px;
        }
        
        footer a {
            color: #00d4ff;
            text-decoration: none;
        }
        
        footer a:hover {
            text-decoration: underline;
        }
        
        .author-badge {
            display: inline-block;
            background: linear-gradient(90deg, #7c3aed, #00d4ff);
            padding: 10px 25px;
            border-radius: 25px;
            font-weight: 500;
            margin-top: 15px;
        }

        /* Responsive */
        @media (max-width: 768px) {
            header h1 {
                font-size: 1.8em;
            }
            
            .metric-card .value {
                font-size: 2.5em;
            }
        }
 </style>
</head>
<body>
    <div class="container">
        <header>
            <div class="logo">👁️</div>
            <h1>Opti-Monitor Dashboard</h1>
            <p class="subtitle">Vision Care Eye Clinic - Server Health Monitoring</p>
            <p class="timestamp">Last Updated: ${TIMESTAMP}</p>
            <div class="refresh-badge">🔄 Auto-refreshes every 60 seconds</div>
        </header>
        
        <div class="status-banner">
            <div class="icon">${STATUS_ICON}</div>
            <h2>${STATUS_TEXT}</h2>
        </div>
        
        <div class="metrics-grid">
            <div class="metric-card">
                <div class="icon">💻</div>
                <h3>CPU Usage</h3>
                <div class="value">${CPU}%</div>
                <div class="details">Processing power utilization</div>
                <div class="progress-bar">
                    <div class="progress-fill ${CPU_BAR_CLASS}" style="width: ${CPU}%"></div>
                </div>
            </div>
            
            <div class="metric-card">
                <div class="icon">🧠</div>
                <h3>Memory Usage</h3>
                <div class="value">${MEM}%</div>
                <div class="details">${MEM_USED}MB used of ${MEM_TOTAL}MB</div>
                <div class="progress-bar">
                    <div class="progress-fill ${MEM_BAR_CLASS}" style="width: ${MEM}%"></div>
                </div>
            </div>
            
            <div class="metric-card">
                <div class="icon">💾</div>
                <h3>Disk Usage</h3>
                <div class="value">${DISK}%</div>
                <div class="details">${DISK_USED} used of ${DISK_TOTAL}</div>
                <div class="progress-bar">
                    <div class="progress-fill ${DISK_BAR_CLASS}" style="width: ${DISK}%"></div>
                </div>
            </div>
        </div>
        
        <div class="system-info">
            <h3>🖥️ System Information</h3>
            <div class="info-grid">
                <div class="info-item">
                    <div class="label">Hostname</div>
                    <div class="value">${HOSTNAME}</div>
                </div>
                <div class="info-item">
                    <div class="label">IP Address</div>
                    <div class="value">${IP_ADDR}</div>
                </div>
 <div class="info-item">
                    <div class="label">Uptime</div>
                    <div class="value">${UPTIME}</div>
                </div>
                <div class="info-item">
                    <div class="label">Status</div>
                    <div class="value">${STATUS}</div>
                </div>
            </div>
        </div>
        
        <div class="logs-section">
            <h3>📋 Recent Health Checks</h3>
            ${RECENT_LOGS}
        </div>
        
        <footer>
            <p>Opti-Monitor v1.0 - Server Monitoring for Healthcare</p>
            <p>Built with 💙 for WhiteFire Eye Clinic</p>
            <div class="author-badge">
                Created by [WhiteFire] | DevOps Engineer
            </div>
        </footer>
    </div>
</body>
</html>
HTMLEOF

echo "✅ Dashboard generated successfully!"
echo "📁 Location: $REPORT_DIR/dashboard.html"
echo ""
echo "To view in browser, run:"
echo "   explorer.exe \$(wslpath -w $REPORT_DIR/dashboard.html)"
