#!/bin/bash
#######################################
# Opti-Monitor Health Check Script
#######################################
# Author: [WhiteFire]
A simple server monitoring tool
#######################################

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color
# Get current time
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Where to save logs
LOG_FILE="$HOME/opti-monitor/logs/health.log"
ALERT_LOG="$HOME/opti-monitor/alerts/alert-history.log"

# Create log files if they don't exist
touch "$LOG_FILE" 2>/dev/null
touch "$ALERT_LOG" 2>/dev/null

# Thresholds
CPU_WARNING=70
MEMORY_WARNING=75
DISK_WARNING=70

#######################################
# FUNCTIONS
#######################################

# Function to get CPU usage
get_cpu() {
    # This works on most Linux systems
    top -bn1 | grep "Cpu(s)" | awk '{print int($2)}'
}

# Function to get memory usage
get_memory() {
    free | awk 'NR==2 {printf "%.0f", $3*100/$2}'
}

# Function to get disk usage
get_disk() {
    df -h / | awk 'NR==2 {print $5}' | tr -d '%'
}

# Function to create a visual bar
make_bar() {
    local percent=$1
    local width=30
    local filled=$((percent * width / 100))
    local empty=$((width - filled))
    
    printf "["
    for ((i=0; i<filled; i++)); do printf "█"; done
    for ((i=0; i<empty; i++)); do printf "░"; done
    printf "]"
}

#######################################
# MAIN SCRIPT
#######################################

# Clear screen for fresh look
clear

# Print header
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   👁️  OPTI-MONITOR - Eye Clinic Server Health Check${NC}"
echo -e "${BLUE}   📅  $TIMESTAMP${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Track overall status
OVERALL="HEALTHY"
ISSUES=()

#######################################
# CPU CHECK
#######################################
echo -e "${BLUE}▶ CPU USAGE${NC}"
CPU=$(get_cpu)

if [ -z "$CPU" ]; then
    CPU=0
fi

if [ "$CPU" -ge 90 ]; then
    echo -e "  Current: ${RED}${CPU}%${NC} [CRITICAL!]"
    OVERALL="CRITICAL"
    ISSUES+=("CPU at ${CPU}%")
elif [ "$CPU" -ge "$CPU_WARNING" ]; then
    echo -e "  Current: ${YELLOW}${CPU}%${NC} [WARNING]"
    OVERALL="WARNING"
    ISSUES+=("CPU at ${CPU}%")
else
    echo -e "  Current: ${GREEN}${CPU}%${NC} [OK]"
fi
echo "  $(make_bar $CPU)"
echo ""

#######################################
# MEMORY CHECK
#######################################
echo -e "${BLUE}▶ MEMORY USAGE${NC}"
MEM=$(get_memory)
MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
MEM_USED=$(free -m | awk 'NR==2 {print $3}')

if [ "$MEM" -ge 90 ]; then
    echo -e "  Current: ${RED}${MEM}%${NC} (${MEM_USED}MB / ${MEM_TOTAL}MB) [CRITICAL!]"
    OVERALL="CRITICAL"
    ISSUES+=("Memory at ${MEM}%")
elif [ "$MEM" -ge "$MEMORY_WARNING" ]; then
    echo -e "  Current: ${YELLOW}${MEM}%${NC} (${MEM_USED}MB / ${MEM_TOTAL}MB) [WARNING]"
    [ "$OVERALL" != "CRITICAL" ] && OVERALL="WARNING"
    ISSUES+=("Memory at ${MEM}%")
else
    echo -e "  Current: ${GREEN}${MEM}%${NC} (${MEM_USED}MB / ${MEM_TOTAL}MB) [OK]"
fi
echo "  $(make_bar $MEM)"
echo ""

#######################################
# DISK CHECK
#######################################
echo -e "${BLUE}▶ DISK USAGE${NC}"
DISK=$(get_disk)
DISK_TOTAL=$(df -h / | awk 'NR==2 {print $2}')
DISK_USED=$(df -h / | awk 'NR==2 {print $3}')

if [ "$DISK" -ge 85 ]; then
    echo -e "  Current: ${RED}${DISK}%${NC} (${DISK_USED} / ${DISK_TOTAL}) [CRITICAL!]"
    OVERALL="CRITICAL"
    ISSUES+=("Disk at ${DISK}%")
elif [ "$DISK" -ge "$DISK_WARNING" ]; then
    echo -e "  Current: ${YELLOW}${DISK}%${NC} (${DISK_USED} / ${DISK_TOTAL}) [WARNING]"
    [ "$OVERALL" != "CRITICAL" ] && OVERALL="WARNING"
    ISSUES+=("Disk at ${DISK}%")
else
    echo -e "  Current: ${GREEN}${DISK}%${NC} (${DISK_USED} / ${DISK_TOTAL}) [OK]"
fi
echo "  $(make_bar $DISK)"
echo ""

#######################################
# SYSTEM INFO
#######################################
echo -e "${BLUE}▶ SYSTEM INFORMATION${NC}"
echo "  Hostname: $(hostname)"
echo "  IP Address: $(hostname -I 2>/dev/null | awk '{print $1}' || echo 'N/A')"
echo "  Uptime: $(uptime -p 2>/dev/null || echo 'N/A')"
echo ""

#######################################
# SUMMARY
#######################################
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if [ "$OVERALL" = "HEALTHY" ]; then
    echo -e "  Status: ${GREEN}✓ ALL SYSTEMS HEALTHY${NC}"
    echo -e "  ${GREEN}Your clinic server is running smoothly!${NC}"
elif [ "$OVERALL" = "WARNING" ]; then
    echo -e "  Status: ${YELLOW}⚠ WARNING - Attention Needed${NC}"
    for issue in "${ISSUES[@]}"; do
        echo -e "  ${YELLOW}• $issue${NC}"
    done
elif [ "$OVERALL" = "CRITICAL" ]; then
    echo -e "  Status: ${RED}🚨 CRITICAL - Action Required!${NC}"
    for issue in "${ISSUES[@]}"; do
        echo -e "  ${RED}• $issue${NC}"
    done
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Save to log file
echo "[$TIMESTAMP] Status: $OVERALL | CPU: ${CPU}% | Memory: ${MEM}% | Disk: ${DISK}%" >> "$LOG_FILE"

echo ""
echo "📝 Log saved to: $LOG_FILE"
