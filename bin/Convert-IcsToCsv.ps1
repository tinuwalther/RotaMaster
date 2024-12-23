## Create a synopsis for the script
<#
.SYNOPSIS
    Convert an .ics file to a .csv file.
.DESCRIPTION
    This script converts an .ics file to a .csv file.
    The .ics file is parsed and the data is converted to a .csv format.
    The .csv file is then written to the specified file path.
.PARAMETER icsFilePath
    The file path of the .ics file to convert.
.PARAMETER csvFilePath
    The file path of the .csv file to create.
.EXAMPLE
    Convert-IcsToCsv -icsFilePath "C:\path\to\file.ics" -csvFilePath "C:\path\to\output.csv"
#>

## Begin the script with [CmdletBinding()] and Param block
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$icsFilePath,

    [Parameter(Mandatory = $true)]
    [string]$csvFilePath
)

## Add a region named 'Functions'
#region Functions
# Function to parse the .ics file
function ConvertFrom-ICS {
    param (
        [string[]]$data
    )

    $events = foreach ($line in $data) {
        switch -Regex ($line) {
            "BEGIN:VEVENT" { $currentEvent = @{} }
            "END:VEVENT" { $currentEvent }
            default {
                if ($null -ne $currentEvent) {
                    $key, $value = $line -split ":", 2
                    $currentEvent[$key] = $value
                }
            }
        }
    }

    return $events
}

# Function to convert the date format
function Convert-DateFormat {
    param (
        [string]$dateString
    )

    $dateTime = [datetime]::ParseExact($dateString, "yyyyMMddTHHmmssZ", $null)
    return $dateTime.ToString("yyyy-MM-dd HH:mm")
}

## Create a function from the code block
function ConvertTo-CsvData {
    param (
        [System.Collections.ArrayList]$events
    )

    $csvData = $events | ForEach-Object {
        [PSCustomObject]@{
            id      = $_.UID
            title   = ($_.SUMMARY -split ' - ')[0]
            type    = ($_.SUMMARY -split ' - ')[1]
            start   = Convert-DateFormat -dateString $_.DTSTART
            end     = Convert-DateFormat -dateString $_.DTEND
            created = (Get-Date).ToString('yyyy-MM-dd HH:mm')
        }
    } | ConvertTo-Csv -NoTypeInformation -Delimiter ';'

    return $csvData
}
#endregion

## Add a region named 'Main'
#region Main
# Read the .ics file
$icsData = Get-Content -Path $icsFilePath

# Parse the .ics file
$events = ConvertFrom-ICS -data $icsData

# Create the CSV data
$csvData = ConvertTo-CsvData -events $events

# Write the CSV data to the file
Set-Content -Path $csvFilePath -Value $csvData

Write-Output "CSV file successfully created: $csvFilePath"
#endregion