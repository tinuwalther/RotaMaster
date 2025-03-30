document.addEventListener('DOMContentLoaded', async function() {
    // Add the App-Version and App-Prefix to the Navbar-Brand
    const pageTitle = `${calendarConfig.appPrefix}RotaMaster V${calendarConfig.appVersion.substring(0,1)}`;
    const navbarBrandElement = document.getElementById('navbarBrand');
    if (navbarBrandElement) {
        navbarBrandElement.textContent = pageTitle;
    };

    // Set the title of the page
    document.getElementById('title').textContent = `${pageTitle} - Absence`;
    document.getElementById('alertTitle').textContent = `${pageTitle} - Alert!`;
    document.getElementById('confirmTitle').textContent = `${pageTitle} - Confirm?`;

    const userCookie = getCookie('CurrentUser');
    let username = null;
    if (userCookie) {
        // console.log(`Name: ${userCookie.name}`);
        // console.log(`Login: ${userCookie.login}`);
        // console.log(`Email: ${userCookie.email}`);
        try {
            username = userCookie.name;
            if (username) {
                const welcomeElement = document.getElementById('currentUser');
                if (welcomeElement) {
                    welcomeElement.textContent = `${username}`;
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
    
    // Absence laden und Tabelle füllen
    readAbsences();

    // Formular zum Hinzufügen einer neuen Absence
    const absenceForm = document.getElementById('absenceForm');
    absenceForm.addEventListener('submit', async function(event) {
        event.preventDefault(); // Standardformular absenden verhindern

        const absenceId = document.querySelector('#absenceId').value;
        const submit = document.querySelector('#submit').value;

        // Formulardaten erfassen
        const formData = new FormData(absenceForm);
        const data = {};
        formData.forEach((value, key) => {
            data[key] = value;
        });

        let response;
        if(absenceId){
            // Update existing absence
            try {
                response = await fetch(`/api/absence/update/${absenceId}`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                });
                console.log('Absence updated:', response);
                document.querySelector('#submit').textContent = 'Add Absence';
            } catch (error) {
                console.error('Error occurred:', error);
                showAlert(`An error occurred while adding the absence ${error}`);
            }
        }else{
            // Add new absence
            try {
                document.querySelector('#submit').textContent = 'Add Absence';
                response = await fetch('/api/absence/create', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                });
            } catch (error) {
                console.error('Error occurred:', error);
                showAlert('An error occurred while adding the absence.');
            }
        }
        if (response.ok) {
            absenceForm.reset();
            readAbsences(); // Tabelle neu laden
        } else {
            console.error('Error adding absence:', response.status);
            showAlert('Failed to add absence.');
        }
    });
});

// Funktion zum Laden der Absence und Befüllen der Tabelle
async function readAbsences() {
    try {
        const response = await fetch('/api/absence/read/*');
        if (!response.ok) {
            throw new Error('Failed to fetch absence');
        }
        const absences = await response.json();    

        let absenceData = [];
        absenceData = [
            ...(Array.isArray(absences) ? absences : [absences] || []) // User Events as Array
        ];

        const absenceTableBody = document.querySelector('#absenceTable tbody');
        absenceTableBody.innerHTML = ''; // Bestehende Tabellenzeilen löschen

        absenceData.forEach(absence => {
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${absence.name}</td>
                <td>${absence.created}</td>
                <td>
                    <button class="btn btn-dark btn-sm" onclick="updateAbsence(${absence.id}, '${absence.name}')">Update</button>
                    <button class="btn btn-danger btn-sm" onclick="deleteAbsence(${absence.id}, '${absence.name}')">Delete</button>
                </td>
            `;
            absenceTableBody.appendChild(row);
        });
    } catch (error) {
        showAlert(`Fehler beim Lesen der Daten aus der Tabelle absence:\n${error}`);
        console.error('Error fetching absences:', error);
    }
}

// Funktion zum Löschen einer Absenz
async function deleteAbsence(absenceId, name) {
    const message = `Are you sure you want to delete "${name}"?`;
    const result = await showConfirm(message);
    if (result) {
        try {
            const response = await fetch(`/api/absence/delete/${absenceId}`, {
                method: 'DELETE'
            });
            if (response.ok) {
                readAbsences(); // Tabelle neu laden
            } else {
                console.error('Error deleting absence:', response.status);
                showAlert('Failed to delete absence.');
            }
        } catch (error) {
            console.error('Error occurred:', error);
            showAlert('An error occurred while deleting the absence.');
        }
    }
}

// Function to update an absence
async function updateAbsence(absenceId, name) {
    try {
        const response = await fetch(`/api/absence/read/${absenceId}`);
        if (!response.ok) {
            throw new Error('Failed to fetch absence data');
        }

        const absence = await response.json();

        if (!absence) {
            throw new Error('Absence data is null');
        }

        // Load the absence data into the input fields
        document.querySelector('#absenceId').value = absence.id;
        document.querySelector('#name').value = absence.name;

        document.querySelector('#submit').textContent = 'Update absence';
    } catch (error) {
        showAlert(`Error fetching absence data`);
        console.error('Error fetching absence data:', error);
    }
}
