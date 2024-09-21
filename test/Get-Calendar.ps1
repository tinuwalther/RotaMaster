<#
.SYNOPSIS
    Generates a calendar for each month of a given year, displaying abbreviated month names and corresponding calendar weeks.

.DESCRIPTION
    This script generates a calendar for each month in a given year. It utilizes two helper functions:
    - `Get-MonthAbbreviation`: Converts the full name of a month to its abbreviated form based on the system's culture settings.
    - `Get-MonthCalendar`: Creates a table that represents the days of a specified month along with their corresponding calendar week numbers.

    The script loops through all months of the year, generating and displaying each month's calendar with the year and abbreviated month name.
    The calendar displays the days of the week from Sunday to Saturday.

.PARAMETER Year
    The year for which the calendars should be generated. This parameter is mandatory and must be an integer between 1970 and 2999.

.EXAMPLE
    .\Generate-YearlyCalendar.ps1 -Year 2023
    This will generate calendars for all months in the year 2023 with abbreviated month names and calendar week numbers.

.NOTES
    - The script relies on the system's current culture settings to determine month names and abbreviations.
    - It automatically adjusts for leap years and handles months of varying lengths.
    - The days are arranged from Sunday to Saturday, with the calendar weeks calculated based on the current regional settings.
#>

[CmdletBinding()]
param(
    [ValidateRange(1970, 2999)]
    [Parameter(Mandatory=$true)]
    [Int] $Year
)

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
    $currCulture   = [system.globalization.cultureinfo]::CurrentCulture
    $MonthAsNumber = [datetime]::ParseExact($MonthName, 'MMMM', $currCulture).Month
    
    # Calculate the first- and the last day of the given year
    $firstDayOfMonth = [datetime]::new($Year, $MonthAsNumber, 1)
    $lastDayOfMonth = $firstDayOfMonth.AddMonths(1).AddDays(-1)

    # Create a calendar object for the calculation of the calendar week
    $calendar         = [System.Globalization.CultureInfo]::CurrentCulture.Calendar
    $calendarWeekRule = [System.Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.CalendarWeekRule
    $firstDayOfWeek   = [System.Globalization.CultureInfo]::CurrentCulture.DateTimeFormat.FirstDayOfWeek

    # Initialize Calendar as empty structure
    $calendarRows = @()

    # Create rows for calendar weeks
    $week = @()    
    for ($i = 0; $i -lt $currentDayOfWeek; $i++) {
        $week += $null  # Empty days before the 1st of the month
    }

     # Insert days of the month into the calendar
    for ($day = 1; $day -le $lastDayOfMonth.Day; $day++) {
        $currentDate = [datetime]::new($Year, $MonthAsNumber, $day)
        $week += $day
        if ($week.Count -eq 7) {
            # Calculate calendar week
            $currentWeekNumber = $calendar.GetWeekOfYear($currentDate, $calendarWeekRule, $firstDayOfWeek)

            # Add row when week full
            $calendarRows += [pscustomobject]@{
                Woche      = $currentWeekNumber
                Sonntag    = $week[0]
                Montag     = $week[1]
                Dienstag   = $week[2]
                Mittwoch   = $week[3]
                Donnerstag = $week[4]
                Freitag    = $week[5]
                Samstag    = $week[6]
                }
            $week = @()  # Start a new week
        }
    }

    # Fill up the remaining days of the last week
    if ($week.Count -gt 0) {
        while ($week.Count -lt 7) {
            $week += $null  # Empty days after the end of the month
        }

        # Calendar week for the last day of the last week
        $currentDate = [datetime]::new($Year, $MonthAsNumber, $lastDayOfMonth.Day)
        $currentWeekNumber = $calendar.GetWeekOfYear($currentDate, $calendarWeekRule, $firstDayOfWeek)

        $calendarRows += [pscustomobject]@{
            Woche      = $currentWeekNumber
            Sonntag    = $week[0]
            Montag     = $week[1]
            Dienstag   = $week[2]
            Mittwoch   = $week[3]
            Donnerstag = $week[4]
            Freitag    = $week[5]
            Samstag    = $week[6]
        }
    }

    # Return Calendar
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
#endregion

#region main
$Month = @('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')
foreach($item in $Month) {
    $monthAbbreviation = Get-MonthAbbreviation -MonthName $item
    Get-MonthCalendar -MonthName $item -Year $Year | Select-Object @{N='Jahr';E={$Year}}, @{N='Monat';E={$monthAbbreviation}}, * | Format-Table -AutoSize
}
#endregion