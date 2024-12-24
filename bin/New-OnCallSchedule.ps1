## Create a synopsis for the script
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
    ## add a parameter for the database path
    param (
        [Parameter(Mandatory=$true)]
        [string]$dbPath
    )

    # Liste der Personen in Rotationsreihenfolge
    # Annahme: Reihenfolge ist fix, kann aber anpassbar gemacht werden.
    $sql = 'SELECT name,firstname FROM person ORDER BY firstname'
    $connection = New-SQLiteConnection -DataSource $dbPath
    $data = Invoke-SqliteQuery -Connection $connection -Query $sql
    $data | ForEach-Object{
        @($_.name + ' ' + $_.firstname)
    }
}

## Create a function from the code block
function Get-AllEvents {
    param (
        [Parameter(Mandatory = $true)]
        [string]$dbPath,

        [Parameter(Mandatory = $true)]
        [int]$year
    )

    # Alle Events für das Jahr laden
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

# Funktion, um zu prüfen, ob eine Person in einem Zeitraum verfügbar ist
function Test-IsPersonAvailable {
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

# Erstellen der Wochenintervalle für das gegebene Jahr
# Wir gehen davon aus, dass die Pikettwoche am Montag 09:00 UTC startet.
# Die Wochen gehen von Montag 09:00 bis Montag 09:00.
function New-OnCallSchedule {
    param(
        [Parameter(Mandatory = $true)]
        [string]$StartDate,

        [Parameter(Mandatory = $true)]
        [string]$EndDate
    )

    # Konvertiere die Eingabe-Strings in Datetime-Objekte
    # $startDate = [datetime]::ParseExact($StartDate, 'yyyy-MM-dd', $null).ToUniversalTime()
    # $endDate   = [datetime]::ParseExact($EndDate, 'yyyy-MM-dd', $null).ToUniversalTime()

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
        Wir nehmen an, dass jeder Eintrag, der den Namen einer Person enthält und Ferien, GLZ Kompensation, Blockiert, Militär,
        Aus/Weiterbildung etc. andeutet, diese Person in diesem Zeitraum sperrt. 
        Pikett-Einträge werden ignoriert, da es sich um vergangene/fixierte Einträge handelt. 
        Du kannst hier dein eigenes Mapping definieren.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [Array]$participants,

        [Parameter(Mandatory=$true)]
        [Array]$events
    )
    
    # Initialisiere die Verfügbarkeit für jede Person
    $unavailable = @{}
    foreach ($person in $participants) {
        $unavailable[$person] = New-Object System.Collections.Generic.List[System.Object]
    }

    foreach ($item in $events) {
        # Suche nach dem Namen im SUMMARY. Annahme: Format "Name - Ferien"
        # Bsp: " percentPerson - Ferien"
        # Wir erkennen Personennamen, indem wir mit allen Personen matchen:
        $foundPerson = $null
        foreach ($p in $participants) {
            if ($item.person -like $p) {
                $foundPerson = $p
                break
            }
        }
        if ($foundPerson) {
            # Prüfe ob das Event den Mitarbeiter blockiert
            # Wir gehen davon aus, dass alles diesen Mitarbeiter blockiert.
            $unavailable[$foundPerson].Add([PSCustomObject]@{
                Start = $item.Start
                End   = $item.End
            })
        }
    }
    return $unavailable
    
}

# Pikettrotation
# Man könnte aber auch bei jeder Rotation prüfen, ob percentPerson gerade genug Einsätze hatte.
function New-OnCallRotation{
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
        Wir gehen davon aus, dass die Rotation der Mitarbeiter zyklisch ist.
        Wir gehen davon aus, dass die Verfügbarkeit der Mitarbeiter in Form von Zeitblöcken gegeben ist.
        Wir gehen davon aus, dass die Wochenintervalle von Montag 09:00 bis Montag 09:00 gehen.
        Wir gehen davon aus, dass percentPerson nur 80% Pensum hat und alle 5 Einsätze einen auslässt.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [Array]$participants,

        [Parameter(Mandatory=$true)]
        [string]$percentPerson,

        [Parameter(Mandatory=$true)]
        [hashtable]$Availability,

        [Parameter(Mandatory=$true)]
        [Array]$weeks
    )

    $percentCounter = 0
    $percentSkipRate = 5  # alle 5 Durchgänge einen percentPerson-Einsatz auslassen

    # Rotation berechnen
    $assignments = New-Object System.Collections.Generic.List[System.Object]

    # Ein Index für die Rotation der Mitarbeiter
    $personIndex = 0
    # Ein Zähler, wie oft percentPerson bisher eingeplant wurde, um 80% Pensum abzubilden.
    $percentAssignedCount = 0 

    foreach ($week in $weeks) {
        $weekStart = $week.Start
        $weekEnd = $week.End

        # Wähle die nächste Person, die verfügbar ist
        $chosenPerson = $null

        # Wir versuchen nacheinander durch die Personen im Kreis zu gehen, bis wir jemanden finden, der verfügbar ist.
        for ($i=0; $i -lt $participants.Count; $i++) {
            $candidate = $participants[$personIndex]

            # Prüfe Verfügbarkeit
            if (Test-IsPersonAvailable -Person $candidate -Availability $Availability -Start $weekStart -End $weekEnd) {
                # Wenn der Kandidat percentPerson ist, prüfen wir, ob wir ihn aufgrund seiner 80%-Quote nehmen:
                if ($candidate -eq $percentPerson) {
                    $percentCounter++
                    # Alle 5 Einsätze darf percentPerson nur 4 machen => d.h. wenn $percentCounter mod 5 == 0, wird percentPerson übersprungen
                    if (($percentCounter % $percentSkipRate) -eq 0) {
                        # => percentPerson wird diesmal geskippt
                        # => wir erhöhen $personIndex und probieren nächste Person
                        $personIndex = ($personIndex + 1) % $participants.Count
                        # => "continue" geht direkt zur nächsten $i in der for-Schleife
                        continue
                    }
                }
                # Wenn wir hierher kommen, ist Person verfügbar und nicht geskippt
                $chosenPerson = $candidate
                break
            }

            # Person nicht verfügbar oder abgelehnt, wir probieren die nächste
            $personIndex = ($personIndex + 1) % $participants.Count
            Write-Host "INFO: $($candidate) is not available for $($weekStart) - $($weekEnd)" -ForegroundColor Green
        }

        if (-not $chosenPerson) {
            # Falls niemand verfügbar ist, kann man eine Logik ergänzen (Ersatzregelung, Ausfall).
            $chosenPerson = "Niemand Verfügbar"
        }else {
            # wir haben $chosenPerson,
            # also das war's für diese Woche – Schleife endete mit break
            # => Der Index wurde in der for-Schleife NICHT für die "bruchab" Person
            #    erhöht, also tun wir das jetzt:
            $personIndex = ($personIndex + 1) % $participants.Count
        }

        $assignments.Add([PSCustomObject]@{
            id = [System.Guid]::NewGuid().ToString()
            title = $chosenPerson
            type = "Pikett"
            start = $weekStart.ToString("o")
            end = $weekEnd.ToString("o")
            created = Get-Date -Format 'yyyy-MM-dd HH:mm'
        })
    }   
    $assignments
}
#endregion

# Define the path to the API folder
$ApiPath = $($PSScriptRoot).Replace('bin','api')
$dbPath = Join-Path -Path $ApiPath -ChildPath 'rotamaster.db'

# Liste der Personen in Rotationsreihenfolge laden
$participants = Get-Participants -dbPath $dbPath
# $participants | Format-Table

# Alle Events für das gegebene Jahr laden
$year = (Get-Date $StartDate).Year
Write-Host "INFO: Generating on-call schedule for year $year" -ForegroundColor Green
$allEvents = Get-AllEvents -dbPath $dbPath -year $Year
# $allEvents | Format-Table -AutoSize

# Verfügbarkeit der Personen basierend auf den Events bestimmen
$Availability = Get-Availability -participants $participants -events $allEvents
# $Availability | Format-Table

# Wochenintervalle für das Jahr berechnen
$weeks = New-OnCallSchedule -StartDate $StartDate -EndDate $EndDate
# $weeks | Format-Table

# Neue Pikettrotation generieren
$assignments = New-OnCallRotation -participants $participants -percentPerson 'Mercury Freddie' -Availability $Availability -weeks $weeks

#region Export to CSV
# Define the output CSV file path
$outputCsvPath = Join-Path -Path $ApiPath -ChildPath "on-call-rota-$($Year).csv"
# Export the patching data to CSV
$assignments | Export-Csv -Path $outputCsvPath -NoTypeInformation -Delimiter ';'
# Display the output file path to the user
Write-Host "INFO: CSV file created: $outputCsvPath" -ForegroundColor Green
#endregion