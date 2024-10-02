@{
    Web = @{
        Static = @{
            Cache = @{
                Enable = $true
            }
        }
    }
    fullCalendar = @{
        backgroundColor = '#343a40' # '#343a40' = dark-mode
        #backgroundColor = '#f8f9fa' # '#f8f9fa' = light-mode
        #headerToolbar = 'multiMonthYear,dayGridMonth,dayGridWeek,dayGridDay,listMonth'
        #headerToolbar = 'multiMonthYear,dayGridMonth,dayGridWeek,listMonth'
        headerToolbar = 'multiMonthYear,dayGridMonth,listMonth'
    }
    absenceType = @{
        'Ferien'      = 'Ferien'
        'Kurs'        = 'Kurs'
        'Gleitzeit'   = 'Gleitzeit'
        'Militär'     = 'Militärdienst'
        'Zivildienst' = 'Zivildienst'
        'Pikett'      = 'Pikettdienst'
        'Pikett Pier' = 'Pikett Pier'
    }
    person = @(
        'Tinu'
        'Fridu'
        'Hausi'
        'Aschi'
        'Peschä'
    )
}