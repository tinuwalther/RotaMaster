/**
* Sends the next year as plain text to the provided API URL and logs the response.
* 
* This asynchronous function calculates the next year dynamically,
* converts it to a string, and sends it to a specified API endpoint using
* a POST request. The function handles any potential errors and logs the
* result or any failures to the console.
* 
* @param {string} url - The API endpoint to which the next year will be sent.
* 
* - Pass the desired API endpoint as the 'url' parameter.
* - It sends the next year (e.g., 2025 if the current year is 2024) as a plain text string to the API.
* - Logs the success or failure of the request to the console.
*
* @async
* @param {string} url - The URL of the API endpoint where the year is sent.
* @returns {Promise<void>} - No return value, but logs results or errors to the console.
* 
* @example
* await getNextYear('/api/year/new'); // Sends the next year to the given API URL and logs the response.
*/
async function getNexYear(url) {
    const nextYear = new Date().getFullYear() + 1; // Calculate the next year dynamically
    const data = nextYear.toString(); // Convert the year to string to send as plain text

    try {
        // Send a POST request using fetch
        const response = await fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'text/plain' // Header to send plain text
            },
            body: data // Sending the data as plain text in the body
        });

        // Check if the request was successful
        if (response.ok) {
            const result = await response.text(); // Read the response as text
            //console.log('Success:', result); // Log the response
        } else {
            console.error('Request failed with status:', response.status);
        }
    } catch (error) {
        console.error('Error occurred:', error); // Log any errors
    }
}

/**
* Fetches calendar event data from the provided API URL.
* 
* This asynchronous function sends a GET request to the specified API endpoint 
* to retrieve calendar event data. It returns the parsed JSON data if the request
* is successful, or an empty array if an error occurs.
* 
* @async
* @param {string} url - The API endpoint from which to fetch the calendar data.
* @returns {Promise<Array>} A promise that resolves to an array of event data. 
* If the request fails, the function returns an empty array.
* 
* @example
* const events = await loadApiData('/api/event/get'); 
* console.log(events); // Logs the calendar event data or an empty array if an error occurs.
*/
async function loadApiData(url) {
    var calendarData = [];
    // console.log('Starting to fetch calendar data from:', url); 

    try {
        const response = await fetch(url);
        if (response.ok) {
            calendarData = await response.json();
        } else {
            console.error('Error fetching calendarData:', response.status);
        }
    } catch (error) {
        console.error('Error:', error);
    }
    return calendarData;
}

// Funktion zum Einfügen der Daten in die HTML-Tabelle
function renderTable(data) {
    // console.log('renderTable:', data);
    const tableBody = document.querySelector('#pikettTable tbody');
    tableBody.innerHTML = ''; // Tabelle zurücksetzen

    // Schleife durch die Daten und füge sie in die Tabelle ein
    Object.keys(data).forEach(person => {
        const row = document.createElement('tr'); // Erstelle eine Tabellenreihe

        const nameCell = document.createElement('td'); // Zelle für den Namen
        nameCell.textContent = person; // Füge den Namen ein
        row.appendChild(nameCell);

        const pikettCell = document.createElement('td'); // Zelle für die Anzahl Pikett
        pikettCell.textContent = data[person].pikett; // Füge die Pikett-Anzahl ein
        row.appendChild(pikettCell);

        const pikettPierCell = document.createElement('td'); // Zelle für die Anzahl Pikett Pier
        pikettPierCell.textContent = data[person].pikettPier; // Füge die Pikett Pier-Anzahl ein
        row.appendChild(pikettPierCell);

        const ferienCell = document.createElement('td'); // Zelle für die Anzahl Ferien
        ferienCell.textContent = data[person].ferien; // Füge die Ferien-Anzahl ein
        row.appendChild(ferienCell);

        tableBody.appendChild(row); // Füge die Reihe zum Tabellenkörper hinzu
    });
}


/**
 * Berechnet die Events im ausgewählten Jahr und gibt die Zusammenfassung zurück.
 * @param {Array} calendarData - Die Kalenderdaten.
 * @param {number} selectedYear - Das ausgewählte Jahr.
 * @returns {Object} - Die Zusammenfassung der Events pro Person.
 */
async function getEventSummary(calendarData, selectedYear) {
    const result = {};

    calendarData.forEach(event => {
        const [personName, eventType] = event.title.split(' - ');
        if (!personName || !eventType) return;

        const eventStartDate = new Date(event.start + 'T00:00:00');
        const eventEndDate = new Date(event.end + 'T00:00:00');

        // Nur Events verarbeiten, die im ausgewählten Jahr liegen
        if (eventStartDate.getFullYear() !== selectedYear && eventEndDate.getFullYear() !== selectedYear) return;

        // Initialisierung der Person im Ergebnis-Objekt
        result[personName] = result[personName] || { pikett: 0, pikettPier: 0, ferien: 0, ferienStart: null, ferienEnd: null };

        // Zähle die Events und aktualisiere die Ferien-Daten
        switch (eventType.trim()) {
            case 'Pikett':
                result[personName].pikett++;
                break;
            case 'Pikett Pier':
                result[personName].pikettPier++;
                break;
            case 'Ferien':
                if (!result[personName].ferienStart || eventStartDate < result[personName].ferienStart) {
                    result[personName].ferienStart = eventStartDate;
                }
                if (!result[personName].ferienEnd || eventEndDate > result[personName].ferienEnd) {
                    result[personName].ferienEnd = eventEndDate;
                }
                break;
        }
    });

    // Berechne die Anzahl der Ferientage (ohne Wochenenden)
    for (const person in result) {
        const { ferienStart, ferienEnd } = result[person];
        result[person].ferien = (ferienStart && ferienEnd) ? calculateWorkdays(ferienStart, ferienEnd) : 0;
    }

    return result;
}

/**
 * Berechnet die Anzahl der Ferientage ohne Wochenenden.
 * 
 * @param {Date} startDate - Das Startdatum der Ferien.
 * @param {Date} endDate - Das Enddatum der Ferien.
 * @returns {number} - Die Anzahl der Ferientage ohne Wochenenden.
 */
function calculateWorkdays(startDate, endDate) {
    let count = 0; // Zähler für die Wochentage
    let currentDate = new Date(startDate); // Startdatum

    // Iteriere über jeden Tag im Zeitraum
    while (currentDate <= endDate) {
        const dayOfWeek = currentDate.getDay();

        // Prüfe, ob der aktuelle Tag ein Wochentag ist (kein Samstag oder Sonntag)
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            count++; // Zähle nur die Wochentage
        }

        // Gehe zum nächsten Tag
        currentDate.setDate(currentDate.getDate() + 1);
    }

    return count;
}

function convertToISOFormat(dateString) {
    // Angenommen das Datum kommt im Format "TT.MM.JJJJ"
    const [day, month, year] = dateString.split('.');
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
}
