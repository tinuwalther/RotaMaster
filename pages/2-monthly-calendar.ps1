Add-PodeWebPage -Name 'monthlycalendar' -DisplayName 'Monthly Calendar' -ScriptBlock {

    Import-PodeWebStylesheet -Url 'https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.css'
    Import-PodeWebJavaScript -Url 'https://cdn.jsdelivr.net/npm/fullcalendar@5.10.1/main.min.js'

    New-PodeWebContainer -id 'monthlycalendar' -Content @(
        # Füge das <div> Element für den Kalender hinzu
        New-PodeWebRaw -Value '<div id="calendar" style="width: 100%; height: 350px;"></div>'
    )

    # Füge das JavaScript direkt in den Raw-HTML Block ein, um FullCalendar zu initialisieren
    New-PodeWebRaw -Value @"
        <script>
            document.addEventListener('DOMContentLoaded', function() {
            
                var calendarEl = document.getElementById('calendar');

                var calendar = new FullCalendar.Calendar(calendarEl, {

                    initialView: 'dayGridMonth',

                    events: '/get-events',  // Holt Events von der PowerShell-Route
                    
                    dateClick: function(info) {
                        alert('Datum angeklickt: ' + info.dateStr);
                    }
                });

                calendar.render();
            });
        </script>
"@

}
