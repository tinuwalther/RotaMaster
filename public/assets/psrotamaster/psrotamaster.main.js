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
            //// console.log('Success:', result); // Log the response
        } else {
            console.error('Request failed with status:', response.status);
        }
    } catch (error) {
        console.error('Error occurred:', error); // Log any errors
    }
}

async function getPerson(url) {
    var person = [];
    // console.log('Starting to fetch person data from:', url); 
    try {
        const response = await fetch(url);
        if (response.ok) {
            person = await response.json();
        } else {
            console.error('Error fetching person:', response.status);
        }
    } catch (error) {
        console.error('Error:', error);
    }
    return person;
}

// Funktion zum Befüllen des datalist mit Optionen
function fillDatalistOptions(datalistId, values) {
    // Referenz auf das datalist-Element
    const datalist = document.getElementById(datalistId);

    if (!datalist) {
        console.error(`Das datalist-Element mit der ID "${datalistId}" wurde nicht gefunden.`);
        return;
    }

    // Prüfe, ob das Argument ein Array ist
    if (!Array.isArray(values)) {
        console.error('Das übergebene Argument ist kein Array:', values);
        return;
    }

    // Leere das datalist zuerst, um sicherzustellen, dass keine alten Optionen existieren
    datalist.innerHTML = '';

    // Füge jede Option aus dem Array hinzu
    values.forEach(value => {
        const option = document.createElement('option');
        option.value = value; // Setze den Wert der Option
        datalist.appendChild(option); // Füge die Option zum datalist hinzu
    });
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
* // console.log(events); // Logs the calendar event data or an empty array if an error occurs.
*/
async function loadApiData(url) {
    var calendarData = [];
    // // console.log('Starting to fetch calendar data from:', url); 

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
    // // console.log('renderTable:', data);
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

        let eventStartDate = new Date(event.start + 'T00:00:00');
        let eventEndDate = new Date(event.end + 'T00:00:00');

        // Nur Events verarbeiten, die im ausgewählten Jahr liegen
        if (eventStartDate.getFullYear() !== selectedYear && eventEndDate.getFullYear() !== selectedYear) return;

        // Initialisierung der Person im Ergebnis-Objekt
        if (!result[personName]) {
            result[personName] = { pikett: 0, pikettIntervals: [], pikettPier: 0, pikettPierIntervals: [], ferien: 0, ferienIntervals: [] };
        }

        // Zähle die Events und speichere die Ferienzeiträume
        switch (eventType.trim()) {
            case 'Pikett':
                result[personName].pikettIntervals.push({ start: eventStartDate, end: eventEndDate });
                // result[personName].pikett++;
                break;
            case 'Pikett Pier':
                result[personName].pikettPierIntervals.push({ start: eventStartDate, end: eventEndDate });
                break;
            case 'Ferien':
                result[personName].ferienIntervals.push({ start: eventStartDate, end: eventEndDate });
                break;
        }
    });

    // Berechnung der Anzahl der Ferientage nach Durchlaufen aller Events
    for (const person in result) {
        let totalFerienTage = 0;
        let totalPikettTage = 0;
        let totalPikettPierTage = 0;

        result[person].ferienIntervals.forEach(interval => {
            totalFerienTage += calculateWorkdays(interval.start, interval.end);
        });
        
        result[person].pikettIntervals.forEach(interval => {
            totalPikettTage += calculatePikettkdays(interval.start, interval.end);
        });

        result[person].pikettPierIntervals.forEach(interval => {
            totalPikettPierTage += calculateWorkdays(interval.start, interval.end);
        });

        result[person].ferien = totalFerienTage;
        // console.log(`Person: ${person}, FerienIntervalle: ${result[person].ferienIntervals}, TotalFerienTage: ${totalFerienTage}`);

        result[person].pikett = totalPikettTage;
        // console.log(`Person: ${person}, PikettIntervalle: ${result[person].pikettIntervals}, TotalPikettTage: ${totalPikettTage}`);

        result[person].pikettPier = totalPikettPierTage;
        // console.log(`Person: ${person}, PikettIntervalle: ${result[person].pikettIntervals}, totalPikettPierTage: ${totalPikettPierTage}`);
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
    let currentDate = new Date(startDate); // Kopie des Startdatums

    // Sicherstellen, dass die Zeiten korrekt gesetzt sind
    currentDate.setHours(0, 0, 0, 0);
    endDate.setHours(0, 0, 0, 0);

    // Iteriere über jeden Tag im Zeitraum, einschließlich des Enddatums
    while (currentDate.getTime() < endDate.getTime()) {
        const dayOfWeek = currentDate.getDay();

        // Prüfe, ob der aktuelle Tag ein Wochentag ist (kein Samstag oder Sonntag)
        if (dayOfWeek !== 0 && dayOfWeek !== 6) {
            count++; // Zähle nur die Wochentage
        } else {
            // console.log(`calculateWorkdays - Überspringe Wochenende: ${currentDate.toDateString()}`);
        }
        // console.log(`calculateWorkdays - currentDate: ${currentDate.toDateString()}, count: ${count}`);
        // Gehe zum nächsten Tag
        currentDate.setDate(currentDate.getDate() + 1);
    }

    // console.log('calculateWorkdays - Startdatum:', startDate.toDateString(), 'Enddatum:', endDate.toDateString(), 'Anzahl der Wochentage:', count);
    return count;
}

/**
 * Berechnet die Anzahl Pikettage inkl. Wochenenden
 *
 * @param {Date} startDate - Das Startdatum der Ferien.
 * @param {Date} endDate - Das Enddatum der Ferien.
 * @returns {number} - Die Anzahl der Pikettage inkl. Wochenenden.
 */
function calculatePikettkdays(startDate, endDate) {
    let count = 0; // Zähler für die Wochentage
    let currentDate = new Date(startDate); // Kopie des Startdatums

    // Sicherstellen, dass die Zeiten korrekt gesetzt sind
    currentDate.setHours(0, 0, 0, 0);
    endDate.setHours(0, 0, 0, 0);

    // Iteriere über jeden Tag im Zeitraum, einschließlich des Enddatums
    while (currentDate.getTime() < endDate.getTime()) {
        count++;
        // console.log(`calculatePikettkdays - currentDate: ${currentDate.toDateString()}, count: ${count}`);
        currentDate.setDate(currentDate.getDate() + 1);
    }

    // console.log('calculatePikettkdays - Startdatum:', startDate.toDateString(), 'Enddatum:', endDate.toDateString(), 'Anzahl der Tage:', count);
    return count;
}


function convertToISOFormat(dateString) {
    // Wenn das Datum im Format "TT.MM.JJJJ" kommt, dann umformatieren in "yyyy-MM-dd"
    if(dateString.includes('.')){
        // console.log('convertToISOFormat(.): ' + dateString);
        const [day, month, year] = dateString.split('.');
        // console.log('day: ' + day + ', month: ' + month + ', year: ' + year)
        return `${day.padStart(2, '0')}.${month.padStart(2, '0')}.${year}`;
    }
    // Wenn das Datum im Format "yyyy-MM-dd" kommt, dann umformatieren in "dd.mm.jjjj"
    if(dateString.includes('-')){
        // console.log('convertToISOFormat(-): ' + dateString);
        const [year, month, day] = dateString.split('-');
        // console.log('day: ' + day + ', month: ' + month + ', year: ' + year)
        return `${day.padStart(2, '0')}.${month.padStart(2, '0')}.${year}`;
    }
}
