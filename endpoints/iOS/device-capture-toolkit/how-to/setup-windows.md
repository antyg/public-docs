# Set Up a Windows Host for iOS Diagnostic Capture

Prepare a Windows workstation to capture iOS/iPadOS device-side diagnostics via
USB. This procedure installs Chocolatey and libimobiledevice, connects the iOS
device, and verifies the environment before capture.

> **⚠ Network capture limitation:** Windows does not support RVI (Remote Virtual
> Interface). This setup captures **device logs and VPN profiles only** — no
> network packet capture is available on Windows. For full capture including VPN
> tunnel traffic, use a macOS host. See
> [`setup-macos.md`](setup-macos.md) and
> [`../reference/platform-comparison.md`](../reference/platform-comparison.md).

---

## Prerequisites

- Windows 10 or later (Windows 11 recommended)
- Administrator account — required for package installation
- Lightning or USB-C cable connecting the iOS device to the Windows PC
- iTunes or the Apple Devices app installed (provides Apple Mobile Device drivers)
- At least 2 GB free disk space for capture output

---

## Steps

### 1. Install Apple device drivers

iTunes or the Apple Devices app installs the Apple Mobile Device USB driver,
which Windows requires to communicate with iOS devices.

**Option A — Apple Devices app (Windows 11, recommended):**
Install from the Microsoft Store — search "Apple Devices".

**Option B — iTunes:**
Download from [apple.com/itunes](https://www.apple.com/itunes/download/).

After installation, connect the iOS device via USB. The device should appear in
Windows Device Manager under **Portable Devices**.

---

### 2. Run the setup script as Administrator

```powershell
# Right-click PowerShell → Run as Administrator
.\Setup-ZCCDiagnostics.ps1
```

Or with automatic dependency installation (no prompts):

```powershell
.\Setup-ZCCDiagnostics.ps1 -InstallDependencies
```

The script checks and installs Chocolatey and libimobiledevice, detects the
connected iOS device, and reports the RVI limitation.

---

### 3. Install Chocolatey (if not already installed)

The setup script installs Chocolatey automatically when prompted. To install
manually:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = `
    [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(`
    'https://community.chocolatey.org/install.ps1'))
```

See [chocolatey.org/install](https://chocolatey.org/install) for full
instructions.

---

### 4. Install libimobiledevice

The setup script installs libimobiledevice via Chocolatey when Chocolatey is
available and the package is not already installed. To install manually:

```powershell
choco install libimobiledevice -y
```

After installation, verify the tools are available:

```powershell
idevice_id -l
idevicesyslog --help
```

---

### 5. Connect and trust the iOS device

1. Connect the iPhone or iPad to the Windows PC via USB cable.
2. Unlock the iOS device.
3. When prompted with **"Trust This Computer?"**, tap **Trust** and enter the
   device passcode.

Verify detection:

```powershell
idevice_id -l
```

A UDID appears in the output when the device is correctly connected and trusted.

If no device is listed, check:

```powershell
# Verify Apple drivers are installed
Get-PnpDevice | Where-Object { $_.FriendlyName -like "*Apple*" }
```

---

### 6. Acknowledge the RVI limitation

The setup script displays a notice that RVI is not available on Windows. Read
this notice and confirm before proceeding. The capture script will collect
device logs and VPN profiles but no network packet data.

For a full list of what is and is not captured on Windows, see
[`../reference/platform-comparison.md`](../reference/platform-comparison.md).

---

## Setup Summary

After the setup script completes, the summary section reports:

| Check             | Expected result                                   |
| ----------------- | ------------------------------------------------- |
| Device logging    | `✓ libimobiledevice available`                    |
| Network capture   | `✗ RVI not supported on Windows (macOS required)` |
| Connected devices | `✓ iPhone detected`                               |
| Disk space        | `✓ Sufficient disk space`                         |

If the setup script reports `✅ Ready to capture device-side ZCC diagnostics!`,
proceed to
[`capture-zcc-diagnostics-windows.md`](capture-zcc-diagnostics-windows.md).

---

## Next Step

[Capture ZCC diagnostics on Windows →](capture-zcc-diagnostics-windows.md)

---

**Last Updated**: February 2026
**Maintainer**: antyg
