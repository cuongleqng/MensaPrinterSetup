# MSA Printer Installer

PowerShell-based printer deployment tool for MSA offices.

This script automatically:

* Detects Windows architecture (x86 / x64)
* Downloads the correct printer driver package
* Creates the printer TCP/IP port
* Installs the printer driver
* Creates the printer
* Applies printer configuration
* Sets the printer as default
* Supports multiple MSA printers from a selection menu

---

## Supported Printers

| Option | Printer                        | Queue       | Address       |
| ------ | ------------------------------ | ----------- | ------------- |
| 1      | Xerox C8145 - MSA Office       | PRT-TED-003 | 172.16.11.251 |
| 2      | Toshiba 6506 - MSA Beta        | PRT-TED-004 | 172.16.21.251 |
| 3      | Fuji C7071 - MSA Office        | PRT-TED-005 | 172.16.11.252 |
| 4      | Toshiba 6506 - MSA Alpha       | PRT-TED-006 | 172.16.31.251 |
| 5      | Toshiba 6506 - MSA Warehouse   | PRT-TED-007 | 172.16.41.251 |
| 6      | Toshiba 6506 - MSA Beta Office | PRT-TED-008 | 172.16.21.252 |

---

## Requirements

* Windows 10 or Windows 11
* Administrator privileges
* Internet access to GitHub
* PowerShell 5.1 or later

---

## Installation

### Method 1 - One-line Installation (Recommended)

Open **PowerShell as Administrator** and run:

```powershell
irm https://raw.githubusercontent.com/cuongleqng/MensaPrinterSetup/refs/heads/main/Install-Printer.ps1 | iex
```

---

### Method 2 - If PowerShell Execution Policy Blocks the Script

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/cuongleqng/MensaPrinterSetup/refs/heads/main/Install-Printer.ps1 | iex
```

---

## Installation Process

1. Launch PowerShell as Administrator.
2. Run the installation command.
3. Select the desired printer from the menu.
4. Wait for the installation to complete.
5. The selected printer will be installed and configured automatically.

---

## Repository Structure

```text
.
├── Install-Printer.ps1
├── Drivers
│   ├── TOSHIBA_Universal_PS3_x64.zip
│   ├── TOSHIBA_Universal_PS3_x86.zip
│   ├── XEROX_C8145_x64.zip
│   └── FUJI_C7071_x64.zip
│
├── Config
│   ├── Toshiba6506_x64.dat
│   ├── XeroxC8145_x64.dat
│   └── FujiC7071_x64.dat
│
└── README.md
```

---

## Troubleshooting

### Driver does not exist in the driver store

Verify that:

* The driver package was downloaded successfully.
* The correct INF file is being installed.
* The driver name in the script matches the actual driver name installed on Windows.

