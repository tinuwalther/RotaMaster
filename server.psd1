@{
    Web = @{
        Static = @{
            Cache = @{
                Enable = $true
            }
        }
    }
    fullCalendar = @{
        # backgroundColor = '#343a40' # '#343a40' = dark-mode
        # backgroundColor = '#f8f9fa' # '#f8f9fa' = light-mode
        # headerToolbar = 'multiMonthYear,dayGridMonth,dayGridWeek,dayGridDay,listMonth'
        # headerToolbar = 'multiMonthYear,dayGridMonth,dayGridWeek,listMonth'
        headerToolbar = 'multiMonthYear,dayGridMonth,listMonth'
    }
    absenceType = @{
        'Pikett'      = 'Pikettdienst'
        'Pikett Pier' = 'Pikett Pier'
        'Ferien'      = 'Ferien'
        'Gleitzeit'   = 'Gleitzeit'
        'Kurs'        = 'Kurs'
        'Krankheit'   = 'Krankheit'
        'Militär'     = 'Militärdienst'
        'Zivildienst' = 'Zivildienst'
    }
    person = @(
        'Tinu'
        'Fridu'
        'Hausi'
        'Aschi'
        'Peschä'
        'Ändu'
        'Fredu'
    )
}