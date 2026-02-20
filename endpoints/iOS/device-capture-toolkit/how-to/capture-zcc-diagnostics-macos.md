# Capture ZCC Diagnostics on macOS

Capture a comprehensive ZCC (Zscaler Client Connector) diagnostic session from
a USB-connected iOS device on a macOS host. This procedure captures device
syslog, VPN profile snapshots, and full network packet capture via RVI.

**Prerequisite:** Complete [`setup-macos.md`](setup-macos.md) before starting
this procedure. The RVI interface must be active and the iOS device trusted.

---

## What This Capture Collects

| File                              | Content                                            |
| --------------------------------- | -------------------------------------------------- |
| `device_logs.txt`                 | Live iOS device syslog (ZCC client events)         |
| `vpn_profiles_initial_<time>.txt` | VPN / MDM profiles before reproducing the issue    |
| `vpn_profiles_final_<time>.txt`   | VPN / MDM profiles after issue reproduction        |
| `device_info_<label>_<time>.txt`  | Device model, serial number, UDID                  |
| `system_info.txt`                 | Mac system details and connected device list       |
| `zcc_vpn_capture_rvi0.pcap`       | Full iOS device network traffic (Wireshark format) |
| `tcpdump_rvi0.log`                | tcpdump verbose output                             |
| `CAPTURE_SUMMARY.txt`             | Session summary and analysis tips                  |

---

## Steps

### 1. Open a terminal and navigate to the scripts directory

```bash
cd /path/to/device-capture-toolkit/scripts/macos
```

---

### 2. Start the capture

```bash
sudo ./capture_diagnostics.sh
```

The script requires sudo for network packet capture (`tcpdump`). If prompted to
continue without sudo, answer `y` — device logs and VPN profiles will still be
captured, but network packets will not.

The script:

1. Creates a timestamped output directory at `scripts/macos/logs/<timestamp>/`
2. Captures system information
3. Starts live device syslog capture in the background
4. Prompts whether to start network packet capture

When prompted `Start network packet capture? (requires sudo) (y/n):` — answer
**`y`** to capture ZCC VPN tunnel traffic.

---

### 3. Capture initial VPN profile snapshot

The script automatically captures a VPN profile snapshot labelled `initial`
immediately after starting. This records the ZCC configuration state before the
issue is reproduced.

---

### 4. Reproduce the ZCC issue

With the capture running, reproduce the issue on the iOS device:

1. Open ZCC on the iPhone.
2. Attempt to connect or disconnect the VPN.
3. If the VPN is intermittently failing, attempt the connection multiple times.
4. Note the **exact time** when the error occurs — this helps locate the
   relevant entries in `device_logs.txt` and the packet capture.

The terminal displays:

```text
✅ Diagnostic capture is now ACTIVE
ZCC VPN Troubleshooting Workflow:
  1️⃣  Reproduce the ZCC VPN connection issue
  2️⃣  Attempt to connect/disconnect VPN multiple times
  3️⃣  Note the exact time when errors occur
  4️⃣  Press Ctrl+C when you have captured the issue
```

---

### 5. Stop the capture

Press **Ctrl+C** once the issue has been reproduced and sufficient time has
elapsed to capture the failure.

The cleanup handler:

1. Stops device syslog capture
2. Stops all tcpdump processes
3. Removes RVI interfaces (device disconnected from virtual network)
4. Captures a final VPN profile snapshot labelled `final`
5. Generates `CAPTURE_SUMMARY.txt`
6. Opens the output directory in Finder

---

### 6. Review the captured output

The output directory opens automatically. Key files for ZCC analysis:

**Start with `device_logs.txt`:**

```bash
# Find ZCC errors
grep -i "zscaler\|zcc\|vpn" device_logs.txt | grep -i "error\|fail"

# Find connection events by time
grep "14:3[0-5]:" device_logs.txt | grep -i "vpn\|tunnel"
```

**Analyse `zcc_vpn_capture_rvi0.pcap` in Wireshark:**

- Filter for TLS handshake failures: `tls.alert_message`
- Filter for DNS queries to Zscaler endpoints: `dns.qry.name contains "zscaler"`
- Filter for certificate issues: `tls.handshake.type == 11`

**Compare VPN profiles:**

```bash
diff vpn_profiles_initial_*.txt vpn_profiles_final_*.txt
```

---

## Output Directory Structure

```text
scripts/macos/logs/20260220_143022/
├── CAPTURE_SUMMARY.txt
├── system_info.txt
├── device_logs.txt
├── vpn_profiles_initial_143022.txt
├── device_info_initial_143022.txt
├── vpn_profiles_final_143445.txt
├── device_info_final_143445.txt
├── zcc_vpn_capture_rvi0.pcap
└── tcpdump_rvi0.log
```

---

## After Capture

- Compress the output directory before sharing with Zscaler or network team:

  ```bash
  tar -czf zcc_diagnostics_$(date +%Y%m%d).tar.gz logs/<timestamp>/
  ```

- Review `CAPTURE_SUMMARY.txt` for analysis guidance before sharing.
- Device logs and packet captures may contain sensitive data (UDIDs, MDM server
  URLs, network traffic). Redact as required before sharing externally.

---

## Troubleshooting

For issues during this procedure, see
[`../troubleshooting/capture-issues.md`](../troubleshooting/capture-issues.md).

---

**Last Updated**: February 2026
**Maintainer**: antyg
