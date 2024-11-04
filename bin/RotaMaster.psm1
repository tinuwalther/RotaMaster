#region main
# $Month = @('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')
# foreach($item in $Month) {
#     $monthAbbreviation = Get-MonthAbbreviation -MonthName $item
#     Get-MonthCalendar -MonthName $item -Year $Year | Select-Object @{N='Jahr';E={$Year}}, @{N='Monat';E={$monthAbbreviation}}, * | Format-Table -AutoSize
# }
#endregion

#region functions
function Get-MonthCalendar{
    <#
    .SYNOPSIS
        Generates a monthly calendar for a given month and year, displaying the days and calendar weeks.

    .DESCRIPTION
        The `Get-MonthCalendar` function creates a table representing the days of a specified month and year.
        It calculates the corresponding week numbers and displays the days from Sunday to Saturday, 
        starting each row with the corresponding calendar week. The function handles months with varying lengths
        and adjusts for partial weeks at the start and end of the month.

    .PARAMETER MonthName
        The full name of the month (e.g., "January", "Februar"). This parameter is mandatory and must be a valid month name 
        according to the system's current culture settings.

    .PARAMETER Year
        The year for which the calendar should be generated. This parameter is mandatory and must be a valid integer.

    .EXAMPLE
        Get-MonthCalendar -MonthName "March" -Year 2023
        This will generate the calendar for March 2023, showing the days and corresponding week numbers.

    .EXAMPLE
        Get-MonthCalendar -MonthName "Oktober" -Year 2022
        This will generate the calendar for October 2022, in accordance with German culture settings.

    .NOTES
        The function uses the system's current culture settings to interpret the month name and determine the first day of the week. 
        It adjusts for varying month lengths and properly handles leap years. Calendar weeks are calculated based on the regional settings.
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$MonthName,
        
        [Parameter(Mandatory=$true)]
        [Int] $Year
    )

    # Attempts to convert the month name into a valid month number
    # $currCulture   = [system.globalization.cultureinfo]::CurrentCulture = 'en-US'
    $currCulture   = [system.globalization.cultureinfo]::CurrentCulture
    $MonthAsNumber = [datetime]::ParseExact($MonthName, 'MMMM', $currCulture).Month

    $firstDayOfMonth = [datetime]::new($Year, $MonthAsNumber, 1)
    $lastDayOfMonth = $firstDayOfMonth.AddMonths(1).AddDays(-1)

    # Monday is start day in German Swiss culture
    $firstDayOfWeek = [System.DayOfWeek]::Monday

    # Calculate offset correctly
    $startOffset = ($firstDayOfMonth.DayOfWeek - $firstDayOfWeek + 7) % 7

    # Calendar structure building
    $calendarRows = @()
    $week = @()

    # Fill initial offset
    for ($i = 0; $i -lt $startOffset; $i++) {
        $week += $null  
    }

    # Insert days of month
    for ($day = 1; $day -le $lastDayOfMonth.Day; $day++) {
        $week += $day

        if ($week.Count -eq 7) {
            $calendarRows += [pscustomobject]@{
                Woche      = $currCulture.Calendar.GetWeekOfYear($firstDayOfMonth.AddDays($day - 1), $currCulture.DateTimeFormat.CalendarWeekRule, $firstDayOfWeek)
                Montag     = $week[0]
                Dienstag   = $week[1]
                Mittwoch   = $week[2]
                Donnerstag = $week[3]
                Freitag    = $week[4]
                Samstag    = $week[5]
                Sonntag    = $week[6]
            }
            $week = @()
        }
    }

    # Finalize remaining days
    if ($week.Count -gt 0) {
        while ($week.Count -lt 7) {
            $week += $null  
        }

        $calendarRows += [pscustomobject]@{
            Woche = $currCulture.Calendar.GetWeekOfYear($lastDayOfMonth, $currCulture.DateTimeFormat.CalendarWeekRule, $firstDayOfWeek)
            Montag     = $week[0]
            Dienstag   = $week[1]
            Mittwoch   = $week[2]
            Donnerstag = $week[3]
            Freitag    = $week[4]
            Samstag    = $week[5]
            Sonntag    = $week[6]
        }
    }

    # Return corrected calendar
    return $calendarRows
}

function Get-MonthAbbreviation {
    <#
    .SYNOPSIS
        Returns the abbreviated month name for a given full month name.

    .DESCRIPTION
        The `Get-MonthAbbreviation` function takes a full month name (e.g., "January" or "Januar") as input and returns the corresponding abbreviated month name (e.g., "Jan").
        It uses the current culture settings of the system to interpret the month name and retrieve the abbreviated form.
        The function works for any valid month name in the system's current language and culture.

    .PARAMETER MonthName
        The full name of the month as a string (e.g., "January", "Februar"). This parameter is mandatory.
        The month name must match the system's current culture setting (e.g., "English (United States)" or "German (Germany)").

    .EXAMPLE
        Get-MonthAbbreviation -MonthName "March"
        This will return "Mar" if the current culture is English.

    .EXAMPLE
        Get-MonthAbbreviation -MonthName "März"
        This will return "Mär" if the current culture is German.

    .NOTES
        The function depends on the system's current culture settings, so the input and output month names are localized accordingly.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$MonthName
    )

    # Attempts to convert the month name into a valid month number
    $currCulture   = [system.globalization.cultureinfo]::CurrentCulture
    $MonthAsNumber = [datetime]::ParseExact($MonthName, 'MMMM', $currCulture).Month

    # Retrieve monthly abbreviations
    $monthAbbreviation = $currCulture.DateTimeFormat.AbbreviatedMonthNames[$MonthAsNumber - 1]

    return $monthAbbreviation
}

function Get-SwissHolidays {
    <#
    .SYNOPSIS
        Calculates movable holidays based on the Easter Sunday for a given year and returns a list of holidays.

    .DESCRIPTION
        This function uses Carl Friedrich Gauss's algorithm to calculate the date of Easter Sunday and derives other holidays such as Good Friday, Easter Monday, Ascension Day, and Pentecost Monday. 
        Additionally, it generates general holidays such as New Year's Day, Labor Day, and Christmas for all Swiss cantons, as well as specific holidays for certain cantons.

    .PARAMETER Year
        The year for which the holidays should be calculated. The value must be between 1970 and 2999.

    .OUTPUTS
        PSCustomObject
        Returns a list of holidays as PSCustomObject, including the date, title, canton, and other information.

    .EXAMPLE
        Get-SwissHolidays -Year 2024
        Calculates holidays for the year 2024 and returns them as a list of objects.

    .NOTES
        The algorithm to calculate Easter Sunday was devised by Carl Friedrich Gauss.
    #>
    [CmdletBinding()]
    param(
        [ValidateRange(1970, 2999)]
        [Parameter(Mandatory = $true)]
        [Int] $Year
    )

    function Get-EasterSunday {
        param (
            [int]$year
        )

        # Algorithm by Carl Friedrich Gauss to calculate Easter Sunday
        $a = $year % 19
        $b = [math]::Floor($year / 100)
        $c = $year % 100
        $d = [math]::Floor($b / 4)
        $e = $b % 4
        $f = [math]::Floor(($b + 8) / 25)
        $g = [math]::Floor(($b - $f + 1) / 3)
        $h = (19 * $a + $b - $d - $g + 15) % 30
        $i = [math]::Floor($c / 4)
        $k = $c % 4
        $l = (32 + 2 * $e + 2 * $i - $h - $k) % 7
        $m = [math]::Floor(($a + 11 * $h + 22 * $l) / 451)
        $month = [math]::Floor(($h + $l - 7 * $m + 114) / 31)
        $day = (($h + $l - 7 * $m + 114) % 31) + 1

        # Return Easter Sunday as a DateTime object
        return Get-Date -Year $year -Month $month -Day $day
    }

    # Calculate movable holidays based on Easter Sunday
    $easterSunday    = (Get-EasterSunday -year $Year).ToString("yyyy-MM-dd")
    $goodFriday      = (Get-EasterSunday -year $Year).AddDays(-2).ToString("yyyy-MM-dd")
    $easterMonday    = (Get-EasterSunday -year $Year).AddDays(1).ToString("yyyy-MM-dd")
    $ascensionDay    = (Get-EasterSunday -year $Year).AddDays(39).ToString("yyyy-MM-dd")
    $pentecostSunday = (Get-EasterSunday -year $Year).AddDays(49).ToString("yyyy-MM-dd")
    $pentecostMonday = (Get-EasterSunday -year $Year).AddDays(50).ToString("yyyy-MM-dd")

    # List of holidays as PSCustomObject
    $holidays_special = @(
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-01-01"; title = "Neujahrstag"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-01-02"; title = "Berchtoldstag"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = $goodFriday; title = "Karfreitag"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = $easterSunday; title = "Ostern"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = $easterMonday; title = "Ostermontag"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-05-01"; title = "Tag der Arbeit (ZH, GR)"; Canton = "ZH, GR" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = $ascensionDay; title = "Auffahrt"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = $pentecostSunday; title = "Pfingsten"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = $pentecostMonday; title = "Pfingstmontag"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-08-01"; title = "Bundesfeier"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-11-01"; title = "Allerheiligen (SG, BE)"; Canton = "SG, BE" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-12-25"; title = "Weihnachtstag"; Canton = "ALL" }
        [PSCustomObject]@{ id = ([GUID]::NewGuid()); Date = "$($Year)-12-26"; title = "Stephanstag"; Canton = "ALL" }
    )

    # Output the list of holidays
    return $holidays_special | Select-Object id,title,@{N='type';E={'Feiertag'}},@{N='start';E={$_.Date}},@{N='end';E={$_.Date}},@{N='created';E={(Get-Date -f 'yyyy-MM-dd')}}
}

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
        $colorMap = @(
            @{ Regex = '^Patch wave \d{1}$'; Color = '#d8d800' }
            @{ Regex = '^Pikett$'; Color = 'red' }
            @{ Regex = '^Pikett-Pier$'; Color = 'orange' }
            @{ Regex = '^(Kurs|Aus\/Weiterbildung)$'; Color = '#A37563' }
            @{ Regex = '^(Militär|ZV\/EO|Zivil)$'; Color = '#006400' }
            @{ Regex = '^Ferien$'; Color = '#05c27c' }
            @{ Regex = '^Feiertag$'; Color = '#B9E2A7' }
            @{ Regex = '^(GLZ Kompensation|Absenz|Urlaub)$'; Color = '#889CC6' }
            @{ Regex = '^(Krankheit|Unfall)$'; Color = '#212529' }
        )
        foreach ($item in $colorMap) {
            if ($Type -match $item.Regex) {
                return $item.Color
            }
        }
        return '#378006'
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
        $BinPath = $PSScriptRoot #Join-Path -Path $($PSScriptRoot) -ChildPath 'bin'
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
                $sql = 'SELECT id,person,"type",start,end FROM events'
                $connection = New-SQLiteConnection -DataSource $dbPath
                $data = Invoke-SqliteQuery -Connection $connection -Query $sql

                $events = foreach($item in $data){
                    switch -Regex ($item.type){
                        'Feiertag|Patch wave' {$title = $item.title; break}
                        default {$title = $item.person, $item.type -join " - "}
                    }
                    [PSCustomObject]@{
                        id = $item.id
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
