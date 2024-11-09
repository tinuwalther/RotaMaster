/**
 * CalendarConfig
 */
const calendarConfig = {
    appVersion: "4.0.0",
    timeZone: 'local',
    locale: 'de-CH',
    initialView: 'multiMonthYear',
    multiMonthMinWidth: 350,
    multiMonthMaxColumns: 2,
    headerToolbar: {
        left: 'prevYear,prev,today,next,nextYear',
        center: 'title',
        right: 'multiMonthYear,dayGridMonth,listMonth exportToIcs'
    },
    buttonText: {
        today: 'Heute',
        year: 'Jahr',
        month: 'Monat',
        list: 'Liste'
    },
    weekNumbers: false,
    dayMaxEvents: true,
    showNonCurrentDates: false,
    fixedWeekCount: false,
    weekNumberCalculation: 'ISO',
    selectable: true,
    editable: true,
    displayEventTime: false,
    navLinks: true,
    customButtons: {
        exportToIcs: {
            text: 'Export Events',
            click: function() {
                // Erstelle eine Bootstrap-Modal-Instanz und öffne das Modal
                const exportModal = new bootstrap.Modal(document.getElementById('multipleEvents'), {
                    keyboard: true
                });
                document.getElementById('btnAllEvents').checked = true;
                document.getElementById('personNameInput').value = '';
                document.getElementById('eventTypeInput').value = '';
                exportModal.show();
            }
        }
    }
};


/**
* Sends the next year as plain text to the provided API URL and logs the response.
* 
* This asynchronous function calculates the next year dynamically,
* converts it to a string, and sends it to a specified API endpoint using
* a POST request. The function handles any potential errors and logs the
* result or any failures to the console.
* 
* Main features:
* - Calculates the next year based on the current date.
* - Sends the next year as plain text using a POST request to the given API endpoint.
* - Handles errors gracefully and logs results to the console.
* 
* @async
* @param {string} url - The URL of the API endpoint where the year is sent.
* @returns {Promise<void>} - No return value, but logs results or errors to the console.
* 
* @example
* await getNextYear('/api/year/new'); // Sends the next year to the given API URL and logs the response.
*/
async function getNextYear(url) {
    const nextYear = new Date().getFullYear() + 1; // Calculate the next year dynamically
    const data = nextYear.toString(); // Convert the year to a string to send as plain text

    try {
        // Send a POST request using fetch
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'text/plain' // Specify that the request body contains plain text
            },
            body: data // Send the year as plain text in the request body
        });

        // Check if the request was successful
        if (response.ok) {
            const result = await response.text(); // Read the response as plain text
            // console.log('Success:', result); // Log the successful response
        } else {
            console.error('Request failed with status:', response.status); // Log if the request failed
        }
    } catch (error) {
        console.error('Error occurred:', error); // Log any errors that occurred during the request
    }
}

/**
* Calculates the displayed year based on the current calendar view.
* 
* This function takes the `info` object, which contains details about the current calendar view, 
* and calculates the displayed year depending on the view type. The function handles different
* types of views (monthly, list, and multi-month) and extracts the correct year from the provided date range.
* 
* Main features:
* - Supports multiple calendar views: 'dayGridMonth', 'listMonth', and 'multiMonthYear'.
* - For 'dayGridMonth' and 'listMonth', the function calculates the central date and extracts the year and month.
* - For 'multiMonthYear', the function calculates the central date and extracts only the year.
* - Returns the calculated displayed year.
* 
* @param {Object} info - The information object from the calendar, containing details about the current view type and date range.
* @returns {number} displayedYear - The year that is displayed based on the calendar view.
* 
* @example
* const displayedYear = calcDisplayedYear(info); // Returns the displayed year depending on the calendar view type.
*/
function calcDisplayedYear(info) {
    let displayedYear;

    // Different handling depending on the view type
    if (info.view.type === 'dayGridMonth' || info.view.type === 'listMonth') {
        const centralDate = new Date(
            (info.start.getTime() + info.end.getTime()) / 2
        );
        // Extract the year and month
        displayedYear = centralDate.getFullYear();
        const displayedMonth = centralDate.getMonth() + 1; // Month is zero-based
        // console.log('Month view - Displayed year:', displayedYear);
        // console.log('Month view - Displayed month:', displayedMonth);
    } else if (info.view.type === 'multiMonthYear') {
        const centralDate = new Date(
            (info.start.getTime() + info.end.getTime()) / 2
        );
        // Extract the year
        displayedYear = centralDate.getFullYear();
        // console.log('Year view - Displayed year:', displayedYear);
    }

    return displayedYear;
};

/**
* Fetches person data from the provided API URL.
* 
* This asynchronous function makes an HTTP GET request to the provided URL using the Fetch API.
* It processes the response and extracts the person data as a JSON object. If the request fails,
* the function logs an error message to the console. The function always returns an array, even
* if the request fails or there is an error.
* 
* Main features:
* - Fetches person data from the provided API endpoint.
* - Handles API errors and logs relevant messages to the console.
* - Returns an array of person data.
* 
* @async
* @param {string} url - The API endpoint from which to fetch person data.
* @returns {Promise<Array>} person - An array of person data fetched from the API.
* 
* @example
* const personData = await getPerson('/api/persons'); // Fetches person data from the API endpoint
*/
async function getPerson(url) {
    var person = []; // Initialize an empty array to store person data
    // console.log('Starting to fetch person data from:', url); 

    try {
        const response = await fetch(url); // Make the fetch request to the provided URL
        if (response.ok) {
            person = await response.json(); // Parse the response JSON if the request was successful
        } else {
            console.error('Error fetching person:', response.status); // Log error status if the request failed
        }
    } catch (error) {
        console.error('Error:', error); // Log any errors that occurred during the request
    }

    return person; // Return the person data (an empty array if the fetch failed)
}

/**
* Fetches data from the provided API URL.
* 
* This asynchronous function makes an HTTP GET request to the provided URL using the Fetch API.
* It processes the response and extracts the data as a JSON object. If the request fails,
* the function logs an error message to the console. The function always returns an array,
* even if the request fails or there is an error.
* 
* Main features:
* - Fetches generic data from the provided API endpoint.
* - Handles API errors and logs relevant messages to the console.
* - Returns an array of data.
* 
* @async
* @param {string} url - The API endpoint from which to fetch data.
* @param {string} [dataType='data'] - A label for the type of data being fetched (e.g., 'person' or 'absence').
* @returns {Promise<Array>} - An array of data fetched from the API.
* 
* @example
* const personData = await fetchData('/api/persons', 'person'); // Fetches person data from the API endpoint
* const absenceData = await fetchData('/api/absence', 'absence'); // Fetches absence data from the API endpoint
*/
async function fetchData(url, dataType = 'data') {
    let data = []; // Initialize an empty array to store the fetched data
    // console.log(`Starting to fetch ${dataType} data from:`, url); 

    try {
        const response = await fetch(url); // Make the fetch request to the provided URL
        if (response.ok) {
            data = await response.json(); // Parse the response JSON if the request was successful
        } else {
            console.error(`Error fetching ${dataType}:`, response.status); // Log error status if the request failed
        }
    } catch (error) {
        console.error(`Error fetching ${dataType}:`, error); // Log any errors that occurred during the request
    }

    return data; // Return the fetched data (an empty array if the fetch failed)
}

/**
* Populates a datalist with options from an array of values.
* 
* This function takes the ID of a `<datalist>` element and an array of values, 
* and dynamically adds each value as an `<option>` to the datalist. If the element
* is not found or the values parameter is not an array, the function logs an error 
* to the console and does not proceed.
* 
* Main features:
* - Finds the specified `<datalist>` element by ID.
* - Clears any existing options in the datalist to avoid duplicates.
* - Adds each value from the array as an `<option>` element to the datalist.
* - Handles errors if the datalist element is not found or the values parameter is invalid.
* 
* @param {string} datalistId - The ID of the datalist element to populate.
* @param {Array} values - An array of values to populate the datalist with.
* @returns {void}
* 
* @example
* fillDatalistOptions('datalistOptions', ['Alice', 'Bob', 'Charlie']); // Populates the datalist with three options.
*/
function fillDatalistOptions(datalistId, values) {
    // Reference to the datalist element
    const datalist = document.getElementById(datalistId);

    if (!datalist) {
        console.error(`The datalist element with the ID "${datalistId}" was not found.`);
        return;
    }

    // Check if the argument is an array
    if (!Array.isArray(values)) {
        console.error('The provided argument is not an array:', values);
        return;
    }

    // Clear the datalist to ensure no old options exist
    datalist.innerHTML = '';

    // Add each value from the array as an option
    values.forEach(value => {
        const option = document.createElement('option');
        option.value = value; // Set the value of the option
        datalist.appendChild(option); // Append the option to the datalist
    });
}

/**
* Populates a dropdown menu (`<select>` element) with options from an array of values.
* 
* This function takes the ID of a `<select>` element and an array of values, 
* and dynamically adds each value as an `<option>` to the dropdown. A default
* "Please select..." option is added first, allowing users to know that they need 
* to make a selection. If the `<select>` element is not found or the `values` 
* parameter is not an array, the function logs an error to the console.
* 
* Main features:
* - Finds the specified `<select>` element by its ID.
* - Clears any existing options in the dropdown to prevent duplicates.
* - Adds a default option "Please select..." at the top of the dropdown.
* - Adds each value from the array as an `<option>` element to the dropdown.
* - Handles errors if the `<select>` element is not found or if the `values` parameter is invalid.
* 
* @param {string} selectId - The ID of the dropdown (`<select>`) element to populate.
* @param {Array} values - An array of values to populate the dropdown with.
* @returns {void}
* 
* @example
* fillDropdownOptions('absenceTypeDropdown', ['Vacation', 'Sick Leave', 'Remote Work']); // Populates the dropdown with options.
*/
function fillDropdownOptions(selectId, values) {
    // Reference to the select element
    const selectElement = document.getElementById(selectId);

    if (!selectElement) {
        console.error(`The select element with the ID "${selectId}" was not found.`);
        return;
    }

    // Check if the argument is an array
    if (!Array.isArray(values)) {
        console.error('The provided argument is not an array:', values);
        return;
    }

    // Clear the select element to ensure no old options exist
    selectElement.innerHTML = '';

    // Add a default option (optional)
    const defaultOption = document.createElement('option');
    defaultOption.value = '';
    defaultOption.textContent = 'Bitte auswählen...';
    selectElement.appendChild(defaultOption);

    // Add each value from the array as an option
    values.forEach(value => {
        const option = document.createElement('option');
        option.value = value; // Set the value of the option
        option.textContent = value; // Set the text of the option
        selectElement.appendChild(option); // Append the option to the select element
    });
}

/**
* Fetches calendar event data from the provided API URL.
* 
* This asynchronous function sends a GET request to the specified API endpoint 
* to retrieve calendar event data. It returns the parsed JSON data if the request
* is successful, or an empty array if an error occurs. This function ensures that
* the caller always receives an array, regardless of the success or failure of the request.
* 
* Main features:
* - Sends a GET request to fetch calendar data from a given API URL.
* - Handles errors gracefully and logs detailed messages to the console.
* - Always returns an array, even if the request fails.
* 
* @async
* @param {string} url - The API endpoint from which to fetch the calendar data.
* @returns {Promise<Array>} A promise that resolves to an array of event data. 
* If the request fails, the function returns an empty array.
* 
* @example
* const events = await loadApiData('/api/event/get'); 
* // console.log(events); // Logs the calendar event data or an empty array if an error occurs.
*/
async function loadApiData(url) {
    var calendarData = []; // Initialize an empty array to store calendar event data
    // console.log('Starting to fetch calendar data from:', url); 

    try {
        const response = await fetch(url); // Send a GET request to the provided URL
        if (response.ok) {
            calendarData = await response.json(); // Parse the response JSON if the request was successful
        } else {
            console.error('Error fetching calendarData:', response.status); // Log error status if the request failed
        }
    } catch (error) {
        console.error('Error:', error); // Log any errors that occurred during the request
    }
    
    return calendarData; // Return the calendar data (an empty array if the fetch failed)
}

/**
* Populates an HTML table with data provided in an object.
* 
* This function takes an object containing event data and populates an HTML table
* with the data. It finds the table body by its selector, clears any existing rows, 
* and iterates over the provided data to create and append new rows. Each person in the data 
* object will have their own row in the table with details such as name, Pikett count,
* Pikett-Pier count, and vacation days.
* 
* Main features:
* - Clears any existing rows in the table body before adding new data.
* - Iterates over the keys in the data object to populate each row of the table.
* - Adds columns for each data field: person name, Pikett count, Pikett-Pier count, and vacation days.
* 
* @param {Object} data - An object containing event data to populate the table.
* Each key represents a person's name, and each value contains details about Pikett, Pikett-Pier, and vacation counts.
* @returns {void}
* 
* @example
* const data = {
*   'Alice': { pikett: 3, pikettPier: 2, ferien: 5 },
*   'Bob': { pikett: 1, pikettPier: 3, ferien: 4 }
* };
* renderTable(data); // Populates the HTML table with rows for Alice and Bob.
*/
function renderTable(data) {
    // console.log('renderTable:', data);
    const tableBody = document.querySelector('#pikettTable tbody');
    tableBody.innerHTML = ''; // Clear the table to ensure no old data is present

    // Loop through the data and insert it into the table
    Object.keys(data).forEach(person => {
        const row = document.createElement('tr'); // Create a new table row

        const nameCell = document.createElement('td'); // Cell for the person's name
        nameCell.textContent = person; // Set the person's name
        row.appendChild(nameCell);

        const pikettCell = document.createElement('td'); // Cell for the Pikett count
        pikettCell.textContent = data[person].pikett; // Set the Pikett count
        row.appendChild(pikettCell);

        const pikettPierCell = document.createElement('td'); // Cell for the Pikett-Pier count
        pikettPierCell.textContent = data[person].pikettPier; // Set the Pikett-Pier count
        row.appendChild(pikettPierCell);

        const ferienCell = document.createElement('td'); // Cell for the vacation count
        ferienCell.textContent = data[person].ferien; // Set the vacation count
        row.appendChild(ferienCell);

        tableBody.appendChild(row); // Append the row to the table body
    });
}

/**
 * Calculates the events in the selected year and returns a summary per person.
 * 
 * This function takes an array of calendar event data and a selected year, and
 * returns a summary of the events categorized by person. It processes different
 * types of events, including Pikett, Pikett-Pier, and vacations, and counts the
 * respective days for each type of event for every person.
 * 
 * Main features:
 * - Processes events for a specific year and ignores those that do not fall within the selected year.
 * - Summarizes event details (Pikett, Pikett-Pier, and vacation intervals) for each person.
 * - Calculates total vacation days, Pikett days, and Pikett-Pier days for every person.
 * 
 * @async
 * @param {Array} calendarData - The array of calendar events. Each event must have a title, start, and end property.
 * @param {number} selectedYear - The year for which to calculate the summary.
 * @returns {Object} An object containing the summary of events per person.
 * Each key represents a person's name, and each value contains counts for Pikett, Pikett-Pier, and vacation.
 * 
 * @example
 * const summary = await getEventSummary(calendarData, 2024); // Returns the summary of events for 2024
 */
async function getEventSummary(calendarData, selectedYear) {
    const result = {};
    calendarData.forEach(event => {

        if(event.type !== 'Feiertag'){
            // console.log('Calculate summary', event);
            const [personName, eventType] = event.title.split(' - ');
            if (!personName || !eventType) return;

            // console.log(event.start,event.end);
            let eventStartDate = new Date(event.start);
            let eventEndDate = new Date(event.end);

            // Process only events that fall within the selected year
            if (eventStartDate.getFullYear() !== selectedYear && eventEndDate.getFullYear() !== selectedYear) return;

            // Initialize the person in the result object if not already present
            if (!result[personName]) {
                result[personName] = { pikett: 0, pikettIntervals: [], pikettPier: 0, pikettPierIntervals: [], ferien: 0, ferienIntervals: [] };
            }

            // Count the events and store the intervals
            switch (eventType.trim()) {
                case 'Pikett':
                    result[personName].pikettIntervals.push({ start: eventStartDate, end: eventEndDate });
                    break;
                case 'Pikett-Pier':
                    result[personName].pikettPierIntervals.push({ start: eventStartDate, end: eventEndDate });
                    break;
                case 'Ferien':
                    result[personName].ferienIntervals.push({ start: eventStartDate, end: eventEndDate });
                    break;
            }
        }

    });

    // Calculate the number of vacation days after processing all events
    for (const person in result) {
        let totalVacationDays = 0;
        let totalPikettDays = 0;
        let totalPikettPierDays = 0;

        result[person].ferienIntervals.forEach(interval => {
            totalVacationDays += calculateWorkdays(interval.start, interval.end);
        });
        
        result[person].pikettIntervals.forEach(interval => {
            totalPikettDays += calculatePikettkdays(interval.start, interval.end);
        });

        result[person].pikettPierIntervals.forEach(interval => {
            totalPikettPierDays += calculateWorkdays(interval.start, interval.end);
        });

        result[person].ferien = totalVacationDays;
        // console.log(`Person: ${person}, Vacation Intervals: ${result[person].ferienIntervals}, Total Vacation Days: ${totalVacationDays}`);

        result[person].pikett = totalPikettDays;
        // console.log(`Person: ${person}, Pikett Intervals: ${result[person].pikettIntervals}, Total Pikett Days: ${totalPikettDays}`);

        result[person].pikettPier = totalPikettPierDays;
        // console.log(`Person: ${person}, Pikett-Pier Intervals: ${result[person].pikettIntervals}, Total Pikett-Pier Days: ${totalPikettPierDays}`);
    }

    return result;
}

/**
 * Calculates the number of vacation days excluding weekends.
 * 
 * This function calculates the number of working days (Monday to Friday)
 * between two given dates. Weekends (Saturday and Sunday) are excluded from the count.
 * The calculation iterates from the `startDate` to the `endDate` and increments a count 
 * for each weekday found in the range.
 * 
 * Main features:
 * - Iterates over all days from `startDate` to `endDate`.
 * - Counts only working days (excludes Saturdays and Sundays).
 * - Adjusts both `startDate` and `endDate` to midnight to ensure accurate day counting.
 * 
 * @param {Date} startDate - The start date of the vacation period.
 * @param {Date} endDate - The end date of the vacation period.
 * @returns {number} - The number of vacation days excluding weekends.
 * 
 * @example
 * const vacationDays = calculateWorkdays(new Date('2024-01-01'), new Date('2024-01-07')); // Returns the number of vacation days excluding weekends.
 */
function calculateWorkdays(startDate, endDate) {
    let count = 0; // Counter for weekdays
    let currentDate = new Date(startDate); // Create a copy of the start date

    // Ensure times are set correctly to midnight
    currentDate.setHours(1, 0, 0, 0);
    endDate.setHours(23, 0, 0, 0);

    // Iterate over each day in the period, including the end date
    while (currentDate.getTime() < endDate.getTime()) {
        const dayOfWeek = currentDate.getDay();

        // Check if the current day is a weekday (not Saturday or Sunday)
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            count++; // Count only weekdays
        } else {
            // console.log(`calculateWorkdays - Skipping weekend: ${currentDate.toDateString()}`);
        }
        // console.log(`calculateWorkdays - currentDate: ${currentDate.toDateString()}, count: ${count}`);

        // Move to the next day
        currentDate.setDate(currentDate.getDate() + 1);
    }

    // console.log('calculateWorkdays - Start date:', startDate.toDateString(), 'End date:', endDate.toDateString(), 'Number of weekdays:', count);
    return count;
}

/**
 * Calculates the number of Pikett days including weekends.
 * 
 * This function calculates the total number of days between the given start and end dates,
 * including weekends. It iterates from the `startDate` to the `endDate` and counts every
 * day in the range, regardless of whether it is a weekday or a weekend.
 * 
 * Main features:
 * - Iterates over all days from `startDate` to `endDate`.
 * - Counts all days in the period, including weekends (Saturday and Sunday).
 * - Adjusts both `startDate` and `endDate` to midnight to ensure accurate day counting.
 * 
 * @param {Date} startDate - The start date of the Pikett period.
 * @param {Date} endDate - The end date of the Pikett period.
 * @returns {number} - The number of Pikett days, including weekends.
 * 
 * @example
 * const pikettDays = calculatePikettkdays(new Date('2024-01-01'), new Date('2024-01-07')); 
 * // Returns the number of Pikett days including weekends.
 */
function calculatePikettkdays(startDate, endDate) {
    let count = 0; // Counter for Pikett days
    let currentDate = new Date(startDate); // Create a copy of the start date

    // Ensure times are set correctly to midnight
    currentDate.setHours(10, 0, 0, 0);
    endDate.setHours(10, 0, 0, 0);

    // Iterate over each day in the period, including the end date
    while (currentDate.getTime() < endDate.getTime()) {
        count++; // Count each day
        // console.log(`calculatePikettkdays - currentDate: ${currentDate.toDateString()}, count: ${count}`);

        // Move to the next day
        currentDate.setDate(currentDate.getDate() + 1);
    }

    // console.log('calculatePikettkdays - Start date:', startDate.toDateString(), 'End date:', endDate.toDateString(), 'Number of days:', count);
    return count;
}

/**
 * Converts a date string between different formats.
 * 
 * This function takes a date string in either "dd.MM.yyyy" or "yyyy-MM-dd" format
 * and converts it to the other format. If the date string is in the format "dd.MM.yyyy",
 * it converts it to "yyyy-MM-dd". If the date string is in the format "yyyy-MM-dd",
 * it converts it to "dd.MM.yyyy".
 * 
 * Main features:
 * - Detects the input format by checking for either a period (.) or a dash (-).
 * - Converts between European "dd.MM.yyyy" and ISO "yyyy-MM-dd" formats.
 * - Returns the reformatted date string.
 * 
 * @param {string} dateString - The date string to convert. Expected formats: "dd.MM.yyyy" or "yyyy-MM-dd".
 * @returns {string} - The reformatted date string.
 * 
 * @example
 * const isoDate = convertToISOFormat('15.08.2024'); // Returns "2024-08-15"
 * const europeanDate = convertToISOFormat('2024-08-15'); // Returns "15.08.2024"
 */
function convertToISOFormat(dateString) {
    // If the date comes in the format "dd.MM.yyyy", reformat it to "yyyy-MM-dd"
    if (dateString.includes('.')) {
        // console.log('convertToISOFormat(.): ' + dateString);
        const [day, month, year] = dateString.split('.');
        // console.log('day: ' + day + ', month: ' + month + ', year: ' + year);
        return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
    }

    // If the date comes in the format "yyyy-MM-dd", reformat it to "dd.MM.yyyy"
    if (dateString.includes('-')) {
        // console.log('convertToISOFormat(-): ' + dateString);
        const [year, month, day] = dateString.split('-');
        // console.log('day: ' + day + ', month: ' + month + ', year: ' + year);
        return `${day.padStart(2, '0')}.${month.padStart(2, '0')}.${year}`;
    }

    // If the input format does not match expected patterns, return an empty string or handle appropriately
    return ''; 
}

function formatDateToShortISOFormat(date) {
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    return `${day}.${month}.${year}`;
}

// Export events per person or all events
function exportCalendarEvents(events, fileName) {
    // Sicherstellen, dass die Eingabe ein Array ist (falls nur ein einzelnes Event übergeben wird)
    if (!Array.isArray(events)) {
        events = [events];
    }

    // ICS-Dateiinhalte erstellen
    let icsContent = `BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//EngOps//RotaMaster//EN`;

    // Alle Events durchlaufen und sie im iCalendar-Format hinzufügen
    events.forEach(event => {
        const startDate = formatDateToICS(event.start);
        const endDate = event.end ? formatDateToICS(event.end) : formatDateToICS(event.start);

        icsContent += `
BEGIN:VEVENT
UID:${event.id}
SUMMARY:${event.title}
DTSTART:${startDate}
DTEND:${endDate}
END:VEVENT`;
    });

    icsContent += `
END:VCALENDAR`;

    // .ics-Datei zum Download bereitstellen
    const blob = new Blob([icsContent], { type: 'text/calendar' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = fileName;
    a.click();
    URL.revokeObjectURL(url);
}

// Format date to ICS-date
function formatDateToICS(date) {
    const year = date.getUTCFullYear();
    const month = (date.getUTCMonth() + 1).toString().padStart(2, '0');
    const day = date.getUTCDate().toString().padStart(2, '0');
    const hours = date.getUTCHours().toString().padStart(2, '0');
    const minutes = date.getUTCMinutes().toString().padStart(2, '0');
    const seconds = date.getUTCSeconds().toString().padStart(2, '0');
    return `${year}${month}${day}T${hours}${minutes}${seconds}Z`;
}

/**
 * functions for SQLite
 */
function getEventColors(type) {
    const colorMap = [
        { regex: /^Pikett$/, color: 'red' },
        { regex: /^Pikett-Pier$/, color: 'orange' },
        { regex: /^(Kurs|Aus\/Weiterbildung)$/, color: '#A37563' },
        { regex: /^(Militär|ZV\/EO|Zivil)$/, color: '#006400' },
        { regex: /^Ferien$/, color: '#05c27c' },
        { regex: /^Feiertag$/, color: '#B9E2A7' },
        { regex: /^(GLZ Kompensation|Absenz|Urlaub)$/, color: '#889CC6' },
        { regex: /^(Krankheit|Unfall)$/, color: '#212529' }
    ];

    // Run through the colorMap and find the first match
    for (const { regex, color } of colorMap) {
        if (regex.test(type)) {
            return color;
        }
    }

    // Return default color if no match was found
    return '#378006';
}

// CRUD Functions
async function createDBData(url, data){
    const response = await fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json' // Send as JSON
        },
        body: JSON.stringify(data) // Convert form data to JSON string
    });
    if (response.ok) {
        return response.status;
    } else {
        return 'Request failed with status:', response.status, response.statusText;
    }
}

async function readDBData(url) {
    const response = await fetch(url);
    if (response.ok) {
        const json = await response.json(); // Convert form data to JSON string
        return json
    } else {
        return 'Request failed with status:', response.status, response.statusText;
    }
}

function updateDBData(query, dbFile, elementId){
    console.log('Not implemented yet:', query)
}

/**
 * Deletes a database record associated with a given event ID using a DELETE request.
 * 
 * This asynchronous function sends a DELETE request to the PowerShell API endpoint to delete
 * a specific event from the database. Upon successful deletion, the page is reloaded to reflect the changes.
 * If an error occurs during the process, an error message is logged to the console, and an alert is shown to the user.
 * 
 * @async
 * @param {string} eventId - The ID of the event to delete from the database.
 * @returns {Promise<void>} - No return value, but logs messages to the console and displays alerts based on the outcome.
 * 
 * @example
 * await deleteDBData('12345'); // Deletes the event with ID '12345' and reloads the page if successful.
 */
async function deleteDBData(eventId){
    try {
        // Sende DELETE-Anfrage an die PowerShell API
        const response = await fetch(`/api/event/delete/${eventId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        // Überprüfe, ob die Anfrage erfolgreich war
        if (response.ok) {
            const responseData = await response.json();
            console.log(responseData.message); // Ausgabe: "Record successfully deleted"
            // Aktualisiere den Kalender oder die UI, nachdem der Record gelöscht wurde
            window.location.reload();
        } else {
            console.error('Failed to delete event:', response.status);
            alert('Fehler beim Löschen des Events');
        }
    } catch (error) {
        console.error('Error occurred while deleting event:', error);
        alert('Ein Fehler ist beim Löschen des Events aufgetreten');
    }
}

/**
 * Outsourced from index.html
 * Event listener to synchronize dropdown selection with datalist input field
**/
function eventListenerDropwodn(soureElement, targetElement){
    document.getElementById(soureElement).addEventListener('change', function() {
        const selectedValue = this.value;
        document.getElementById(targetElement).value = selectedValue; // Update datalist input field
    });
}

/**
 * Exportiert gefilterte Events als ICS-Datei.
 *
 * @param {Array} events - Die zu filternden Events.
 * @param {Function} filterFn - Eine Callback-Funktion, um Events zu filtern.
 * @param {string} filename - Der Dateiname der ICS-Datei.
 * @param {Function} exportFn - Die Funktion zum Exportieren der Events.
 */
function exportFilteredEvents(events, filterFn, filename, exportFn) {
    const filteredEvents = events.filter(filterFn);
    if (filteredEvents.length > 0) {
        exportFn(filteredEvents, filename);
    } else {
        alert('Keine passenden Events gefunden.');
    }
}

/**
 * Setzt die Event-Daten in das Modal.
 *
 * @param {Object} event - Das Event-Objekt.
 */
function setModalEventData(event) {

    const eventStartDate = formatDateToShortISOFormat(event.start);
    //const eventEndDate = formatDateToShortISOFormat(new Date(event.end.setDate(event.end.getDate() - 1))); // remove one day from the end-date
    const eventEndDate = formatDateToShortISOFormat(event.end); // remove one day from the end-date

    var days = 0;
    for (const [key, value] of Object.entries(event.extendedProps)) {
        if(value === 'Pikett'){
            days = calculatePikettkdays(event.start,event.end)
        }else{
            days = calculateWorkdays(event.start,event.end)
        }
    };

    document.getElementById('id').textContent = `id: ${event.id}`;
    document.getElementById('title').textContent = `title: ${event.title}, ${days} Tage`;
    document.getElementById('date').textContent = `start: ${eventStartDate} end: ${eventEndDate}`;
    
    // Falls es erweiterte Eigenschaften gibt, hier setzen
    /*     
    const otherElement = document.getElementById('other');
    otherElement.textContent = '';
    for (const [key, value] of Object.entries(event.extendedProps)) {
        otherElement.textContent += `${key}: ${value}\n`;
    }
    */
}

/**
 * Verarbeitet den Klick auf die Schaltflächen im Modal.
 *
 * @param {Object} event - Das Event-Objekt.
 */
function handleModalButtonClick(event) {
    if (btnExportEvent.checked) {
        exportCalendarEvents(event, `${event.title}.ics`);
    }
    if (btnRemoveEvent.checked) {
        if(event.id){
            if (confirm(`Event ${event.id}, ${event.title} wirklich löschen?`)) {
                deleteDBData(event.id);
            }
        }else{
            alert (`${event.title} kann nicht gelöscht werden!`)
        }
    }
}

// Funktion zum Extrahieren und Validieren der Formulardaten
function getFormData(form) {
    const formData = new FormData(form);
    const data = {};
    formData.forEach((value, key) => {
        data[key] = value;
    });

    // Überprüfe die Formulardaten auf Vollständigkeit
    if (!data.name || !data.type || !data.start || !data.end) {
        console.error('Fehler: Fehlende Formulardaten', data);
        return null;
    }

    console.log('Formulardaten extrahiert:', data);
    return data;
}
