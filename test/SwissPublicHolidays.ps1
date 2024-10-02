[CmdletBinding()]
param(
    [ValidateRange(1970, 2999)]
    [Parameter(Mandatory=$true)]
    [Int] $Year
)

function Get-EasterSunday {
    param (
        [int]$year
    )

    # Algorithmen nach Carl Friedrich Gauß zur Berechnung des Ostersonntags
    $a = $year % 19
    $b = [math]::Floor($year / 100)
    $c = $year % 100
    $d = [math]::Floor($b / 4)
    $e = $b % 4
    $f = [math]::Floor(($b + 8) / 25)
    $g = [math]::Floor(($b - $f + 1) / 3)
    $h = (19 * $a + $b - $d - $g + 15) % 30
    $i = [math]::Floor($c / 4)
    $k = $c % 4
    $l = (32 + 2 * $e + 2 * $i - $h - $k) % 7
    $m = [math]::Floor(($a + 11 * $h + 22 * $l) / 451)
    $month = [math]::Floor(($h + $l - 7 * $m + 114) / 31)
    $day = (($h + $l - 7 * $m + 114) % 31) + 1

    # Rückgabe des Ostersonntags als DateTime-Objekt
    return Get-Date -Year $year -Month $month -Day $day
}

# Berechnung der beweglichen Feiertage für 2024
$easterSunday  = (Get-EasterSunday -year $Year).ToString("yyyy-MM-dd")
$karfreitag    = (Get-EasterSunday -year $Year).AddDays(-2).ToString("yyyy-MM-dd")
$ostermontag   = (Get-EasterSunday -year $Year).AddDays(1).ToString("yyyy-MM-dd")
$auffahrt      = (Get-EasterSunday -year $Year).AddDays(39).ToString("yyyy-MM-dd")
$pfingstmontag = (Get-EasterSunday -year $Year).AddDays(50).ToString("yyyy-MM-dd")

# Liste von Feiertagen als PSCustomObject
#"id";"title";"type";"start";"end";"created"
$feiertage_spezial = @(
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-01-01"; title = "Neujahrstag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-01-02"; title = "Berchtoldstag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = $karfreitag; title = "Karfreitag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = $easterSunday; title = "Ostersonntag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = $ostermontag; title = "Ostermontag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-05-01"; title = "Tag der Arbeit (ZH, GR)"; Kanton = "ZH, GR" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = $auffahrt; title = "Auffahrt"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = $pfingstmontag; title = "Pfingstmontag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-08-01"; title = "Bundesfeier"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-11-01"; title = "Allerheiligen (SG, BE)"; Kanton = "SG, BE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-12-25"; title = "Weihnachtstag"; Kanton = "ALLE" }
    [PSCustomObject]@{ id = ([GUID]::NewGuid()); Datum = "$($Year)-12-26"; title = "Stephanstag"; Kanton = "ALLE" }
)

# Ausgabe der Feiertage
$feiertage_spezial | Select-Object id,title,@{N='type';E={'Feiertag'}},@{N='start';E={$_.Datum}},@{N='end';E={$_.Datum}},@{N='created';E={(Get-Date -f 'yyyy-MM-dd')}} #| ConvertTo-Csv -Delimiter ';'
