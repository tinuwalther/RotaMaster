# Importiere die benötigten Module
Import-Module Pode
Import-Module Pode.Web

#region Functions
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
$Port = 8088
$Protocol = 'http'
# Erstelle den Webserver
Start-PodeServer -Browse {

    $PodeRootPath = $($PSScriptRoot).Replace('bin','')

    Write-Host "Press Ctrl. + C to terminate the Pode server" -ForegroundColor Yellow

    <#     
    Import-PodeWebStylesheet -Url 'https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.css'
    Import-PodeWebJavaScript -Url 'https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.js'

    Import-PodeWebStylesheet -Url 'https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css'
    Import-PodeWebStylesheet -Url 'https://cdn.jsdelivr.net/npm/bootstrap-icons@1.8.1/font/bootstrap-icons.css'

    Import-PodeWebStylesheet -Url 'https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.css'
    Import-PodeWebJavaScript -Url 'https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.js'
    #>

    # Enables Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Set the engine to use and render .pode files
    # Set-PodeViewEngine -Type Pode
    
    Use-PodeWebTemplates -Title 'RotaMaster' -Theme Dark

    # Add dynamic pages
    Get-ChildItem (Join-Path $PodeRootPath -ChildPath 'pages') -filter "*.ps1" | ForEach-Object {
        . "$($PSItem.FullName)"
    } | Sort-Object -Descending
    
    # Route, um die Events als JSON bereitzustellen
    Add-PodeRoute -Method Get -Path '/get-events' -ScriptBlock {
        # Beispiel-Events (diese könntest du aus einer Datei oder Datenbank laden)
        $events = @(
            @{
                title = 'Ferien - Max Mustermann'
                start = '2024-09-20'
                end = '2024-09-25'
            },
            @{
                title = 'Militärdienst - John Doe'
                start = '2024-10-01'
                end = '2024-10-10'
            }
        )

        # Gib die Events als JSON aus
        Write-PodeJsonResponse -Value $events
    }
        
    # Add listener to Port 8080 for Protocol http
    Add-PodeEndpoint -Address $Address -Port $Port -Protocol $Protocol

} -Verbose 
#endregion