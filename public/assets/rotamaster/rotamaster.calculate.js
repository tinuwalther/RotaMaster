// Wait until the DOM is fully loaded
document.addEventListener('DOMContentLoaded', async () => {
    // Add the App-Version and App-Prefix to the Navbar-Brand
    const pageTitle = `${calendarConfig.appPrefix}RotaMaster V${calendarConfig.appVersion.substring(0,1)}`;
    const navbarBrandElement = document.getElementById('navbarBrand');
    if (navbarBrandElement) {
        navbarBrandElement.textContent = pageTitle;
    };

    // Set the title of the page
    document.getElementById('title').textContent = `${pageTitle} - Calculate`;
    document.getElementById('alertTitle').textContent = `${pageTitle} - Alert!`;
    document.getElementById('confirmTitle').textContent = `${pageTitle} - Confirm?`;

    const userCookie = getCookie('CurrentUser');
    let username = null;
    if (userCookie) {
        console.log(`Name: ${userCookie.name}, Login: ${userCookie.login}, Email: ${userCookie.email}`);
        try {
            username = userCookie.name;
            if (username) {
                const welcomeElement  = document.getElementById('currentUser');
                const languageElement = document.getElementById('language');
                if (welcomeElement) {
                    welcomeElement.textContent = `${username}`;
                    languageElement.textContent = `${navigator.language}`;
                } else {
                    console.error("Element with ID 'welcomeMessage' not found.");
                }
            }else{
                showAlert("No username found!");
            }
        } catch (error) {
            showAlert("There is something wrong with the userCookie!");
            console.log("There is something wrong with the userCookie!" + error);
        }
    }else{
        console.log('User cookie not found or invalid');
        showAlert('User cookie not found or invalid');
    }
    
    // Generische Funktion zur Berechnung der Zeitdifferenz
    function calculateTimeDifference(suffix) {
        const startTime = document.getElementById(`startTime${suffix}`).value;
        const endTime = document.getElementById(`endTime${suffix}`).value;
        const breakMinutes = parseInt(document.getElementById(`breakTime${suffix}`).value) || 0;
        
        if (!startTime || !endTime) {
            document.getElementById(`totalTime${suffix}`).value = '';
            document.getElementById(`decimalTime${suffix}`).value = '';
            return 0; // Rückgabe 0 Minuten für Gesamtberechnung
        }
        
        // Parse Zeiten
        const [startHours, startMinutes] = startTime.split(':').map(Number);
        const [endHours, endMinutes] = endTime.split(':').map(Number);
        
        // Konvertiere zu Minuten
        const startTotalMinutes = startHours * 60 + startMinutes;
        let endTotalMinutes = endHours * 60 + endMinutes;
        
        // Wenn Endzeit vor Startzeit, addiere 24 Stunden
        if (endTotalMinutes < startTotalMinutes) {
            endTotalMinutes += 24 * 60;
        }
        
        // Berechne Differenz minus Pause
        const diffMinutes = endTotalMinutes - startTotalMinutes - breakMinutes;
        
        // Konvertiere zurück zu hh:mm
        const hours = Math.floor(diffMinutes / 60);
        const minutes = diffMinutes % 60;
        
        document.getElementById(`totalTime${suffix}`).value = 
            `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;

        // Berechne Dezimalstunden
        const decimalHours = (diffMinutes / 60).toFixed(2);
        document.getElementById(`decimalTime${suffix}`).value = `${decimalHours} h`;
        
        return diffMinutes; // Rückgabe für Gesamtberechnung
    }

    // Berechne Gesamtzeit (AM + PM)
    function calculateTotal() {
        const minutesAM = calculateTimeDifference('AM');
        const minutesPM = calculateTimeDifference('PM');
        
        const totalMinutes = minutesAM + minutesPM;
        
        if (totalMinutes === 0) {
            document.getElementById('totalTimeTotal').value = '';
            document.getElementById('decimalTimeTotal').value = '';
            return;
        }
        
        // Konvertiere zurück zu hh:mm
        const hours = Math.floor(totalMinutes / 60);
        const minutes = totalMinutes % 60;
        
        document.getElementById('totalTimeTotal').value = 
            `${String(hours).padStart(2, '0')}:${String(minutes).padStart(2, '0')}`;
        
        // Berechne Dezimalstunden
        const decimalHours = (totalMinutes / 60).toFixed(2);
        document.getElementById('decimalTimeTotal').value = `${decimalHours} h`;
    }

    // Event Listener für Vormittag (AM)
    const startTimeAM = document.getElementById('startTimeAM');
    const endTimeAM = document.getElementById('endTimeAM');
    const breakTimeAM = document.getElementById('breakTimeAM');

    if (startTimeAM && endTimeAM && breakTimeAM) {
        startTimeAM.addEventListener('change', calculateTotal);
        endTimeAM.addEventListener('change', calculateTotal);
        breakTimeAM.addEventListener('input', calculateTotal);
    } else {
        console.error('Vormittag-Zeitfelder nicht gefunden im DOM');
    }

    // Event Listener für Nachmittag (PM)
    const startTimePM = document.getElementById('startTimePM');
    const endTimePM = document.getElementById('endTimePM');
    const breakTimePM = document.getElementById('breakTimePM');

    if (startTimePM && endTimePM && breakTimePM) {
        startTimePM.addEventListener('change', calculateTotal);
        endTimePM.addEventListener('change', calculateTotal);
        breakTimePM.addEventListener('input', calculateTotal);
    } else {
        console.error('Nachmittag-Zeitfelder nicht gefunden im DOM');
    }

});