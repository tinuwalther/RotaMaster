// Listener for the load event
window.addEventListener('load', () => {
    getNextYear('/api/year/new'); // Call the API once the page is fully loaded
});

let db;

// Listener for DOMContentLoaded event
document.addEventListener('DOMContentLoaded', async function() {
    
    // Load userCookie and display the username
    const userCookie = getCookie('CurrentUser');
    let username = null;
    if (userCookie) {
        // console.log(`Name: ${userCookie.name}, Login: ${userCookie.login}, Email: ${userCookie.email}`);
        try {
            username = userCookie.name;
            if (username) {
                const welcomeElement = document.getElementById('currentUser');
                if (welcomeElement) {
                    welcomeElement.textContent = `${username}`;
                    document.getElementById('datalistName').value = username;
                } else {
                    console.error("Element with ID 'welcomeMessage' not found.");
                }
            }else{
                showAlert(`No username found!`);
            }
        } catch (error) {
            showAlert('There is something wrong with the userCookie!');
            console.log("There is something wrong with the userCookie!" + error);
        }
    }else{
        console.log('User cookie not found or invalid');
        showAlert('User cookie not found or invalid!');
    }

    // Refresh the footer datetime
    const d = new Date();
    document.getElementById('footerDate').textContent = 'Last refresh: ' + d.toLocaleString();

    // Fetch the events from the API (from the SQLite view v_events) and fill the calendar with the events
    const events = await readDBData('/api/event/read/*');
    const holidays = await loadApiData('/api/csv/read');
    let calendarEvents = [];
    calendarEvents = [
        ...(holidays || []), // Holidays (if available)
        ...(Array.isArray(events) ? events : [events] || []) // User Events as Array
    ];
    // console.log('DEBUG', 'calendarEvents', calendarEvents);
    // Fetch the person from the API (from the SQLite table person) and fill the datalist with the person names
    try {
        const person = await readDBData('/api/person/read/*');
        const personNames = new Array;
        if(Array.isArray(person)){
            person.map((item) => {
                personNames.push(item.fullname);
            });
        }else{
            personNames.push(person.fullname);
        }

        if (personNames.length) {
            fillDatalistOptions('datalistOptions', personNames);
            fillDropdownOptions('nameDropdownPerson', personNames);
            fillDropdownOptions('nameDropdownPersonModal', personNames);
        } else {
            console.error('No person found.');
        }
    } catch (error) {
        console.error('Error fetching person:', error);
    }

    // Fetch the absence from the API (from the SQLite table absence) and fill the dropdown with the absence names
    try {
        const absence = await readDBData('/api/absence/read/*');
        const absenceNames = new Array;
        if(Array.isArray(absence)){
            absence.map((item) => {
                absenceNames.push(item.name);
            });
        }else{
            absenceNames.push(absence.name);
        }

        if (absenceNames.length) {
            fillDropdownOptions('nameDropdownAbsence', absenceNames);
            fillDropdownOptions('nameDropdownAbsenceModal', absenceNames);
        } else {
            console.error('No absence found.');
        }
    } catch (error) {
        console.error('Error fetching absences:', error);
    }

    // Create a new FullCalendar instance
    let calendarEl = document.getElementById('calendar');
    let calendar = new FullCalendar.Calendar(calendarEl, {
        // Concatenate the calendarConfig from the rotamaster.js file
        ...calendarConfig,

        // Data from the API is fetched and displayed in the calendar
        events: calendarEvents,

        // Custom Buttons for the calendar
        customButtons: {
            refreshButton: {
                text: 'Refresh',
                icon: 'bi bi-arrow-repeat',
                hint: 'Kalender aktualisieren',
                click: function() {
                    console.log('DEBUG', 'Refresh the calendar');
                    refreshCalendarData(calendar);
                }
            },
            // Button to export all events as iCalendar (.ics) file
            exportToIcs: {
                // Create a Bootstrap-Modal-Instance for multipleEvents and open it
                text: 'Export Events',
                click: function() {
                    const exportModal = new bootstrap.Modal(document.getElementById('multipleEvents'), {
                        keyboard: true
                    });
                    document.getElementById('btnAllEvents').checked = true;
                    document.getElementById('nameDropdownPersonModal').value = '';
                    document.getElementById('nameDropdownAbsenceModal').value = '';
                    document.getElementById('personNameContainer').style.display = 'none';
                    document.getElementById('eventTypeContainer').style.display = 'none';
                    exportModal.show();
                }
            },
            // Button to export person specific events as iCalendar (.ics) file
            filterEvents: {
                text: 'My Events',
                click: async function() {
                    const button = document.querySelector('.fc-filterEvents-button');
                    const holidays = await loadApiData('/api/csv/read');
                    isMyEvents = button.textContent;
                    let currentEvents = [];
                    let calendarEvents = [];

                    if (isMyEvents.includes('My Events')) {
                        // Export events of the current user
                        const response = await fetch(`/api/event/read/${username}`);
                        if (!response.ok) {
                            throw new Error(`Failed to fetch user events of ${username}`);
                        }
                        currentEvents = await response.json();
                        button.textContent = 'All Events';
                    }else if(isMyEvents.includes('All Events')) {
                        // Export events of all users
                        const response = await fetch('/api/event/read/*');
                        if (!response.ok) {
                            throw new Error('Failed to fetch user events of all users');
                        }
                        currentEvents = await response.json();
                        button.textContent = 'My Events';
                    }

                    calendarEvents = [
                        ...(holidays || []), // Holidays (if available)
                        ...(Array.isArray(currentEvents) ? currentEvents : [currentEvents] || []) // User Events as Array
                    ];

                    calendar.removeAllEvents();
                    calendar.addEventSource(calendarEvents);
                }
            }
        },

        // This function is called when the view is changed or the date changes
        datesSet: function(info) {
            
            let displayedYear = calcDisplayedYear(info);

            // Display the year after the Summary text
            if (displayedYear) {
                const summaryElement = document.getElementById('eventSummary');
                summaryElement.textContent = 'Summary ' + displayedYear;
            } else {
                // console.log('DEBUG', 'No year found:', displayedYear);
            }

            // Call the function and render the table after the page has loaded
            getEventSummary(calendarEvents, displayedYear).then(summary => {
                // console.log('DEBUG', 'Calculate summary');
                renderTable(summary); 
            });

            refreshCalendarData(calendar);
            document.querySelector('.fc-filterEvents-button').textContent = 'My Events';
        },

        // This function is called when an event is clicked
        eventClick: function(info) {
            // Create a Bootstrap-Modal-Instance for singleEvent and open it
            const event = info.event;
            const singleEvent = new bootstrap.Modal(document.getElementById('singleEvent'), {
                keyboard: true
            });
            setModalEventData(event);
            document.getElementById('btnExportEvent').checked = true;
            singleEvent.show();

            const btnExportEvent = document.getElementById('btnExportEvent'); 
            const btnRemoveEvent = document.getElementById('btnRemoveEvent'); 

            const singleEventSubmit = document.getElementById('singleEventSubmit'); 
            singleEventSubmit.onclick = async function() {
                if (btnExportEvent.checked) {
                    exportCalendarEvents(event, `${event.title}.ics`);
                } else {
                    if(event.id){
                        const message = `Event ${event.id}, ${event.title} wirklich löschen?`;
                        const result = await showConfirm(message);
                        if (result) {
                            if(event.title.includes('Pikett')){
                                // Remove Override form OpsGenie
                                if(calendarConfig.opsGenie){
                                    const override = {                                    
                                        scheduleName: calendarConfig.scheduleName,
                                        rotationName: calendarConfig.rotationName,
                                        userName: event.extendedProps.email,
                                        alias: event.extendedProps.alias,
                                        onCallStart: event.start,
                                    };
                                    console.log('DEBUG', 'Remove Override form OpsGenie', override);
                                    const opsGenieResult = await removeOpsGenieOverride(override);
                                    console.log('DEBUG', 'OpsGenie Override:', opsGenieResult.result);
                                    // showAlert(`OpsGenie Override ${event.extendedProps.alias} ${opsGenieResult.result}`)
                                }
                            }
                            deleteDBData('/api/event/delete', event)
                            .then(() => {
                                // Fetch new data and refresh the calendar
                                refreshCalendarData(calendar);
                            })
                            .catch(error => {
                                console.error('Error deleting event:', error);
                                showAlert('Fehler beim Löschen des Events, ggf. OpsGenie prüfen!');
                            });
                        }
                    }else{
                        showAlert(`${event.title} kann nicht gelöscht werden!`)
                    }
                }
                const singleEventSubmit = bootstrap.Modal.getInstance(document.getElementById('singleEvent'));
                singleEventSubmit.hide();                        
            }
        },

        // This function is called when an event is selected
        select: function(info) {

            // Convert start and end dates to Date objects
            const eventStartDate = new Date(info.startStr);
            const eventEndDate = new Date(info.endStr);
            // console.log('DEBUG', 'Filling data in event form', eventStartDate, eventEndDate);

            // Subtract one day from the end date because the endDate is not correctly passed from the calendar
            eventEndDate.setDate(eventEndDate.getDate() - 1);

            // Create formatted dates in the format yyyy-MM-dd
            const formattedStartDate = eventStartDate.toISOString().split('T')[0];
            const formattedEndDate = eventEndDate.toISOString().split('T')[0];
            // console.log('DEBUG', 'Formatted:', formattedStartDate, formattedEndDate);

            // Set values in form elements
            document.getElementById('start').value = formattedStartDate;
            document.getElementById('end').value = formattedEndDate;
        },

        // This function is called when an event is moved
        eventDrop: async function(info) {
            if(info.event.id){
                const message = `'${info.event.title}' verschieben nach ${formatDateToShortISOFormat(info.event.start).substring(0,10)}?`;
                const result = await showConfirm(message);
                const event = info.event;
                if (result) {
                    // Update the event in the SQLite table event with the new start and end date
                    const updatedEvent = {
                        id: event.id,
                        type: event.extendedProps.type,
                        start: event.start,
                        end: event.end
                    };
                    await updateDBData('/api/event/update', updatedEvent);
                    // refreshCalendarData(calendar);

                    // Update Override in OpsGenie if it's Pikett and OpsGenie is enabled and the alias is not empty
                    if(event.extendedProps.type === 'Pikett'){
                        if(calendarConfig.opsGenie){
                            if(event.extendedProps.alias){
                                const override = {                                    
                                    scheduleName: calendarConfig.scheduleName,
                                    rotationName: calendarConfig.rotationName,
                                    userName: event.extendedProps.email,
                                    alias: event.extendedProps.alias,
                                    onCallStart: event.start,
                                    onCallEnd: event.end
                                };
                                // console.log('DEBUG', 'Send update to OpsGenie as Override', event);
                                const updateOverride = await updateOpsGenieOverride(override);
                                // console.log('DEBUG', 'Update OpsGenie Override:', updateOverride);
                            }else{
                                console.log('DEBUG', 'Alias empty', event.extendedProps);
                                showAlert(`'${event.title} von ${formatDateToShortISOFormat(event.start).substring(0,10)} bis ${formatDateToShortISOFormat(event.end).substring(0,10)}'\nBitte im OpsGenie prüfen und ggf. manuell anpassen!`, `${calendarConfig.appPrefix}RotaMaster - OpsGenie Alias ist leer!`)
                            }
                        }
                    }
                } else {
                    info.revert();
                }
            }else{
                info.revert();
                showAlert(`'${info.event.title}' ist von einem CSV und kann nicht verschoben werden!`)
            }
        }
    });

    // Render the calendar
    calendar.render();
    
    // Add the App-Version and App-Prefix to the Navbar-Brand
    const pageTitle = `${calendarConfig.appPrefix}RotaMaster V${calendarConfig.appVersion.substring(0,1)}`;
    const navbarBrandElement = document.getElementById('navbarBrand');
    if (navbarBrandElement) {
        navbarBrandElement.textContent = pageTitle;
    };

    // Set the title of the page
    document.getElementById('title').textContent = `${pageTitle} - Home`;
    document.getElementById('exampleModalLabel').textContent = `${pageTitle} - Export multiple Events`;
    document.getElementById('updateExportEventTitle').textContent = `${pageTitle} - Single Events`;
    document.getElementById('alertTitle').textContent = `${pageTitle} - Alert!`;
    document.getElementById('confirmTitle').textContent = `${pageTitle} - Confirm?`;

    // Add an event listener to the start date input field to set the end date to the start date
    document.getElementById('start').addEventListener('change', function() {
        const startDate = this.value;
        document.getElementById('end').value = startDate;
    });

    // Add an event listener to the export button for the modal multipleEvents to export the events as iCalendar (.ics) file
    const exportButton = document.getElementById('btnExport');
    exportButton.addEventListener('click', function() {
        // Get the events from the calendar
        const events = calendar.getEvents();
        
        if (btnAllEvents.checked) {
            // Export all events as iCalendar (.ics) file
            exportCalendarEvents(events, 'all-events.ics');
        } else if (btnPersonEvents.checked) {
            // Export person specific events as iCalendar (.ics) file
            const personName = document.getElementById('nameDropdownPersonModal').value.trim();
            if (personName) {
                exportFilteredEvents(
                    events,
                    event => {
                        const [eventPersonName] = event.title.split(' - ');
                        return eventPersonName.trim().toLowerCase() === personName.toLowerCase();
                    },
                    `${personName}-events.ics`,
                    exportCalendarEvents
                );
            } else {
                showAlert('Bitte geben Sie einen Namen ein.');
            }
        } else if (btnTypeOfEvents.checked) {
            // Export type of events as iCalendar (.ics) file
            const eventType = document.getElementById('nameDropdownAbsenceModal').value.trim();
            if (eventType) {
                exportFilteredEvents(
                    events,
                    event => {
                        const [, eventTypeName] = event.title.split(' - ');
                        return eventTypeName && eventTypeName.trim().toLowerCase() === eventType.toLowerCase();
                    },
                    `${eventType}-events.ics`,
                    exportCalendarEvents
                );
            } else {
                showAlert('Bitte geben Sie einen Event-Typ ein.');
            }
        }

        // Hide the modal after the export
        const exportModal = bootstrap.Modal.getInstance(document.getElementById('multipleEvents'));
        exportModal.hide();
    });

    // Listener for the radio buttons to show the input field when the corresponding radio button is selected
    const btnAllEvents = document.getElementById('btnAllEvents');
    const btnPersonEvents = document.getElementById('btnPersonEvents');
    const btnTypeOfEvents = document.getElementById('btnTypeOfEvents');
    const personNameContainer = document.getElementById('personNameContainer');
    const eventTypeContainer = document.getElementById('eventTypeContainer');

    // If the button all events is checked, hide the input fields for person name and event type
    btnAllEvents.addEventListener('change', function() {
        if (btnAllEvents.checked) {
            personNameContainer.style.display = 'none';
            eventTypeContainer.style.display = 'none';
        }
    });

    // If the button person events is checked, show the input field for the person name and hide the input field for the event type
    btnPersonEvents.addEventListener('change', function() {
        if (btnPersonEvents.checked) {
            personNameContainer.style.display = 'block';
            eventTypeContainer.style.display = 'none';
        }
    });

    // If the button type of events is checked, show the input field for the event type and hide the input field for the person name
    btnTypeOfEvents.addEventListener('change', function() {
        if (btnTypeOfEvents.checked) {
            personNameContainer.style.display = 'none';
            eventTypeContainer.style.display = 'block';
        }
    });

    // Add Tooltip to the buttons, timeout is needed to ensure that the buttos are already rendered
    setTimeout(function() {
        const buttons = [
            { selector: '.fc-multiMonthYear-button', tooltip: 'Jahressansicht', },
            { selector: '.fc-dayGridMonth-button', tooltip: 'Monatsansicht' },
            { selector: '.fc-listMonth-button', tooltip: 'Listenansicht' },
            { selector: '.fc-exportToIcs-button', tooltip: 'Exportiere alle Kalender-Events als iCalendar (.ics) Datei' },
            { selector: '.fc-filterEvents-button', tooltip: 'Zeige nur meine Events an' },
            { selector: '.fc-exportPersonEvents-button', tooltip: 'Exportiere alle Kalender-Events personenspezifisch als iCalendar (.ics) Datei' }
        ];
    
        buttons.forEach(button => {
            const element = document.querySelector(button.selector);
            if (element) {
                element.setAttribute('title', button.tooltip);
            }
        });
    }, 0);                
    
    // Default form submit and to call the API to add the event
    const form = document.querySelector('form');
    form.addEventListener('submit', async function(event) {
        event.preventDefault(); // Prevent default form submission

        // Get the form data as an object
        const data = getFormData(form);
        if (!data) {
            showAlert('Bitte füllen Sie alle erforderlichen Felder aus.');
            return;
        }

        // Add the event to the SQLite table event
        try {
            if(data.start <= data.end){
                // Perform the API call using fetch add data
                // console.log('DEBUG', calendarConfig.opsGenie);
                if(data.type === 'Pikett'){
                    const username = data.name;
                    // Fetch the current user from the API (from the SQLite table person)
                    const response = await fetch(`/api/person/read/${username}`);
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
                                // showAlert(`OpsGenie Override ${opsGenieResult.data.alias} created`)
                                // const message = `Override in OpsGenie für ${currentUser.email} als ${opsGenieResult.data.alias} erstellt. Kalender aktualisieren?`;
                                // const messageResult = await showConfirm(message);
                                // if (messageResult) {
                                    // Add the event to the SQLite table event
                                    data.alias = opsGenieResult.data.alias;
                                    // console.log('DEBUG', data);
                                    await createDBData('/api/event/create', data, currentUser);
                                // }
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
    });

    // Synchronize the dropdown selection with the datalist input field
    eventListenerDropwodn('nameDropdownPerson','datalistName');

    document.getElementById('Loading').remove(); // Remove the loading spinner

});


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
                'Content-Type': 'text/plain; charset=UTF-8' // Specify that the request body contains plain text
            },
            body: data // Send the year as plain text in the request body
        });

        // Check if the request was successful
        if (response.ok) {
            const result = await response.text(); // Read the response as plain text
            // console.log('DEBUG', 'Success:', result); // Log the successful response
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
        // console.log('DEBUG', 'Month view - Displayed year:', displayedYear);
        // console.log('DEBUG', 'Month view - Displayed month:', displayedMonth);
    } else if (info.view.type === 'multiMonthYear') {
        const centralDate = new Date(
            (info.start.getTime() + info.end.getTime()) / 2
        );
        // Extract the year
        displayedYear = centralDate.getFullYear();
        // console.log('DEBUG', 'Year view - Displayed year:', displayedYear);
    }

    return displayedYear;
};

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
* const events = await loadApiData('/api/event/read/*'); 
* // console.log(events); // Logs the calendar event data or an empty array if an error occurs.
*/
async function loadApiData(url) {
    var calendarData = []; // Initialize an empty array to store calendar event data
    // console.log('DEBUG', 'Starting to fetch calendar data from:', url); 

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
* Pikett-Peer count, and vacation days.
* 
* Main features:
* - Clears any existing rows in the table body before adding new data.
* - Iterates over the keys in the data object to populate each row of the table.
* - Adds columns for each data field: person name, Pikett count, Pikett-Peer count, and vacation days.
* 
* @param {Object} data - An object containing event data to populate the table.
* Each key represents a person's name, and each value contains details about Pikett, Pikett-Peer, and vacation counts.
* @returns {void}
* 
* @example
* const data = {
*   'Alice': { pikett: 3, PikettPeer: 2, ferien: 5 },
*   'Bob': { pikett: 1, PikettPeer: 3, ferien: 4 }
* };
* renderTable(data); // Populates the HTML table with rows for Alice and Bob.
*/
function renderTable(data) {
    // console.log('DEBUG', 'renderTable:', data);
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

        const PikettPeerCell = document.createElement('td'); // Cell for the Pikett-Peer count
        PikettPeerCell.textContent = data[person].PikettPeer; // Set the Pikett-Peer count
        row.appendChild(PikettPeerCell);

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
 * types of events, including Pikett, Pikett-Peer, and vacations, and counts the
 * respective days for each type of event for every person.
 * 
 * Main features:
 * - Processes events for a specific year and ignores those that do not fall within the selected year.
 * - Summarizes event details (Pikett, Pikett-Peer, and vacation intervals) for each person.
 * - Calculates total vacation days, Pikett days, and Pikett-Peer days for every person.
 * 
 * @async
 * @param {Array} calendarData - The array of calendar events. Each event must have a title, start, and end property.
 * @param {number} selectedYear - The year for which to calculate the summary.
 * @returns {Object} An object containing the summary of events per person.
 * Each key represents a person's name, and each value contains counts for Pikett, Pikett-Peer, and vacation.
 * 
 * @example
 * const summary = await getEventSummary(calendarData, 2024); // Returns the summary of events for 2024
 */
async function getEventSummary(calendarData, selectedYear) {
    const result = {};
    calendarData.forEach(event => {

        if(event.type !== 'Feiertag'){
            // console.log('DEBUG', 'Calculate summary', event);
            const [personName, eventType] = event.title.split(' - ');
            if (!personName || !eventType) return;

            // console.log('DEBUG', event.start,event.end);
            let eventStartDate = new Date(event.start);
            let eventEndDate = new Date(event.end);

            // Process only events that fall within the selected year
            if (eventStartDate.getFullYear() !== selectedYear && eventEndDate.getFullYear() !== selectedYear) return;

            // Initialize the person in the result object if not already present
            if (!result[personName]) {
                result[personName] = { pikett: 0, pikettIntervals: [], PikettPeer: 0, PikettPeerIntervals: [], ferien: 0, ferienIntervals: [] };
            }

            // Count the events and store the intervals
            switch (eventType.trim()) {
                case 'Pikett':
                    result[personName].pikettIntervals.push({ start: eventStartDate, end: eventEndDate });
                    break;
                case 'Pikett-Peer':
                    result[personName].PikettPeerIntervals.push({ start: eventStartDate, end: eventEndDate });
                    break;
                case 'Ferien':
                    result[personName].ferienIntervals.push({ start: eventStartDate, end: eventEndDate });
                    break;
            }
        }

    });

    let swissHolidays = getSwissHolidays(selectedYear)
    // console.log('DEBUG', 'swissHolidays', swissHolidays);

    // Calculate the number of vacation days after processing all events
    for (const person in result) {
        let totalVacationDays = 0;
        let totalPikettDays = 0;
        let totalPikettPeerDays = 0;

        result[person].ferienIntervals.forEach(interval => {
            totalVacationDays += calculateWorkdays(interval.start, interval.end, swissHolidays);
        });
        
        result[person].pikettIntervals.forEach(interval => {
            totalPikettDays += calculatePikettkdays(interval.start, interval.end);
        });

        result[person].PikettPeerIntervals.forEach(interval => {
            totalPikettPeerDays += calculateWorkdays(interval.start, interval.end, swissHolidays);
        });

        result[person].ferien = totalVacationDays;
        // console.log('DEBUG', `Person: ${person}, Vacation Intervals: ${result[person].ferienIntervals}, Total Vacation Days: ${totalVacationDays}`);

        result[person].pikett = totalPikettDays;
        // console.log('DEBUG', `Person: ${person}, Pikett Intervals: ${result[person].pikettIntervals}, Total Pikett Days: ${totalPikettDays}`);

        result[person].PikettPeer = totalPikettPeerDays;
        // console.log('DEBUG', `Person: ${person}, Pikett-Peer Intervals: ${result[person].pikettIntervals}, Total Pikett-Peer Days: ${totalPikettPeerDays}`);
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
function calculateWorkdays(startDate, endDate, holidays) {
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
            // console.log('DEBUG', 'WorkingDay', formattedDate, currentDate)
            count++; // Count only weekdays
        }
        // Move to the next day
        currentDate.setDate(currentDate.getDate() + 1);
    }
    // console.log('DEBUG', 'calculateWorkdays - Start date:', startDate.toDateString(), 'End date:', endDate.toDateString(), 'Number of weekdays:', count);
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
        // console.log('DEBUG', `calculatePikettkdays - currentDate: ${currentDate.toDateString()}, count: ${count}`);

        // Move to the next day
        currentDate.setDate(currentDate.getDate() + 1);
    }

    // console.log('DEBUG', 'calculatePikettkdays - Start date:', startDate.toDateString(), 'End date:', endDate.toDateString(), 'Number of days:', count);
    return count;
}

function formatDateToShortISOFormat(date) {
    const day = String(date.getDate()).padStart(2, '0');
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const year = date.getFullYear();
    const hours = String(date.getHours()).toString().padStart(2, '0');
    const minutes = String(date.getMinutes()).toString().padStart(2, '0');
    return `${day}.${month}.${year} ${hours}:${minutes}`;
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
        { regex: /^Pikett-Peer$/, color: 'orange' },
        { regex: /^(Kurs|Aus\/Weiterbildung)$/, color: '#A37563' },
        { regex: /^(Militär\/ZV\/EO|Zivil)$/, color: '#006400' },
        { regex: /^Ferien$/, color: '#05c27c' },
        { regex: /^Feiertag$/, color: '#B9E2A7' },
        { regex: /^(GLZ Kompensation|Absenz|Urlaub)$/, color: '#889CC6' },
        { regex: /^(Krankheit|Unfall)$/, color: '#212529' }
    ];

    // Run through the colorMap and find the first match
    for (const { regex, color } of colorMap) {
        if (regex.test(type)) {
            //console.log('DEBUG', 'Color:', color, 'Type:', type);
            return color;
        }
    }

    // Return default color if no match was found
    return '#4F0680';
}

/**
 * Create an OpsGenie override for a specific user and time period.
 * @param {*} data 
 * @returns 
 * @example
 * const data = { name: "John", type: "Meeting", start: "2024-12-01", end: "2024-12-02" };
 * const response = await createOpsGenieOverride(data);
 */
async function createOpsGenieOverride(data){
    const response = await fetch('/api/opsgenie/override/create', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json' // Send as JSON
        },
        body: JSON.stringify(data) // Convert form data to JSON string
    });
    if (response.ok) {
        // console.log('DEBUG', response.status, response.statusText, `${data.userName}`, `${data.data.alias}`); // Ausgabe: "Record successfully updated"
        const json = await response.json(); // Convert form data to JSON string
        return json
    } else {
        console.error('Failed to create override:', response, data);
        return 'Request failed with status:', response.status, response.statusText;
    }
}

async function updateOpsGenieOverride(data){
    const response = await fetch('/api/opsgenie/override/update', {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json' // Send as JSON
        },
        body: JSON.stringify(data) // Convert form data to JSON string
    });
    if (response.ok) {
        // console.log('DEBUG', response.status, response.statusText, `${data.userName}`, `${data.alias}`); // Ausgabe: "Record successfully updated"
        const json = await response.json(); // Convert form data to JSON string
        return json
    } else {
        console.error('Failed to update override:', response, data);
        return 'Request failed with status:', response.status, response.statusText;
    }
}


async function removeOpsGenieOverride(data){
    const response = await fetch('/api/opsgenie/override/delete', {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json' // Send as JSON
        },
        body: JSON.stringify(data) // Convert form data to JSON string
    });
    if (response.ok) {
        // console.log('DEBUG', response.status, response.statusText, response, `${data.userName}`, `${data.result}`); // Ausgabe: "Record successfully removed"
        const json = await response.json(); // Convert form data to JSON string
        return json
    } else {
        console.error('Failed to delete override:', response, data);
        return 'Request failed with status:', response.status, response.statusText;
    }
}

/**
 * Sends data to a database using a POST request and returns the response status.
 * 
 * This asynchronous function performs a POST request to the specified API endpoint, 
 * sending the provided data as a JSON payload. If the request is successful, the HTTP 
 * status code is returned. Otherwise, an error message including the response status 
 * and status text is returned.
 *
 * @async
 * @param {string} url - The API endpoint URL where the data will be sent.
 * @param {Object} data - The data object to be sent to the server.
 * @returns {number|string} - The HTTP status code if the request is successful; otherwise, an error message.
 *
 * @example
 * const data = { name: "John", type: "Meeting", start: "2024-12-01", end: "2024-12-02" };
 * const status = await createDBData('/api/event/create', data);
 * if (status === 200) {
 *     console.log('Data successfully inserted into the database.');
 * } else {
 *     console.error('Failed to insert data:', status);
 * }
 */
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
        showAlert(`Fehler beim Erstellen des Events ${data.name}, ggf. OpsGenie prüfen - ${data.type}: ${response.status}, ${response.statusText}`);
    }
}

/**
 * Fetches data from a database via an API and returns the result as JSON.
 * 
 * This asynchronous function performs a GET request to the specified API endpoint,
 * retrieves the data, and converts it into a JSON object. If the request is successful,
 * the parsed JSON data is returned. If the request fails, an error message containing 
 * the response status and status text is returned.
 *
 * @async
 * @param {string} url - The API endpoint URL to fetch data from.
 * @returns {Object|string} - The JSON data if the request is successful; otherwise, an error message.
 *
 * @example
 * const data = await readDBData('/api/event/read');
 * if (typeof data === 'object') {
 *     console.log('Retrieved data:', data);
 * } else {
 *     console.error('Failed to fetch data:', data);
 * }
 */
async function readDBData(url) {
    const response = await fetch(url);
    if (response.ok) {
        const json = await response.json(); // Convert form data to JSON string
        return json
    } else {
        console.error('Failed to read event:', response);
        return 'Request failed with status:', response.status, response.statusText;
    }
}

async function updateDBData(url, event){
    try {
        // Sende UPDATE-Anfrage an die PowerShell API
        const response = await fetch(`${url}/${event.id}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(event)
        });

        // Überprüfe, ob die Anfrage erfolgreich war
        if (response.ok) {
            const responseData = await response.json();
            console.log('DEBUG', responseData.message); // Ausgabe: "Record successfully updated"
        } else {
            console.error('Failed to update event:', response, event);
            showAlert(`Fehler beim Aktualisieren des Events ${event.name}, ggf. OpsGenie prüfen! - ${event.type}: ${response.status}, ${response.statusText}`);
        }
    } catch (error) {
        console.error('Error occurred while updating event:', error);
        showAlert('Ein Fehler ist beim Aktualisieren des Events aufgetreten');
    }
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
async function deleteDBData(url, event){
    try {
        // Sende DELETE-Anfrage an die PowerShell API
        const response = await fetch(`${url}/${event.id}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        });

        // Überprüfe, ob die Anfrage erfolgreich war
        if (response.ok) {
            const responseData = await response.json();
            console.log('DEBUG', responseData.message, event); // Ausgabe: "Record successfully deleted"
            // Aktualisiere den Kalender oder die UI, nachdem der Record gelöscht wurde
            if(event.title.includes('Pikett') || event.title.includes('Ferien')){
                window.location.reload();
            }
        } else {
            console.error('Failed to delete event:', response, event);
            showAlert(`Fehler beim Löschen des Events ${event.name} - ${event.type}: ${response.status}, ${response.statusText}`);
        }
    } catch (error) {
        console.error('Error occurred while deleting event:', error);
        showAlert('Ein Fehler ist beim Löschen des Events aufgetreten');
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
        showAlert('Keine passenden Events gefunden.');
    }
}

/**
 * Setzt die Event-Daten in das Modal.
 *
 * @param {Object} event - Das Event-Objekt.
 */
function setModalEventData(event) {
    let swissHolidays = getSwissHolidays(event.start.getFullYear());
    const eventStartDate = formatDateToShortISOFormat(event.start);
    //const eventEndDate = formatDateToShortISOFormat(new Date(event.end.setDate(event.end.getDate() - 1))); // remove one day from the end-date
    const eventEndDate = formatDateToShortISOFormat(event.end); // remove one day from the end-date

    var days = 0;
    for (const [key, value] of Object.entries(event.extendedProps)) {
        if(value === 'Pikett'){
            days = calculatePikettkdays(event.start,event.end)
        }else{
            if(value === 'Feiertag'){
                days = calculateWorkdays(event.start, event.end, [])
            }else{
                days = calculateWorkdays(event.start, event.end, swissHolidays)
            }
        }
    };

    // const eventTitle = event.title.split(' - ');
    // document.getElementById('updateExportEventTitle').textContent = eventTitle[0];

    if(event.id){
        document.getElementById('singleEvent-id').textContent = `id: ${event.id}`;
    }else{
        document.getElementById('singleEvent-id').textContent = 'id: n/a, this event is form a file!';
    }
    document.getElementById('singleEvent-title').textContent = `${event.title}, ${days} Tage`;
    document.getElementById('singleEvent-date').textContent = `von: ${eventStartDate} bis: ${eventEndDate}`;
    
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
 * Refreshes the calendar by fetching updated event data.
 */
async function refreshCalendarData(calendar) {
    try {
        const holidays = await loadApiData('/api/csv/read');
        const events = await readDBData('/api/event/read/*');
        let calendarEvents = [];
        calendarEvents = [
            ...(holidays || []), // Feiertage (falls vorhanden)
            ...(Array.isArray(events) ? events : [events] || []) // User Events als Array
        ];
        calendar.removeAllEvents();
        calendar.addEventSource(calendarEvents);
        const button = document.querySelector('.fc-filterEvents-button');
        button.textContent = 'My Events';
    } catch (error) {
        console.error('Error refreshing calendar data:', error);
        showAlert('Ein Fehler ist beim Aktualisieren der Kalenderdaten aufgetreten.');
    }
}

/**
 * Extracts and validates data from an HTML form.
 * 
 * This function retrieves all form inputs using the FormData API,
 * converts them into a JavaScript object, and validates the presence 
 * of required fields (`name`, `type`, `start`, and `end`). If any 
 * required field is missing, the function logs an error and returns `null`.
 *
 * @param {HTMLFormElement} form - The form element to extract data from.
 * @returns {Object|null} - A JavaScript object containing the form data if all required fields are present, otherwise `null`.
 *
 * @example
 * const form = document.querySelector('#eventForm');
 * const formData = getFormData(form);
 * if (formData) {
 *     console.log('Valid form data:', formData);
 * } else {
 *     console.error('Invalid form data.');
 * }
 */
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

    // console.log('DEBUG', 'Formulardaten extrahiert:', data);
    return data;
}

/**
 * Retrieves the value of a specific cookie by name.
 * 
 * This function searches through the document's cookies, locates the cookie
 * with the specified name, and returns its value. If the cookie is not found,
 * the function returns `null`.
 *
 * @param {string} name - The name of the cookie to retrieve.
 * @returns {string|null} - The value of the cookie if found, otherwise `null`.
 *
 * @example
 * // Assuming a cookie 'username=JohnDoe' exists:
 * const username = getCookie('username');
 * console.log(username); // Output: 'JohnDoe'
 *
*/
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

/**
 * showAlert(`Welcome ${userCookie.name}`,'RotaMaster - Alert');
 * @param {*} title 
 * @param {*} message 
 */
function showAlert(message,title) {
    if(title){
        document.getElementById('alertTitle').innerText = title;
    }
    document.getElementById('alertText').innerText = message;
    var alertModal = new bootstrap.Modal(document.getElementById('alert'));
    alertModal.show();
}

/**
 * showConfirm(`Welcome ${userCookie.name}`,'RotaMaster - Message');
 * @param {*} title 
 * @param {*} message 
 * 
 * Beispiel für die Verwendung der showConfirm-Funktion
 * showConfirm('RotaMaster - Message','Möchten Sie fortfahren?').then((result) => {
 *  if (result) {
 *      console.log('Benutzer hat Ja gewählt');
 *      // Führen Sie die Aktion für Ja aus
 *  } else {
 *      console.log('Benutzer hat Nein gewählt');
 *      // Führen Sie die Aktion für Nein aus
 *  }
 * });
 */
async function showConfirm(message,title) {
    return new Promise((resolve) => {
        if(title){
            document.getElementById('confirmTitle').innerText = title;
        }
        document.getElementById('confirmText').innerText = message;
        var confirmModal = new bootstrap.Modal(document.getElementById('confirm'));

        document.getElementById('btnYes').onclick = function() {
            resolve(true);
            confirmModal.hide();
        };

        document.getElementById('btnNo').onclick = function() {
            resolve(false);
            confirmModal.hide();
        };

        confirmModal.show();
    });
}

/*
* Returns the date of Easter Sunday for a specific year.
* @param {number} year - The year for which to calculate Easter Sunday.
* @returns {Date} - The date of Easter Sunday in local time.
*/
function getEasterSunday(year) {
    // Algorithm by Carl Friedrich Gauss to calculate Easter Sunday
    const a = year % 19;
    const b = Math.floor(year / 100);
    const c = year % 100;
    const d = Math.floor(b / 4);
    const e = b % 4;
    const f = Math.floor((b + 8) / 25);
    const g = Math.floor((b - f + 1) / 3);
    const h = (19 * a + b - d - g + 15) % 30;
    const i = Math.floor(c / 4);
    const k = c % 4;
    const l = (32 + 2 * e + 2 * i - h - k) % 7;
    const m = Math.floor((a + 11 * h + 22 * l) / 451);
    const month = Math.floor((h + l - 7 * m + 114) / 31);
    const day = ((h + l - 7 * m + 114) % 31) + 1;

    return new Date(year, month - 1, day);
}

/*
* Returns a list of Swiss holidays for a specific year.
* @param {number} year - The year for which to calculate the holidays.
* @returns {Array} - An array of Swiss holidays in local ISO date format (YYYY-MM-DD).
*/
function getSwissHolidays(year) {
    if (year < 1970 || year > 2999) {
        throw new Error("Year must be between 1970 and 2999");
    }

    const easterSunday = getEasterSunday(year);
    const goodFriday = new Date(easterSunday);
    goodFriday.setDate(easterSunday.getDate() - 2);

    const easterMonday = new Date(easterSunday);
    easterMonday.setDate(easterSunday.getDate() + 1);

    const ascensionDay = new Date(easterSunday);
    ascensionDay.setDate(easterSunday.getDate() + 39);

    const pentecostSunday = new Date(easterSunday);
    pentecostSunday.setDate(easterSunday.getDate() + 49);

    const pentecostMonday = new Date(easterSunday);
    pentecostMonday.setDate(easterSunday.getDate() + 50);

    const holidays = [
        formatDateToLocalISO(new Date(year, 0, 1)),   // title: "Neujahrstag", canton: "ALL" },
        formatDateToLocalISO(new Date(year, 0, 2)),   // title: "Berchtoldstag", canton: "ALL" }
        formatDateToLocalISO(goodFriday),             // title: "Karfreitag", canton: "ALL" },
        formatDateToLocalISO(easterSunday),           // title: "Ostern", canton: "ALL" },
        formatDateToLocalISO(easterMonday),           // title: "Ostermontag", canton: "ALL" },
        formatDateToLocalISO(new Date(year, 4, 1)),   // title: "Tag der Arbeit (ZH, GR)", canton: "ZH, GR" },
        formatDateToLocalISO(ascensionDay),           // title: "Auffahrt", canton: "ALL" },
        formatDateToLocalISO(pentecostSunday),        // title: "Pfingsten", canton: "ALL" },
        formatDateToLocalISO(pentecostMonday),        // title: "Pfingstmontag", canton: "ALL" },
        formatDateToLocalISO(new Date(year, 7, 1)),   // title: "Bundesfeier", canton: "ALL" },
        formatDateToLocalISO(new Date(year, 10, 1)),  // title: "Allerheiligen (SG, BE)", canton: "SG, BE" },
        formatDateToLocalISO(new Date(year, 11, 25)), // title: "Weihnachtstag", canton: "ALL" },
        formatDateToLocalISO(new Date(year, 11, 26))  // title: "Stephanstag", canton: "ALL" }
    ];

    return holidays;
}

/*
* Formats a date object to a local ISO date string (YYYY-MM-DD).
* @param {Date} date - The date object to format.
* @returns {string} - The formatted date string in local ISO format.
*/
function formatDateToLocalISO(date) {
    const year = date.getFullYear();
    const month = String(date.getMonth() + 1).padStart(2, '0');
    const day = String(date.getDate()).padStart(2, '0');
    return `${year}-${month}-${day}`;
}