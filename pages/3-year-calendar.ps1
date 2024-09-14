Add-PodeWebPage -Name 'yearcalendar' -DisplayName 'Year Calendar' -ScriptBlock {

    Import-PodeWebStylesheet -Url 'https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.css'
    Import-PodeWebJavaScript -Url 'https://unpkg.com/js-year-calendar@latest/dist/js-year-calendar.min.js'

    New-PodeWebContainer -id 'monthlycalendar' -Content @(
        # Füge das <div> Element für den Kalender hinzu
        New-PodeWebRaw -Value '<div id="calendar" style="width: 100%; height: 350px;"></div>'
    )

    # Füge das JavaScript direkt in den Raw-HTML Block ein, um FullCalendar zu initialisieren
    New-PodeWebRaw -Value @"
        <script>
            document.addEventListener('DOMContentLoaded', function() {
                    var calendarEl = document.getElementById('calendar');
                    new Calendar(calendarEl, {
                        style: 'background',
                        language: 'en'
                    });
                });
        </script>
"@

}
