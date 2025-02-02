# CHANGELOG

## 2025-02-02

Fix Issue with ä, ö, ü in usernames. After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.3.

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

## 2025-01-15

After implementing the following code, increase the appVersion in rotamaster.config.js to 5.4.2.

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

## 2025-01-08

Fix if the user set the startdate less than the enddate in index.html on

````javascript
// Default form submit and to call the API to add the event
document.querySelector('form');
````

## 2024-12-30

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
