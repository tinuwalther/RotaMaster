# OpsGenie Integration

Test and manage OpsGenie integration for on-call scheduling and overrides.

## Description
This skill provides commands for testing and managing the OpsGenie API integration, including schedule management and override operations.

## Prerequisites
- Valid OpsGenie API credentials
- OpsGenie API key configured
- PowerShell 7+ (pwsh)
- Development server running (for API testing)

## Usage

### List schedule information:
```powershell
.\bin\Invoke-OpsGenieMaintenace.ps1 -ScheduleName 'your_schedule_name' -ListSchedule
```

### List all rotations:
```powershell
.\bin\Invoke-OpsGenieMaintenace.ps1 -ScheduleName 'your_schedule_name' -ListRotations
```

### List all overrides:
```powershell
.\bin\Invoke-OpsGenieMaintenace.ps1 -ScheduleName 'your_schedule_name' -ListOverrides
```

### Remove obsolete override:
```powershell
$alias = 'override-alias-here'
.\bin\Invoke-OpsGenieMaintenace.ps1 -ScheduleName 'your_schedule_name' -RemoveOverride -Alias $alias
```

### Create new on-call schedule:
```powershell
.\bin\New-OnCallSchedule.ps1 -StartDate '2025-03-01' -EndDate '2025-12-31'
```

### Test OpsGenie API via web interface:
- Access the OpsGenie section in the RotaMaster web UI
- Create overrides using the web interface
- Test synchronization/refresh functionality

## Configuration
OpsGenie settings are configured in:
- `public/assets/rotamaster/rotamaster.config.js`
- Key settings: `opsGenie`, `scheduleName`, `rotationName`

## Expected Output
Successful operations should return:
- Schedule details including ID, name, timezone, and owner team
- Rotation information with dates and type
- Override details with user, dates, and rotation associations
- Confirmation of successful delete operations

## Troubleshooting
- Verify API key is valid and has proper permissions
- Check schedule name matches your OpsGenie schedule exactly
- Ensure network connectivity to OpsGenie API
- Review PowerShell error messages for specific API errors
- Check OpsGenie documentation for API rate limits and quotas

## Notes
- Schedule name must match your OpsGenie schedule name exactly
- The integration requires OpsGenie API access
- Overrides are temporary changes to the regular rotation
- The web UI provides easier override creation for end users
- API operations require proper authentication and permissions