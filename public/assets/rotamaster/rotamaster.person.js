document.addEventListener('DOMContentLoaded', async function() {
    // Add the App-Version and App-Prefix to the Navbar-Brand
    const pageTitle = `${calendarConfig.appPrefix}RotaMaster V${calendarConfig.appVersion.substring(0,1)}`;
    const navbarBrandElement = document.getElementById('navbarBrand');
    if (navbarBrandElement) {
        navbarBrandElement.textContent = pageTitle;
    };

    // Set the title of the page
    document.getElementById('title').textContent = `${pageTitle} - Person`;
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
    
    // Personen laden und Tabelle füllen
    readPersons();

    // Formular zum Hinzufügen einer neuen Person
    const personForm = document.getElementById('personForm');
    personForm.addEventListener('submit', async function(event) {
        event.preventDefault(); // Standardformular absenden verhindern

        const personId = document.querySelector('#personId').value;
        const submit = document.querySelector('#submit').value;

        const formData = new FormData(personForm);
        const data = {};
        formData.forEach((value, key) => {
            data[key] = value;
        });

        // Formulardaten erfassen
        let response;
        if(personId){
            // Update existing person
            try {
                // console.log('PersonId:', personId, data);
                response = await fetch(`/api/person/update/${personId}`, {
                    method: 'PUT',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                });
                console.log('Person updated:', response);
                document.querySelector('#submit').textContent = 'Add Person';
            } catch (error) {
                console.error('Error occurred:', error);
                showAlert(`n error occurred while adding the person ${error}`);
            }
        }else{
            // Add new person
            try {
                document.querySelector('#submit').textContent = 'Add Person';
                response = await fetch('/api/person/create', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify(data)
                });
            } catch (error) {
                console.error('Error occurred:', error);
                showAlert(`n error occurred while adding the person ${error}`);
            }
        }
        if (response.ok) {
            personForm.reset();
            readPersons(); // Tabelle neu laden
        } else {
            console.error('Error adding person:', response.status);
            showAlert(`Failed to add person ${formData.get('login')}`);
        }
    });
});

// Funktion zum Laden der Personen und Befüllen der Tabelle
async function readPersons() {
    try {
        const response = await fetch('/api/person/read/*');
        if (!response.ok) {
            throw new Error('Failed to fetch persons');
        }
        const persons = await response.json();

        let personData = [];
        personData = [
            ...(Array.isArray(persons) ? persons : [persons] || []) // User Events as Array
        ];

        const personTableBody = document.querySelector('#personTable tbody');
        personTableBody.innerHTML = ''; // Bestehende Tabellenzeilen löschen

        personData.forEach(person => {
            // console.log(person);
            const row = document.createElement('tr');
            row.innerHTML = `
                <td>${person.login}</td>
                <td>${person.firstname}</td>
                <td>${person.name}</td>
                <td>${person.email}</td>
                <td>${person.topic}</td>
                <td>${person.active}</td>
                <td>${person.workload}</td>
                <td>${person.created}</td>
                <td>
                    <button class="btn btn-dark btn-sm" onclick="updatePerson(${person.id}, '${person.login}')">Update</button>
                    <button class="btn btn-danger btn-sm" onclick="deletePerson(${person.id}, '${person.login}')">Delete</button>
                </td>
            `;
            personTableBody.appendChild(row);
        });
    } catch (error) {
        showAlert(`Fehler beim Lesen der Daten aus der Tabelle person:\n${error}`);
        console.error('Error fetching persons:', error);
    }
}

// Funktion zum Löschen einer Person
async function deletePerson(personId, login) {
    const message = `Are you sure you want to delete "${login}"?`;
    const result = await showConfirm(message);
    if (result) {
        try {
            const response = await fetch(`/api/person/delete/${personId}`, {
                method: 'DELETE'
            });
            if (response.ok) {
                readPersons(); // Tabelle neu laden
            } else {
                console.error('Error deleting person:', response.status);
                alert('Failed to delete person.');
            }
        } catch (error) {
            console.error('Error occurred:', error);
            showAlert(`An error occurred while deleting the person ${login}`);
        }
    }
}

// Function to update a person
async function updatePerson(personId, login) {
    try {
        const response = await fetch(`/api/person/read/${personId}`);
        if (!response.ok) {
            throw new Error('Failed to fetch person data');
        }

        const person = await response.json();

        if (!person) {
            throw new Error('Person data is null');
        }

        // Load the person data into the input fields
        document.querySelector('#personId').value = person.id;
        document.querySelector('#login').value = person.login;
        document.querySelector('#firstname').value = person.firstname;
        document.querySelector('#name').value = person.name;
        document.querySelector('#email').value = person.email;
        document.querySelector('#topic').value = person.topic;
        document.querySelector('#active').value = person.active;
        document.querySelector('#workload').value = person.workload;

        document.querySelector('#submit').textContent = 'Update Person';
    } catch (error) {
        showAlert(`Error fetching person data`);
        console.error('Error fetching person data:', error);
    }
}
