function Get-MonthCalendar {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$MonthName,
        
        [Parameter(Mandatory=$true)]
        [Int] $Year
    )

    # Get the current culture information (make sure to use de-CH)
    $currCulture = [system.globalization.cultureinfo]::GetCultureInfo("de-CH")
    
    # Convert the month name into a valid month number
    $MonthAsNumber = [datetime]::ParseExact($MonthName, 'MMMM', $currCulture).Month

    # Calculate the first and last day of the given month and year
    $firstDayOfMonth = [datetime]::new($Year, $MonthAsNumber, 1)
    $lastDayOfMonth = $firstDayOfMonth.AddMonths(1).AddDays(-1)

    # Define the first day of the week as Monday explicitly
    $firstDayOfWeek = [System.DayOfWeek]::Monday

    # Calculate the day of the week for the first day of the month
    $dayOfWeekOffset = [int]$firstDayOfMonth.DayOfWeek
    $startOffset = ($dayOfWeekOffset - 1 + 7) % 7  # Calculate offset relative to Monday

    Write-Host "First day of $MonthName $Year is: $($firstDayOfMonth.DayOfWeek)"
    Write-Host "First day of the week (configured): $firstDayOfWeek"
    Write-Host "Calculated startOffset: $startOffset"

    # Initialize Calendar as an empty structure
    $calendarRows = @()

    # Create rows for calendar weeks
    $week = @()    

    # Fill empty slots for days before the 1st of the month
    for ($i = 0; $i -lt $startOffset; $i++) {
        $week += $null  # Use $null for empty days
    }

    # Insert days of the month into the calendar
    for ($day = 1; $day -le $lastDayOfMonth.Day; $day++) {
        $currentDate = [datetime]::new($Year, $MonthAsNumber, $day)
        $week += $day

        if ($week.Count -eq 7) {
            # Calculate the calendar week
            # $currentWeekNumber = $calendar.GetWeekOfYear($currentDate, $currCulture.DateTimeFormat.CalendarWeekRule, $firstDayOfWeek)

            # Add row when week is full
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

    # Fill up the remaining days of the last week if any
    if ($week.Count -gt 0) {
        while ($week.Count -lt 7) {
            $week += $null  # Fill with $null for empty slots after the month's end
        }

        # Calculate the calendar week for the last row
        # $currentWeekNumber = $calendar.GetWeekOfYear($currentDate, $currCulture.DateTimeFormat.CalendarWeekRule, $firstDayOfWeek)

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

    # Return the calendar
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
$Year = 2024
$Month = @('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')
# foreach($item in $Month) {
    $monthAbbreviation = Get-MonthAbbreviation -MonthName 'November'
    Get-MonthCalendar -MonthName 'November' -Year $Year | Select-Object @{N='Jahr';E={$Year}}, @{N='Monat';E={$monthAbbreviation}}, * | Format-Table -AutoSize
# }
#endregion