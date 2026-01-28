# CHANGELOG

## Table of Contents

- [2025-07-25](#2025-07-25)
- [2025-04-22](#2025-04-22)
- [2025-04-09](#2025-04-09)
- [2025-04-04](#2025-04-04)
- [2025-03-30](#2025-03-30)
- [2025-03-23](#2025-03-23)
- [2025-03-12](#2025-03-12)
- [2025-03-05](#2025-03-05)
- [2025-02-22](#2025-02-22)
- [2025-02-02](#2025-02-02)
- [2025-01-15](#2025-01-15)
- [2025-01-08](#2025-01-08)
- [2024-12-30](#2024-12-30)

## Open: Export from current Year

````javascript
// ...existing code...
exportButton.addEventListener('click', function() {
    const events = calendar.getEvents();
    const currentYear = new Date().getFullYear();

    // Helper: checks if the event is in the current year

    function isEventInCurrentYear(event) {
        const start = new Date(event.start);
        return start.getFullYear() === currentYear;
    }

    if (btnAllEvents.checked) {
        // Export only events of the current year
        exportCalendarEvents(events.filter(isEventInCurrentYear), `all-events-${currentYear}.ics`);
    } else if (btnPersonEvents.checked) {
        const personName = document.getElementById('nameDropdownPersonModal').value.trim();
        if (personName) {
            exportFilteredEvents(
                events.filter(isEventInCurrentYear),
                event => {
                    const [eventPersonName] = event.title.split(' - ');
                    return eventPersonName.trim().toLowerCase() === personName.toLowerCase();
                },
                `${personName}-events-${currentYear}.ics`,
                exportCalendarEvents
            );
        } else {
            showAlert('Bitte geben Sie einen Namen ein.');
        }
    } else if (btnTypeOfEvents.checked) {
        const eventType = document.getElementById('nameDropdownAbsenceModal').value.trim();
        if (eventType) {
            exportFilteredEvents(
                events.filter(isEventInCurrentYear),
                event => {
                    const [, eventTypeName] = event.title.split(' - ');
                    return eventTypeName && eventTypeName.trim().toLowerCase() === eventType.toLowerCase();
                },
                `${eventType}-events-${currentYear}.ics`,
                exportCalendarEvents
            );
        } else {
            showAlert('Bitte geben Sie einen Event-Typ ein.');
        }
    }

    const exportModal = bootstrap.Modal.getInstance(document.getElementById('multipleEvents'));
    exportModal.hide();
});
// ...existing code...
`````

## 2025-07-25

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.5.5. This version implements a context menu for the calendar.

### rotamaster.main.js

Replace the function ````calculateWorkdays```` with:

````javascript
...
function calculateWorkdays(startDate, endDate, holidays, daypart = 'full') {
    let count = 0; // Counter for weekdays
    let currentDate = new Date(startDate); // Create a copy of the start date

    // Ensure times are set correctly to midnight
    currentDate.setHours(1, 0, 0, 0);
    endDate.setHours(23, 0, 0, 0);

    // Iterate over each day in the period, including the end date
    while (currentDate.getTime() < endDate.getTime()) {
        const dayOfWeek = currentDate.getDay(); // Get the day of the week (0-6)
        const formattedDate = formatDateToLocalISO(currentDate); // Format the date as 'YYYY-MM-DD'
        const isWeekend = dayOfWeek === 0 || dayOfWeek === 6; // Sunday = 0, Saturday = 6
        const isSwissHoliday = holidays.includes(formattedDate); // Check if the current date is a Swiss holiday
        if(!isSwissHoliday && !isWeekend){
            if (startDate.toDateString() === endDate.toDateString()) {
                if (daypart === 'morning' || daypart === 'afternoon') {
                    count += 0.5;
                } else {
                    count += 1;
                }
            } else {
                count += 1;
            }
        }
        // Move to the next day
        currentDate.setDate(currentDate.getDate() + 1);
    }
    // console.log('DEBUG', 'calculateWorkdays - Start date:', startDate.toDateString(), 'End date:', endDate.toDateString(), 'Number of weekdays:', count);
    return count;
}
...
````

Replace the function ````setModalEventData````

````javascript
...
function setModalEventData(event) {
    let swissHolidays = getSwissHolidays(event.start.getFullYear());
    const eventStartDate = formatDateToShortISOFormat(event.start);
    const eventEndDate = formatDateToShortISOFormat(event.end);

    let daypart = 'fullday';
    const startHour = event.start.getHours();
    const endHour = event.end.getHours();

    if (startHour === 13 || endHour === 17) {
        daypart = 'afternoon';
    }

    if (startHour === 8 && endHour === 12) {
        daypart = 'morning';
    }

    var days = 0;
    for (const [key, value] of Object.entries(event.extendedProps)) {
        if(value === 'Pikett'){
            days = calculatePikettkdays(event.start,event.end)
        }else{
            if(value === 'Feiertag'){
                days = calculateWorkdays(event.start, event.end, [], daypart)
            }else{
                days = calculateWorkdays(event.start, event.end, swissHolidays, daypart)
            }
        }
    };

    if(event.id){
        document.getElementById('singleEvent-id').textContent = `id: ${event.id}`;
    }else{
        document.getElementById('singleEvent-id').textContent = 'id: n/a, this event is form a file!';
    }
    document.getElementById('singleEvent-title').textContent = `${event.title}, ${days} Tage`;
    document.getElementById('singleEvent-date').textContent = `von: ${eventStartDate} bis: ${eventEndDate}`;

}
...
````

### rotamaster.index.js

After ````let db````

````javascript
...
let username = null; // contextMenu V5.5.5
...
````

After ````// Fetch the person from the API (from the SQLite table person) and fill the datalist with the person names````

````javascript
...
if (personNames.length) {
    fillDatalistOptions('datalistOptions', personNames);
    fillDropdownOptions('nameDropdownPerson', personNames);
    fillDropdownOptions('nameDropdownPersonModal', personNames);
    fillDropdownOptions('nameDropdownPerson-contextMenu', personNames); // contextMenu V5.5.5
} else {
    console.error('No person found.');
}
...
````

After ````// Fetch the absence from the API (from the SQLite table absence) and fill the dropdown with the absence names````

````javascript
...
if (absenceNames.length) {
    fillDropdownOptions('nameDropdownAbsence', absenceNames);
    fillDropdownOptions('nameDropdownAbsenceModal', absenceNames);
    fillDropdownOptions('nameDropdownAbsence-contextMenu', absenceNames); // contextMenu V5.5.5
} else {
    console.error('No absence found.');
}
...
````

In ````select: function(info)````

````javascript
...
// contextMenu V5.5.5
document.getElementById('start-contextMenu').value = formattedStartDate;
document.getElementById('end-contextMenu').value = formattedEndDate;
...
````

After ````toggleFormButton.addEventListener````

````javascript
...
//#region Modal contextMenu V5.5.5
const contextMenu = document.getElementById("contextMenu");
const exportNewEvent = document.getElementById('btnNewEvent');

// Right-click on calendar to open the contextMenu
const calendarElement = document.getElementById('calendar');
calendarElement.addEventListener("contextmenu", function (e) {
    e.preventDefault();

    const startDate = document.getElementById('start-contextMenu');
    const endDate = document.getElementById('end-contextMenu');
    
    document.getElementById('nameDropdownPerson-contextMenu').value = username || '';        
    document.getElementById('nameDropdownAbsence-contextMenu').value = '';
    
    if(!startDate.value){
        document.getElementById('start-contextMenu').value = new Date().toISOString().split('T')[0];
    }
    if(!endDate.value){
        document.getElementById('end-contextMenu').value = new Date().toISOString().split('T')[0];
    }

    handleDaypartByDateRange(startDate.value, endDate.value);

    const contextMenuModal = new bootstrap.Modal(document.getElementById('contextMenu'));
    contextMenuModal.show();
});

// Close the contextMenu when clicking outside of it
window.addEventListener("click", function (event) {
    if (event.target === contextMenu) {
        if (modalInstance) {
            modalInstance.hide();
        }
    }
});

// Add an event listener to the submit button of the contextMenu
exportNewEvent.addEventListener('click', async function() {

    const eventType = document.getElementById('nameDropdownAbsence-contextMenu').value.trim();
    const personName = document.getElementById('nameDropdownPerson-contextMenu').value.trim();
    const startDate = document.getElementById('start-contextMenu').value.trim();
    const endDate = document.getElementById('end-contextMenu').value.trim();
    const fullDay = document.getElementById('fullday-contextMenu').checked;
    const afternoon = document.getElementById('afternoon-contextMenu').checked;
    const morning = document.getElementById('morning-contextMenu').checked;

    // alert(`DEBUG: ${eventType}, ${personName}, ${startDate}, ${endDate}, ${fullDay}, ${afternoon}, ${morning}`);

    if (!eventType || !personName || !startDate || !endDate){
        showAlert(`Bitte alle Felder auswählen!\nName: ${personName}\nType: ${eventType}\nStart: ${startDate}\nEnd: ${endDate}`);
        return;
    }

    switch (true) {
        case fullDay:
            // Handle full day event
            //showAlert(`${personName}\nEvent: ${eventType}\nfrom: ${startDate}\nto: ${endDate}`, `${calendarConfig.appPrefix}RotaMaster - Full Day Event`);
            dayPart = 'fullDay';
            break;
        case afternoon && (eventType !== 'Pikett' && eventType !== 'Pikett-Peer' && eventType !== 'Ferien'):
            // Handle afternoon event
            //showAlert(`${personName}\nEvent: ${eventType}\nfrom: ${startDate}\nto: ${endDate}`, `${calendarConfig.appPrefix}RotaMaster - Afternoon Event`);
            dayPart = 'afternoon';
            break;
        case morning && (eventType !== 'Pikett' && eventType !== 'Pikett-Peer' && eventType !== 'Ferien'):
            // Handle morning event
            //showAlert(`${personName}\nEvent: ${eventType}\nfrom: ${startDate}\nto: ${endDate}`, `${calendarConfig.appPrefix}RotaMaster - Morning Event`);
            dayPart = 'morning';
            break;
        default:
            // unsupported event type
            showAlert(`Unsupported event combination:\nPerson: ${personName}\nEvent: ${eventType}\nfrom: ${startDate}\nto: ${endDate}\nDaypart: ${morning ? 'Morning' : ''} ${afternoon ? 'Afternoon' : ''} ${fullDay ? 'Full Day' : ''}`);
            return;
    }

    try {
        const data = {
            type: eventType,
            name: personName,
            daypart: dayPart,
            start: startDate,
            end: endDate
        };

        if(data.start <= data.end){
            if(data.type === 'Pikett') {

                const response = await fetch(`/api/person/read/${personName}`);
                if (!response.ok) {
                    throw new Error(`Failed to fetch user ${username}`);
                }
                const currentUser = await response.json();
                if(currentUser){
                    // Create Override in OpsGenie
                    if(calendarConfig.opsGenie){
                        const override = {                                    
                            scheduleName: calendarConfig.scheduleName,
                            rotationName: calendarConfig.rotationName,
                            userName: currentUser.email,
                            onCallStart: data.start,
                            onCallEnd: data.end
                        };
                        const opsGenieResult = await createOpsGenieOverride(override);
                        console.log('DEBUG', 'OpsGenie Override:', opsGenieResult);
                        if(opsGenieResult){
                            // Add the event to the SQLite table event
                            data.alias = opsGenieResult.data.alias;
                            // console.log('DEBUG', data);
                            await createDBData('/api/event/create', data, currentUser);
                        }else{
                            showAlert(`Fehler beim Erstellen des Override in OpsGenie für ${currentUser.email}`);
                            throw new Error(`Failed to create Override in OpsGenie for user ${currentUser.email}`);
                        }
                    }else{
                        // Add the event to the SQLite table event
                        data.alias = null;
                        // console.log('DEBUG', data);
                        await createDBData('/api/event/create', data, currentUser);
                    }
                }else{
                    throw new Error(`Failed to create Override in OpsGenie for user ${username}`);
                }
            }else{
                // Add the event to the SQLite table event
                data.alias = null;
                // console.log('DEBUG', data);
                await createDBData('/api/event/create', data, currentUser);
                refreshCalendarData(calendar);
            }

        }else{
            showAlert(`Das Enddatum kann nicht vor dem Startdatum liegen!\n${data.name} - ${data.type}\nStart: ${data.start}, End: ${data.end}`);
        }
    } catch (error) {
        console.error('Error occurred:', error);
        showAlert('An error occurred while adding the event.');
    }
    finally {
        // Close the context menu modal
        const contextMenuModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('contextMenu'));
        contextMenuModal.hide();
    }
});

function handleDaypartByDateRange(startStr, endStr) {
    const startDate = new Date(startStr);
    const endDate = new Date(endStr);

    // Differenz in Tagen (inclusive)
    const dayDiff = (endDate - startDate) / (1000 * 60 * 60 * 24);

    const radioFull = document.getElementById('fullday-contextMenu');
    const radioMorning = document.getElementById('morning-contextMenu');
    const radioAfternoon = document.getElementById('afternoon-contextMenu');

    if (dayDiff >= 1) {
        radioFull.checked = true;
        radioMorning.disabled = true;
        radioAfternoon.disabled = true;
    } else {
        radioFull.checked = true;
        radioMorning.disabled = false;
        radioAfternoon.disabled = false;
    }
}
//#endregion Modal contextMenu
...
````

### index.html

After ````#region Begin NavBar````

````html
...
<!-- #region Begin Modal contextMenu V5.5.5 -->
<div class="modal" id="contextMenu" tabindex="-1" aria-labelledby="contextMenu" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">

        <div class="modal-header">
            <h1 class="modal-title fs-5" id="contextMenuTitle">RotaMaster - New Event</h1>
            <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
        </div>

        <div class="modal-body">
            <p>Event erstellen:</p>

            <div class="row g-2">

                <!-- inputfield for name -->
                <div class="input-group" id="personNameContainer-contextMenu" style="margin-top: 10px;">
                    <span class="input-group-text" id="basic-addon1" style="min-width: 80px;">Name</span>
                    <select class="form-select" id="nameDropdownPerson-contextMenu" name="nameDropdownPerson-contextMenu">
                        <option value="">Please select...</option>
                        <!-- Option values will be filled dynamically by JavaScript -->
                    </select>
                </div>

                <!-- inputfield for event type -->
                <div class="input-group" id="eventTypeContainer-contextMenu" style="margin-top: 10px;">
                    <span class="input-group-text" id="basic-addon1" style="min-width: 80px;">Absenz</span>
                    <select class="form-select" id="nameDropdownAbsence-contextMenu" name="nameDropdownAbsence-contextMenu">
                        <option value="">Please select...</option>
                        <!-- Option values will be filled dynamically -->
                    </select><br>
                </div>

                <!-- inputfield for date range -->
                <div class="input-group" id="dateRangeContainer-contextMenu" style="margin-top: 10px;">
                    <!-- label for="start" class="form-label">Startdatum und Enddatum wählen</label><br> -->
                    <div class="input-group mb-3">
                        <span class="input-group-text" id="basic-addon1" style="min-width: 80px;">Start</span>
                        <input type="date" class="form-control" id="start-contextMenu" name="start"><br>
                        <span class="input-group-text" id="basic-addon1" style="min-width: 80px;">Ende</span>
                        <input type="date" class="form-control" id="end-contextMenu" name="end"><br>
                    </div>
                </div>

            </div>

        </div>

        <div class="modal-footer">
            <button type="button" id="btnClose" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
            <button type="button" id="btnNewEvent" class="btn btn-dark">Submit</button>
        </div>

        </div>
    </div>
</div>
<!-- #endregion Modal contextMenu -->
...
````

### RotaMaster.psm1

In ````# Create new record into the table events````

````PowerShell
...
# contextMenu V5.5.5
switch($WebEvent.Data['daypart']){
    'morning'   {
        $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 08:00"
        $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 12:00"
    }
    'afternoon' {
        $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 13:00"
        $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 17:00"
    }
    default     {
        $start   = "$(Get-Date ([datetime]($WebEvent.Data['start'])) -f 'yyyy-MM-dd') 01:00"
        $end     = "$(Get-Date ([datetime]($WebEvent.Data['end'])) -f 'yyyy-MM-dd') 23:00"
    }
}
...
````

## 2025-04-22

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.5.4.

### rotamaster.index.js

````javascript
...
// Load userCookie and display the username
const userCookie = getCookie('CurrentUser');
const eventView = userCookie.events || "all";
const savedView = userCookie.savedView || "dayGridMonth";
...
let calendar = new FullCalendar.Calendar(calendarEl, {
    // Concatenate the calendarConfig from the rotamaster.js file
    ...calendarConfig,
    // get initialView from cookie
    initialView: userCookie.savedView,
...
// This function is called when the view is changed or the date changes
datesSet: function(info) {
    
    userCookie.events = eventView;
    userCookie.savedView = info.view.type;
    setCookie('CurrentUser', JSON.stringify(userCookie), 1);
    ...
}
...
````

## 2025-04-09

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.5.3.

### PodeServer.ps1

Replace Set-PodeCookie in New-PodeAuthScheme.

````powershell
...
$jsonData = $cookieData | ConvertTo-Json -Depth 10 -Compress

Set-PodeCookie -Name "CurrentUser" -Value $jsonData -ExpiryDate (Get-Date).AddDays(1)
...
````

### rotamaster.index.js

````javascript
if (userCookie) {
    userCookie.events = "all";
    setCookie('CurrentUser', JSON.stringify(userCookie), 1);
...
````

### rotamaster.main.js

Replace function getCookie, setCookie and createDBData.

````javascript
function getCookie(name) {
    const cookies = document.cookie.split('; ');
    for (const cookie of cookies) {
        const [key, value] = cookie.split('=');
        if (key === name) {
            try {
                const decoded = decodeURIComponent(value); // Dekodiere den Cookie-Wert
                return JSON.parse(decoded); // Parsen als JSON
            } catch (err) {
                console.error(`Fehler beim Parsen des Cookies "${name}":`, err, value);
                return null;
            }
        }
    }
    return null;
}

function setCookie(name, value, days) {
    const expires = new Date();
    expires.setTime(expires.getTime() + (days * 24 * 60 * 60 * 1000));
    document.cookie = `${name}=${encodeURIComponent(value)};expires=${expires.toUTCString()};path=/`;
}

async function createDBData(url, data){
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json' // Send as JSON
        },
        body: JSON.stringify(data) // Convert form data to JSON string
    });
    if (response.ok) {
        // console.log('DEBUG', response.status, response.statusText, `${data.name} - ${data.type}`); // Ausgabe: "Record successfully updated"
        if(data.type.includes('Pikett') || data.type.includes('Ferien')){
            window.location.reload();
        }
    } else {
        console.error('Failed to create event:', response, data);
        if(data.type.includes('Pikett')){
            showAlert(`Fehler beim Erstellen des Pikett-Events ${data.name}, ggf. OpsGenie prüfen - ${data.type}: ${response.status}, ${response.statusText}`);
        }else{
            showAlert(`Fehler beim Erstellen des Events ${data.name} - ${data.type}: ${response.status}, ${response.statusText}`);
        }
    }
}
````

## 2025-04-04

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.5.2.

### rotamaster.about.js

````javascript
...
    <span class="navbar-text ms-auto p-2" id="currentUser">
        <!-- logged-in as Username -->
    </span>
    <span class="navbar-text p-2" id="language">
        <!-- current browser language -->
    </span>
...
````

### rotamaster.absence.js

````javascript
...
    const welcomeElement  = document.getElementById('currentUser');
    const languageElement = document.getElementById('language');
    if (welcomeElement) {
        welcomeElement.textContent = `${username}`;
        languageElement.textContent = `${navigator.language}`;
    } else {
        console.error("Element with ID 'welcomeMessage' not found.");
    }
...
````

### rotamaster.index.js

````javascript
...
    const welcomeElement  = document.getElementById('currentUser');
    const languageElement = document.getElementById('language');
    if (welcomeElement) {
        welcomeElement.textContent = `${username}`;
        languageElement.textContent = `${navigator.language}`;
        document.getElementById('datalistName').value = username;
    } else {
        console.error("Element with ID 'welcomeMessage' not found.");
    }
...
````

### rotamaster.person.js

````javascript
...
    const welcomeElement  = document.getElementById('currentUser');
    const languageElement = document.getElementById('language');
    if (welcomeElement) {
        welcomeElement.textContent = `${username}`;
        languageElement.textContent = `${navigator.language}`;
    } else {
        console.error("Element with ID 'welcomeMessage' not found.");
    }
...
````

### about.html

````html
...
    <span class="navbar-text ms-auto p-2" id="currentUser">
        <!-- logged-in as Username -->
    </span>
    <span class="navbar-text p-2" id="language">
        <!-- current browser language -->
    </span>
...
````

### absence.html

````html
...
    <span class="navbar-text ms-auto p-2" id="currentUser">
        <!-- logged-in as Username -->
    </span>
    <span class="navbar-text p-2" id="language">
        <!-- current browser language -->
    </span>
...
````

### index.html

````html
...
    <span class="navbar-text ms-auto p-2" id="currentUser">
        <!-- logged-in as Username -->
    </span>
    <span class="navbar-text p-2" id="language">
        <!-- current browser language -->
    </span>
...
````

### person.html

````html
...
    <span class="navbar-text ms-auto p-2" id="currentUser">
        <!-- logged-in as Username -->
    </span>
    <span class="navbar-text p-2" id="language">
        <!-- current browser language -->
    </span>
...
````

## 2025-03-30

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.5.1.

### rotamaster.main.js

Replace the function renderTable.

````javascript
function renderTable(data) {
    // console.log('DEBUG', 'renderTable:', data);
    const tableBody = document.querySelector('#pikettTable tbody');
    tableBody.innerHTML = ''; // Clear the table to ensure no old data is present

    // Initialize variables to store column sums
    let totalPikett = 0;
    let totalPikettPeer = 0;
    let totalFerien = 0;

    // Loop through the data and insert it into the table
    Object.keys(data).forEach(person => {
        const row = document.createElement('tr'); // Create a new table row

        const nameCell = document.createElement('td'); // Cell for the person's name
        nameCell.textContent = person; // Set the person's name
        row.appendChild(nameCell);

        const pikettCell = document.createElement('td'); // Cell for the Pikett count
        pikettCell.textContent = data[person].pikett; // Set the Pikett count
        row.appendChild(pikettCell);
        totalPikett += data[person].pikett; // Add to total Pikett count

        const PikettPeerCell = document.createElement('td'); // Cell for the Pikett-Peer count
        PikettPeerCell.textContent = data[person].PikettPeer; // Set the Pikett-Peer count
        row.appendChild(PikettPeerCell);
        totalPikettPeer += data[person].PikettPeer; // Add to total Pikett-Peer count

        const ferienCell = document.createElement('td'); // Cell for the vacation count
        ferienCell.textContent = data[person].ferien; // Set the vacation count
        row.appendChild(ferienCell);
        totalFerien += data[person].ferien; // Add to total vacation count

        tableBody.appendChild(row); // Append the row to the table body
    });

    // Add a row for the totals
    const totalRow = document.createElement('tr');
    totalRow.style.fontWeight = 'bold'; // Make the total row bold

    const totalNameCell = document.createElement('td'); // Empty cell for the name column
    totalNameCell.textContent = 'Total';
    totalRow.appendChild(totalNameCell);

    const totalPikettCell = document.createElement('td'); // Cell for the total Pikett count
    totalPikettCell.textContent = totalPikett;
    totalRow.appendChild(totalPikettCell);

    const totalPikettPeerCell = document.createElement('td'); // Cell for the total Pikett-Peer count
    totalPikettPeerCell.textContent = totalPikettPeer;
    totalRow.appendChild(totalPikettPeerCell);

    const totalFerienCell = document.createElement('td'); // Cell for the total vacation count
    totalFerienCell.textContent = totalFerien;
    totalRow.appendChild(totalFerienCell);

    tableBody.appendChild(totalRow); // Append the total row to the table body
}
````

## 2025-03-26

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.5.0.

### person

Add Field topic in to table person.

````sql
ALTER TABLE person
ADD COLUMN topic TEXT;

ALTER TABLE person RENAME TO person_old;

-- Create the new table with the desired column order
CREATE TABLE person (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL,
    name TEXT NOT NULL,
    firstname TEXT NOT NULL,
    email TEXT NOT NULL,
    topic TEXT, -- New column added here
    active INTEGER NOT NULL DEFAULT 1,
    workload INTEGER NOT NULL DEFAULT 100,
    created TEXT NOT NULL DEFAULT current_timestamp,
    author TEXT NOT NULL
);

-- Copy data from the old table to the new table
INSERT INTO person (id, login, name, firstname, email, active, workload, created, author)
SELECT id, login, name, firstname, email, active, workload, created, author
FROM person_old;

-- Drop the old table
DROP TABLE person_old;
````

### person.html

Add dropdown for topics.

````html
...
<select id="topic" name="topic" class="form-select" required>
    <option value="ESXi">ESXi</option>
    <option value="Hyper-V">Hyper-V</option>
</select>
...
<th>Topic</th>
...
````

### rotamaster.person.js

````javascript
// Update existing person
...
...<td>${person.topic}</td>
...
document.querySelector('#topic').value = person.topic;
...
````

### RotaMaster.psm1

````powershell
...
$sql = "INSERT INTO person (login, firstname, name, email,topic, active, workload, created, author) VALUES ('$($login)', '$($firstname)', '$($lastname)', '$($email)', '$($topic)', '$($active)', '$($workload)', '$($created)', '$($WebEvent.Auth.User.Name)')"
...
$sql = 'SELECT id,login,name,firstname, active, workload, email, topic,created FROM person ORDER BY firstname ASC'
} elseif ($isInteger) {
    $sql = "SELECT id,login,name,firstname, active, workload, email,topic,created FROM person WHERE id = $searchFor"
} else {
    $sql = "SELECT id,login,name,firstname, active, workload, email,topic,created FROM person WHERE (name || ' ' || firstname) = '$($searchFor)'"
}
...
topic     = $item.topic
...
$topic     = $WebEvent.Data['topic']
...
topic     = '$topic',
...
````

## 2025-03-23

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.7.

### rotamaster.config.js

Add the psModules and Verions.

````javascript
    psModules: [
        {
            moduleName: "Pode",
            moduleVersion: "1.0.0"
        },
        {
            moduleName: "PSSQLite",
            moduleVersion: "1.0.0"
        }
    ],
````

### about.html

Add the placeholder of psModules.

````html
<tr>
    <td>Pode (PowerShell Module)</td>
    <td id="podeVersion">...</td>
</tr>
<tr>
    <td>PSSQLite (PowerShell Module)</td>
    <td id="psSqliteVersion">...</td>
</tr>
...
<h2>On Call Management</h2>
<p>
    On-call and alert management <a href="https://www.atlassian.com/software/opsgenie" Target="_blank"> OpsGenie</a> will be <span class="badge text-bg-warning">End of Support at 5. April 2027!</span> You can migrate to <a href="https://www.atlassian.com/software/jira/service-management" Target="_blank">Jira Service Management</a> or to <a href="https://www.atlassian.com/software/compass" Target="_blank">Compass.</a>
</p>
...
<h2>License</h2>
<p>
    All components are licensed under <a href="https://mit-license.org/" Target="_blank">MIT</a> except On Call Management. RotaMaster is written by <a href="https://github.com/tinuwalther" Target="_blank">tinuwalther</a>,
    you contact me via <a href="https://github.com/tinuwalther" Target="_blank">GitHub</a> or <a href="https://tinuwalther.bsky.social" Target="_blank">Bluesky</a>.
</p>
````

### rotamaster.about.js

Add the psModules form rotamaster.config.js.

````javascript
    // Fetch psModules
    try{
        calendarConfig.psModules.map(module => {
            if(module.moduleName === "Pode"){
                document.getElementById('podeVersion').textContent = module.moduleVersion;
            }
            if(module.moduleName === "PSSQLite"){
                document.getElementById('psSqliteVersion').textContent = module.moduleVersion;
            }
        });

    } catch (error) {
        console.error('Error reading PowerShell Modules:', error);
        document.getElementById('podeVersion').textContent = "Error eading PowerShell Modules";
        document.getElementById('psSqliteVersion').textContent = "Error eading PowerShell Modules";
    }    
});
````

## 2025-03-12

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.6.

### index.html

````html
<!-- Begin Section Events -->
...
<!-- Begin Toggle Button for Events and Form Section -->
<button id="toggleButton" class="btn btn-dark" title="Toggle Events" aria-expanded="true" aria-controls="events">
    <span id="toggleIcon" class="bi bi-chevron-left"></span>
</button>
<button id="toggleFormButton" class="btn btn-dark" title="Toggle Form" aria-expanded="true" aria-controls="eventForm">
    <span id="toggleFormIcon" class="bi bi-chevron-up"></span>
</button>
<!-- End Toggle Button for Events and Form Section -->
...
<div id="showEvents" class="collapse show">
...
    <!-- Begin Palceholder Form -->
    <div id="eventForm" class="collapse show">
        <form action="/api/event/new" method="POST" >
        ...
        </form>
    </div>
    <!-- End Form -->
````

### rotamaster.index.js

````javascript
window.addEventListener('resize', () => {
    const eventsSection = document.getElementById('showEvents');
    let space = 180;
    if (eventsSection.classList.contains('show')) space = 380;
    resizeCalendar(space);
});

document.addEventListener('DOMContentLoaded', async function() {
  ...
  // Add an event listener to the toggle button to show/hide the events section
  const toggleButton = document.getElementById('toggleButton');
  const toggleIcon = document.getElementById('toggleIcon');
  const eventsSection = document.getElementById('showEvents');

  const toggleFormButton = document.getElementById('toggleFormButton');
  const toggleFormIcon = document.getElementById('toggleFormIcon');
  const formSection = document.getElementById('eventForm');

    toggleButton.addEventListener('click', function() {
        if (eventsSection.classList.contains('show')) {
            eventsSection.classList.remove('show');
            toggleIcon.classList.remove('bi-chevron-left');
            toggleIcon.classList.add('bi-chevron-right');
            toggleFormButton.hidden = true;
            resizeCalendar(180);
            refreshCalendarData(calendar);
        } else {
            eventsSection.classList.add('show');
            toggleIcon.classList.remove('bi-chevron-right');
            toggleIcon.classList.add('bi-chevron-left');
            toggleFormButton.hidden = false;
            resizeCalendar(380);
            refreshCalendarData(calendar);
        }
    });

    toggleFormButton.addEventListener('click', function() {
        if (formSection.classList.contains('show')) {
            formSection.classList.remove('show');
            toggleFormIcon.classList.remove('bi-chevron-up');
            toggleFormIcon.classList.add('bi-chevron-down');
        } else {
            formSection.classList.add('show');
            toggleFormIcon.classList.remove('bi-chevron-down');
            toggleFormIcon.classList.add('bi-chevron-up');
        }
    });

});
````

### rotamaster.main.js

````javascript
...
function resizeCalendar(space) {
    const calendarEl = document.getElementById('calendar');
    let calendar = new FullCalendar.Calendar(calendarEl, {});
    const windowWidth = window.innerWidth;
    const newWidth = windowWidth - space;
    calendarEl.style.width = `${newWidth}px`;
    calendar.updateSize();
}
...
````

## 2025-03-05

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.5.

### rotamaster.main.js

````javascript
async function refreshCalendarData(calendar) {
  ...
  let events = [];
  if(userCookie.events === 'all'){
      events = await readDBData('/api/event/read/*');
      button.textContent = 'My Events';
  }else if(userCookie.events === 'personal'){
      events = await readDBData(`/api/event/read/${userCookie.name}`);
      button.textContent = 'All Events';
  }
  ...
}

function setCookie(name, value, days) {
    let expires = "";
    if (days) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        expires = "; expires=" + date.toUTCString();
    }
    document.cookie = name + "=" + (value || "") + expires + "; path=/";
}
...
````

### rotamaster.index.js

````javascript
...
// Load userCookie and display the username
const userCookie = getCookie('CurrentUser');
userCookie.events = "all";
setCookie('CurrentUser', JSON.stringify(userCookie), 1);
...

datesSet: function(info) {
  ...
  refreshCalendarData(calendar);
  if(userCookie.events === 'all'){
      document.querySelector('.fc-filterEvents-button').textContent = 'My Events';
  }else if(userCookie.events === 'personal'){
      document.querySelector('.fc-filterEvents-button').textContent = 'All Events';
  }
  ...
}
...
// Button to export person specific events as iCalendar (.ics) file
filterEvents: {
    text: 'My Events',
    click: async function() {
      ...
      if (isMyEvents.includes('My Events')) {
          // Export events of the current user
          const response = await fetch(`/api/event/read/${username}`);
          if (!response.ok) {
              throw new Error(`Failed to fetch user events of ${username}`);
          }
          currentEvents = await response.json();
          userCookie.events = "personal";
          button.textContent = 'All Events';
          
      }else if(isMyEvents.includes('All Events')) {
          // Export events of all users
          const response = await fetch('/api/event/read/*');
          if (!response.ok) {
              throw new Error('Failed to fetch user events of all users');
          }
          currentEvents = await response.json();
          userCookie.events = "all";
          button.textContent = 'My Events';
          
      }
      setCookie('CurrentUser', JSON.stringify(userCookie), 1);
      ...
    }
}
````

## 2025-02-22

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.4.

### index.html

- Remove /assets/rotamaster/fullcalendar.main.min.js in index.html
- Move script src to the bottom of the body in index.html
- Move the script code from index.html to rotamaster.index.js
- Add header 'Loading FullCalendar' into index.html
- Change the hfre from /logout to # and add an id to address it from a function

````html
...
<!-- <li Class="nav-item"  ><a Class="nav-link" href="/logout"  >Logoff</a></li> -->
<li class="nav-item"><a class="nav-link" id="logoutLink" href="#">Logoff</a></li>
...
<!-- Begin Palceholder Calendar -->
<div id="calendar">
    <h2 id="Loading" Style="text-align:center;margin-top:250px;color:#000"  >Loading FullCalendar ...</h2>
</div>
<!-- End Calendar -->
````

### rotamaster.config.js

 Add height = auto in calendar.

````javascript
const calendarConfig = {
  ...
  height : 'auto',
  ...
}
````

### about.html

- Move script src to the bottom of the body in about.html
- Add script into rotamaster.about.js

### absence.html

- Move script src to the bottom of the body in absence.html
- Add script into rotamaster.absence.js

### person.html

- Move script src to the bottom of the body in person.html
- Add script into rotamaster.person.js

### rotamaster.index.js

- Remove header 'Loading FullCalendar', add the code below at the end of DOMContentLoaded
- Add an event listener to the logout link at the end of DOMContentLoaded

````javascript
document.addEventListener('DOMContentLoaded', async function() {
  ...
  document.getElementById('Loading').remove(); // Remove the loading spinner
  ...
    // Add an event listener to the logout link
  const logoutLink = document.getElementById('logoutLink');
  if (logoutLink) {
      logoutLink.addEventListener('click', function(event) {
          event.preventDefault(); // Prevent default form submission
          deleteCookie('CurrentUser'); // Delete the user cookie
          window.location.href = '/logout'; // Redirect to the logout page
      });
  }
}
````

### rotamaster.main.js

- Add a function for deleteCookie

````javascript
...
function deleteCookie(name) {
    document.cookie = name + '=; expires=Thu, 01 Jan 1970 00:00:00 UTC; path=/;';
}
...
````

[Top](#changelog)

## 2025-02-02

Fix Issue with ä, ö, ü in usernames. After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.3.

- [Fix write Cookie in PodeServer.ps1](#fix-write-cookie-in-podeserverps1)
- [Fix getCookie in rotamaster.main.js](#fix-getcookie-in-rotamastermainjs)

### Fix write Cookie in PodeServer.ps1

````powershell
  # encode JSON explicit to UTF-8 no BOM
  $utf8Bytes = [System.Text.Encoding]::UTF8.GetBytes($jsonData)
  $utf8Json = [System.Text.Encoding]::UTF8.GetString($utf8Bytes)

  # encode JSON to URL
  $encodedJson = [System.Web.HttpUtility]::UrlEncode($utf8Json)

  # Set cookie with encoded JSON no BOM and URL encoded, add 1 day to expiry date
  Set-PodeCookie -Name "CurrentUser" -Value $encodedJson -ExpiryDate (Get-Date).AddDays(1)
````

### Fix getCookie in rotamaster.main.js

````javascript
function getCookie(name) {
    const value = `; ${document.cookie}`;
    const parts = value.split(`; ${name}=`);

    if (parts.length === 2) {
        let cookieValue = parts.pop().split(';').shift();
        try {
            // URL-Dekodierung und Umwandlung von "+" zurück in Leerzeichen
            cookieValue = decodeURIComponent(cookieValue).replace(/\+/g, " ");

            // JSON parsen
            const parsedValue = JSON.parse(cookieValue);
            return parsedValue;
        } catch (error) {
            console.error('Error parsing cookie value:', error, cookieValue);
            return null;
        }
    }

    return null;
}
````

[Top](#changelog)

## 2025-01-15

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.2.

- [Add login to the extendedProps in RotaMaster.psm1](#add-login-to-the-extendedprops-in-rotamasterpsm1)
- [Fix swissHolidays for Summary in rotamaster.main.js](#fix-swissholidays-for-summary-in-rotamastermainjs)
- [Add a parameter holidays in calculateWorkdays](#add-a-parameter-holidays-in-calculateworkdays)
- [Add a parameter holidays in setModalEventData](#add-a-parameter-holidays-in-setmodaleventdata)
- [Add new function getEasterSunday](#add-new-function-geteastersunday)
- [Add new function getSwissHolidays](#add-new-function-getswissholidays)
- [Add new function formatDateToLocalISO](#add-new-function-formatdatetolocaliso)

### Add login to the extendedProps in RotaMaster.psm1

````powershell
Add-PodeRoute -Method Get -Path 'api/event/read/:person' ... -ScriptBlock {
  ...
  $sql = 'SELECT id,person,login,email,"type",start,end,alias FROM v_events'
  ...
  $sql = "SELECT id,person,login,email,""type"",start,end,alias FROM v_events WHERE person = '$($person'"
  ...
  extendedProps = [PSCustomObject]@{
      login = $item.login
      email = $item.email
      alias = $item.alias
  }
  ...
}
````

### Fix swissHolidays for Summary in rotamaster.main.js

````javascript
async function getEventSummary(calendarData, selectedYear) {
  ...
  let swissHolidays = getSwissHolidays(selectedYear)
  ...
  result[person].ferienIntervals.forEach(interval => {
      totalVacationDays += calculateWorkdays(interval.start, interval.end, swissHolidays);
  });
  ...
  result[person].PikettPeerIntervals.forEach(interval => {
      totalPikettPeerDays += calculateWorkdays(interval.start, interval.end, swissHolidays);
  });
  ...
}
````

### Add a parameter holidays in calculateWorkdays

````javascript
function calculateWorkdays(startDate, endDate, holidays) 
  ...
  while (currentDate.getTime() < endDate.getTime()) {
      const dayOfWeek = currentDate.getDay(); // Get the day of the week (0-6)
      const formattedDate = formatDateToLocalISO(currentDate); // Format the date as 'YYYY-MM-DD'
      const isWeekend = dayOfWeek === 0 || dayOfWeek === 6; // Sunday = 0, Saturday = 6
      const isSwissHoliday = holidays.includes(formattedDate); // Check if the current date is a Swiss holiday
      if(!isSwissHoliday && !isWeekend){
          count++; // Count only weekdays
      }
      // Move to the next day
      currentDate.setDate(currentDate.getDate() + 1);
  }
}
````

### Add a parameter holidays in setModalEventData

````javascript
function setModalEventData(event) {
    let swissHolidays = getSwissHolidays(event.start.getFullYear());
    ...
        for (const [key, value] of Object.entries(event.extendedProps)) {
        if(value === 'Pikett'){
            days = calculatePikettkdays(event.start,event.end)
        }else{
            days = calculateWorkdays(event.start, event.end, swissHolidays)
        }
    };
    ...
}
````

### Add new function getEasterSunday

````javascript
function getEasterSunday(year) 
````

### Add new function getSwissHolidays

````javascript
function getSwissHolidays(year)
````

### Add new function formatDateToLocalISO

````javascript
function formatDateToLocalISO(date) 
````

[Top](#changelog)

## 2025-01-08

Fix if the user set the startdate less than the enddate in index.html on

````javascript
// Default form submit and to call the API to add the event
document.querySelector('form');
````

[Top](#changelog)

## 2024-12-30

- [OpsGenie integration](#1-opsgenie-integration)
- [Mark deleted events](#2-mark-deleted-events)
- [Re-create View for Pikett](#3-re-create-view-for-pikett)

### 1. OpsGenie integration

Adding the OpsGenie integration with add and remove override. To remove the override, the events table requires a column for the OpsGenie override alias.

New structure in table events:

````sql
-- Add column alias
ALTER TABLE events 
  ADD alias TEXT;
````

and in view v_events:

````sql
-- Delete View v_events
DROP VIEW v_events;
````

````sql
-- Create the view for events with alias
CREATE VIEW v_events
AS 
SELECT 
  e.id,
  e.person,
  e.type,
  e.start,
  e.end,
  e.alias,
  p.login,
  p.firstname,
  p.name,
  p.email,
  e.created,
  e.author
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE e.active = 1
ORDER BY 
  e.id ASC;
````

### 2. Mark deleted events

Adding a column for deleted records instead to remove the record.

New structure in table events:

````sql
-- Add column active
ALTER TABLE events 
  ADD active INTEGER NOT NULL 
  DEFAULT 1;
````

````sql
-- Add column deleted
ALTER TABLE events 
  ADD deleted TEXT;
````

and create a new view v_events_deleted:

````sql  
-- Create the view for deleted events
CREATE VIEW v_events_deleted
AS 
SELECT 
  e.id,
  e.person,
  e.type,
  e.start,
  e.end,
  e.alias,
  p.login,
  p.firstname,
  p.name,
  p.email,
  e.created,
  e.deleted,
  e.author
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE e.active = 0
ORDER BY 
  e.id ASC;
````

### 3. Re-create View for Pikett

Re-create the View for Pikett.

````sql
DROP VIEW v_pikett;
````

````sql
-- Create the view for pikett
CREATE VIEW v_pikett
AS 
SELECT 
  e.person,
  e.type,
  e.alias,
  e.start,
  e.end,
  e.deleted,
  p.login,
  p.email
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE
  e.type = 'Pikett'
ORDER BY 
  e.start ASC;
````

[Top](#changelog)
