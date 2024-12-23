## Create a synopsis for the script
<#
.SYNOPSIS
    Import events from a file into the SQLite database.
.DESCRIPTION
    This script imports events from a file into the SQLite database.
    The script reads the data from the file and imports it into the events table in the database.
    The script supports .ics and .csv file formats.
    The script uses the following logic to import the events:
    - Parse the .ics file and extract the events.
    - Convert the date format from 'yyyyMMddTHHmmssZ' to 'yyyy-MM-dd HH:mm'.
    - Import the events into the events table in the database.
    - Return the status of the import process.
.PARAMETER FilePath
    The path to the file containing the events.
.PARAMETER ImportToDatabase
    Switch to indicate whether to import the events into the database.
.EXAMPLE
    Import-ToSqLiteTable -FilePath 'C:\events.ics' -ImportToDatabase
    Import the events from the .ics file into the database.
.EXAMPLE
    Import-ToSqLiteTable -FilePath 'C:\events.csv' -ImportToDatabase
    Import the events from the .csv file into the database.
#>

## Begin the script with [CmdletBinding()] and Param block
[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string]$FilePath,

    [Parameter(Mandatory = $false)]
    [switch]$ImportToDatabase
)

#region Functions
function ConvertFrom-ICS {
    ## Create the synopsis for the function
    <#
    .SYNOPSIS
        Parse the .ics file.
    .DESCRIPTION
        This function parses the .ics file and returns the events as a collection of objects.
    .PARAMETER data
        The data from the .ics file.
    .EXAMPLE
        ConvertFrom-ICS -data $icsData
        Parse the .ics file and return the events.
    #>
    param (
        [Parameter(Mandatory = $true)]
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
    ## Create the synopsis for the function
    <#
    .SYNOPSIS
        Convert the date format.
    .DESCRIPTION
        This function converts the date format from 'yyyyMMddTHHmmssZ' to 'yyyy-MM-dd HH:mm'.
    .PARAMETER dateString
        The date string in the format 'yyyyMMddTHHmmssZ'.
    .EXAMPLE
        Convert-DateFormat -dateString '20220101T080000Z'
        Convert the date format to '2022-01-01 08:00'.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$dateString
    )

    switch -Regex ($dateString) {
        # Case to parse the date format '20220101T080000Z'
        '\d{8}T\d{6}Z' {
            $dateTime = [datetime]::ParseExact($dateString, "yyyyMMddTHHmmssZ", $null).ToString("yyyy-MM-dd HH:mm")
        }
        # Case to parse the date format '2025-01-06T09:00:00.0000000+01:00' with timezone
        '\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d+[\+\-]\d{2}:\d{2}' {
            $dateTime = [datetimeoffset]::Parse($dateString).ToLocalTime().ToString("yyyy-MM-dd HH:mm")
        }
        default {
            $dateTime = $dateString
        }
    }

    return $dateTime

}

## Create a function to import the .ics file into the table events
function Import-ToDatabase {
    ## Create the synopsis for the function
    param (
        [Parameter(Mandatory = $true)]
        [string]$dbPath,

        [Parameter(Mandatory = $true)]
        [System.Collections.ArrayList]$events,

        [Parameter(Mandatory = $true)]
        [string]$soure
    )

    Write-Verbose "Import-ToDatabase, $soure"
    switch ($soure) {
        'ics' {
            Write-Verbose 'Import ICS data'
            $items = $events | ForEach-Object {
                [PSCustomObject]@{
                    id      = $_.UID
                    person  = ($_.SUMMARY -split ' - ')[0]
                    type    = ($_.SUMMARY -split ' - ')[1]
                    start   = Convert-DateFormat -dateString $_.DTSTART
                    end     = Convert-DateFormat -dateString $_.DTEND
                    created = (Get-Date).ToString('yyyy-MM-dd HH:mm')
                    author  = 'Administrator'
                }
            }
            # $items | Format-Table
        }
        'csv' {
            # Check for headers in the events
            $firstEvent = $events[0]
            $properties = @("title", "name", "person")

            # Find the first existing property
            $person = $properties | Where-Object { $firstEvent.PSObject.Properties.Match($_).Count -gt 0 } | Select-Object -First 1

            # Process the events based on the headers
            Write-Verbose 'Import CSV data'
            $items = $events | ForEach-Object {
                [PSCustomObject]@{
                    id      = $_.id
                    person  = $_.$person
                    type    = $_.type
                    start   = Convert-DateFormat -dateString $_.start
                    end     = Convert-DateFormat -dateString $_.end
                    created = (Get-Date).ToString('yyyy-MM-dd HH:mm')
                    author  = 'Administrator'
                }
            }
            $items | Format-Table
        }
        Default {
            Write-Warning "Unsupported source: $soure"
        }
    }

    $data = $items | ForEach-Object {
        $sql = "
        INSERT INTO events (person, type, start, end, created, author) 
                    VALUES ('$($_.person)', '$($_.type)', '$($_.start)', '$($_.end)', '$($_.created)', '$($_.author)')
        "
        try{
            $connection = New-SQLiteConnection -DataSource $dbPath
            Invoke-SqliteQuery -Connection $connection -Query $sql
            $response = 'Success'
        }
        catch {
            $response = "$($_.Exception.Message)"
            $Error.Clear()
        }

        [PSCustomObject]@{
            ID         = $_.id
            Name       = $_.person
            Type       = $_.type
            Start      = $_.start
            End        = $_.end
            StatusCode = $response
        }

    }

    return $data

}
#endregion

## Add a region named 'Main'
#region Main
$ApiPath = $($PSScriptRoot).Replace('bin','api')
$dbPath  = Join-Path -Path $ApiPath -ChildPath 'rotamaster.db'

# Determine the file type based on the file extension
$fileExtension = [System.IO.Path]::GetExtension($FilePath).ToLower()
# Read the file based on the file type
if ($fileExtension -eq ".ics") {
    $fileData = Get-Content -Path $FilePath
    $icsData = ConvertFrom-ICS -data $fileData

    if ($ImportToDatabase) {
        Import-ToDatabase -events $icsData -dbPath $dbPath -soure 'ics' | Format-Table
        Write-Output "Import process completed."
    }else{
        $icsData
    }
} elseif ($fileExtension -eq ".csv") {
    $csvData = Import-Csv -Path $FilePath -Delimiter ';'

    if ($ImportToDatabase) {
        Import-ToDatabase -events $csvData -dbPath $dbPath -soure 'csv' | Format-Table
        Write-Output "Import process completed."
    }else{
        $csvData | Format-Table
    }
} else {
    Write-Error "Unsupported file type: $fileExtension"
}
#endregion