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
$createdDate = (Get-Date).ToString('yyyy-MM-dd')

# Create an empty list to hold the patching data
$patchingData = @()

# Initialize patching ID
$patchingId = 1

# Loop through each month of the specified year
for ($month = 1; $month -le 12; $month++) {
    # Get the first day of the month
    $firstDayOfMonth = Get-Date -Year $year -Month $month -Day 1
    
    # Find the first Wednesday of the month
    $dayOfWeek = [int]$firstDayOfMonth.DayOfWeek
    if ($dayOfWeek -le 2) {
        $firstWednesday = $firstDayOfMonth.AddDays(2 - $dayOfWeek)
    } else {
        $firstWednesday = $firstDayOfMonth.AddDays(9 - $dayOfWeek)
    }
    
    # Calculate the 1st and 2nd Wednesdays of the month
    $firstWednesday = $firstWednesday
    $secondWednesday = $firstWednesday.AddDays(7)

    # Generate patching dates for each Wednesday
    foreach ($patchingDate in @($firstWednesday, $secondWednesday)) {
        # Determine if it's Patch wave 1 or 2
        $week = if ($patchingDate.Day -le 7) { "1" } else { "2" }
        $type = "Patch wave $week"

        # Generate dates for Monday to Friday of the patching week
        $monday = $patchingDate.AddDays(-1 * ($patchingDate.DayOfWeek - [DayOfWeek]::Monday))
        for ($i = 0; $i -lt 5; $i++) {
            $currentDay = $monday.AddDays($i)
            
            # Add the record to the patching data list
            $patchingData += [PSCustomObject]@{
                id      = $patchingId
                title   = $Title
                type    = $type
                start   = $currentDay.ToString('yyyy-MM-dd') + " 01:00"
                end     = $currentDay.ToString('yyyy-MM-dd') + " 23:00"
                created = $createdDate
            }

            # Increment the patching ID
            $patchingId++
        }
    }
}

# Define the output CSV file path
$outputCsvPath = Join-Path -Path $ApiPath -ChildPath "patching$($year).csv"

# Export the patching data to CSV
$patchingData | Export-Csv -Path $outputCsvPath -NoTypeInformation -Delimiter ';'

# Display the output file path to the user
Write-Output "CSV file created: $outputCsvPath"
