# Check Required Modules

Verify and install required PowerShell modules for RotaMaster development.

## Description
This skill checks if the required PowerShell modules are installed and provides installation commands if they are missing.

## Required Modules
- **Pode** (v2.11.1+) - Web framework for the server
- **PSSQLite** - SQLite database interaction

## Usage

### Check if modules are installed:
```powershell
Get-Module -ListAvailable | Select-Object Name, Version
```

### Check specific modules:
```powershell
Get-Module -ListAvailable -Name Pode
Get-Module -ListAvailable -Name PSSQLite
```

### Install missing modules:
```powershell
Install-Module -Name Pode -Repository PSGallery -PassThru -Verbose
Install-Module -Name PSSQLite -Repository PSGallery -PassThru -Verbose
```

### Update modules to latest version:
```powershell
Update-Module -Name Pode -Force -PassThru
Update-Module -Name PSSQLite -Force -PassThru
```

## Expected Output
Commands should show:
- Installed module names and versions
- Installation progress for PSGallery downloads
- Confirmation of successful installation
- Module location information

## Troubleshooting
- If PSGallery is not trusted: `Set-PSRepository -Name PSGallery -InstallationPolicy Trusted`
- If installation fails due to permissions, run PowerShell as administrator
- If network issues occur, check internet connectivity and PSGallery accessibility
- Module version conflicts can be resolved by specifying specific version: `-RequiredVersion x.x.x`

## Notes
- Modules install to user scope by default (no admin rights required)
- Pode v2.11.1 is the minimum version currently tested
- PSSQLite is required for SQLite database operations
- Both modules are available from the official PowerShell Gallery
