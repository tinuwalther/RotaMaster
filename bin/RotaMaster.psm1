#region main
# $Month = @('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')
# foreach($item in $Month) {
#     $monthAbbreviation = Get-MonthAbbreviation -MonthName $item
#     Get-MonthCalendar -MonthName $item -Year $Year | Select-Object @{N='Jahr';E={$Year}}, @{N='Monat';E={$monthAbbreviation}}, * | Format-Table -AutoSize
# }
#endregion

#region functions
function Get-OpsGenieSchedule {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Test-Compute_schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                # $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule?identifierType=name"
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                }

                # Construct the URL for the specific rotation
                #$Url = "$BaseUrl/$RotationId"

                # Send the GET request to OpsGenie API
                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    #$Response | ConvertTo-Json -Depth 10 | Write-Output
                    if($Response){
                        $Response.data
                    }else{
                        $Response
                    }
                }
                catch {
                    Write-Warning "Failed to retrieve ."
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function Get-OpsGenieRotation {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Test-Compute_schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/rotations?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                }

                # Construct the URL for the specific rotation
                #$Url = "$BaseUrl/$RotationId"

                # Send the GET request to OpsGenie API
                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    #$Response | ConvertTo-Json -Depth 10 | Write-Output
                    if($Response){
                        $Response.data
                    }else{
                        $Response
                    }
                }
                catch {
                    Write-Warning "Failed to retrieve ."
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function New-OpsGenieRotation {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Test-Compute_schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $Rotation,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $startDate,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 3
        )]
        [String] $endDate,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 4
        )]
        [Object] $participants,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 5
        )]
        [String] $ApiKey
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/rotations?scheduleIdentifierType=name"

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                    "Content-Type" = "application/json"
                }

                # Create the body the API request
                $Payload = [PSCustomObject]@{
                    name         = $Rotation
                    startDate    = (Get-Date $startDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    endDate      = (Get-Date $endDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                    type         = 'weekly'
                    participants = $participants
                }
                $JsonPayload = $Payload | ConvertTo-Json -Depth 10 -Compress
                Write-Verbose $($Payload | Out-String) -Verbose

                try {
                    Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method POST -Body $JsonPayload
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

function Get-OpsGenieOverride {
    <#
    .SYNOPSIS
        A short one-line action-based description, e.g. 'Tests if a function is valid'
    .DESCRIPTION
        A longer description of the function, its purpose, common use cases, etc.
    .NOTES
        Information or caveats about the function e.g. 'This function is not supported in Linux'
    .EXAMPLE
        New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
        Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
    #>
    [CmdletBinding(SupportsShouldProcess=$True)]
    param(
        # Test-Compute_schedule
        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 0
        )]
        [String] $Schedule,

        [Parameter(
            Mandatory=$true,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 1
        )]
        [String] $ApiKey,

        [Parameter(
            Mandatory=$false,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true,
            Position = 2
        )]
        [String] $Alias
    )

    begin{
        #region Do not change this region
        $StartTime = Get-Date
        $function = $($MyInvocation.MyCommand.Name)
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
        #endregion
    }

    process{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
        foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
        if ($PSCmdlet.ShouldProcess($params.Trim())){
            try{
                # Define variables
                if([String]::IsNullOrEmpty($Alias)){
                    $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/overrides?scheduleIdentifierType=name"
                }else{
                    # $ScheduleId = Get-IXOpsGenieSchedule -Schedule $Schedule -ApiKey $ApiKey | Select-Object -ExpandProperty Id
                    # $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$($ScheduleId)/overrides/$($Alias)"
                    $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$($Schedule)/overrides/$($Alias)"
                }

                # Create headers for the API request
                $Headers = @{
                    Authorization = "GenieKey $ApiKey"
                    "Content-Type" = "application/json"
                }

                try {
                    $Response = Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method Get
                    if($Response){
                        $Response.data
                    }else{
                        $Response
                    }
                }
                catch {
                    Write-Warning $_.Exception.Message
                }
            }catch{
                Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                $Error.Clear()
            }
        }
    }

    end{
        #region Do not change this region
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
        $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
        $Formatted = $TimeSpan | ForEach-Object {
            '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
        }
        Write-Verbose $('Finished in:', $Formatted -Join ' ')
        #endregion
    }
}

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
            @{ Regex = '^Pikett-Peer$'; Color = 'orange' }
            @{ Regex = '^(Kurs|Aus/Weiterbildung)$'; Color = '#A37563' }
            @{ Regex = '^(Militär/ZV/EO|Zivil)$'; Color = '#006400' }
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
        return '#4F0680'
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
            if(Test-PodeCookie  -Name 'CurrentUser'){
                Remove-PodeCookie -Name 'CurrentUser'
            }
            # Leite den Benutzer auf die Login-Seite weiter (oder eine andere Seite)
            Redirect-PodeRoute -Location '/login'
        }

        # Absence
        Add-PodeRoute -Method Get -Path '/absence' -Authentication 'Login' -ScriptBlock {
            Write-PodeViewResponse -Path 'absence.html'
        }
        # Person
        Add-PodeRoute -Method Get -Path '/person' -Authentication 'Login' -ScriptBlock {
            Write-PodeViewResponse -Path 'person.html'
        }
        # About
        Add-PodeRoute -Method Get -Path '/about' -Authentication 'Login' -ScriptBlock {
            Write-PodeViewResponse -Path 'about.html'
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
        $LogPath = $($BinPath).Replace('bin','logs')
        $Logfile = Join-Path -Path $LogPath -ChildPath "informational_$(Get-Date -f 'yyyy-MM-dd').log"
        $dbPath = Join-Path -Path $($ApiPath) -ChildPath '/rotamaster.db'

        # Calculate swiss holidays for next year
        Add-PodeRoute -Method Post -Path '/api/year/new' -ContentType 'application/text' -ArgumentList @($ApiPath) -Authentication 'Login' -ScriptBlock {
            param($ApiPath)
            
            $Year    = [int]$WebEvent.Data
            $NewFile = (Join-Path -Path $ApiPath -ChildPath "holidays$($Year).csv")

            if(-not(Test-Path $NewFile)){            
                $data = Get-SwissHolidays -Year $Year
                $data | Export-Csv -Path $NewFile -Delimiter ';' -Encoding utf8 -Append -NoTypeInformation
                Write-PodeJsonResponse -Value ($data | ConvertTo-Json)
            }
        }

        # Read events from CSV and return it as JSON, used for swiss holidays or patching
        Add-PodeRoute -Method Get -Path '/api/csv/read' -ArgumentList @($ApiPath) -Authentication 'Login' -ScriptBlock {
            param($ApiPath)
            $data = Get-ChildItem -Path $ApiPath -Filter '*.csv' | ForEach-Object {
                Import-Csv -Path $PSItem.Fullname -Delimiter ';' -Encoding utf8
            }

            $events = foreach($item in $data){
                switch -Regex ($item.type){
                    'Feiertag|Patch wave' {$title = $item.title; break}
                    default {$title = $item.title, $item.type -join " - "}
                }
                if($item.type -eq 'Pikett'){
                    $start = "$(Get-Date $item.start -f 'yyyy-MM-dd') 10:00"
                    $end   = "$(Get-Date $item.end -f 'yyyy-MM-dd') 10:00"
                }else{
                    $start = "$(Get-Date $item.start -f 'yyyy-MM-dd') 01:00"
                    $end   = "$(Get-Date $item.end -f 'yyyy-MM-dd') 23:00"
                }
                [PSCustomObject]@{
                    title = $title
                    type  = $item.type
                    start = $start
                    end   = $end
                    color = Get-EventColor -type $item.type
                } 
            }
            Write-PodeJsonResponse -Value $events
        }

        #region CRUD operations for Absence
        # Create new absence into the table absence
        Add-PodeRoute -Method POST -Path '/api/absence/create' -ArgumentList @($dbPath, $Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            if(-not([String]::IsNullOrEmpty($WebEvent.Data['name']))){
                try{
                    $name      = $WebEvent.Data['name']
                    $created   = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
                    
                    $sql = "INSERT INTO absence (name, created, author) VALUES ('$($name)', '$($created)', '$($WebEvent.Auth.User.Name)')"
                    $connection = New-SQLiteConnection -DataSource $dbPath
                    Invoke-SqliteQuery -Connection $connection -Query $sql
                    $Connection.Close()
                    Write-PodeJsonResponse -Value $($data | ConvertTo-Json)

                }catch{
                    $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
                }
            }else{
                Write-PodeJsonResponse -StatusCode 400 -Value @{ StatusDescription = 'No name is given!' }
            }
        }

        # Read data from SQLiteDB for absence
        Add-PodeRoute -Method Get -Path 'api/absence/read/:id' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)
            try{
                $searchFor = $WebEvent.Parameters['id']

                if ($searchFor -eq '*') {
                    $sql = 'SELECT id,name,created FROM absence ORDER BY name ASC'
                } else {
                    $sql = "SELECT id,name,created FROM absence WHERE id = $searchFor"
                }

                # $sql = 'SELECT id,name,created FROM absence ORDER BY name ASC'
                $connection = New-SQLiteConnection -DataSource $dbPath
                $data = Invoke-SqliteQuery -Connection $connection -Query $sql

                $absences = foreach($item in $data){
                    [PSCustomObject]@{
                        id      = $item.id
                        name    = $item.name
                        created = $item.created
                    } 
                }
                $Connection.Close()
                Write-PodeJsonResponse -Value $($absences | ConvertTo-Json)
            }catch{
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }
        
        # Update absence from table absence
        Add-PodeRoute -Method PUT -Path '/api/absence/update/:id'  -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
        param($dbPath,$Logfile)

            $id        = $WebEvent.Parameters['id']
            $name      = $WebEvent.Data['name']
            $created   = $created = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
            $author    = $WebEvent.Auth.User.Name

            $sql = "UPDATE absence SET name = '$name', created = '$created', author = '$author' WHERE id = '$id'"

            try {
                Invoke-SqliteQuery -DataSource $dbPath -Query $sql
                Write-PodeJsonResponse -Value @{ status = "success"; message = "Record successfully updated" }
            } catch {
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -Value @{ status = "error"; message = "Failed to update record: $_" } -StatusCode 500
            }
        }

        # Delete absence from table absence
        Add-PodeRoute -Method DELETE -Path '/api/absence/delete/:id'  -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            $id = $WebEvent.Parameters['id']
            $sql = "DELETE FROM absence WHERE id = $id"
            
            try {
                Invoke-SqliteQuery -DataSource $dbPath -Query $sql
                Write-PodeJsonResponse -Value @{ status = "success"; message = "Record successfully deleted" }
            } catch {
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -Value @{ status = "error"; message = "Failed to delete record: $_" } -StatusCode 500
            }
        }
        #endregion

        #region CRUD operations for Person
        # Create new person into the table person
        Add-PodeRoute -Method POST -Path '/api/person/create' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            if((-not([String]::IsNullOrEmpty($WebEvent.Data['login'])) -and (-not([String]::IsNullOrEmpty($WebEvent.Data['name'])) -and (-not([String]::IsNullOrEmpty($WebEvent.Data['firstname'])))))){
                try{
                    $login     = $WebEvent.Data['login']
                    $firstname = $WebEvent.Data['firstname']
                    $lastname  = $WebEvent.Data['name']
                    $email     = $WebEvent.Data['email']
                    $active    = $WebEvent.Data['active']
                    $workload  = $WebEvent.Data['workload']
                    $created   = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
                    
                    $sql = "INSERT INTO person (login, firstname, name, email, active, workload, created, author) VALUES ('$($login)', '$($firstname)', '$($lastname)', '$($email)', '$($active)', '$($workload)', '$($created)', '$($WebEvent.Auth.User.Name)')"
                    $connection = New-SQLiteConnection -DataSource $dbPath
                    Invoke-SqliteQuery -Connection $connection -Query $sql
                    $Connection.Close()
                    Write-PodeJsonResponse -Value $($data | ConvertTo-Json)

                }catch{
                    $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
                }
            }else{
                Write-PodeJsonResponse -StatusCode 400 -Value @{ StatusDescription = 'No login, firstname, name is given!' }
            }
        }

        # Read data from SQLiteDB for person
        Add-PodeRoute -Method Get -Path 'api/person/read/:person' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)
            try{
                $searchFor = $WebEvent.Parameters['person']

                # Check if $searchFor is an integer
                $isInteger = [int]::TryParse($searchFor, [ref]$null)

                if ($searchFor -eq '*') {
                    $sql = 'SELECT id,login,name,firstname, active, workload, email,created FROM person ORDER BY firstname ASC'
                } elseif ($isInteger) {
                    $sql = "SELECT id,login,name,firstname, active, workload, email,created FROM person WHERE id = $searchFor"
                } else {
                    $sql = "SELECT id,login,name,firstname, active, workload, email,created FROM person WHERE (name || ' ' || firstname) = '$($searchFor)'"
                }

                $connection = New-SQLiteConnection -DataSource $dbPath
                $data = Invoke-SqliteQuery -Connection $connection -Query $sql

                $person = foreach($item in $data){
                    [PSCustomObject]@{
                        id         = $item.id
                        login      = $item.login
                        name       = $item.name
                        firstname  = $item.firstname
                        active     = $item.active
                        workload   = $item.workload
                        email      = $item.email
                        fullname   = "$($item.name) $($item.firstname)"
                        created    = $item.created
                    } 
                }
                $Connection.Close()
                Write-PodeJsonResponse -Value $($person | ConvertTo-Json)
            }catch{
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }

        # Update person from table person
        Add-PodeRoute -Method PUT -Path '/api/person/update/:id'  -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            $id        = $WebEvent.Parameters['id']
            $login     = $WebEvent.Data['login']
            $name      = $WebEvent.Data['name']
            $firstname = $WebEvent.Data['firstname']
            $active    = $WebEvent.Data['active']
            $workload  = $WebEvent.Data['workload']
            $email     = $WebEvent.Data['email']
            $created   = $created = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
            $author    = $WebEvent.Auth.User.Name

            $sql = @"
        UPDATE person
        SET 
            login     = '$login',
            name      = '$name',
            firstname = '$firstname',
            active    = '$active',
            workload  = '$workload',
            email     = '$email',
            created   = '$created',
            author    = '$author'
        WHERE id = '$id';
"@
            
            try {
                Invoke-SqliteQuery -DataSource $dbPath -Query $sql
                Write-PodeJsonResponse -Value @{ status = "success"; message = "Record successfully updated" }
            } catch {
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -Value @{ status = "error"; message = "Failed to update record: $_" } -StatusCode 500
            }
        }

        # Delete person from table person
        Add-PodeRoute -Method DELETE -Path '/api/person/delete/:id'  -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            $id = $WebEvent.Parameters['id']
            $sql = "DELETE FROM person WHERE id = $id"
            
            try {
                Invoke-SqliteQuery -DataSource $dbPath -Query $sql
                Write-PodeJsonResponse -Value @{ status = "success"; message = "Record successfully deleted" }
            } catch {
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -Value @{ status = "error"; message = "Failed to delete record: $_" } -StatusCode 500
            }
        }
        #endregion

        #region CRUD operations for events
        # Create new record into the table events
        Add-PodeRoute -Method POST -Path '/api/event/create' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)
            # Read the data of the formular
            if((-not([String]::IsNullOrEmpty($WebEvent.Data['name'])) -and (-not([String]::IsNullOrEmpty($WebEvent.Data['type']))))){
                try{
                    $person  = $WebEvent.Data['name']
                    $type    = $WebEvent.Data['type']
                    if($type -match '^Pikett$'){
                        $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 10:00"
                        $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 10:00"
                    }else{
                        $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 01:00"
                        $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 23:00"
                    }
                    $alias   = $WebEvent.Data['alias']
                    $created = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
    
                    $sql = "INSERT INTO events (person, type, start, end, alias, created, author) VALUES ('$($person)', '$($type)', '$($start)', '$($end)', '$($alias)', '$($created)', '$($WebEvent.Auth.User.Name)')"
                    $connection = New-SQLiteConnection -DataSource $dbPath
                    Invoke-SqliteQuery -Connection $connection -Query $sql
                    $Connection.Close()
                    Write-PodeJsonResponse -Value $($data | ConvertTo-Json)
                }catch{
                    $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
                }
            }else{
                Write-PodeJsonResponse -StatusCode 400 -Value @{ StatusDescription = 'No person or type is selected!' }
            }
        }

        # Read data from table events
        Add-PodeRoute -Method Get -Path 'api/event/read/:person' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)
            try{
                # Read from view instead from table
                $person = $WebEvent.Parameters['person']
                if($person -eq '*'){
                    $sql = 'SELECT id,person,login,email,"type",start,end,alias FROM v_events'
                }else{
                    $sql = "SELECT id,person,login,email,""type"",start,end,alias FROM v_events WHERE person = '$($person)'"
                }
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
                        start = Get-Date $item.start -f 'yyyy-MM-dd HH:mm'
                        end   = Get-Date $item.end -f 'yyyy-MM-dd HH:MM'
                        color = Get-EventColor -type $item.type
                        extendedProps = [PSCustomObject]@{
                            login = $item.login
                            email = $item.email
                            alias = $item.alias
                        }
                    } 
                }
                $Connection.Close()
                Write-PodeJsonResponse -Value $($events | ConvertTo-Json)
            }catch{
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }

        # Update data from table events
        Add-PodeRoute -Method Put -Path '/api/event/update/:id' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            $id      = $WebEvent.Parameters['id']
            $type    = $WebEvent.Data['type']
            $alias   = $WebEvent.Data['alias']

            if($type -match '^Pikett$'){
                $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 10:00"
                $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 10:00"
            }else{
                $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 01:00"
                $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 23:00"
            }
            $created = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
            $author  = $WebEvent.Auth.User.Name

            if($alias){
                $sql = "
                UPDATE events
                SET 
                    start = '$start',
                    end = '$end',
                    alias = '$alias',
                    created = '$created',
                    author = '$author'
                WHERE id = '$id';
                "
            }else{
                $sql = "
                UPDATE events
                SET 
                    start = '$start',
                    end = '$end',
                    created = '$created',
                    author = '$author'
                WHERE id = '$id';
                "
            }

            try {
                Invoke-SqliteQuery -DataSource $dbPath -Query $sql
                Write-PodeJsonResponse -Value @{ status = "success"; message = "Record successfully updated" }
            } catch {
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -Value @{ status = "error"; message = "Failed to update record: $_" } -StatusCode 500
            }
        }

        # Delete data from table events
        Add-PodeRoute -Method Delete -Path '/api/event/delete/:id' -ArgumentList @($dbPath,$Logfile) -Authentication 'Login' -ScriptBlock {
            param($dbPath,$Logfile)

            $id      = $WebEvent.Parameters['id']
            $deleted = Get-Date -f 'yyyy-MM-dd HH:mm:ss'
            $author  = $WebEvent.Auth.User.Name

            # $sql = "DELETE FROM events WHERE id = $id"
            $sql = @"
        UPDATE events
        SET 
            active = 0,
            deleted = '$deleted',
            author = '$author'
        WHERE id = $id
"@

            try {
                Invoke-SqliteQuery -DataSource $dbPath -Query $sql
                Write-PodeJsonResponse -Value @{ status = "success"; message = "Record successfully deleted" }
            } catch {
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -Value @{ status = "error"; message = "Failed to delete record: $_" } -StatusCode 500
            }
        }
        #endregion

        #region CRUD operations for OpsGenie
        # Create new override in opsgenie
        Add-PodeRoute -Method POST -Path '/api/opsgenie/override/create' -ArgumentList @($Logfile) -Authentication 'Login' -ScriptBlock {
            param($Logfile)

            function New-OpsGenieOverride {
                <#
                .SYNOPSIS
                    A short one-line action-based description, e.g. 'Tests if a function is valid'
                .DESCRIPTION
                    A longer description of the function, its purpose, common use cases, etc.
                .NOTES
                    Information or caveats about the function e.g. 'This function is not supported in Linux'
                .EXAMPLE
                    New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
                    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
                #>
                [CmdletBinding(SupportsShouldProcess=$True)]
                param(
                    # Test-Compute_schedule
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 0
                    )]
                    [String] $Schedule,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 1
                    )]
                    [Object] $Rotation,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 2
                    )]
                    [String] $startDate,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 3
                    )]
                    [String] $endDate,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 4
                    )]
                    [Object] $participants,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 5
                    )]
                    [String] $ApiKey,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 6
                    )]
                    [String] $Logfile
                )
            
                begin{
                    #region Do not change this region
                    $StartTime = Get-Date
                    $function = $($MyInvocation.MyCommand.Name)
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
                    #endregion
                }
            
                process{
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
                    foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
                    if ($PSCmdlet.ShouldProcess($params.Trim())){
                        try{
                            # Define variables
                            $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/overrides?scheduleIdentifierType=name"
            
                            # Create headers for the API request
                            $Headers = @{
                                Authorization = "GenieKey $ApiKey"
                                "Content-Type" = "application/json"
                            }
            
                            # Create the body the API request
                            $Payload = [PSCustomObject]@{
                                #alias        = ([guid]::NewGuid()).Guid
                                user         = $participants[0]
                                startDate    = (Get-Date $startDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                                endDate      = (Get-Date $endDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                                rotations    = $Rotation
                            }
                            $JsonPayload = $Payload | ConvertTo-Json -Depth 10 -Compress
            
                            try {
                                Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method POST -Body $JsonPayload
                            }
                            catch {
                                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $BaseUrl | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $JsonPayload | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                @{ statusCode = "error"; statusText = $_.Exception.Message}
                            }
                        }catch{
                            Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                            $Error.Clear()
                        }
                    }
                }
            
                end{
                    #region Do not change this region
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
                    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
                    $Formatted = $TimeSpan | ForEach-Object {
                        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
                    }
                    Write-Verbose $('Finished in:', $Formatted -Join ' ')
                    #endregion
                }
            }

            try{

                $ScheduleName   = $WebEvent.Data['scheduleName']
                $ScheduleApiKey = $env:OPS_GENIE_API_KEY
                $RotationName   = $WebEvent.Data['rotationName']
                $Username       = $WebEvent.Data['userName']
                $OnCallStart    = Get-Date $WebEvent.Data['onCallStart'] -f 'yyyy-MM-dd 10:00'
                $OnCallEnd      = Get-Date $WebEvent.Data['onCallEnd'] -f 'yyyy-MM-dd 10:00'

                if ($ScheduleName -and $ScheduleApiKey -and $RotationName -and $Username -and $OnCallStart -and $OnCallEnd) {
                    $participants = @(
                        [PSCustomObject]@{
                            type = 'user'
                            username = $Username
                        }
                    )
                    
                    $rotations = @(
                        [PSCustomObject]@{
                            name = $RotationName
                        }
                    )

                    $NewOpsGenieOverride = New-OpsGenieOverride -Schedule $ScheduleName -Rotation $rotations -startDate $OnCallStart -endDate $OnCallEnd -participants $participants -ApiKey $ScheduleApiKey -Logfile $Logfile
                    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'); $($WebEvent.Auth.User.Username); Override created as $($NewOpsGenieOverride.data.alias)" | Out-File -Append -FilePath $Logfile -Encoding utf8
                    Write-PodeJsonResponse -Value $($NewOpsGenieOverride | ConvertTo-Json)
                }else{
                    "Missing parameters" | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    Write-PodeJsonResponse -StatusCode 400 -Value @{ status = "error"; message = "Missing parameters" }
                }
            }catch{
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }

        # Update override in opsgenie
        Add-PodeRoute -Method PUT -Path '/api/opsgenie/override/update' -ArgumentList @($Logfile) -Authentication 'Login' -ScriptBlock {
            param($Logfile)

            function Update-OpsGenieOverride {
                <#
                .SYNOPSIS
                    A short one-line action-based description, e.g. 'Tests if a function is valid'
                .DESCRIPTION
                    A longer description of the function, its purpose, common use cases, etc.
                .NOTES
                    Information or caveats about the function e.g. 'This function is not supported in Linux'
                .EXAMPLE
                    New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
                    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
                #>
                [CmdletBinding(SupportsShouldProcess=$True)]
                param(
                    # Test-Compute_schedule
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 0
                    )]
                    [String] $Schedule,

                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 1
                    )]
                    [String] $Alias,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 2
                    )]
                    [Object] $Rotation,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 3
                    )]
                    [String] $startDate,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 4
                    )]
                    [String] $endDate,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 5
                    )]
                    [Object] $participants,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 6
                    )]
                    [String] $ApiKey,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 7
                    )]
                    [String] $Logfile
                )
            
                begin{
                    #region Do not change this region
                    $StartTime = Get-Date
                    $function = $($MyInvocation.MyCommand.Name)
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
                    #endregion
                }
            
                process{
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
                    foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
                    if ($PSCmdlet.ShouldProcess($params.Trim())){
                        try{
                            # Define variables
                            $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$Schedule/overrides/$($alias)?scheduleIdentifierType=name"
            
                            # Create headers for the API request
                            $Headers = @{
                                Authorization = "GenieKey $ApiKey"
                                "Content-Type" = "application/json"
                            }
            
                            # Create the body the API request
                            $Payload = [PSCustomObject]@{
                                user         = $participants[0]
                                startDate    = (Get-Date $startDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                                endDate      = (Get-Date $endDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
                                rotations    = $Rotation
                            }
                            $JsonPayload = $Payload | ConvertTo-Json -Depth 10 -Compress
            
                            try {
                                Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method PUT -Body $JsonPayload
                            }
                            catch {
                                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $BaseUrl | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $JsonPayload | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                @{ statusCode = "error"; statusText = $_.Exception.Message}
                            }
                        }catch{
                            Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                            $Error.Clear()
                        }
                    }
                }
            
                end{
                    #region Do not change this region
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
                    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
                    $Formatted = $TimeSpan | ForEach-Object {
                        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
                    }
                    Write-Verbose $('Finished in:', $Formatted -Join ' ')
                    #endregion
                }
            }

            try{

                $ScheduleName   = $WebEvent.Data['scheduleName']
                $ScheduleApiKey = $env:OPS_GENIE_API_KEY
                $RotationName   = $WebEvent.Data['rotationName']
                $Username       = $WebEvent.Data['userName']
                $OnCallStart    = Get-Date $WebEvent.Data['onCallStart'] -f 'yyyy-MM-dd 10:00'
                $OnCallEnd      = Get-Date $WebEvent.Data['onCallEnd'] -f 'yyyy-MM-dd 10:00'
                $OverrideAlias  = $WebEvent.Data['alias']

                if ($ScheduleName -and $ScheduleApiKey -and $RotationName -and $Username -and $OnCallStart -and $OnCallEnd -and $OverrideAlias) {
                    $participants = @(
                        [PSCustomObject]@{
                            type = 'user'
                            username = $Username
                        }
                    )
                    
                    $rotations = @(
                        [PSCustomObject]@{
                            name = $RotationName
                        }
                    )

                    $UpdateOpsGenieOverride = Update-OpsGenieOverride -Schedule $ScheduleName -Alias $OverrideAlias -Rotation $rotations -startDate $OnCallStart -endDate $OnCallEnd -participants $participants -ApiKey $ScheduleApiKey -Logfile $Logfile
                    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'); $($WebEvent.Auth.User.Username); Override updated for $($UpdateOpsGenieOverride.data.alias)" | Out-File -Append -FilePath $Logfile -Encoding utf8
                    Write-PodeJsonResponse -Value $($UpdateOpsGenieOverride | ConvertTo-Json)
                }else{
                    "Missing parameters" | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    Write-PodeJsonResponse -StatusCode 400 -Value @{ status = "error"; message = "Missing parameters" }
                }
            }catch{
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }
        
        # Delete override in opsgenie
        Add-PodeRoute -Method DELETE -Path '/api/opsgenie/override/delete' -ArgumentList @($Logfile) -Authentication 'Login' -ScriptBlock {
            param($Logfile)

            function Remove-OpsGenieOverride {
                <#
                .SYNOPSIS
                    A short one-line action-based description, e.g. 'Tests if a function is valid'
                .DESCRIPTION
                    A longer description of the function, its purpose, common use cases, etc.
                .NOTES
                    Information or caveats about the function e.g. 'This function is not supported in Linux'
                .EXAMPLE
                    New-MwaFunction @{Name='MyName';Value='MyValue'} -Verbose
                    Explanation of the function or its result. You can include multiple examples with additional .EXAMPLE lines
                #>
                [CmdletBinding(SupportsShouldProcess=$True)]
                param(
                    # Test-Compute_schedule
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 0
                    )]
                    [String] $Schedule,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 1
                    )]
                    [String] $Alias,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 2
                    )]
                    [String] $ApiKey,
            
                    [Parameter(
                        Mandatory=$true,
                        ValueFromPipeline=$true,
                        ValueFromPipelineByPropertyName=$true,
                        Position = 3
                    )]
                    [String] $Logfile
                )
            
                begin{
                    #region Do not change this region
                    $StartTime = Get-Date
                    $function = $($MyInvocation.MyCommand.Name)
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
                    #endregion
                }
            
                process{
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
                    foreach($item in $PSBoundParameters.keys){ $params = "$($params) -$($item) $($PSBoundParameters[$item])" }
                    if ($PSCmdlet.ShouldProcess($params.Trim())){
                        try{
                            # Define variables
                            $BaseUrl = "https://api.eu.opsgenie.com/v2/schedules/$ScheduleName/overrides/$($Alias)?scheduleIdentifierType=name"
            
                            # Create headers for the API request
                            $Headers = @{
                                Authorization = "GenieKey $ApiKey"
                            }
            
                            try {
                                Invoke-RestMethod -Uri $BaseUrl -Headers $Headers -Method DELETE
                            }
                            catch {
                                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $BaseUrl | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                                @{ statusCode = "error"; statusText = $_.Exception.Message}
                            }
                        }catch{
                            Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
                            $Error.Clear()
                        }
                    }
                }
            
                end{
                    #region Do not change this region
                    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
                    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
                    $Formatted = $TimeSpan | ForEach-Object {
                        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
                    }
                    Write-Verbose $('Finished in:', $Formatted -Join ' ')
                    #endregion
                }
            }

            try{

                $ScheduleName   = $WebEvent.Data['scheduleName']
                $ScheduleApiKey = $env:OPS_GENIE_API_KEY
                $OverrideAlias  = $WebEvent.Data['alias']

                if ($ScheduleName -and $ScheduleApiKey -and $OverrideAlias) {
                    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'); $($WebEvent.Auth.User.Username); Searching for Override $($OverrideAlias)" | Out-File -Append -FilePath $Logfile -Encoding utf8
                    $RemoveOpsGenieOverride = Remove-OpsGenieOverride -Schedule $ScheduleName -Alias $OverrideAlias -ApiKey $ScheduleApiKey -logfile $Logfile
                    "$(Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'); $($WebEvent.Auth.User.Username); Override $($OverrideAlias) $($RemoveOpsGenieOverride.result)" | Out-File -Append -FilePath $Logfile -Encoding utf8
                    Write-PodeJsonResponse -Value $($RemoveOpsGenieOverride | ConvertTo-Json)
                }else{
                    "Missing parameters" | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                    Write-PodeJsonResponse -StatusCode 400 -Value @{ status = "error"; message = "Missing parameters" }
                }
            }catch{
                $_.Exception.Message | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                $WebEvent.Data | Out-String | Out-File -Append -FilePath $Logfile.Replace('informational','error') -Encoding utf8
                Write-PodeJsonResponse -StatusCode 500 -Value @{ status = "error"; message = $_.Exception.Message }
            }
        }
        #endregion
    }

    end{
        Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', "$($MyInvocation.MyCommand.Name)" -Join ' ')
    }

}

function ConvertTo-SHA256{
    [CmdletBinding()]
    param($String)

    $SHA256 = New-Object System.Security.Cryptography.SHA256Managed
    $SHA256Hash = $SHA256.ComputeHash([Text.Encoding]::ASCII.GetBytes($String))
    $SHA256HashString = [Convert]::ToBase64String($SHA256Hash)
    return $SHA256HashString
}

function ConvertTo-SaltedSHA256 {
    param (
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [string]$Salt = "default-salt" # Optionaler Salt-Parameter mit Standardwert
    )

    try {
        $salted = $Salt + $ApiKey
        $sha256 = [System.Security.Cryptography.SHA256]::Create()
        $hashBytes = $sha256.ComputeHash([Text.Encoding]::ASCII.GetBytes($salted))
        $hashString = -join ($hashBytes | ForEach-Object { "{0:x2}" -f $_ })
        return $hashString
    } catch {
        Write-Error "An error occurred: $_"
    }
}

function Update-PSModuleVersion{
    [CmdletBinding()]
    param()
    try {
        # Read from rotamaster.config.js
        $configFilePath = Join-Path -Path $PSScriptRoot.Replace('bin','public/assets/rotamaster') -ChildPath 'rotamaster.config.js'
        $configContent  = Get-Content -Path $configFilePath -Raw

        # Get the latest versions of Pode and PSSQLite
        $podeVersion     = (Get-Module -Name Pode -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version
        $psSqliteVersion = (Get-Module -Name PSSQLite -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).Version

        # Update the module versions in the config file content
        $configContent = $configContent -replace '(moduleName: "Pode",\s*moduleVersion: ")([^"]+)', "`$1$podeVersion"
        $configContent = $configContent -replace '(moduleName: "PSSQLite",\s*moduleVersion: ")([^"]+)', "`$1$psSqliteVersion"

        # Write the updated content back to the config file
        Set-Content -Path $configFilePath -Value $configContent
} catch {
        Write-Error "An error occurred: $_"
    }
}
#endregion
