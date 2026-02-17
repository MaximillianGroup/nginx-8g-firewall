#!/bin/bash
# ========================================================================
# 8G Firewall for Nginx - Installation Script
# ========================================================================
# 
# This script helps install the 8G Firewall into your Nginx configuration
#
# Usage: sudo ./install.sh
# ========================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Error: This script must be run as root or with sudo${NC}"
    exit 1
fi

echo "========================================================================="
echo "  8G Firewall for Nginx - Installation"
echo "========================================================================="
echo ""

# Detect Nginx configuration directory
NGINX_CONF_DIR="/etc/nginx"
if [ ! -d "$NGINX_CONF_DIR" ]; then
    echo -e "${RED}Error: Nginx configuration directory not found at $NGINX_CONF_DIR${NC}"
    echo "Please install Nginx first or specify the correct path."
    exit 1
fi

echo -e "${GREEN}✓${NC} Found Nginx configuration directory: $NGINX_CONF_DIR"

# Check if Nginx is installed
if ! command -v nginx &> /dev/null; then
    echo -e "${RED}Error: Nginx command not found${NC}"
    echo "Please install Nginx first."
    exit 1
fi

echo -e "${GREEN}✓${NC} Nginx is installed"
nginx -v

echo ""
echo "Installing 8G Firewall..."
echo ""

# Copy the firewall configuration
if [ -f "8g-firewall.conf" ]; then
    cp 8g-firewall.conf "$NGINX_CONF_DIR/8g-firewall.conf"
    echo -e "${GREEN}✓${NC} Copied 8g-firewall.conf to $NGINX_CONF_DIR/"
else
    echo -e "${RED}Error: 8g-firewall.conf not found in current directory${NC}"
    exit 1
fi

# Create log directory if it doesn't exist
LOG_DIR="/var/log/nginx"
if [ ! -d "$LOG_DIR" ]; then
    mkdir -p "$LOG_DIR"
    echo -e "${GREEN}✓${NC} Created log directory: $LOG_DIR"
fi

# Set permissions
chown -R nginx:nginx "$LOG_DIR" 2>/dev/null || chown -R www-data:www-data "$LOG_DIR" 2>/dev/null || true
echo -e "${GREEN}✓${NC} Set permissions for log directory"

echo ""
echo "========================================================================="
echo "  Installation Complete!"
echo "========================================================================="
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Add this line to your nginx.conf in the http {} block:"
echo "   ${GREEN}include /etc/nginx/8g-firewall.conf;${NC}"
echo ""
echo "2. Add firewall activation to your server blocks:"
echo "   ${GREEN}limit_conn 8g_conn 20;${NC}"
echo "   ${GREEN}limit_req zone=8g_global burst=50 nodelay;${NC}"
echo "   ${GREEN}if (\$block_all) { return 444; }${NC}"
echo ""
echo "3. Test the configuration:"
echo "   ${GREEN}sudo nginx -t${NC}"
echo ""
echo "4. Reload Nginx:"
echo "   ${GREEN}sudo systemctl reload nginx${NC}"
echo ""
echo "For detailed instructions, see README.md"
echo "For an example configuration, see nginx.conf.example"
echo ""
echo "========================================================================="
