#!/bin/bash
#######################################
# Setup Automatic Monitoring
#######################################

PROJECT_DIR="$HOME/opti-monitor"

echo "🔧 Setting up automated monitoring..."
echo ""

# Create cron job entries
CRON_JOBS="
# Opti-Monitor: Run health check every 5 minutes
*/5 * * * * $PROJECT_DIR/scripts/health-check.sh >> $PROJECT_DIR/logs/cron.log 2>&1

# Opti-Monitor: Update dashboard every 10 minutes
*/10 * * * * $PROJECT_DIR/scripts/generate-dashboard.sh >> $PROJECT_DIR/logs/cron.log 2>&1
"

# Check if already set up
if crontab -l 2>/dev/null | grep -q "Opti-Monitor"; then
    echo "⚠️  Automation already configured!"
    echo ""
    echo "Current schedule:"
    crontab -l | grep "Opti-Monitor" -A1
else
    # Add to crontab
    (crontab -l 2>/dev/null; echo "$CRON_JOBS") | crontab -
    echo "✅ Automation configured successfully!"
    echo ""
    echo "Your server will now be monitored automatically:"
    echo "  • Health check runs every 5 minutes"
    echo "  • Dashboard updates every 10 minutes"
fi

echo ""
echo "To remove automation later, run: crontab -e"
