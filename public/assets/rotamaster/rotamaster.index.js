// Listener for the load event
window.addEventListener('load', () => {
    getNextYear('/api/year/new'); // Call the API once the page is fully loaded
});

let db;
let username = null; // contextMenu V5.5.5

window.addEventListener('resize', () => {
    const eventsSection = document.getElementById('showEvents');
    let space = 180;
    if (eventsSection.classList.contains('show')) space = 380;
    resizeCalendar(space);
});

// Listener for DOMContentLoaded event
document.addEventListener('DOMContentLoaded', async function() {
    
    // Load userCookie and display the username
    const userCookie = getCookie('CurrentUser');
    const eventView = userCookie.events || "all";
    const savedView = userCookie.savedView || "dayGridMonth";
        
    if (userCookie) {
        setCookie('CurrentUser', JSON.stringify(userCookie), 1);

        console.log(`Name: ${userCookie.name}, Login: ${userCookie.login}, Email: ${userCookie.email}`);
        try {
            username = userCookie.name;
            if (username) {
                const welcomeElement  = document.getElementById('currentUser');
                const languageElement = document.getElementById('language');
                if (welcomeElement) {
                    welcomeElement.textContent = `${username}`;
                    languageElement.textContent = `${navigator.language}`;
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
            fillDropdownOptions('nameDropdownPerson-contextMenu', personNames); // contextMenu V5.5.5
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
            fillDropdownOptions('nameDropdownAbsence-contextMenu', absenceNames); // contextMenu V5.5.5
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
        // get initialView from cookie
        initialView: userCookie.savedView,

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
                    let response = null;

                    if (isMyEvents.includes('My Events')) {
                        // Export events of the current user
                        response = await fetch(`/api/event/read/${username}`);
                        if (!response.ok) {
                            // throw new Error(`Failed to fetch user events of ${username}`);
                            response = await fetch('/api/event/read/*');
                            if (!response.ok) {
                                throw new Error('Failed to fetch user events of all users');
                            }
                            currentEvents = await response.json();
                            userCookie.events = "all";
                            button.textContent = 'My Events';
                        }
                        currentEvents = await response.json();
                        userCookie.events = "personal";
                        button.textContent = 'All Events';
                    }else if(isMyEvents.includes('All Events')) {
                        // Export events of all users
                        response = await fetch('/api/event/read/*');
                        if (!response.ok) {
                            throw new Error('Failed to fetch user events of all users');
                        }
                        currentEvents = await response.json();
                        userCookie.events = "all";
                        button.textContent = 'My Events';
                    }
                    setCookie('CurrentUser', JSON.stringify(userCookie), 1);

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
            
            userCookie.events = eventView;
            userCookie.savedView = info.view.type;
            setCookie('CurrentUser', JSON.stringify(userCookie), 1);
        
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
            if(userCookie.events === 'all'){
                document.querySelector('.fc-filterEvents-button').textContent = 'My Events';
            }else if(userCookie.events === 'personal'){
                document.querySelector('.fc-filterEvents-button').textContent = 'All Events';
            }
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
            // contextMenu V5.5.5
            document.getElementById('start-contextMenu').value = formattedStartDate;
            document.getElementById('end-contextMenu').value = formattedEndDate;

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
        // contextMenu V5.5.5
        finally {
            // Close the context menu modal
            const contextMenuModal = bootstrap.Modal.getOrCreateInstance(document.getElementById('contextMenu'));
            contextMenuModal.hide();
        }
    });

    // Synchronize the dropdown selection with the datalist input field
    eventListenerDropwodn('nameDropdownPerson','datalistName');

    document.getElementById('Loading').remove(); // Remove the loading spinner

    // Add an event listener to the logout link
    const logoutLink = document.getElementById('logoutLink');
    if (logoutLink) {
        logoutLink.addEventListener('click', function(event) {
            event.preventDefault(); // Prevent default form submission
            deleteCookie('CurrentUser'); // Delete the user cookie
            window.location.href = '/logout'; // Redirect to the logout page
        });
    }
});
