<#
    .SYNOPSIS
    Start Pode server

    .DESCRIPTION
    Test if it's running on Windows, then test if it's running with elevated Privileges, and start a new session if not.

    .EXAMPLE
    pwsh .\PodePSHTML\PodeServer.ps1
#>
[CmdletBinding()]
param ()

#region functions
# all functions could be found in the Module RotaMaster.psd1
#endregion

#region Main
enum OSType {
    Linux
    Mac
    Windows
}

if($PSVersionTable.PSVersion.Major -lt 6){
    $CurrentOS = [OSType]::Windows
}else{
    if($IsMacOS)  {$CurrentOS = [OSType]::Mac}
    if($IsLinux)  {$CurrentOS = [OSType]::Linux}
    if($IsWindows){$CurrentOS = [OSType]::Windows}
}
#endregion

#region Pode server
if($CurrentOS -eq [OSType]::Windows){
    $Address = 'localhost'
}else{
    $Address = '*'
}
$Port = 8080
$Protocol = 'http'

# We'll use 2 threads to handle API requests
Start-PodeServer -Browse -Threads 2 {
    Write-Host "Press Ctrl. + C to terminate the Pode server" -ForegroundColor Yellow

    Import-Module PSSQLite -Force

    $BinPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
    Import-Module -FullyQualifiedName (Join-Path -Path $BinPath -ChildPath 'RotaMaster.psd1')

    # Enables Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Add listener to Port 8080 for Protocol http
    Add-PodeEndpoint -Address $Address -Port $Port -Protocol $Protocol

    # Set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode
    
    # Set Pode endpoints for the web pages
    Initialize-WebEndpoints

    # Set Pode endpoints for the api
    Initialize-ApiEndpoints

} -Verbose 

#endregion