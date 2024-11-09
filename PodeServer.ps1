#Requires -Modules pode, PSSQLite
<#
    .SYNOPSIS
    Start Pode server

    .DESCRIPTION
    Start a pode server and open the default browser.

    .EXAMPLE
    pwsh .\RotaMaster\PodeServer.ps1
#>
[CmdletBinding()]
param ()

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

    # Here our sessions will last for 15 Min, and will be extended on each request
    Enable-PodeSessionMiddleware -Duration 900 -Extend

    # Setup ActiveDirectory authentication
    # https://pode.readthedocs.io/en/latest/Tutorials/Authentication/Inbuilt/WindowsAD/#usage
    # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -DirectGroups
    # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -Groups @('XAAS-vCenter-Administrators-Compute-GS') -FailureUrl '/login' -SuccessUrl '/'

    # Setup Form authentication
    New-PodeAuthScheme -Form | Add-PodeAuth -Name 'Login' -FailureUrl '/login' -SuccessUrl '/' -ScriptBlock {
        param($username, $password)
    
        # here you'd check a real user storage, this is just for example
        if ($password -eq 'VerySecure!') {
            return @{
                User = @{
                    ID   = New-Guid
                    Name = $username
                    Type = 'local'
                }
            }
        }
    
        # No user was found
        return @{ Message = 'Invalid details supplied!' }
    }

    # Redirected to the login page
    Add-PodeRoute -Method Get -Path '/' -Authentication 'Login' -ScriptBlock {
        $WebEvent.Session.Data.Views++
        Write-PodeViewResponse -Path 'index.html' -Data @{
            Username = $WebEvent.Auth.User.Name;
        }
    }

    # the login page itself
    Add-PodeRoute -Method Get -Path '/login' -Authentication 'Login' -Login -ScriptBlock {
        Write-PodeViewResponse -Path 'login.pode' -FlashMessages
    }

    # the POST action for the <form>
    Add-PodeRoute -Method Post -Path '/login' -Authentication 'Login' -Login
    
    # the logout Route
    Add-PodeRoute -Method Post -Path '/logout' -Authentication 'Login' -Logout
    #endregion

    Import-Module PSSQLite -Force

    $BinPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
    Import-Module -FullyQualifiedName (Join-Path -Path $BinPath -ChildPath 'RotaMaster.psd1')

    # Enables Error Logging
    New-PodeLoggingMethod -File -Name 'error' -MaxDays 7 | Enable-PodeErrorLogging

    # Add listener to Port 8080 for Protocol http
    Add-PodeEndpoint -Address $Address -Port $Port -Protocol $Protocol

    # Set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode
    
    # Set Pode endpoints for the web pages
    # Initialize-WebEndpoints

    # Set Pode endpoints for the api
    Initialize-ApiEndpoints

} -Verbose 

#endregion