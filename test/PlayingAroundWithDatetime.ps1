# Playing around with datetime
[CmdletBinding()]
param(
    [ValidateSet('Januar','Februar','März','April','Mai','Juni','Juli','August','September','Oktober','November','Dezember')]
    [Parameter(Mandatory=$true)]
    [string]$MonthName,
    
    [ValidateRange(1970, 2999)]
    [Parameter(Mandatory=$true)]
    [Int] $Year
)

# Attempts to convert the month name into a valid month number
$currCulture = [system.globalization.cultureinfo]::CurrentCulture
$NumberOfMonth = [datetime]::ParseExact($MonthName, 'MMMM', $currCulture).Month

# Calculate the first- and the last day of the given year
$StartDateOfYear = [datetime]::new($Year, 1, 1)
$EndDateOfYear   = [datetime]::new($Year, 12, 31)

# Calculate the first- and the last day of the month
$firstDayOfMonth   = [datetime]::new($Year, $NumberOfMonth, 1)
# The first day of the next month is calculated by increasing the current month by 1
$firstDayNextMonth = [datetime]::new($Year, $NumberOfMonth, 1).AddMonths(1)
$lastDayOfMonth    = $firstDayNextMonth.AddDays(-1)

$obj = [PSCustomObject]@{
    CurrentCulture  = $currCulture
    Year            = $Year
    BeginOfYear     = $StartDateOfYear.DateTime
    EndOfYear       = $EndDateOfYear.DateTime
    Month           = $MonthName
    FirstDayOfMonth = $firstDayOfMonth.DateTime
    FirstDayOfWeek  = $firstDayOfMonth.DayOfWeek.value__
    LastDayOfMonth  = $lastDayOfMonth.DateTime
    LastDayOfWeek   = $lastDayOfMonth.DayOfWeek.value__
    DaysOfMonth     = ($lastDayOfMonth.DayOfYear - $firstDayOfMonth.DayOfYear) + 1
}

$obj

# First week
for($i = $firstDayOfMonth.DayOfWeek.value__; $i -lt 7; $i++){
    $i
}

# The whole month
$fullMonth = 0..($lastDayOfMonth.DayOfYear -$firstDayOfMonth.DayOfYear) | ForEach-Object {
    # '{0:d2}. {1} {2}' -f $($_+1), $MonthName, $Year
    [datetime]::new($Year, $NumberOfMonth, $($_+1))
}

$fullMonth | Select-Object @{N='DayOfMonth';E={$_.Day}} | Format-List
