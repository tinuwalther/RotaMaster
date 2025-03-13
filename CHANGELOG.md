# CHANGELOG

## Table of Contents

- [2025-03-12](#2025-03-12)
- [2025-03-05](#2025-03-05)
- [2025-02-22](#2025-02-22)
- [2025-02-02](#2025-02-02)
- [2025-01-15](#2025-01-15)
- [2025-01-08](#2025-01-08)
- [2024-12-30](#2024-12-30)

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
