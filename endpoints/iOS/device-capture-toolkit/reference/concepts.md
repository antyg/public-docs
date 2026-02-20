# Key Concepts

Reference for the core technologies and data types used in the iOS device
capture toolkit.

---

## RVI — Remote Virtual Interface

RVI is an Apple-provided mechanism that creates a virtual network interface on a
Mac, mirroring all network traffic from a USB-connected iOS device. The
interface (`rvi0`, `rvi1`, etc.) appears as a standard network interface and can
be captured by any packet capture tool, including `tcpdump` and Wireshark.

| Attribute                    | Value                                             |
| ---------------------------- | ------------------------------------------------- |
| macOS command                | `rvictl`                                          |
| Interface naming             | `rvi0`, `rvi1` (one per connected device)         |
| Traffic captured             | All device network traffic — Wi-Fi, cellular, VPN |
| Requires sudo                | Yes (for `rvictl -s` to create interface)         |
| Packet capture requires sudo | Yes (`tcpdump`)                                   |
| Windows support              | ❌ Not available                                  |
| Framework dependency         | Apple CoreDevice frameworks (macOS-only)          |

**Creating an RVI interface:**

```bash
sudo rvictl -s <device-UDID>
```

**Removing an RVI interface:**

```bash
sudo rvictl -x <device-UDID>
```

**Listing active RVI interfaces:**

```bash
rvictl -l
ifconfig | grep rvi
```

Apple documentation: [Remote Virtual Interface — Apple Developer](https://developer.apple.com/documentation/xcode/capturing-http-traffic-from-a-device)

---

## cfgutil — Apple Configurator Utility

`cfgutil` is the command-line interface for Apple Configurator 2. It provides
device management, profile inspection, and syslog streaming capabilities.

| Attribute       | Value                                                         |
| --------------- | ------------------------------------------------------------- |
| Location        | `/Applications/Apple Configurator.app/Contents/MacOS/cfgutil` |
| Platform        | macOS only                                                    |
| Syslog command  | `cfgutil syslog`                                              |
| Profile listing | `cfgutil get installedProfiles`                               |
| Device info     | `cfgutil get deviceType modelName serialNumber UDID`          |
| Device listing  | `cfgutil list`                                                |

The toolkit prefers `cfgutil` over `idevicesyslog` when Apple Configurator is
installed, as `cfgutil` provides both syslog and profile access in a single tool.

Apple documentation: [Apple Configurator Help](https://support.apple.com/guide/apple-configurator-mac/welcome/mac)

---

## idevicesyslog — libimobiledevice Syslog Tool

`idevicesyslog` streams the iOS device syslog over a USB connection. It is part
of the open-source [libimobiledevice](https://libimobiledevice.org/) library.

| Attribute         | Value                                      |
| ----------------- | ------------------------------------------ |
| Install (macOS)   | `brew install libimobiledevice`            |
| Install (Windows) | `choco install libimobiledevice`           |
| Platform          | macOS, Windows, Linux                      |
| Syslog command    | `idevicesyslog`                            |
| Device listing    | `idevice_id -l`                            |
| Device info       | `ideviceinfo`                              |
| Profile listing   | `ideviceprovision list`                    |
| Network capture   | ❌ Cannot create RVI interfaces on Windows |

The toolkit uses `idevicesyslog` as the fallback when `cfgutil` is not
available, and as the primary tool on Windows.

---

## ZCC Log Scope

ZCC (Zscaler Client Connector) events appear throughout the iOS device syslog
under several subsystems and processes.

| Log subsystem / process | Content                                                     |
| ----------------------- | ----------------------------------------------------------- |
| `com.zscaler.zcc`       | ZCC client application events                               |
| ZCC VPN process         | VPN tunnel establishment, disconnection, error states       |
| `neagent`               | iOS Network Extension agent — VPN configuration and routing |
| `nesessionmanager`      | VPN session lifecycle management                            |
| `profiled`              | MDM profile installation and removal                        |
| `mdmclient`             | MDM server communication                                    |

**Useful search patterns for `device_logs.txt`:**

```bash
# ZCC-specific events
grep -i "zscaler\|zcc" device_logs.txt

# VPN tunnel events
grep -i "vpn\|tunnel\|neagent\|nesession" device_logs.txt

# Authentication failures
grep -i "auth.*fail\|credential\|401\|403" device_logs.txt

# Certificate events
grep -i "certificate\|tls\|ssl\|x509" device_logs.txt
```

---

## VPN Profile Snapshots

The capture scripts record the installed VPN and MDM profiles at two
checkpoints:

| Checkpoint label | Timing                                                                  |
| ---------------- | ----------------------------------------------------------------------- |
| `initial`        | Captured at capture start — baseline state before reproducing the issue |
| `final`          | Captured on Ctrl+C — state after issue reproduction                     |

Comparing initial vs final profiles reveals whether a VPN profile was
added, removed, or modified during the capture session.

**On macOS**, profiles are captured via `cfgutil get installedProfiles` or
`ideviceprovision list`.

**On Windows**, profiles are captured via `ideviceprovision list`.

---

## ADE / DEP — Automated Device Enrolment

ADE (Automated Device Enrolment, formerly Device Enrolment Programme / DEP) is
Apple's zero-touch provisioning mechanism. Devices assigned to an organisation
in Apple Business Manager (ABM) receive an enrolment profile during activation.

The backup README in the source toolkit documents a DEP-specific diagnostic
workflow using macOS system logs (`log stream --level debug`) to capture
`mdmclient`, `profiled`, and `ManagedConfiguration` subsystem events during
enrolment.

The current toolkit focuses on ZCC VPN diagnostics (the primary production
use case). The DEP enrolment diagnostic workflow is documented in the
backup scripts in the source repository and is not included in this published
toolkit.

Key subsystems for DEP diagnostics (for reference):

| Subsystem                        | Content                            |
| -------------------------------- | ---------------------------------- |
| `com.apple.ManagedConfiguration` | MDM and profile management         |
| `mdmclient`                      | MDM client–server communication    |
| `profiled`                       | Profile installation and lifecycle |
| `appstored`                      | App installation from MDM          |
| `CloudConfigurationDetails`      | DEP server communication           |

Apple documentation: [Device Enrollment — Apple Developer](https://developer.apple.com/documentation/devicemanagement/device_enrollment)

---

**Last Updated**: February 2026
**Maintainer**: antyg
