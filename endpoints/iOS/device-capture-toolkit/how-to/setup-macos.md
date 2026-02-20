# Set Up a macOS Host for iOS Diagnostic Capture

Prepare a Mac workstation to capture iOS/iPadOS diagnostics via USB. This
procedure installs and verifies the required tools, connects the iOS device,
and creates the RVI (Remote Virtual Interface) needed for network packet capture.

---

## Prerequisites

- macOS 11 (Big Sur) or later — macOS 12+ recommended
- Administrator account (sudo access required for RVI and packet capture)
- Lightning or USB-C cable connecting the iOS device to the Mac
- At least 2 GB free disk space for capture output

---

## Steps

### 1. Run the setup script

The setup script checks all prerequisites, installs missing tools, connects the
device, and creates the RVI interface in a single pass.

```bash
cd scripts/macos
chmod +x setup.sh capture_diagnostics.sh
./setup.sh
```

The script outputs a colour-coded summary. Review each section before
proceeding.

---

### 2. Verify Homebrew

The setup script checks for [Homebrew](https://brew.sh). If Homebrew is not
installed, the script prompts to install it automatically.

To install Homebrew manually:

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

> **Note:** On Apple Silicon Macs, Homebrew installs to `/opt/homebrew/`. On
> Intel Macs, it installs to `/usr/local/`. The setup script handles both paths.

---

### 3. Verify device logging tools

The setup script checks for and installs device logging tools in this priority
order:

| Tool                               | Source                          | Detection                               |
| ---------------------------------- | ------------------------------- | --------------------------------------- |
| `cfgutil` (Apple Configurator)     | Mac App Store                   | `/Applications/Apple Configurator.app/` |
| `idevicesyslog` (libimobiledevice) | `brew install libimobiledevice` | `command -v idevicesyslog`              |

If neither is installed and Homebrew is available, the script automatically
installs `libimobiledevice`.

To install `libimobiledevice` manually:

```bash
brew install libimobiledevice
```

To install Apple Configurator: search "Apple Configurator" in the Mac App Store.

---

### 4. Connect and trust the iOS device

1. Connect the iPhone or iPad to the Mac via USB cable.
2. Unlock the iOS device.
3. When prompted with **"Trust This Computer?"**, tap **Trust** and enter the
   device passcode.

Verify the device is detected:

```bash
# If using Apple Configurator
cfgutil list

# If using libimobiledevice
idevice_id -l
```

A UDID appears in the output when the device is correctly connected and trusted.

---

### 5. Create the RVI interface

The setup script automatically creates an RVI interface if a device is
connected and no interface exists. To create one manually:

```bash
# Obtain the device UDID
idevice_id -l

# Create the RVI interface (replace <UDID> with actual device UDID)
sudo rvictl -s <UDID>

# Verify the interface was created
ifconfig | grep rvi
```

A successful result shows an interface named `rvi0` (or `rvi1` if multiple
devices are connected).

> **Note:** The RVI interface persists only while the device is connected. If
> the device is disconnected and reconnected, run `sudo rvictl -s <UDID>` again.

---

### 6. Verify sudo access

Network packet capture via `tcpdump` requires elevated privileges:

```bash
sudo -v
```

If prompted for a password, provide your administrator password. If sudo is not
available, contact your system administrator.

---

### 7. Check disk space

```bash
df -g ~
```

Ensure at least 2 GB is available. Packet captures for extended sessions can
reach 500 MB–2 GB.

---

## Setup Summary

After the setup script completes, the summary section reports:

| Check             | Expected result                                    |
| ----------------- | -------------------------------------------------- |
| Device logging    | `✓ Device logging tools available`                 |
| RVI interface     | `✓ RVI interface ready for ZCC VPN packet capture` |
| Connected devices | `✓ iPhone detected`                                |
| Disk space        | `✓ Sufficient disk space`                          |

If the setup script reports `✅ Ready to capture ZCC VPN diagnostics!`, proceed
to [`capture-zcc-diagnostics-macos.md`](capture-zcc-diagnostics-macos.md).

---

## Next Step

[Capture ZCC diagnostics on macOS →](capture-zcc-diagnostics-macos.md)

---

**Last Updated**: February 2026
**Maintainer**: antyg
