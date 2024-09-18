function Get-MonthCalendar {
    param (
        [int]$Year,
        [string]$MonthName
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
        $week += 0  # Empty days before the 1st of the month
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
                Kalenderwoche = $currentWeekNumber
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
            $week += 0  # Empty days after the end of the month
        }

        # Calendar week for the last day of the last week
        $currentDate = [datetime]::new($Year, $MonthAsNumber, $lastDayOfMonth.Day)
        $currentWeekNumber = $calendar.GetWeekOfYear($currentDate, $calendarWeekRule, $firstDayOfWeek)

        $calendarRows += [pscustomobject]@{
            Kalenderwoche = $currentWeekNumber
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

# Beispiel: Kalender für September 2023
$year = 2024
$MonthAsNumber = 'September'
$calendar = Get-MonthCalendar -Year $year -MonthName $MonthAsNumber

# Kalender anzeigen
$calendar | Format-Table -AutoSize
