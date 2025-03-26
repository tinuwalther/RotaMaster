<#
.SYNOPSIS
    Generate an on-call schedule for a given time.
.DESCRIPTION
    This script generates an on-call schedule for a given time.
    The script reads the data from the SQLite database and generates the schedule based on the availability of the participants.
    The schedule is then exported to a CSV file with the format: id;title;type;start;end;created.
    The script uses the following logic to generate the schedule:
    - Load the list of participants in rotation order.
    - Load all events for the given year from the database.
    - Determine the availability of each participant based on the events.
    - Generate weekly intervals for the given year.
    - Assign participants to the weekly intervals based on availability and rotation order.
    - Export the schedule to a CSV file.
.PARAMETER StartDate
    The start date of the schedule in the format 'yyyy-MM-dd'.
.PARAMETER EndDate
    The end date of the schedule in the format 'yyyy-MM-dd'.
.EXAMPLE
    Generate-OnCallSchedule -StartDate '2022-01-01' -EndDate '2022-12-31'
    Generate the on-call schedule for the year 2022.
.NOTES
    The script assumes that the SQLite database contains the following tables:
    - person: The table containing the list of participants.
    - v_events: The view containing the events for the participants.
    The script uses the tables to determine the availability of the participants and generate the schedule.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$StartDate,

    [Parameter(Mandatory = $true)]
    [string]$EndDate
)

## Add a region named 'Functions'
#region Functions
## Create a function from the code block
function Get-Participants {
    <#
    .SYNOPSIS
        Get the list of participants in rotation order.
    .DESCRIPTION
        This function retrieves the list of participants in rotation order from the database.
        The function queries the database to get the list of participants and orders them based on their first name.
        The function returns the list of participants as an array.
    .PARAMETER dbPath
        The path to the SQLite database.
    .EXAMPLE
        Get-Participants -dbPath 'C:\path\to\database.db'
    .NOTES
        The function assumes that the database contains a table named 'person' with the following columns:
        - name: The name of the participant.
        - firstname: The first name of the participant.
        The function queries the database to get the list of participants in rotation order.
    #>
    param (
        [Parameter(Mandatory=$true)]
        [string]$dbPath
    )

    # Assumption: Order is fixed, but can be made adjustable.
    $sql = 'SELECT name,firstname,workload FROM person WHERE active = 1 ORDER BY firstname'
    $connection = New-SQLiteConnection -DataSource $dbPath
    $data = Invoke-SqliteQuery -Connection $connection -Query $sql
    $data | ForEach-Object{
        [PSCustomObject]@{
            Name = $_.name + ' ' + $_.firstname
            Workload = $_.workload
        }
    }
}

## Create a function from the code block
function Get-AllEvents {
    <#
    .SYNOPSIS
        Get all events for the given year from the database.
    .DESCRIPTION
        This function retrieves all events for the given year from the database.
        The function queries the database to get all events for the specified year.
        The function returns the events as an array of objects.
    .PARAMETER dbPath
        The path to the SQLite database.
    .PARAMETER year
        The year for which to get the events.
    .EXAMPLE
        Get-AllEvents -dbPath 'C:\path\to\database.db' -year 2022
    .NOTES
        The function assumes that the database contains a view named 'v_events' with the following columns:
        - id: The unique identifier for the event.
        - person: The person associated with the event.
        - type: The type of event.
        - start: The start date and time of the event.
        - end: The end date and time of the event.
        The function queries the database to get all events for the specified year.
    #>
    param (
        [Parameter(Mandatory = $true)]
        [string]$dbPath,

        [Parameter(Mandatory = $true)]
        [int]$year
    )

    # Load all events for the year from the database view v_events
    $sql = 'SELECT * FROM v_events WHERE start LIKE "%' + $year + '%"'
    $connection = New-SQLiteConnection -DataSource $dbPath
    $data = Invoke-SqliteQuery -Connection $connection -Query $sql
    $data | ForEach-Object{
        [PSCustomObject]@{
            id = $_.id
            person = $_.person
            type = $_.type
            start = $_.start
            end = $_.end
        }
    }
}

function Test-IsPersonAvailable {
    <#
    .SYNOPSIS
        Check if a person is available in the given time frame.
    .DESCRIPTION
        This function checks if a person is available in the given time frame.
        The function takes the person's name, availability blocks, and the start and end times as input.
        The function checks if the person is available based on their availability blocks.
        The function returns $true if the person is available and $false if the person is not available.
    .PARAMETER Person
        The name of the person to check availability for.
    .PARAMETER Availability
        The availability blocks for the person.
    .PARAMETER Start
        The start time of the time frame.
    .PARAMETER End
        The end time of the time frame.
    .EXAMPLE
        Test-IsPersonAvailable -Person 'John Doe' -Availability $Availability -Start '2022-01-01T09:00:00' -End '2022-01-01T17:00:00'
    .NOTES
        The function assumes that the availability blocks are in the form of a hashtable with the person's name as the key.
        The availability blocks are an array of objects with 'Start' and 'End' properties.
        The function checks if the person is available based on the availability blocks.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$Person,

        [Parameter(Mandatory = $true)]
        [hashtable]$Availability,

        [Parameter(Mandatory = $true)]
        [datetime]$Start,

        [Parameter(Mandatory = $true)]
        [datetime]$End
    )

    $blocks = $Availability[$Person]
    foreach ($b in $blocks) {
        # Wenn sich die Zeiträume überlappen => nicht verfügbar
        if (($Start -lt $b.End) -and ($End -gt $b.Start)) {
            return $false
        }
    }
    return $true
}

function New-OnCallSchedule {
    <#
    .SYNOPSIS
        Create weekly intervals for the given time frame.
    .DESCRIPTION
        This function creates weekly intervals for the given time frame.
        The function takes the start and end dates as input and generates weekly intervals from Monday 09:00 to Monday 09:00.
        The function returns a list of weekly intervals as objects with 'Start' and 'End' properties.
    .PARAMETER StartDate
        The start date of the schedule in the format 'yyyy-MM-dd'.
    .PARAMETER EndDate
        The end date of the schedule in the format 'yyyy-MM-dd'.
    .EXAMPLE
        New-OnCallSchedule -StartDate '2022-01-01' -EndDate '2022-12-31'
    .NOTES
        The function assumes that the weeks start on Monday at 09:00 UTC and end on the following Monday at 09:00 UTC.
        The function generates weekly intervals from the start date to the end date.
    #>
    param(
        [Parameter(Mandatory = $true)]
        [string]$StartDate,

        [Parameter(Mandatory = $true)]
        [string]$EndDate
    )

    # Konvertiere die Eingabe-Strings in Datetime-Objekte
    $start = Get-Date $StartDate
    $end   = Get-Date $EndDate

    # Erster Montag um 10:00 im Startdatum finden
    while ($start.DayOfWeek -ne [System.DayOfWeek]::Monday) {
        $start = $start.AddDays(1)
    }
    $start = $start.Date.AddHours(10) # auf 10:00 Uhr setzen

    # Liste der Wochenintervalle erstellen
    $weeks = New-Object System.Collections.Generic.List[System.Object]

    $currentStart = $start
    while ($currentStart -lt $end) {
        $currentEnd = $currentStart.AddDays(7)
        if ($currentEnd -ge $end) {
            $currentEnd = $end
        }
        $weeks.Add([PSCustomObject]@{
            Start = $currentStart
            End   = $currentEnd
        })
        $currentStart = $currentEnd
    }

    return $weeks
}

function Get-Availability{
    <#
    .SYNOPSIS
        Get the availability of the participants based on the events.
    .DESCRIPTION
        This function determines the availability of the participants based on the events.
        The function takes a list of participants and a list of events as input.
        It then checks each event to see if it blocks any of the participants.
        The function creates a dictionary with the availability of each participant.
    .PARAMETER participants
        The list of participants in rotation order.
    .PARAMETER events
        The list of events for the given year.
    .EXAMPLE
        Get-Availability -participants $participants -events $allEvents
    .NOTES
        We assume that any entry containing a person's name and vacation, GLZ compensation, blocked, military,
        education, etc. indicates that this person is blocked during that period. (You can define your own mapping here.)
    #>
    param(
        [Parameter(Mandatory=$true)]
        [Array]$participants,

        [Parameter(Mandatory=$true)]
        [Array]$events
    )
    # Initialize the availability for each person as an empty list
    $unavailable = @{}
    foreach ($person in $participants) {
        $unavailable[$person] = New-Object System.Collections.Generic.List[System.Object]
    }

    foreach ($item in $events) {
        # Check if the event blocks any of the participants
        $foundPerson = $null
        foreach ($p in $participants) {
            # Check if the person is part of the event
            if ($item.person -like $p) {
                $foundPerson = $p
                break
            }
        }
        if ($foundPerson) {
            # Check if the event blocks the employee
            # We assume that everything blocks this employee.
            $unavailable[$foundPerson].Add([PSCustomObject]@{
                Start = $item.Start
                End   = $item.End
            })
        }
    }
    return $unavailable
    
}

# On-call rotation
# The on-call rotation is based on the availability of the employees.
# You could also check in each rotation if percentPerson has had enough assignments.
function New-OnCallRotation {
    <#
    .SYNOPSIS
        Generate a new on-call rotation based on the availability of the participants.
    .DESCRIPTION
        This function generates a new on-call rotation based on the availability of the participants.
        The function takes a list of participants, a percentPerson, a hashtable with the availability of each participant, and a list of weeks as input.
        The function assigns participants to the weeks based on their availability and the rotation order.
        The function uses a simple heuristic to handle the percentPerson's 80% workload.
    .PARAMETER participants
        The list of participants in rotation order.
    .PARAMETER percentPerson
        The person who has a 80% workload.
    .PARAMETER Availability
        The hashtable with the availability of each participant.
    .PARAMETER weeks
        The list of weeks for which to generate the rotation.
    .EXAMPLE
        New-OnCallRotation -participants $participants -percentPerson 'Mercury Freddie' -Availability $Availability -weeks $weeks
    .NOTES
        Assumptions:

        We assume that the rotation of the employees is cyclical.
        We assume that the availability of the employees is given in the form of time blocks.
        We assume that the weekly intervals go from Monday 09:00 to Monday 09:00.
        We assume that percentPerson has only 80% workload and skips one out of every 5 assignments.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [Array]$participants,

        [Parameter(Mandatory=$true)]
        [Array]$percentPersons,  # Ändere hier

        [Parameter(Mandatory=$true)]
        [hashtable]$Availability,

        [Parameter(Mandatory=$true)]
        [Array]$weeks
    )

    $percentCounter = @{}
    $percentSkipRate = 5  # skip one percentPerson assignment every 5 rotations

    # Initialize the counter for each 80% person
    foreach ($person in $percentPersons) {
        $percentCounter[$person] = 0
    }

    # Calculate rotation
    $assignments = New-Object System.Collections.Generic.List[System.Object]

    # An index for the rotation of employees
    $personIndex = 0
    # A counter to track how often each 80% person has been scheduled
    $percentAssignedCount = @{}
    foreach ($person in $percentPersons) {
        $percentAssignedCount[$person] = 0
    }

    foreach ($week in $weeks) {
        $weekStart = $week.Start
        $weekEnd = $week.End

        # Choose the next person who is available
        $chosenPerson = $null

        # We try to go through the participants in a circle until we find someone who is available.
        for ($i=0; $i -lt $participants.Count; $i++) {
            $candidate = $participants[$personIndex]

            # Check availability
            if (Test-IsPersonAvailable -Person $candidate -Availability $Availability -Start $weekStart -End $weekEnd) {
                # If the candidate is in the list of 80% persons, we check if we take them due to their 80% quota:
                if ($percentPersons -contains $candidate) {
                    $percentCounter[$candidate]++
                    $percentAssignedCount[$candidate]++
                    # Every 5 assignments, the 80% person should only do 4 => i.e., if $percentCounter mod 5 == 0, the 80% person is skipped
                    if (($percentCounter[$candidate] % $percentSkipRate) -eq 0) {
                        # => the 80% person will be skipped this time
                        # => we increment $personIndex and try the next person
                        $personIndex = ($personIndex + 1) % $participants.Count
                        # => "continue" goes directly to the next $i in the for-loop
                        continue
                    }
                }
                # If we get here, the person is available and not skipped
                $chosenPerson = $candidate
                break
            }

            # Person not available or rejected, we try the next one
            $personIndex = ($personIndex + 1) % $participants.Count
            Write-Host "INFO: $($candidate) is not available for $($weekStart) - $($weekEnd)" -ForegroundColor Green
        }

        if (-not $chosenPerson) {
            # If no one is available, you can add logic (substitute rule, failure).
            $chosenPerson = "No one available"
        } else {
            # we have $chosenPerson,
            # so that's it for this week – loop ended with break
            # => The index was NOT incremented for the "break" person in the for-loop
            #    so we do it now:
            $personIndex = ($personIndex + 1) % $participants.Count
        }

        # Add the assignment to the list
        $assignments.Add([PSCustomObject]@{
            id = [System.Guid]::NewGuid().ToString()
            title = $chosenPerson
            type = "Pikett - proposal"
            start = $weekStart.ToString("o")
            end = $weekEnd.ToString("o")
            created = Get-Date -Format 'yyyy-MM-dd HH:mm'
        })
    }

    foreach ($person in $percentPersons) {
        Write-Host "INFO: 80% workload person '$person' was assigned $($percentAssignedCount[$person]) times." -ForegroundColor Green
    }
    $assignments
}

function New-OnCallRotationBalanced {
    <#
    .SYNOPSIS
        Generate a balanced on-call rotation based on the availability of the participants.
    .DESCRIPTION
        This function generates a balanced on-call rotation based on the availability of the participants.
        The function takes a list of participants, a list of percentPersons, a hashtable with the availability of each participant, and a list of weeks as input.
        The function assigns participants to the weeks based on their availability and ensures that the assignments are balanced.
    .PARAMETER participants
        The list of participants in rotation order.
    .PARAMETER percentPersons
        The list of participants with 80% workload.
    .PARAMETER Availability
        The hashtable with the availability of each participant.
    .PARAMETER weeks
        The list of weeks for which to generate the rotation.
    .EXAMPLE
        New-OnCallRotationBalanced -participants $participants -percentPersons $percentPersons -Availability $Availability -weeks $weeks
    .NOTES
        Assumptions:
        - The rotation of the employees is cyclical.
        - The availability of the employees is given in the form of time blocks.
        - The weekly intervals go from Monday 09:00 to Monday 09:00.
        - PercentPersons have only 80% workload and skip one out of every 5 assignments.
    #>

    param(
        [Parameter(Mandatory=$true)]
        [Array]$participants,

        [Parameter(Mandatory=$true)]
        [Array]$percentPersons,

        [Parameter(Mandatory=$true)]
        [hashtable]$Availability,

        [Parameter(Mandatory=$true)]
        [Array]$weeks
    )

    $percentCounter = @{}
    $percentSkipRate = 5  # skip one percentPerson assignment every 5 rotations

    # Initialize the counter for each 80% person
    foreach ($person in $percentPersons) {
        $percentCounter[$person] = 0
    }

    # Initialize the assignment count for each participant
    $assignmentCount = @{}
    foreach ($person in $participants) {
        $assignmentCount[$person] = 0
    }

    # Calculate rotation
    $assignments = New-Object System.Collections.Generic.List[System.Object]

    # An index for the rotation of employees
    $personIndex = 0

    foreach ($week in $weeks) {
        $weekStart = $week.Start
        $weekEnd = $week.End

        # Choose the next person who is available and has the least assignments
        $chosenPerson = $null

        # We try to go through the participants in a circle until we find someone who is available and has the least assignments.
        for ($i=0; $i -lt $participants.Count; $i++) {
            $candidate = $participants[$personIndex]

            # Check availability
            if (Test-IsPersonAvailable -Person $candidate -Availability $Availability -Start $weekStart -End $weekEnd) {
                # If the candidate is in the list of 80% persons, we check if we take them due to their 80% quota:
                if ($percentPersons -contains $candidate) {
                    $percentCounter[$candidate]++
                    # Every 5 assignments, the 80% person should only do 4 => i.e., if $percentCounter mod 5 == 0, the 80% person is skipped
                    if (($percentCounter[$candidate] % $percentSkipRate) -eq 0) {
                        # => the 80% person will be skipped this time
                        # => we increment $personIndex and try the next person
                        $personIndex = ($personIndex + 1) % $participants.Count
                        # => "continue" goes directly to the next $i in the for-loop
                        continue
                    }
                }
                # If we get here, the person is available and not skipped
                $chosenPerson = $candidate
                break
            }

            # Person not available or rejected, we try the next one
            $personIndex = ($personIndex + 1) % $participants.Count
        }

        if (-not $chosenPerson) {
            # If no one is available, you can add logic (substitute rule, failure).
            $chosenPerson = "No one available"
        } else {
            # we have $chosenPerson,
            # so that's it for this week – loop ended with break
            # => The index was NOT incremented for the "break" person in the for-loop
            #    so we do it now:
            $personIndex = ($personIndex + 1) % $participants.Count
        }

        # Add the assignment to the list
        $assignments.Add([PSCustomObject]@{
            id = [System.Guid]::NewGuid().ToString()
            title = $chosenPerson
            type = "Pikett - proposal"
            start = $weekStart.ToString("o")
            end = $weekEnd.ToString("o")
            created = Get-Date -Format 'yyyy-MM-dd HH:mm'
        })

        # Increment the assignment count for the chosen person
        if ($chosenPerson -ne "No one available") {
            $assignmentCount[$chosenPerson]++
        }
    }

    foreach ($person in $percentPersons) {
        Write-Host "INFO: 80% workload person '$person' was assigned $($assignmentCount[$person]) times." -ForegroundColor Green
    }
    $assignments
}
#endregion

# Define the path to the API folder
$ApiPath = $($PSScriptRoot).Replace('bin','api')
$dbPath = Join-Path -Path $ApiPath -ChildPath 'rotamaster.db'

# Load the list of participants in rotation order
$participants   = Get-Participants -dbPath $dbPath
$percentPersons = $participants | Where-Object Workload -le 80 | Select-Object -ExpandProperty Name
# $participants | Format-Table

# Load all events for the given year
$year = (Get-Date $StartDate).Year
Write-Host "INFO: Generating on-call schedule for year $year" -ForegroundColor Green
$allEvents = Get-AllEvents -dbPath $dbPath -year $Year
# $allEvents | Format-Table -AutoSize

# Determine the availability of the participants based on the events
if($allEvents){
    $Availability = Get-Availability -participants ($participants| Select-Object -ExpandProperty Name) -events $allEvents
    # $Availability | Format-Table
}else{
    Write-Host "INFO: No events found for the year $year" -ForegroundColor Green
    $Availability = @{}
}

# Calculate weekly intervals for the year
$weeks = New-OnCallSchedule -StartDate $StartDate -EndDate $EndDate
# $weeks | Format-Table

# Generate new on-call rotation
# $assignments = New-OnCallRotation -participants ($participants| Select-Object -ExpandProperty Name) -percentPersons $percentPersons -Availability $Availability -weeks $weeks
$assignments = New-OnCallRotationBalanced -participants ($participants | Where-Object Workload -ge 60 | Select-Object -ExpandProperty Name) -percentPersons $percentPersons -Availability $Availability -weeks $weeks

#region Export to CSV
# Define the output CSV file path
$outputCsvPath = Join-Path -Path $ApiPath -ChildPath "on-call-rota-$($Year).csv"
# Export the patching data to CSV
$assignments | Export-Csv -Path $outputCsvPath -NoTypeInformation -Delimiter ';'
# Display the output file path to the user
Write-Host "INFO: CSV file created: $outputCsvPath" -ForegroundColor Green
#endregion