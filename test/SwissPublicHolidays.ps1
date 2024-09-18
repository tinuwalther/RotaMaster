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

# Beispiel: Ostersonntag für das Jahr 2024 berechnen
$easterSunday2024 = Get-EasterSunday -year 2024
$easterSunday2024

# Berechnung der beweglichen Feiertage für 2024
$karfreitag_2024 = (Get-EasterSunday -year 2024).AddDays(-2).ToString("yyyy-MM-dd")
$ostermontag_2024 = (Get-EasterSunday -year 2024).AddDays(1).ToString("yyyy-MM-dd")
$auffahrt_2024 = (Get-EasterSunday -year 2024).AddDays(39).ToString("yyyy-MM-dd")
$pfingstmontag_2024 = (Get-EasterSunday -year 2024).AddDays(50).ToString("yyyy-MM-dd")

# Liste von Feiertagen als PSCustomObject
$feiertage_spezial = @(
    [PSCustomObject]@{ Datum = "2024-01-01"; Feiertag = "Neujahrstag"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = "2024-01-02"; Feiertag = "Berchtoldstag"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = $karfreitag_2024; Feiertag = "Karfreitag"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = $ostermontag_2024; Feiertag = "Ostermontag"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = "2024-05-01"; Feiertag = "Tag der Arbeit"; Kanton = "ZH, GR" }
    [PSCustomObject]@{ Datum = $auffahrt_2024; Feiertag = "Auffahrt"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = $pfingstmontag_2024; Feiertag = "Pfingstmontag"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = "2024-08-01"; Feiertag = "Bundesfeier"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = "2024-11-01"; Feiertag = "Allerheiligen"; Kanton = "SG, BE" }
    [PSCustomObject]@{ Datum = "2024-12-25"; Feiertag = "Weihnachtstag"; Kanton = "ALLE" }
    [PSCustomObject]@{ Datum = "2024-12-26"; Feiertag = "Stephanstag"; Kanton = "ALLE" }
)

# Ausgabe der Feiertage
$feiertage_spezial | Select-Object Feiertag,@{N='start';E={$_.Datum}},@{N='end';E={$_.Datum}} | ConvertTo-Csv -Delimiter ';'
