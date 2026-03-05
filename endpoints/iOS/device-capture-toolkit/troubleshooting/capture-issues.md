# Troubleshooting Capture Issues

Symptom-driven guidance for resolving issues during iOS device capture setup
and capture sessions on both macOS and Windows hosts.

---

## Device Not Detected

**Symptom:** `idevice_id -l` or `cfgutil list` returns no output. Setup script
reports `⚠ No devices detected`.

| Cause                                 | Resolution                                                                                                                          |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| iOS device is locked                  | Unlock the device before connecting                                                                                                 |
| Trust dialog not answered             | On the iOS device, tap **Trust** when prompted with "Trust This Computer?" and enter the device passcode                            |
| USB cable issue                       | Try a different cable — data transfer cables only (charging-only cables do not work)                                                |
| USB port issue                        | Try a different USB port directly on the computer (avoid USB hubs)                                                                  |
| Apple drivers not installed (Windows) | Install iTunes or the Apple Devices app from the Microsoft Store                                                                    |
| Previous trust revoked                | On the iOS device: **Settings → General → Transfer or Reset iPhone → Reset → Reset Location & Privacy** — reconnect and trust again |
| libimobiledevice not installed        | Run `brew install libimobiledevice` (macOS) or `choco install libimobiledevice` (Windows)                                           |

**Verify drivers (Windows):**

```powershell
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Apple*" }
```

---

## RVI Interface Not Created (macOS)

**Symptom:** `ifconfig | grep rvi` returns no output after running `setup.sh`.
Script reports `⚠ RVI interface not configured`.

| Cause                                   | Resolution                                                                                |
| --------------------------------------- | ----------------------------------------------------------------------------------------- |
| Device not connected or not trusted     | Ensure device is connected, unlocked, and the Trust dialog has been acknowledged          |
| `rvictl` requires sudo                  | Run `sudo rvictl -s <UDID>` manually                                                      |
| lockdownd connection failure            | Disconnect and reconnect the device; unlock and trust again                               |
| RVI already exists for a different UDID | Run `rvictl -l` to list active interfaces; remove stale ones with `sudo rvictl -x <UDID>` |
| macOS version compatibility             | macOS 11+ recommended; older versions may have rvictl issues                              |

**Manual RVI creation:**

```bash
# Get UDID
idevice_id -l

# Create RVI
sudo rvictl -s <UDID>

# Verify
ifconfig | grep rvi
```

**If rvictl reports "Could not connect to lockdownd":**

```text
→ Unlock iPhone and tap Trust when prompted
→ Then run: sudo rvictl -s <UDID>
```

---

## Permission Denied / Sudo Required (macOS)

**Symptom:** `tcpdump` fails with `permission denied`. Script reports capture
started but no `.pcap` file is created.

| Cause                                        | Resolution                                                                                                                                                                    |
| -------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Script not run with sudo                     | Run `sudo ./capture_diagnostics.sh`                                                                                                                                           |
| sudo session expired mid-capture             | Re-run the script with sudo                                                                                                                                                   |
| System Integrity Protection blocking tcpdump | Check `csrutil status` — if enabled (default), tcpdump should still work; if tcpdump is not in `/usr/sbin/`, reinstall via Xcode Command Line Tools: `xcode-select --install` |

---

## Administrator Privileges Required (Windows)

**Symptom:** Setup script fails to install Chocolatey or libimobiledevice.
Error: `Administrator privileges required`.

| Cause                               | Resolution                                                                                                                 |
| ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| PowerShell not run as administrator | Right-click PowerShell → **Run as Administrator** — then re-run setup                                                      |
| Execution policy blocking scripts   | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` then retry                                                       |
| Group Policy blocking Chocolatey    | Contact your IT administrator; install libimobiledevice manually from [libimobiledevice.org](https://libimobiledevice.org) |

---

## Device Logs Empty or Not Streaming

**Symptom:** `device_logs.txt` is created but contains no content, or log
entries stop appearing shortly after capture starts.

| Cause                               | Resolution                                                                                       |
| ----------------------------------- | ------------------------------------------------------------------------------------------------ |
| Device disconnected during capture  | Keep the USB cable connected throughout the session; lock-screen timeouts do not affect capture  |
| cfgutil syslog stopped unexpectedly | Re-run the capture script; check `ps aux \| grep cfgutil`                                        |
| idevicesyslog stopped unexpectedly  | Re-run the capture script; check `ps aux \| grep idevicesyslog`                                  |
| Multiple devices connected          | `idevicesyslog` may connect to the wrong device; use `-u <UDID>` flag: `idevicesyslog -u <UDID>` |
| Background job failed (Windows)     | Check `Get-Job` in PowerShell to verify the job is running                                       |

**Verify capture is active (macOS):**

```bash
ps aux | grep "cfgutil syslog\|idevicesyslog"
```

---

## Packet Capture File Empty or Not Created (macOS)

**Symptom:** `zcc_vpn_capture_rvi0.pcap` is not present in the output directory,
or the file exists but contains no packets.

| Cause                                         | Resolution                                                                                              |
| --------------------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Answered `n` when prompted for packet capture | Re-run with sudo and answer `y` to the packet capture prompt                                            |
| RVI interface not active                      | Run `ifconfig \| grep rvi` — if no RVI exists, create one: `sudo rvictl -s <UDID>`                      |
| tcpdump not found                             | `tcpdump` is bundled with macOS; if missing, install Xcode Command Line Tools: `xcode-select --install` |
| Device disconnected before RVI was used       | Reconnect device, recreate RVI, and restart capture                                                     |
| Packet capture started but RVI had no traffic | Ensure ZCC is actively attempting to connect during the capture window                                  |

---

## Large Log Files

**Symptom:** `device_logs.txt` or `.pcap` files are very large (>500 MB),
making analysis difficult.

| Cause                     | Resolution                                                |
| ------------------------- | --------------------------------------------------------- |
| Long capture session      | Aim for the minimum session needed to reproduce the issue |
| Verbose logging on device | Normal for iOS syslog — use grep to filter                |

**Filter device logs to relevant events:**

```bash
# ZCC events only
grep -i "zscaler\|zcc\|neagent\|nesession" device_logs.txt > zcc_only.txt

# Errors only
grep -iE "error|fault|fail" device_logs.txt > errors_only.txt

# Time window (e.g., 14:30–14:35)
awk '/14:3[0-5]:/' device_logs.txt > time_window.txt
```

**Filter packet capture in Wireshark:**

- ZCC-related TLS: `ssl.handshake`
- Zscaler endpoints: `ip.host contains "zscaler"`
- TLS alerts (failures): `tls.alert_message`

---

## cfgutil: Command Not Found (macOS)

**Symptom:** Script reports `⚠ Apple Configurator not found`.

| Cause                            | Resolution                                                                                                                                                              |
| -------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Apple Configurator not installed | Install from the Mac App Store — search "Apple Configurator"                                                                                                            |
| cfgutil not in PATH              | The toolkit searches the application bundle directly at `/Applications/Apple Configurator.app/Contents/MacOS/cfgutil` — ensure the app is installed in `/Applications/` |

The toolkit falls back to `idevicesyslog` if `cfgutil` is not available.
Device syslog capture is not blocked by this condition.

---

## Chocolatey or libimobiledevice Not in PATH (Windows)

**Symptom:** After installation, `idevice_id` is not recognised as a command.

| Cause                                     | Resolution                                                               |
| ----------------------------------------- | ------------------------------------------------------------------------ |
| Terminal session open before installation | Close and reopen PowerShell after installation to reload PATH            |
| Chocolatey installed to non-standard path | Run `refreshenv` in the same PowerShell session                          |
| PATH not updated                          | Manually check: `$env:Path -split ';' \| Select-String libimobiledevice` |

**Verify and refresh PATH (Windows):**

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + `
    [System.Environment]::GetEnvironmentVariable("Path","User")

idevice_id -l
```

---

**Last Updated**: February 2026
**Maintainer**: antyg
