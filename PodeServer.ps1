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
            Write-PodeViewResponse -Path 'Index.pode'
        }
        # Test
        Add-PodeRoute -Method Get -Path '/test' -ScriptBlock {
            Write-PodeViewResponse -Path 'test.html'
        }
        # PS Calendar
        Add-PodeRoute -Method Get -Path '/ps-calendar' -ScriptBlock {
            Write-PodeViewResponse -Path 'ps-calendar.pode'
        }
        # Full Calendar
        Add-PodeRoute -Method Get -Path '/full-calendar' -ScriptBlock {
            Write-PodeViewResponse -Path 'full-calendar.pode'
        }
        # Year Calendar
        Add-PodeRoute -Method Get -Path '/year-calendar' -ScriptBlock {
            Write-PodeViewResponse -Path 'year-calendar.pode'
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
        $DbPath  = $($BinPath).Replace('bin','db')

        Add-PodeRoute -Method Post -Path '/api/month/next' -ContentType 'application/json' -ArgumentList @($BinPath) -ScriptBlock {
            param($BinPath)
            
            $body = $WebEvent.Data

            # 'Now' | Out-Default
            # $CurrentMonth = ([System.DateTime]::Now).Month

            # 'WebData' | Out-Default
            # $MonthName     = [PSCustomObject]$WebEvent.Data.Month
            # $currCulture   = [system.globalization.cultureinfo]::CurrentCulture
            # $MonthAsNumber = [System.DateTime]::ParseExact($MonthName, 'MMMM', $currCulture).Month
            
            if($CurrentOS -eq [OSType]::Windows){Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force}
            $Response = . $(Join-Path $BinPath -ChildPath 'New-PshtmlCalendar.ps1') -Title 'PS calendar' -Year $body.Year -Month $body.Month
            Write-PodeJsonResponse -Value $Response    

        }

        Add-PodeRoute -Method Post -Path '/api/year/new' -ContentType 'application/text' -ArgumentList @($DbPath) -ScriptBlock {
            param($DbPath)
            
            $Year    = [int]$WebEvent.Data
            $NewFile = (Join-Path -Path $DbPath -ChildPath "$($Year).csv")

            if(-not(Test-Path $NewFile)){            
                $data = Get-SwissHolidays -Year $Year
                $data | Export-Csv -Path $NewFile -Delimiter ';' -Encoding utf8 -Append -NoTypeInformation
                Write-PodeJsonResponse -Value ($data | ConvertTo-Json)
            }
        }

        Add-PodeRoute -Method Post -Path '/api/event/new' -ArgumentList @($DbPath) -ScriptBlock {
            param($DbPath)

            # Read the data of the formular
            if(-not([String]::IsNullOrEmpty($WebEvent.Data['name']))){
                $title  = $WebEvent.Data['name']
                # $descr  = $WebEvent.Data['description']
                $type   = $WebEvent.Data['type']
                $start  = $WebEvent.Data['start']
                $end    = $WebEvent.Data['end']
                
                # "new-events: $($title), $($start), $($end)"| Out-Default
                $data = [PSCustomObject]@{
                    Id    = [guid]::NewGuid()
                    Title = $title
                    # Description = $descr
                    Type    = $type
                    Start   = Get-Date ([datetime]$start) -f 'yyyy-MM-dd'
                    End     = Get-Date ([datetime]$end).AddDays(1) -f 'yyyy-MM-dd'
                    Created = Get-Date -f 'yyyy-MM-dd'
                }

                $data | Export-Csv -Path (Join-Path -Path $DbPath -ChildPath "calendar.csv") -Delimiter ';' -Encoding utf8 -Append -NoTypeInformation

                Write-PodeJsonResponse -Value $($WebEvent.Data | ConvertTo-Json)

            }
            # How can I reload the full-calendar page?
            
        }

        # Route zum Abrufen der Events als JSON
        Add-PodeRoute -Method Get -Path '/api/event/get' -ArgumentList @($DbPath) -ScriptBlock {
            param($DbPath)
            $data = Get-ChildItem -Path $DbPath -Filter '*.csv' | ForEach-Object {
                Import-Csv -Path $PSItem.Fullname -Delimiter ';' -Encoding utf8
            }

            $events = foreach($item in $data){
                switch -RegEx ($item.type){
                    'Pikett'                    { $color = '#cd00cd'} # purple
                    'Pikett Pier'               { $color = '#ffa500'} # orange
                    'Kurs'                      { $color = '#3498db'} # blue
                    'Militär|Zivil'             { $color = '#006400'} # dark green
                    'Ferien|Feiertag|Gleitzeit' { $color = '#05c27c'} # green
                    default                     { $color = '#378006'}
                }
                [PSCustomObject]@{
                    title = if($item.type -ne 'Feiertag'){$item.title, $item.type -join " - "}else{$item.title}
                    # description = $item.description
                    start = $item.start
                    end   = $item.end
                    color = $color
                } 
            }
            # Gebe die Events als JSON aus, damit sie im Calendar angezeigt werden
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

    0 | Set-PodeCache -Key Count -Ttl 10

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