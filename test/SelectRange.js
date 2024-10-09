select: function(info) {
    const eventTitle = prompt('Gib die Person und das Event, siehe Events links, für die gewählte Zeit ein (Format: Person - Event):', 'Tinu - Ferien');

    if (eventTitle) {

        const eventStartDate = new Date(info.startStr);
        const eventEndDate = new Date(info.endStr);
        const [personName, eventType] = eventTitle.split(' - ');

        if (!personName || !eventType) {
            alert('Fehler: Bitte den Event-Titel im Format "Person - Event" eingeben.');
            return;
        }

        document.getElementById('name').value = personName;
        document.getElementById('type').value = eventType;
        /*
        Funktioniert (noch) nicht
        document.getElementById('start').value = eventStartDate;
        document.getElementById('end').value = eventEndDate;
        */

        // Event-Daten erstellen
        const eventData = {
            request: 'select',
            name: personName,
            type: eventType,
            start: eventStartDate,
            end: eventEndDate
        };
        //console.log('Event-Data: ' + eventData.name + ', ' + eventData.type + ', ' + eventData.start + ', ' + eventData.end);

        // API-Request senden
        fetch('/api/event/new', {
        method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify(eventData)
        })
        .then(response => {
            // Prüfen, ob die Antwort erfolgreich war
            if (!response.ok) {
                throw new Error('Fehler beim Erstellen des Events: ${response.status} ${response.statusText}');
            }
            // Versuche, die Antwort als JSON zu lesen, wenn Inhalt vorhanden ist
            return response.text().then(text => {
                return text ? JSON.parse(text) : {};
            });
        })
        .then(data => {
            // Falls ein JSON-Objekt zurückgegeben wird, anzeigen
            if (data) {
                //alert('Event erfolgreich erstellt.');
                window.location.reload(); // Reload the page to show updated data
            }
        })
        .catch(error => {
            console.error('Es gab ein Problem mit der Anfrage:', error);
            alert('Fehler beim Erstellen des Events');
        });
    } else {
        //alert('Event-Erstellung wurde abgebrochen, kein Event erstellt.');
    }

}