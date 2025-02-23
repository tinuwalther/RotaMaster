/**
 * Configuration object for the FullCalendar instance.
 * 
 * This constant defines the default configuration settings for a FullCalendar instance, 
 * including the application version, time zone, locale, initial view, toolbar layout, 
 * button labels, and various display preferences. It centralizes the calendar setup 
 * to ensure consistency across the application.
 */
const calendarConfig = {
    appVersion: "5.4.4",
    appPrefix: "PS",
    opsGenie: true,
    scheduleName: 'tinu_schedule',
    rotationName: '2025',
    timeZone: 'local',
    locale: 'de-CH',
    height: 'auto',
    themeSystem: 'standard',
    initialView: 'multiMonthYear',
    multiMonthMinWidth: 400,
    multiMonthMaxColumns: 2,
    headerToolbar: {
        left: 'prevYear,prev,today,next,nextYear refreshButton',
        center: 'title',
        right: 'multiMonthYear,dayGridMonth,listMonth exportToIcs,filterEvents'
    },
    buttonText: {
        today: 'Heute',
        year: 'Jahr',
        month: 'Monat',
        list: 'Liste'
    },
    weekNumbers: true,
    dayMaxEvents: true,
    showNonCurrentDates: false,
    fixedWeekCount: false,
    weekNumberCalculation: 'ISO',
    selectable: true,
    editable: true,
    displayEventTime: false,
    navLinks: true
};
