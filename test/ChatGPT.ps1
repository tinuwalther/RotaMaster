[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [int]$Year
)

function Get-MonthCalendar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$MonthName,

        [Parameter(Mandatory = $true)]
        [int]$Year
    )

    # Use de-CH Culture
    # $currCulture = [system.globalization.cultureinfo]::GetCultureInfo("de-CH")
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
# Test November 2024
# Get-MonthCalendar -MonthName $MonthName -Year $Year | Format-Table -AutoSize




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
#endregion

#region main
# $Year = 2024
$Month = @('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')
foreach($item in $Month) {
    $monthAbbreviation = Get-MonthAbbreviation -MonthName $item
    Get-MonthCalendar -MonthName $item -Year $Year | Select-Object @{N='Jahr';E={$Year}}, @{N='Monat';E={$monthAbbreviation}}, * | Format-Table -AutoSize
}
#endregion