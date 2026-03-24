#!/bin/bash

################################################################################
# ZCC VPN Diagnostic Capture Script
#
# Purpose: Capture comprehensive diagnostics for Zscaler Client Connector (ZCC)
#          VPN troubleshooting including:
#   - iOS device logs (ZCC client behavior)
#   - Network packet capture via RVI (VPN tunnel traffic)
#   - Device VPN profiles (ZCC configuration)
#
# Requirements:
#   - macOS with attached iPhone via USB
#   - Optional: Apple Configurator or libimobiledevice for device logs
#   - Run with administrator privileges for network capture
#
# Usage:
#   sudo ./capture_diagnostics.sh
################################################################################

set -e

# Configuration
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/logs/${TIMESTAMP}"
DEVICE_LOG_PID=""
PACKET_CAPTURE_PID=""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Create output directory
if mkdir -p "$OUTPUT_DIR"; then
    echo -e "${GREEN}📁 Created output directory: $OUTPUT_DIR${NC}"
    chmod -R 755 "${SCRIPT_DIR}/logs" 2>/dev/null || true
    chown -R $(id -u):$(id -g) "${SCRIPT_DIR}/logs" 2>/dev/null || true
else
    echo -e "${RED}❌ Failed to create output directory: $OUTPUT_DIR${NC}"
    exit 1
fi

# Verify directory is writable
if [ ! -w "$OUTPUT_DIR" ]; then
    echo -e "${RED}❌ Output directory is not writable: $OUTPUT_DIR${NC}"
    exit 1
fi

################################################################################
# Cleanup function
################################################################################
cleanup() {
    echo -e "\n${YELLOW}🛑 Stopping all diagnostic captures...${NC}"

    # Kill device log capture
    if [ -n "$DEVICE_LOG_PID" ]; then
        kill $DEVICE_LOG_PID 2>/dev/null || true
        echo "  ✓ Stopped device log capture"
    fi

    # Kill packet capture (single PID)
    if [ -n "$PACKET_CAPTURE_PID" ]; then
        kill $PACKET_CAPTURE_PID 2>/dev/null || true
        echo "  ✓ Stopped packet capture"
    fi

    # Kill any other tcpdump processes capturing to our output directory
    pkill -f "tcpdump.*$OUTPUT_DIR" 2>/dev/null || true

    # Clean up ALL RVI interfaces that exist
    if command -v rvictl &> /dev/null; then
        echo "  Removing Remote Virtual Interfaces..."

        # Get all active RVI UDIDs from rvictl
        local RVI_UDIDS=$(rvictl -l 2>/dev/null | grep -oE "[0-9a-f]{40}" | sort -u)

        if [ -n "$RVI_UDIDS" ]; then
            while read -r udid; do
                [ -z "$udid" ] && continue

                if rvictl -x "$udid" > /dev/null 2>&1; then
                    echo "    ✓ Removed RVI for device: $udid"
                fi
            done <<< "$RVI_UDIDS"
        else
            echo "    (No RVI interfaces to remove)"
        fi
    fi

    # Capture final VPN profiles
    capture_vpn_profiles "final"

    # Generate summary
    generate_summary

    echo -e "\n${GREEN}✅ Diagnostic capture complete!${NC}"
    echo -e "${BLUE}📂 Output directory: $OUTPUT_DIR${NC}"
    open "$OUTPUT_DIR"
}

trap cleanup EXIT INT TERM

################################################################################
# Capture functions
################################################################################

capture_device_info() {
    echo -e "${BLUE}💻 Capturing system information...${NC}"

    {
        echo "============================================"
        echo "ZCC VPN Diagnostic Capture Session"
        echo "============================================"
        echo "Timestamp: $(date)"
        echo "Session ID: $TIMESTAMP"
        echo ""
        echo "System Information:"
        echo "==================="
        system_profiler SPHardwareDataType SPSoftwareDataType
        echo ""
        echo "Connected iOS Devices:"
        echo "======================"

        if command -v cfgutil &> /dev/null; then
            cfgutil list
        elif command -v idevice_id &> /dev/null; then
            idevice_id -l
        else
            echo "No device query tools available"
        fi

    } > "$OUTPUT_DIR/system_info.txt"

    echo "  ✓ System information captured"
}

start_device_log_capture() {
    echo -e "${BLUE}📱 Checking for attached iOS devices...${NC}"

    # Check if cfgutil is available (Apple Configurator)
    if command -v cfgutil &> /dev/null; then
        echo "  ✓ Found cfgutil, starting device log capture..."

        cfgutil syslog > "$OUTPUT_DIR/device_logs.txt" 2>&1 &
        DEVICE_LOG_PID=$!
        echo "  ✓ Device log capture started (PID: $DEVICE_LOG_PID)"

    elif command -v idevicesyslog &> /dev/null; then
        # Alternative: libimobiledevice
        echo "  ✓ Found idevicesyslog, starting device log capture..."

        idevicesyslog > "$OUTPUT_DIR/device_logs.txt" 2>&1 &
        DEVICE_LOG_PID=$!
        echo "  ✓ Device log capture started (PID: $DEVICE_LOG_PID)"

    else
        echo -e "  ${YELLOW}⚠️  cfgutil or idevicesyslog not found${NC}"
        echo "     Install Apple Configurator or: brew install libimobiledevice"
        echo "     Continuing without device-specific logs..."
    fi
}

capture_vpn_profiles() {
    local label=${1:-"manual"}
    local timestamp=$(date +"%H%M%S")

    echo -e "${BLUE}📋 Capturing device VPN profiles (checkpoint: $label)...${NC}"

    mkdir -p "$OUTPUT_DIR"

    local device_profile_file="$OUTPUT_DIR/vpn_profiles_${label}_${timestamp}.txt"
    local device_info_file="$OUTPUT_DIR/device_info_${label}_${timestamp}.txt"

    # Try cfgutil first (Apple Configurator)
    if command -v cfgutil &> /dev/null; then
        echo "  📱 Capturing iOS device profiles via cfgutil..."

        local device_count=$(cfgutil list 2>/dev/null | grep -c "ECID" || echo "0")
        if [ "$device_count" -eq 0 ]; then
            echo -e "  ${YELLOW}⚠️  No iOS devices detected by cfgutil${NC}"
            {
                echo "No iOS devices detected"
                echo "======================="
                echo "Run 'cfgutil list' to verify device connection"
            } > "$device_profile_file"
        else
            echo "  ✓ Detected $device_count device(s)"

            # Capture device profiles
            if cfgutil get installedProfiles > "$device_profile_file" 2>&1; then
                if [ -f "$device_profile_file" ] && [ -s "$device_profile_file" ]; then
                    local size=$(stat -f%z "$device_profile_file" 2>/dev/null || stat -c%s "$device_profile_file" 2>/dev/null || echo "0")
                    echo "  ✓ iOS device profiles captured: $size bytes"
                else
                    echo "  ✓ Device profiles command succeeded (may be no profiles yet)"
                fi
            fi

            # Get device info for context
            cfgutil get deviceType modelName serialNumber UDID > "$device_info_file" 2>&1
        fi

    # Try libimobiledevice as alternative
    elif command -v ideviceinfo &> /dev/null; then
        echo "  📱 Capturing iOS device info via libimobiledevice..."

        if ideviceinfo > "$device_info_file" 2>&1; then
            echo "  ✓ Device info captured"
        fi

        if command -v ideviceprovision &> /dev/null; then
            if ideviceprovision list > "$device_profile_file" 2>&1; then
                echo "  ✓ iOS provisioning profiles captured"
            fi
        fi

    else
        echo -e "  ${YELLOW}⚠️  No iOS device profile tools available${NC}"
        {
            echo "iOS Device Profile Capture Failed"
            echo "=================================="
            echo "Install Apple Configurator or libimobiledevice to capture device profiles."
        } > "$device_profile_file"
    fi
}

start_packet_capture() {
    echo -e "${BLUE}🌐 Starting network packet capture for ZCC VPN traffic...${NC}"
    echo "  ℹ️  Capturing iPhone network traffic via RVI interfaces"
    echo "      • RVI captures ALL device traffic including:"
    echo "        - ZCC VPN tunnel establishment"
    echo "        - VPN encrypted packets"
    echo "        - Split-tunnel traffic (both VPN and direct routes)"
    echo ""

    mkdir -p "$OUTPUT_DIR"

    # Setup RVI interfaces for ALL connected iOS devices
    echo -e "${BLUE}📱 Setting up RVI interfaces for connected devices...${NC}"

    if command -v rvictl &> /dev/null; then
        # Get ALL connected device UDIDs
        local DEVICE_UDIDS=""

        if command -v cfgutil &> /dev/null; then
            DEVICE_UDIDS=$(cfgutil list 2>/dev/null | awk '{print $1}')
        elif [ -f "/Applications/Apple Configurator.app/Contents/MacOS/cfgutil" ]; then
            DEVICE_UDIDS=$("/Applications/Apple Configurator.app/Contents/MacOS/cfgutil" list 2>/dev/null | awk '{print $1}')
        elif command -v idevice_id &> /dev/null; then
            DEVICE_UDIDS=$(idevice_id -l 2>/dev/null)
        fi

        if [ -z "$DEVICE_UDIDS" ]; then
            echo -e "  ${RED}✗${NC} No iOS devices detected"
            echo "     Connect iPhone via USB, unlock, and trust this Mac"
        else
            local DEVICE_COUNT=$(echo "$DEVICE_UDIDS" | wc -l | tr -d ' ')
            echo "  ✓ Found $DEVICE_COUNT connected device(s)"

            # Create RVI interface for each device
            while read -r device_udid; do
                [ -z "$device_udid" ] && continue

                echo ""
                echo "  Setting up RVI for device: $device_udid"

                if rvictl -s "$device_udid" > /dev/null 2>&1; then
                    sleep 1
                    echo "    ✓ Created RVI interface"
                else
                    echo -e "    ${YELLOW}⚠️${NC} Could not create RVI for $device_udid"
                fi
            done <<< "$DEVICE_UDIDS"
        fi
    else
        echo -e "  ${RED}✗${NC} rvictl command not found (should be available on macOS)"
    fi

    echo ""
    echo -e "${BLUE}📡 Starting packet captures on all RVI interfaces...${NC}"

    # Get all RVI interfaces from ifconfig
    local ALL_RVI=$(ifconfig 2>/dev/null | grep -o "^rvi[0-9]*" | sort -u)

    if [ -z "$ALL_RVI" ]; then
        echo -e "  ${YELLOW}⚠️${NC} No RVI interfaces available"
        echo "  Cannot capture ZCC VPN network traffic without RVI interfaces"
    else
        local RVI_COUNT=$(echo "$ALL_RVI" | wc -l | tr -d ' ')
        echo "  Starting captures for $RVI_COUNT RVI interface(s)..."

        # Start capture on each RVI interface
        while read -r rvi_interface; do
            [ -z "$rvi_interface" ] && continue

            local rvi_pcap="$OUTPUT_DIR/zcc_vpn_capture_${rvi_interface}.pcap"
            local rvi_log="$OUTPUT_DIR/tcpdump_${rvi_interface}.log"

            # Use -p flag to disable promiscuous mode
            if tcpdump -p -i "$rvi_interface" -w "$rvi_pcap" -v > "$rvi_log" 2>&1 & then
                local pid=$!
                echo "    ✓ $rvi_interface (PID: $pid) → ${rvi_interface}.pcap"

                # Store first PID for cleanup tracking
                if [ -z "$PACKET_CAPTURE_PID" ]; then
                    PACKET_CAPTURE_PID=$pid
                fi
            else
                echo -e "    ${YELLOW}⚠️${NC} Failed to start capture on $rvi_interface"
            fi
        done <<< "$ALL_RVI"

        echo ""
        echo -e "${GREEN}✅ ZCC VPN network capture summary:${NC}"
        echo "  • RVI interfaces: $RVI_COUNT"
        echo "  • Capturing: ALL ZCC VPN traffic (tunnel + direct routes)"
        echo ""
    fi
}

generate_summary() {
    echo -e "${BLUE}📝 Generating capture summary...${NC}"

    {
        echo "============================================"
        echo "ZCC VPN Diagnostic Capture Summary"
        echo "============================================"
        echo "Session ID: $TIMESTAMP"
        echo "Capture End: $(date)"
        echo "Output Directory: $OUTPUT_DIR"
        echo ""
        echo "Captured Files:"
        echo "==============="
        ls -lh "$OUTPUT_DIR"
        echo ""
        echo "File Descriptions:"
        echo "=================="
        echo "• device_logs.txt - iPhone/iPad syslog (ZCC client logs)"
        echo "• vpn_profiles_*.txt - iPhone VPN/MDM profiles at capture points"
        echo "• device_info_*.txt - iPhone device information"
        echo "• system_info.txt - Mac and connected device information"
        echo "• zcc_vpn_capture_rvi*.pcap - ZCC VPN network traffic capture"
        echo "• tcpdump_*.log - tcpdump verbose output logs"
        echo ""
        echo "ZCC VPN Troubleshooting Focus:"
        echo "=============================="
        echo "This capture focuses on Zscaler Client Connector (ZCC) VPN issues:"
        echo "  ✓ iPhone ZCC client logs (device_logs.txt)"
        echo "  ✓ VPN configuration profiles (vpn_profiles_*.txt)"
        echo "  ✓ Complete network traffic via RVI:"
        echo "      • VPN tunnel establishment"
        echo "      • TLS handshake issues"
        echo "      • Certificate chain validation"
        echo "      • MTU/fragmentation problems"
        echo "      • Split-tunnel routing behavior"
        echo ""
        echo "RVI Interface Explained:"
        echo "  • RVI = Remote Virtual Interface"
        echo "  • Created via: rvictl -s <device_udid>"
        echo "  • Captures complete mirror of ALL device network activity"
        echo "  • Includes encrypted VPN packets as they leave/enter device"
        echo "  • Essential for diagnosing VPN connection issues"
        echo ""
        echo "Analysis Tips:"
        echo "=============="
        echo "1. Check device_logs.txt for ZCC client errors and VPN events"
        echo "2. Compare vpn_profiles_*.txt to verify ZCC configuration"
        echo "3. Analyze zcc_vpn_capture_rvi*.pcap for network-level issues:"
        echo "   - Use Wireshark to inspect VPN tunnel handshake"
        echo "   - Look for TLS version mismatches"
        echo "   - Check certificate chain validation failures"
        echo "   - Identify MTU/fragmentation issues"
        echo "   - Examine DNS resolution for ZCC endpoints"
        echo "4. Search device_logs.txt for ZCC-specific bundle IDs"
        echo "5. Look for authentication flows and certificate exchanges"

    } > "$OUTPUT_DIR/CAPTURE_SUMMARY.txt"

    echo "  ✓ Summary generated"
}

################################################################################
# Main script
################################################################################

echo -e "${GREEN}================================================${NC}"
echo -e "${GREEN}ZCC VPN Diagnostic Capture${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""

# Check for sudo
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}⚠️  This script should be run with sudo for full capture capabilities${NC}"
    echo "   Network packet capture requires elevated privileges"
    echo ""
    read -p "Continue anyway? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Capture baseline information
capture_device_info

# Start device log capture
start_device_log_capture

# Prompt for packet capture
read -p "Start network packet capture? (requires sudo) (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    start_packet_capture
fi

# Capture initial VPN profiles
capture_vpn_profiles "initial"

echo -e "\n${GREEN}✅ Diagnostic capture is now ACTIVE${NC}"
echo -e "${GREEN}================================================${NC}"
echo ""
echo "ZCC VPN Troubleshooting Workflow:"
echo ""
echo "  1️⃣  Reproduce the ZCC VPN connection issue"
echo "  2️⃣  Attempt to connect/disconnect VPN multiple times"
echo "  3️⃣  Note the exact time when errors occur"
echo "  4️⃣  Press Ctrl+C when you have captured the issue"
echo ""
echo -e "${YELLOW}Press Ctrl+C when capture is complete${NC}"
echo ""

# Wait for user interrupt
while true; do
    sleep 1
done

# The cleanup function will be called automatically via trap
exit 0
