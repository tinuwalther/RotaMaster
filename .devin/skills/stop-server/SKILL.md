# Stop Development Server

Stop the running RotaMaster Pode development server.

## Description
This skill stops the Pode web server that is currently running in the background or foreground.

## Usage

### If running in background (shell session):
Find the shell session ID and terminate it:
```powershell
# List running processes to find the Pode server
Get-Process -Name pwsh
# Or if using Devin's shell management, use the shell ID
```

### If running in foreground:
Press `Ctrl+C` in the terminal where the server is running.

### Alternative - Kill PowerShell process:
```powershell
Get-Process | Where-Object {$_.ProcessName -eq "pwsh"} | Stop-Process -Force
```

## Expected Output
The server should stop immediately and you should see:
- Process termination confirmation
- Release of port 8443
- Shell session termination (if background)

## Troubleshooting
- If the server won't stop, use `Stop-Process -Force` on the pwsh process
- If port 8443 remains in use, check for zombie processes: `lsof -i :8443`
- If multiple instances are running, identify the correct one by process ID or start time
- On macOS, you may need to use `kill -9 <PID>` for stubborn processes

## Notes
- The server typically runs on port 8443
- Stopping the server will disconnect all active users
- Any pending requests will be terminated
- Database changes are saved immediately, so no data loss occurs on shutdown
- The server does not save state between restarts (except in the database)

## Verification
Verify the server has stopped by checking if port 8443 is free:
```powershell
lsof -i :8443
# Should return no results if server is stopped
```