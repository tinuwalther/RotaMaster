# Start Development Server

Start the RotaMaster Pode development server for local development and testing.

## Description
This skill starts the Pode web server for the RotaMaster application, allowing you to test the application locally.

## Prerequisites
- PowerShell 7+ (pwsh)
- Pode module installed
- PSSQLite module installed
- SQLite database exists in api/rotamaster.db

## Usage
Run the following command from the project root:
```powershell
pwsh ./PodeServer.ps1
```

## Expected Output
The server should start and display:
- Pode version information
- Route registration messages for all API endpoints
- RunspacePool initialization messages
- Listening endpoint (typically https://localhost:8443/)

## Troubleshooting
- If Pode module is missing: `Install-Module -Name Pode -Repository PSGallery`
- If PSSQLite module is missing: `Install-Module -Name PSSQLite -Repository PSGallery`
- If database is missing, run the database-init skill first
- If port 8443 is in use, stop the conflicting process or change the port in PodeServer.ps1

## Notes
- Press Ctrl+C to stop the server
- The server runs with HTTPS using a self-signed certificate
- Default login credentials are configured in api/users.json