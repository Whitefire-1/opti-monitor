# opti-monitor
Server monitoring system for healthcare - DevOps portfolio project
cat > README.md << 'EOF'
# 👁️ Opti-Monitor: Healthcare Server Monitoring System

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?style=for-the-badge&logo=html5&logoColor=white)

🎯 Project Overview

Opti-Monitor is a lightweight, automated server monitoring solution designed for small healthcare facilities. It provides real-time health monitoring, automatic alerting, and a beautiful web dashboard.

The Problem I Solved

Small healthcare clinics often lack IT resources to monitor their critical systems. When servers crash:
- 📅 Patient appointments are lost
- 🌐 Online booking systems fail
- 👨‍⚕️ Staff waste time troubleshooting
- 😞 Patients have poor experiences

 My Solution

An automated monitoring system that:
- ✅ Checks server health every 5 minutes automatically
- ✅ Alerts when issues are detected
- ✅ Provides a beautiful, real-time web dashboard
- ✅ Maintains logs for troubleshooting
- ✅ Requires zero maintenance once set up

---



 Terminal Health Check

### Web Dashboard
The dashboard shows:
- Real-time CPU, Memory, and Disk metrics
- Visual progress bars with color coding
- System information
- Recent health check history
- Auto-refreshes every 60 seconds

---

## 🏗️ Architecture

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/opti-monitor.git
cd opti-monitor

# Run interactive menu
./opti-monitor.sh

# Or run individual commands:
./scripts/health-check.sh      # Run health check
./scripts/generate-dashboard.sh # Generate dashboard
./scripts/setup-automation.sh   # Setup auto-monitoring
