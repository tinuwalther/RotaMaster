## Create a synopsis for the script
<#
.SYNOPSIS
    Generate an on-call schedule for a given year.
.DESCRIPTION
    This script generates an on-call schedule for a given year.
    The script reads the data from the SQLite database and generates the schedule based on the availability of the participants.
    The schedule is then exported to a CSV file with the format: id;title;type;start;end;created.
    The script uses the following logic to generate the schedule:
    - Load the list of participants in rotation order.
    - Load all events for the given year from the database.
    - Determine the availability of each participant based on the events.
    - Generate weekly intervals for the given year.
    - Assign participants to the weekly intervals based on availability and rotation order.
    - Export the schedule to a CSV file.
.PARAMETER Year
    The year for which to generate the on-call schedule.
.EXAMPLE
    New-OnCallSchedule -Year 2022
#>

[CmdletBinding()]
param(
    # Set the year for which you want to generate the patching schedule
    [Parameter(Mandatory=$true)]
    [Int] $Year
)

## Add a region named 'Functions'
#region Functions
## Create a function from the code block
function Get-Participants {
    ## add a parameter for the database path
    param (
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
        [string]$dbPath,
        [int]$year
    )

    # Alle Events für das Jahr laden
    $sql = 'SELECT * FROM v_Events WHERE start LIKE "%' + $year + '%"'
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
        [string]$Person,
        [datetime]$Start,
        [datetime]$End
    )

    $blocks = $unavailable[$Person]
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
function Get-WeekIntervals {
    param(
        [int]$Year
    )

    # Erster Montag um 09:00 im Jahr finden
    # Annahme: Wir starten am ersten Montag des Jahres um 09:00 UTC
    $startDate = [datetime]"$Year-01-01T00:00:00Z"
    while ($startDate.DayOfWeek -ne [System.DayOfWeek]::Monday) {
        $startDate = $startDate.AddDays(1)
    }
    $startDate = $startDate.Date.AddHours(10) # auf 09:00 Uhr setzen

    $endOfYear = [datetime]"$($Year+1)-01-01T00:00:00Z"

    $weeks = New-Object System.Collections.Generic.List[System.Object]

    $currentStart = $startDate
    while ($currentStart -lt $endOfYear) {
        $currentEnd = $currentStart.AddDays(7)
        if ($currentEnd -ge $endOfYear) {
            $currentEnd = $endOfYear
        }
        $weeks.Add([PSCustomObject]@{
            Start = $currentStart
            End   = $currentEnd
        })
        $currentStart = $currentEnd
    }

    return $weeks
}
#endregion

# Define the path to the API folder
$ApiPath = $($PSScriptRoot).Replace('bin','api')
$dbPath = Join-Path -Path $ApiPath -ChildPath 'rotamaster.db'

$participants = Get-Participants -dbPath $dbPath

# percentPerson hat nur 80% Pensum.
# Eine einfache Heuristik: von 5 normalen Einsätzen bekommt percentPerson nur 4.
# Man könnte aber auch bei jeder Rotation prüfen, ob percentPerson gerade genug Einsätze hatte.
$percentPerson = 'Mercury Freddie'
$percentCounter = 0
$percentSkipRate = 5  # alle 5 Durchgänge einen percentPerson-Einsatz auslassen

# Alle Events für das gegebene Jahr laden
$allEvents = Get-AllEvents -dbPath $dbPath -year $Year

# Verfügbarkeiten ermitteln
# Wir nehmen an, dass jeder Eintrag, der den Namen einer Person enthält und Ferien, GLZ Kompensation, Blockiert, Militär, Aus/Weiterbildung etc. andeutet,
# diese Person in diesem Zeitraum sperrt. Pikett-Einträge werden ignoriert, da es sich um vergangene/fixierte Einträge handelt.
# Du kannst hier dein eigenes Mapping definieren.
$unavailable = @{}

foreach ($person in $participants) {
    $unavailable[$person] = New-Object System.Collections.Generic.List[System.Object]
}

foreach ($ev in $allEvents) {
    # Suche nach dem Namen im SUMMARY. Annahme: Format "Name - Ferien"
    # Bsp: " percentPerson - Ferien"
    # Wir erkennen Personennamen, indem wir mit allen Personen matchen:
    $foundPerson = $null
    foreach ($p in $participants) {
        if ($ev.type -like "*$p*") {
            $foundPerson = $p
            break
        }
    }
    if ($foundPerson) {
        # Prüfe ob das Event den Mitarbeiter blockiert
        # Wir gehen davon aus, dass alles außer "Pikett" diesen Mitarbeiter blockiert.
        $unavailable[$foundPerson].Add([PSCustomObject]@{
            Start = $ev.Start
            End   = $ev.End
        })
    }
}

$weeks = Get-WeekIntervals -Year $Year

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
        if (Test-IsPersonAvailable -Person $candidate -Start $weekStart -End $weekEnd) {
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


#region Export to CSV
# Define the output CSV file path
$outputCsvPath = Join-Path -Path $ApiPath -ChildPath "on-call-rota-$($Year).csv"
# Export the patching data to CSV
$assignments | Export-Csv -Path $outputCsvPath -NoTypeInformation -Delimiter ';'
# Display the output file path to the user
Write-Output "CSV file created: $outputCsvPath"
#endregion