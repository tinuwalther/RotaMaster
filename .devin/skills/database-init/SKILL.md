# Database Initialization

Initialize or reset the RotaMaster SQLite database for development and testing.

## Description
This skill manages the SQLite database used by RotaMaster, including creating a fresh database with required tables and views.

## Prerequisites
- PowerShell 7+ (pwsh)
- PSSQLite module installed

## Usage

### Remove existing database and create new one:
```powershell
.\bin\Invoke-SQLiteMaintenance.ps1 -RemoveDatabase
.\bin\Invoke-SQLiteMaintenance.ps1 -NewDatabase
```

### Query the database:
```powershell
.\bin\Invoke-SQLiteMaintenance.ps1 -Query 'SELECT * FROM v_events'
```

### Check specific tables:
```powershell
.\bin\Invoke-SQLiteMaintenance.ps1 -Query 'SELECT * FROM events'
.\bin\Invoke-SQLiteMaintenance.ps1 -Query 'SELECT * FROM person'
.\bin\Invoke-SQLiteMaintenance.ps1 -Query 'SELECT * FROM absence'
```

## Database Structure
The database contains the following tables:
- `events` - Calendar events and absence records
- `person` - User/person management
- `absence` - Absence types

And views:
- `v_events` - FullCalendar view of events
- `v_events_deleted` - Deleted events tracking
- `v_pikett` - On-call duty view

## Expected Output
After initialization, you should see:
- Confirmation of database creation
- List of created tables and views
- Sample data in v_events showing "Initialize DB" event
- Default admin user in person table
- Default absence type in absence table

## Troubleshooting
- If PSSQLite module is missing: `Install-Module -Name PSSQLite -Repository PSGallery`
- The -RemoveDatabase command creates a backup in archiv/rotamaster.bak
- Confirm prompts can be automated if needed for CI/CD

## Notes
- Database file location: api/rotamaster.db
- Backup location: archiv/rotamaster.bak
- Initial data includes one admin user and sample absence types
- The database is required for the server to start properly