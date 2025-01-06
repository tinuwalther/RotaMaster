<#
.SYNOPSIS
    This script is used to generate the patching schedule for the specified year.
.DESCRIPTION
    This script generates the patching schedule for the specified year.
    It creates two patch waves for each month, with the first wave on the first full week and the second wave on the second full week.
.PARAMETER Title
    The title for the patching events.
.PARAMETER Year
    The year for which to generate the patching schedule.
.OUTPUTS
    A CSV file containing the patching schedule for the specified year.
.EXAMPLE
    New-PatchWaves -Title "Hyper-V Cluster Patching" -Year 2022
    Generate the patching schedule for the year 2022 with the title "Hyper-V Cluster Patching".
#>
[CmdletBinding()]
param(
    # Define the Title for the events. For example: Hyper-V Cluster Patching or better HV/ESXi Patching
    [Parameter(Mandatory=$true)]
    [String]$Title,

    # Set the year for which you want to generate the patching schedule
    [Parameter(Mandatory=$true)]
    [Int] $Year
)

$ApiPath = $($PSScriptRoot).Replace('bin','api')

# Define the created date as today
$createdDate = (Get-Date).ToString('yyyy-MM-dd HH:mm')

# Create an empty list to hold the patching data
$patchingData = @()

# Initialize patching ID
$patchingId = 1

# Loop through each month of the specified year
for ($month = 1; $month -le 12; $month++) {
    # Get the first day of the month
    $firstDayOfMonth = Get-Date -Year $Year -Month $month -Day 1
    
    # Find the first Monday of the month
    $dayOfWeek = [int]$firstDayOfMonth.DayOfWeek
    if ($dayOfWeek -eq 1) {
        $firstMonday = $firstDayOfMonth
    } elseif ($dayOfWeek -eq 0) {
        $firstMonday = $firstDayOfMonth.AddDays(1)
    } else {
        $firstMonday = $firstDayOfMonth.AddDays(8 - $dayOfWeek)
    }

    # Check if the first Monday is part of a complete week (Monday to Friday)
    if (($firstMonday.AddDays(4)).Month -eq $month) {
        $firstFullWeekMonday = $firstMonday
    } else {
        $firstFullWeekMonday = $firstMonday.AddDays(7)
    }

    # Calculate the start of the first and second full weeks
    $secondFullWeekMonday = $firstFullWeekMonday.AddDays(7)

    # Generate patching dates for each week
    foreach ($monday in @($firstFullWeekMonday, $secondFullWeekMonday)) {
        # Determine if it's Patch wave 1 or 2
        $week = if ($monday -eq $firstFullWeekMonday) { "1" } else { "2" }
        $type = "Patch wave $week"

        # Set the start and end time for the week (Monday 01:00 to Friday 23:00)
        $startDateTime = "$($monday.ToString('yyyy-MM-dd'))T01:00"
        $endDateTime = "$($monday.AddDays(4).ToString('yyyy-MM-dd'))T23:00"
        
        # Add the record to the patching data list
        $patchingData += [PSCustomObject]@{
            id      = $patchingId
            title   = $Title
            type    = $type
            start   = $startDateTime
            end     = $endDateTime
            created = $createdDate
        }

        # Increment the patching ID
        $patchingId++
    }
}

# Define the output CSV file path
$outputCsvPath = Join-Path -Path $ApiPath -ChildPath "patching$($Year).csv"

# Export the patching data to CSV
$patchingData | Export-Csv -Path $outputCsvPath -NoTypeInformation -Delimiter ';'

# Display the output file path to the user
Write-Output "CSV file created: $outputCsvPath"
