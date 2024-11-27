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
$Port = 8443
$Protocol = 'https'

# We'll use 2 threads to handle API requests
Start-PodeServer -Browse -Threads 2 {
    Write-Host "Press Ctrl. + C to terminate the Pode server" -ForegroundColor Yellow

    # Enables Logging
    New-PodeLoggingMethod -File -Name 'error' -MaxDays 7 | Enable-PodeErrorLogging
    New-PodeLoggingMethod -File -Name 'requests' -MaxDays 7 | Enable-PodeRequestLogging

    # Here our sessions will last for 10 Std, and will be extended on each request
    Enable-PodeSessionMiddleware -Duration 36000 -Extend

    # Setup ActiveDirectory authentication
    # https://pode.readthedocs.io/en/latest/Tutorials/Authentication/Inbuilt/WindowsAD/#usage
    # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -DirectGroups
    # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -Groups @('XAAS-vCenter-Administrators-Compute-GS') -FailureUrl '/login' -SuccessUrl '/'

    # Setup Form authentication
    # New-PodeAuthScheme -Form | Add-PodeAuth -Name 'Login' -FailureUrl '/login' -SuccessUrl '/' -ScriptBlock {
    #     param($username, $password)
    
    #     # here you'd check a real user storage, this is just for example
    #     if ($password -eq 'VerySecure!') {
    #         return @{
    #             User = @{
    #                 ID   = New-Guid
    #                 Name = $username
    #                 Type = 'local'
    #             }
    #         }
    #     }else{
    #         return @{ Message = 'Authorisation failed' }
    #     }
    
    #     # No user was found
    #     return @{ Message = 'Invalid details supplied!' }
    # }

    $ApiPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'api'
    New-PodeAuthScheme -Form | Add-PodeAuthUserFile -FilePath (Join-Path -Path $ApiPath -ChildPath 'users.json') -Name 'Login' -FailureUrl '/login' -SuccessUrl '/' -ScriptBlock {
        param($user)
        Set-PodeCookie -Name 'CurrentUser' -Value $user.Name
        return @{ User = $user }
    }

    # Redirected to the login page
    Add-PodeRoute -Method Get -Path '/' -Authentication 'Login' -ScriptBlock {
        $username = $WebEvent.Auth.User.Name
        Write-PodeViewResponse -Path 'index.html' -Data @{ Username = $username }
    }

    # the login page itself
    Add-PodeRoute -Method Get -Path '/login' -Authentication 'Login' -Login -ScriptBlock {
        Write-PodeViewResponse -Path 'login.pode' -FlashMessages
    }

    # the POST action for the <form>
    Add-PodeRoute -Method Post -Path '/login' -Authentication 'Login' -Login
    
    # the logout Route
    Add-PodeRoute -Method Post -Path '/logout' -Authentication 'Login' -Logout
    Add-PodeRoute -Method Get -Path '/logout' -Authentication 'Login' -Logout -ScriptBlock {
        # Beende die aktuelle Sitzung, um den Benutzer auszuloggen
        Remove-PodeAuth -Name 'Login'
    
        # Leite den Benutzer auf die Login-Seite weiter (oder eine andere Seite)
        Redirect-PodeRoute -Location '/login'
    }
    #endregion

    Import-Module PSSQLite -Force
    
    $BinPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
    Import-Module -FullyQualifiedName (Join-Path -Path $BinPath -ChildPath 'RotaMaster.psd1')

    # Add listener to Port 8080 for Protocol http
    Add-PodeEndpoint -Address $Address -Port $Port -Protocol $Protocol -SelfSigned

    # Set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode
    
    # Set Pode endpoints for the web pages
    Initialize-WebEndpoints

    # Set Pode endpoints for the api
    Initialize-ApiEndpoints

} -Verbose 

#endregion