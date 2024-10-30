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
function Get-EventColor{
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$type
    )

    begin{
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)", $type -Join ' ')
    }

    process{
        switch -RegEx ($type){
            '^Patch wave \d{1}$' {$color = '#d8d800'; break}
            '^Pikett$' { $color = 'red'; break}
            '^Pikett-Pier$' { $color = 'orange'; break} # orange
            'Kurs|Aus/Weiterbildung' { $color = '#A37563'; break}
            'Militär/ZV/EO|Zivil' { $color = '#006400'; break} # dark green
            '^Ferien$' { $color = '#05c27c'; break} # green
            '^Feiertag$' { $color = '#B9E2A7'; break} # green
            'GLZ Kompensation|Absenz|Urlaub' { $color = '#889CC6'; break} # green
            'Krankheit|Unfall' { $color = '#212529'; break}
            default { $color = '#378006'}
        }
        return $color
    }

    end{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    }

}

function Initialize-FileWatcher {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [String]$Watch
    )

    begin{
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)", $Watch -Join ' ')
    }

    process{

        Add-PodeFileWatcher -Name PodePSHTML -Path $Watch -ScriptBlock {

            Write-Verbose "$($FileEvent.Name) -> $($FileEvent.Type) -> $($FileEvent.FullPath)"

            $BinPath  = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'

            try{
                "        - Received: $($FileEvent.Name) at $($FileEvent.Timestamp)" | Out-Default
                switch -Regex ($FileEvent.Type){
                    'Created|Changed' {
                        # Move-Item, New-Item
                        switch -Regex ($FileEvent.Name){
                            'index.txt' {
                                Start-Sleep -Seconds 3
                                Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
                                . $(Join-Path $BinPath -ChildPath 'New-PshtmlIndexPage.ps1') -Title 'Index' -Request 'FileWatcher'
                            }
                        }

                        $index   = Join-Path -Path $($PSScriptRoot) -ChildPath 'views/index.pode'
                        $content = Get-Content $index
                        $content -replace 'Created at\s\d{4}\-\d{2}\-\d{2}\s\d{2}\:\d{2}\:\d{2}', "Created at $(Get-Date -f 'yyyy-MM-dd HH:mm:ss')" | Set-Content -Path $index -Force -Confirm:$false

                    }
                    'Deleted' {
                        # Move-Item, Remove-Item
                    }
                    'Renamed' {
                        # Rename-Item
                    }
                    default {
                        "        - $($FileEvent.Type): is not supported" | Out-Default
                    }

                }
            }catch{
                Write-Warning "$($function): An error occured on line $($_.InvocationInfo.ScriptLineNumber): $($_.Exception.Message)"
                $Error.Clear()
            }

        } -Verbose

    }

    end{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    }
}

function Initialize-WebEndpoints {
    [CmdletBinding()]
    param()

    begin{
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)", $Watch -Join ' ')
    }

    process{
        # Index
        Add-PodeRoute -Method Get -Path '/' -ScriptBlock {
            Write-PodeViewResponse -Path 'index.html'
        }
    }

    end{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    }

}

function Initialize-ApiEndpoints {
    [CmdletBinding()]
    param()

    begin{
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', "$($function)", $Watch -Join ' ')
    }

    process{
        $BinPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
        $ApiPath = $($BinPath).Replace('bin','api')
        $dbPath = Join-Path -Path $($ApiPath) -ChildPath '/rotamaster.db'

        # Get person from JSON-file
        Add-PodeRoute -Method Get -Path '/api/events/person' -ArgumentList @($ApiPath) -ScriptBlock {
            param($ApiPath)
            $person = Get-Content -Path (Join-Path -Path $ApiPath -ChildPath 'person.json') | ConvertFrom-Json | Sort-Object
            Write-PodeJsonResponse -Value $person  
        }

        # Get absences from JSON-file
        Add-PodeRoute -Method Get -Path '/api/events/absence' -ArgumentList @($ApiPath) -ScriptBlock {
            param($ApiPath)
            $absence = Get-Content -Path (Join-Path -Path $ApiPath -ChildPath 'absence.json') | ConvertFrom-Json | Sort-Object
            Write-PodeJsonResponse -Value $absence  
        }

        <# Calculate next month for PS calendar
        Add-PodeRoute -Method Post -Path '/api/month/next' -ContentType 'application/json' -ArgumentList @($BinPath) -ScriptBlock {
            param($BinPath)
            
            $body = $WebEvent.Data
            
            if($CurrentOS -eq [OSType]::Windows){Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force}
            $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlCalendar.ps1') -Title 'PS calendar' -Year $body.Year -Month $body.Month
            Write-PodeJsonResponse -Value $Response    

        }
        #>

        # Calculate swiss holidays for next year
        Add-PodeRoute -Method Post -Path '/api/year/new' -ContentType 'application/text' -ArgumentList @($ApiPath) -ScriptBlock {
            param($ApiPath)
            
            $Year    = [int]$WebEvent.Data
            $NewFile = (Join-Path -Path $ApiPath -ChildPath "holidays$($Year).csv")

            if(-not(Test-Path $NewFile)){            
                $data = Get-SwissHolidays -Year $Year
                $data | Export-Csv -Path $NewFile -Delimiter ';' -Encoding utf8 -Append -NoTypeInformation
                Write-PodeJsonResponse -Value ($data | ConvertTo-Json)
            }
        }

        <# obsolete
        Add-PodeRoute -Method Post -Path '/api/event/new' -ArgumentList @($ApiPath) -ScriptBlock {
            param($ApiPath)

            # Read the data of the formular
            if((-not([String]::IsNullOrEmpty($WebEvent.Data['name'])) -and (-not([String]::IsNullOrEmpty($WebEvent.Data['type']))))){
                $title  = $WebEvent.Data['name']
                # $descr  = $WebEvent.Data['description']
                $type   = $WebEvent.Data['type']
                $start  = $WebEvent.Data['start']
                $end    = $WebEvent.Data['end']
                
                # "new-events: $($title), $($start), $($end)"| Out-Default
                # $EndSate = Get-Date ([datetime]$end).AddDays(1) -f 'yyyy-MM-dd'
                $EndSate = "$(Get-Date ([datetime]$end) -f 'yyyy-MM-dd')"
                $data = [PSCustomObject]@{
                    # Id    = [guid]::NewGuid()
                    person  = $title
                    # Description = $descr
                    type    = $type
                    start   = "$(Get-Date ([datetime]$start) -f 'yyyy-MM-dd')"
                    end     = $EndSate 
                    created = Get-Date -f 'yyyy-MM-dd'
                }

                # $data | Export-Csv -Path (Join-Path -Path $ApiPath -ChildPath "calendar.csv") -Delimiter ';' -Encoding utf8 -Append -NoTypeInformation

                Write-PodeJsonResponse -Value $($data | ConvertTo-Json)

            }else{
                Write-PodeJsonResponse -StatusCode 400 -Value @{ StatusDescription = 'No person or type is selected!' }
            }
            
        }
        #>

        # Add new record into the SQLiteDB
        Add-PodeRoute -Method POST -Path '/api/event/insert' -ArgumentList @($dbPath) -ScriptBlock {
            param($dbPath)
            # Read the data of the formular
            if((-not([String]::IsNullOrEmpty($WebEvent.Data['name'])) -and (-not([String]::IsNullOrEmpty($WebEvent.Data['type']))))){
                try{
                    $person  = $WebEvent.Data['name']
                    $type    = $WebEvent.Data['type']
                    $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd')"
                    $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd')"
                    $created = Get-Date -f 'yyyy-MM-dd'
    
                    $sql = "INSERT INTO events (person, type, start, end, created) VALUES ('$($person)', '$($type)', '$($start)', '$($end)', '$($created)')"
                    $connection = New-SQLiteConnection -DataSource $dbPath
                    Invoke-SqliteQuery -Connection $connection -Query $sql
                    $Connection.Close()
                    Write-PodeJsonResponse -Value $($data | ConvertTo-Json)
                }catch{
                    $_.Exception.Message | Out-Default
                    Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
                }
            }else{
                Write-PodeJsonResponse -StatusCode 400 -Value @{ StatusDescription = 'No person or type is selected!' }
            }
        }

        # Read data from SQLiteDB for events
        Add-PodeRoute -Method Get -Path 'api/event/read' -ArgumentList @($dbPath) -ScriptBlock {
            param($dbPath)
            try{
                $sql = 'SELECT person,"type",start,end FROM events'
                $connection = New-SQLiteConnection -DataSource $dbPath
                $data = Invoke-SqliteQuery -Connection $connection -Query $sql

                $events = foreach($item in $data){
                    switch -Regex ($item.type){
                        'Feiertag|Patch wave' {$title = $item.title; break}
                        default {$title = $item.person, $item.type -join " - "}
                    }
                    [PSCustomObject]@{
                        title = $title
                        type  = $item.type
                        start = Get-Date $item.start -f 'yyyy-MM-dd'
                        end   = Get-Date (Get-Date $item.end).AddDays(1) -f 'yyyy-MM-dd'
                        color = Get-EventColor -type $item.type
                    } 
                }
                $Connection.Close()
                Write-PodeJsonResponse -Value $($events | ConvertTo-Json)
            }catch{
                $_.Exception.Message | Out-Default
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }

        # Get events from CSV and return it as JSON, used for swiss holidays
        Add-PodeRoute -Method Get -Path '/api/event/get' -ArgumentList @($ApiPath) -ScriptBlock {
            param($ApiPath)
            $data = Get-ChildItem -Path $ApiPath -Filter '*.csv' | ForEach-Object {
                Import-Csv -Path $PSItem.Fullname -Delimiter ';' -Encoding utf8
            }

            $events = foreach($item in $data){
                switch -Regex ($item.type){
                    'Feiertag|Patch wave' {$title = $item.title; break}
                    default {$title = $item.title, $item.type -join " - "}
                }
                [PSCustomObject]@{
                    title = $title
                    type  = $item.type
                    start = Get-Date $item.start -f 'yyyy-MM-dd'
                    end   = Get-Date (Get-Date $item.end).AddDays(1) -f 'yyyy-MM-dd'
                    color = Get-EventColor -type $item.type
                } 
            }
            Write-PodeJsonResponse -Value $events
        }
    }

    end{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    }

}
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

    # if($CurrentOS -eq [OSType]::Mac){
    #     Write-Host "Re-builds of pages not supportet on $($CurrentOS), because mySQLite support only Windows and Linux" -ForegroundColor Red
    # }
    Import-Module PSSQLite -Force

    $BinPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
    Import-Module -FullyQualifiedName (Join-Path -Path $BinPath -ChildPath 'PSCalendar.psd1')

    # Enables Error Logging
    New-PodeLoggingMethod -Terminal | Enable-PodeErrorLogging

    # Add listener to Port 8080 for Protocol http
    Add-PodeEndpoint -Address $Address -Port $Port -Protocol $Protocol

    # Set the engine to use and render .pode files
    Set-PodeViewEngine -Type Pode

    # Add File Watcher
    # $WatcherPath = Join-Path -Path $($PSScriptRoot) -ChildPath 'upload'
    # Initialize-FileWatcher -Watch $WatcherPath
    
    # Set Pode endpoints for the web pages
    Initialize-WebEndpoints

    # Set Pode endpoints for the api
    Initialize-ApiEndpoints

} -Verbose 

#endregion