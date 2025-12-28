#!/bin/bash
#######################################
# Opti-Monitor Master Control
# One command to control everything!
#######################################

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$HOME/opti-monitor"

show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║                                                          ║"
    echo "║   👁️  OPTI-MONITOR - Eye Clinic Server Monitor          ║"
    echo "║                                                          ║"
    echo "║   Your DevOps Portfolio Project                          ║"
    echo "║                                                          ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

show_menu() {
    echo -e "${GREEN}What would you like to do?${NC}"
    echo ""
    echo "  1) Run Health Check"
    echo "  2) Generate Dashboard"
    echo "  3) Open Dashboard in Browser"
    echo "  4) View Recent Logs"
    echo "  5) Run Everything (Check + Dashboard + Open)"
    echo "  6) Exit"
    echo ""
    echo -n "Enter your choice [1-6]: "
}

run_health_check() {
    echo ""
    echo -e "${YELLOW}Running health check...${NC}"
    "$PROJECT_DIR/scripts/health-check.sh"
}

generate_dashboard() {
    echo ""
    echo -e "${YELLOW}Generating dashboard...${NC}"
    "$PROJECT_DIR/scripts/generate-dashboard.sh"
}

open_dashboard() {
    echo ""
    echo -e "${YELLOW}Opening dashboard in browser...${NC}"
    explorer.exe $(wslpath -w "$PROJECT_DIR/reports/dashboard.html")
    echo -e "${GREEN}✅ Dashboard opened!${NC}"
}

view_logs() {
    echo ""
    echo -e "${YELLOW}Recent Health Check Logs:${NC}"
    echo "─────────────────────────────────────────"
    tail -15 "$PROJECT_DIR/logs/health.log" 2>/dev/null || echo "No logs yet!"
    echo "─────────────────────────────────────────"
    echo ""
    read -p "Press Enter to continue..."
}

run_everything() {
    run_health_check
    echo ""
    generate_dashboard
    echo ""
    open_dashboard
}

# Main loop
while true; do
    show_banner
    show_menu
    read choice
    
    case $choice in
        1) run_health_check; read -p "Press Enter to continue..." ;;
        2) generate_dashboard; read -p "Press Enter to continue..." ;;
        3) open_dashboard; read -p "Press Enter to continue..." ;;
        4) view_logs ;;
        5) run_everything; read -p "Press Enter to continue..." ;;
        6) echo "Goodbye! 👋"; exit 0 ;;
        *) echo "Invalid option. Please try again."; sleep 1 ;;
    esac
done
