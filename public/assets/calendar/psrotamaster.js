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
    console.log('Starting to fetch calendar data from:', url); 

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


async function getEventSummary(calendarData, regex) {
    var result = null;
    try {
        const filteredEvents = calendarData.filter(event => {
            return regex.test(event.title);
        });

        console.log('Filtered Events:', filteredEvents.length);
        result = filteredEvents;

    } catch (error) {
        console.error('Error:', error);
    }
    return result;
}

async function getEventSummarySplit(calendarData, regex) {
    const result = {};
    try {
        // Iteriere durch alle Events im Kalender
        calendarData.forEach(event => {
            if (event.title.includes(' - ')) {
                // Teile den Titel am Bindestrich, um den Namen der Person und den Event-Typ zu extrahieren
                const [personName, eventType] = event.title.split(' - ');

                // Wenn die Person noch nicht im result-Objekt existiert, füge sie hinzu
                if (!result[personName]) {
                    result[personName] = {
                        pikett: 0,       // Zähler für Pikett-Events
                        pikettPier: 0,   // Zähler für Pikett Pier-Events
                        ferien: 0        // Zähler für Ferien-Events
                    };
                }

                // Zähle die Event-Typen entsprechend
                if (eventType === 'Pikett') {
                    result[personName].pikett++;
                } else if (eventType === 'Pikett Pier') {
                    result[personName].pikettPier++;
                } else if (eventType === 'Ferien') {
                    result[personName].ferien++;
                }
            }
        });

        return result; // Gib das Zählerobjekt zurück

    } catch (error) {
        console.error('Error:', error);
        return {}; // Rückgabe eines leeren Objekts bei Fehler
    }
}


// Funktion zum Einfügen der Daten in die HTML-Tabelle
function renderTable(data) {
    console.log('renderTable:', data);
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
