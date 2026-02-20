#!/bin/bash

################################################################################
# Setup Script for ZCC VPN Diagnostic Capture
#
# Purpose: Verify prerequisites and prepare environment for Zscaler Client
#          Connector (ZCC) VPN troubleshooting via iOS device diagnostics
################################################################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE}ZCC VPN Diagnostic Capture - Setup${NC}"
echo -e "${BLUE}================================================${NC}"
echo ""

# Check macOS version
echo -e "${BLUE}Checking system...${NC}"
OS_VERSION=$(sw_vers -productVersion)
echo "  macOS version: $OS_VERSION"

MAJOR_VERSION=$(echo "$OS_VERSION" | cut -d. -f1)
if [ "$MAJOR_VERSION" -lt 11 ]; then
    echo -e "  ${YELLOW}⚠️  macOS 11+ recommended for best results${NC}"
fi

echo ""

# Check for required commands
echo -e "${BLUE}Checking required commands...${NC}"

if command -v log &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} log (system logging)"
else
    echo -e "  ${RED}✗${NC} log command not found (required)"
    exit 1
fi

if command -v tcpdump &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} tcpdump (network capture)"
else
    echo -e "  ${YELLOW}⚠${NC} tcpdump not found (optional, requires sudo)"
fi

echo ""

# Check/Install Homebrew first if needed
echo -e "${BLUE}Checking for Homebrew...${NC}"
if command -v brew &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} Homebrew installed"
    BREW_AVAILABLE=true
else
    echo -e "  ${YELLOW}⚠${NC} Homebrew not found"
    echo ""
    echo "  Homebrew is required to install libimobiledevice for device logging."
    read -p "  Install Homebrew now? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo ""
        echo "  Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for this session
        if [ -f "/opt/homebrew/bin/brew" ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [ -f "/usr/local/bin/brew" ]; then
            eval "$(/usr/local/bin/brew shellenv)"
        fi

        if command -v brew &> /dev/null; then
            echo -e "  ${GREEN}✓${NC} Homebrew installed successfully"
            BREW_AVAILABLE=true
        else
            echo -e "  ${RED}✗${NC} Homebrew installation failed"
            echo "     Please install manually from: https://brew.sh"
            BREW_AVAILABLE=false
        fi
    else
        echo "  Skipped Homebrew installation"
        BREW_AVAILABLE=false
    fi
fi

echo ""

# Check for device logging tools
echo -e "${BLUE}Checking iOS device logging tools...${NC}"

CFGUTIL_PATH="/Applications/Apple Configurator.app/Contents/MacOS/cfgutil"
if [ -f "$CFGUTIL_PATH" ]; then
    echo -e "  ${GREEN}✓${NC} Apple Configurator (cfgutil)"
    CFGUTIL_AVAILABLE=true
elif command -v cfgutil &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} cfgutil (in PATH)"
    CFGUTIL_AVAILABLE=true
else
    echo -e "  ${YELLOW}⚠${NC} Apple Configurator not found"
    CFGUTIL_AVAILABLE=false
fi

if command -v idevicesyslog &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} libimobiledevice (idevicesyslog)"
    LIBIMOBILE_AVAILABLE=true
else
    echo -e "  ${YELLOW}⚠${NC} libimobiledevice not found"
    LIBIMOBILE_AVAILABLE=false
fi

# Auto-install libimobiledevice if missing and Homebrew is available
if ! $CFGUTIL_AVAILABLE && ! $LIBIMOBILE_AVAILABLE && $BREW_AVAILABLE; then
    echo ""
    echo "  No device logging tools available. Installing libimobiledevice..."
    echo ""

    if brew install libimobiledevice; then
        echo -e "  ${GREEN}✓${NC} libimobiledevice installed successfully"
        LIBIMOBILE_AVAILABLE=true
    else
        echo -e "  ${RED}✗${NC} Failed to install libimobiledevice"
        echo "     Try manually: brew install libimobiledevice"
        LIBIMOBILE_AVAILABLE=false
    fi
fi

# If still no tools available, warn user
if ! $CFGUTIL_AVAILABLE && ! $LIBIMOBILE_AVAILABLE; then
    echo ""
    echo -e "  ${YELLOW}⚠️  No device log capture tools available${NC}"
    echo "     Device logs will be missing from capture"
    echo ""
    if ! $BREW_AVAILABLE; then
        echo "     Options:"
        echo "       • Install Homebrew from https://brew.sh"
        echo "       • Then run: brew install libimobiledevice"
        echo "       • Or install Apple Configurator from Mac App Store"
    else
        echo "     Alternative: Install Apple Configurator from Mac App Store"
    fi
fi

echo ""

# Check for RVI capability
echo -e "${BLUE}Checking RVI (Remote Virtual Interface) capability...${NC}"

if command -v rvictl &> /dev/null; then
    echo -e "  ${GREEN}✓${NC} rvictl (network capture for iOS)"
    RVICTL_AVAILABLE=true

    # Check for existing RVI interfaces
    EXISTING_RVI=$(ifconfig 2>/dev/null | grep -o "^rvi[0-9]*" | sort -u | head -n 1)
    if [ -n "$EXISTING_RVI" ]; then
        echo -e "     ${GREEN}✓${NC} RVI interface already exists: $EXISTING_RVI"
        RVI_EXISTS=true
    else
        echo -e "     ${YELLOW}⚠${NC} No RVI interfaces found (will create if device connected)"
        RVI_EXISTS=false
    fi
else
    echo -e "  ${YELLOW}⚠${NC} rvictl not found (should be included with macOS)"
    RVICTL_AVAILABLE=false
    RVI_EXISTS=false
fi

echo ""

# Check for connected devices
echo -e "${BLUE}Checking for connected iOS devices...${NC}"

DEVICE_FOUND=false
DEVICE_UDID=""

if $CFGUTIL_AVAILABLE; then
    DEVICES=$("$CFGUTIL_PATH" list 2>/dev/null || cfgutil list 2>/dev/null || echo "")
    if [ -n "$DEVICES" ]; then
        echo -e "  ${GREEN}✓${NC} Device(s) detected via cfgutil:"
        echo "$DEVICES" | sed 's/^/    /'
        DEVICE_FOUND=true
        # Get first UDID
        DEVICE_UDID=$(echo "$DEVICES" | head -n 1 | awk '{print $1}')
    fi
fi

if ! $DEVICE_FOUND && $LIBIMOBILE_AVAILABLE; then
    DEVICES=$(idevice_id -l 2>/dev/null || echo "")
    if [ -n "$DEVICES" ]; then
        echo -e "  ${GREEN}✓${NC} Device(s) detected via libimobiledevice:"
        echo "$DEVICES" | sed 's/^/    /'
        DEVICE_FOUND=true
        # Get first UDID
        DEVICE_UDID=$(echo "$DEVICES" | head -n 1)
    fi
fi

if ! $DEVICE_FOUND; then
    echo -e "  ${YELLOW}⚠${NC} No devices detected"
    echo "     • Connect iPhone via USB"
    echo "     • Unlock the iPhone"
    echo "     • Trust this Mac when prompted"
fi

echo ""

# Auto-setup RVI interface if device is connected and no RVI exists
if $DEVICE_FOUND && $RVICTL_AVAILABLE && ! $RVI_EXISTS && [ -n "$DEVICE_UDID" ]; then
    echo -e "${BLUE}Setting up RVI interface for ZCC VPN traffic capture...${NC}"
    echo ""
    echo "  📱 Device UDID: $DEVICE_UDID"
    echo "  🌐 RVI enables network packet capture for ZCC VPN diagnostics"
    echo ""
    echo "  Creating RVI interface (requires sudo)..."
    echo ""

    # Create RVI with proper error handling
    RVI_OUTPUT=$(sudo rvictl -s "$DEVICE_UDID" 2>&1)
    RVI_EXIT_CODE=$?

    if [ $RVI_EXIT_CODE -eq 0 ]; then
        sleep 2

        # Verify RVI was created
        NEW_RVI=$(ifconfig 2>/dev/null | grep -o "^rvi[0-9]*" | sort -u | head -n 1)
        if [ -n "$NEW_RVI" ]; then
            echo -e "  ${GREEN}✓${NC} RVI interface created: ${GREEN}$NEW_RVI${NC}"
            echo ""
            echo -e "  ${GREEN}✅ ZCC VPN network capture is ready!${NC}"
            echo ""
            RVI_EXISTS=true
        else
            echo -e "  ${YELLOW}⚠️${NC} RVI interface not detected after creation"
            echo "  Check: ${CYAN}ifconfig | grep rvi${NC}"
        fi
    else
        echo ""
        echo -e "  ${RED}✗${NC} Failed to create RVI interface"
        echo ""
        if echo "$RVI_OUTPUT" | grep -qi "Could not connect to lockdownd"; then
            echo "    → Unlock iPhone and tap 'Trust' when prompted"
            echo "    → Then run this setup script again"
        elif echo "$RVI_OUTPUT" | grep -qi "interface already exists"; then
            echo "    → RVI may already exist"
            echo "    → Check: ${CYAN}ifconfig | grep rvi${NC}"
        else
            echo "    → Error: $RVI_OUTPUT"
        fi
    fi
    echo ""
elif $DEVICE_FOUND && $RVI_EXISTS; then
    echo -e "${BLUE}RVI interface status:${NC}"
    echo -e "  ${GREEN}✓${NC} RVI already configured and ready"
    echo ""
fi

# Check sudo access
echo -e "${BLUE}Checking administrator access...${NC}"

if sudo -n true 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} sudo access available"
else
    echo -e "  ${YELLOW}⚠${NC} sudo access required for packet capture"
    echo "     Run scripts with: sudo ./capture_diagnostics.sh"
fi

echo ""

# Make scripts executable
echo -e "${BLUE}Setting up scripts...${NC}"

if [ -f "capture_diagnostics.sh" ]; then
    chmod +x capture_diagnostics.sh
    echo -e "  ${GREEN}✓${NC} capture_diagnostics.sh is executable"
else
    echo -e "  ${RED}✗${NC} capture_diagnostics.sh not found"
fi

echo ""

# Check disk space
echo -e "${BLUE}Checking disk space...${NC}"

AVAILABLE_GB=$(df -g ~ | tail -1 | awk '{print $4}')
echo "  Available space: ${AVAILABLE_GB}GB"

if [ "$AVAILABLE_GB" -lt 2 ]; then
    echo -e "  ${RED}✗${NC} Low disk space! Need at least 2GB for diagnostic capture"
    echo "     Device logs and packet captures can be large (500MB-2GB)"
else
    echo -e "  ${GREEN}✓${NC} Sufficient disk space"
fi

echo ""

# Summary
echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}Setup Summary${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

READY=true

echo "Device Logging:"
if $CFGUTIL_AVAILABLE || $LIBIMOBILE_AVAILABLE; then
    echo -e "  ${GREEN}✓${NC} Device logging tools available"
else
    echo -e "  ${RED}✗${NC} No device logging tools available"
    READY=false
fi

echo ""
echo "Network Capture:"
if $RVICTL_AVAILABLE && $RVI_EXISTS; then
    echo -e "  ${GREEN}✓${NC} RVI interface ready for ZCC VPN packet capture"
elif $RVICTL_AVAILABLE && $DEVICE_FOUND; then
    echo -e "  ${YELLOW}⚠${NC} RVI interface not configured"
    echo "     Run this setup script again to create RVI"
else
    echo -e "  ${YELLOW}⚠${NC} RVI not available (connect device)"
fi

echo ""
echo "Connected Devices:"
if $DEVICE_FOUND; then
    echo -e "  ${GREEN}✓${NC} iPhone detected"
else
    echo -e "  ${YELLOW}⚠${NC} No devices detected - connect before capture"
fi

echo ""

if $READY; then
    echo -e "${GREEN}✅ Ready to capture ZCC VPN diagnostics!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Ensure ZCC is installed on iPhone"
    echo "  2. Run: sudo ./capture_diagnostics.sh"
    echo "  3. Reproduce ZCC VPN connection issue"
    echo "  4. Press Ctrl+C when complete"
    echo ""

    # Suggest RVI setup if not done
    if ! $RVI_EXISTS && $DEVICE_FOUND; then
        echo -e "${YELLOW}💡 Tip:${NC} RVI interface not configured yet"
        echo "   Run this setup script again to configure RVI"
        echo ""
    fi
else
    echo -e "${YELLOW}⚠️  Setup incomplete but can continue${NC}"
    echo ""
    echo "Missing components will limit diagnostic capabilities."
    echo "You can still run: sudo ./capture_diagnostics.sh"
    echo ""
fi

echo ""

exit 0
