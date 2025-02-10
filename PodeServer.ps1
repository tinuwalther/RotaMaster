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

# We'll use 2 threads to handle API requests
Start-PodeServer -Browse -Threads 2 {
    Write-Host "Press Ctrl. + C to terminate the Pode server" -ForegroundColor Yellow

    # Enables Logging
    # [System.Diagnostics.EventLog]::CreateEventSource('RotaMaster', 'Application')
    # New-PodeLoggingMethod -EventViewer -EventLogName 'Application' -Source 'RotaMaster' -Batch 10
    # try {...}catch {$_ | Write-PodeErrorLog}
    New-PodeLoggingMethod -File -Name 'error'    -MaxDays 7 -Batch 10 | Enable-PodeErrorLogging
    New-PodeLoggingMethod -File -Name 'requests' -MaxDays 7 -Batch 10 | Enable-PodeRequestLogging

    # Here our sessions will last for 10 Std, and will be extended on each request
    Enable-PodeSessionMiddleware -Duration 36000 -Extend

    # Rate limit
    # Add-PodeLimitRule -Type IP -Values * -Limit 200 -Seconds 10
    Add-PodeLimitRule -Type Route -Values '/api' -Limit 10 -Seconds 1

    # Setup ActiveDirectory authentication
    # https://pode.readthedocs.io/en/latest/Tutorials/Authentication/Inbuilt/WindowsAD/#usage
    # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -DirectGroups or
    # New-PodeAuthScheme -Form | Add-PodeAuthWindowsAd -Name 'Login' -Groups @('RotaMaster-App-GS') -FailureUrl '/login' -SuccessUrl '/' -KeepCredential -ScriptBlock {
    #     param($user)
    #     $cookieData = @{
    #         name  = $user.Name
    #         login = $user.Username
    #         email = $user.Email
    #     }
    #     $jsonData = $cookieData | ConvertTo-Json -Depth 10 -Compress
    #     Set-PodeCookie -Name 'CurrentUser' -Value $jsonData
    #     return @{ User = $user }
    # }

    # Setup File authentication -> Initialize-WebEndpoints in RotaMaster.psm1
    $ApiPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'api'
    New-PodeAuthScheme -Form | Add-PodeAuthUserFile -FilePath (Join-Path -Path $ApiPath -ChildPath 'users.json') -Name 'Login' -FailureUrl '/login' -SuccessUrl '/' -ScriptBlock {
        param($user)
        $cookieData = @{
            name  = $user.Name
            login = $user.Username
            email = $user.Email
        }
        $jsonData = $cookieData | ConvertTo-Json -Depth 10 -Compress

        # encode JSON explicit to UTF-8 no BOM
        $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonData)
        $utf8Json = [System.Text.Encoding]::UTF8.GetString($utf8Bytes)

        # encode JSON to URL
        $encodedJson = [System.Web.HttpUtility]::UrlEncode($utf8Json)

        # Set cookie with encoded JSON no BOM and URL encoded, add 1 day to expiry date
        Set-PodeCookie -Name "CurrentUser" -Value $encodedJson -ExpiryDate (Get-Date).AddDays(1)

        return @{ User = $user }
    }

    Import-Module PSSQLite -Force
    
    $BinPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
    Import-Module -FullyQualifiedName (Join-Path -Path $BinPath -ChildPath 'RotaMaster.psd1')

    # Add listener
    $Port     = (Get-PodeConfig).Port
    $Protocol = (Get-PodeConfig).Protocol
    # Add-PodeEndpoint -Hostname example.pode.com -Port $Port -Protocol $Protocol -LookupHostname
    Add-PodeEndpoint -Address $Address -Port $Port -Protocol $Protocol -SelfSigned

    # Set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode
    
    # Set Pode endpoints for the web pages
    Initialize-WebEndpoints

    # Set Pode endpoints for the api
    Initialize-ApiEndpoints

} -Verbose 

#endregion