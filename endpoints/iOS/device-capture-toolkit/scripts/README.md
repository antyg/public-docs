# Scripts

Published script assets for the iOS device capture toolkit.

---

## Directory Structure

```
scripts/
├── macos/
│   ├── setup.sh                       # macOS environment setup + RVI initialisation
│   └── capture_diagnostics.sh         # macOS ZCC diagnostic capture
└── windows/
    ├── Setup-ZCCDiagnostics.ps1       # Windows environment setup
    └── Invoke-ZCCDiagnosticCapture.ps1  # Windows ZCC diagnostic capture
```

---

## Script Summary

| Script | Platform | Purpose |
|---|---|---|
| `macos/setup.sh` | macOS | Verify and install prerequisites; connect device; create RVI interface |
| `macos/capture_diagnostics.sh` | macOS | Capture device syslog, VPN profiles, and network packets via RVI |
| `windows/Setup-ZCCDiagnostics.ps1` | Windows | Verify and install prerequisites; check device connection |
| `windows/Invoke-ZCCDiagnosticCapture.ps1` | Windows | Capture device syslog and VPN profiles (no network capture) |

For detailed parameter documentation and output file descriptions, see
[`../reference/script-reference.md`](../reference/script-reference.md).

---

## Usage

### macOS

```bash
cd macos
chmod +x setup.sh capture_diagnostics.sh
./setup.sh
sudo ./capture_diagnostics.sh
```

### Windows (run as Administrator)

```powershell
cd windows
.\Setup-ZCCDiagnostics.ps1
.\Invoke-ZCCDiagnosticCapture.ps1
```

---

## Output

Both platforms write timestamped output to a `logs/` subdirectory within the
platform folder:

- macOS: `macos/logs/<YYYYMMDD_HHmmss>/`
- Windows: `windows\logs\<YYYYMMDD_HHmmss>\`

The `logs/` directories are not tracked in version control.

---

**Last Updated**: February 2026
**Maintainer**: antyg
