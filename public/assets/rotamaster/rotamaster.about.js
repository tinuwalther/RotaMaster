// Wait until the DOM is fully loaded
document.addEventListener('DOMContentLoaded', async () => {
    // Add the App-Version and App-Prefix to the Navbar-Brand
    const pageTitle = `${calendarConfig.appPrefix}RotaMaster V${calendarConfig.appVersion.substring(0,1)}`;
    const navbarBrandElement = document.getElementById('navbarBrand');
    if (navbarBrandElement) {
        navbarBrandElement.textContent = pageTitle;
    };

    // Set the title of the page
    document.getElementById('title').textContent = `${pageTitle} - About`;
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
    
    // Set appVersion from calendarConfig
    if (typeof calendarConfig !== 'undefined' && calendarConfig.appVersion) {
        document.getElementById('appVersion').textContent = `${calendarConfig.appVersion}`;
    } else {
        document.getElementById('appVersion').textContent = "Unknown";
    }

    // Fetch FullCalendar version from the minified JS file
    try {
        const response = await fetch('/assets/fullcalendar/index.global.min.js');
        if (response.ok) {
            const jsContent = await response.text();
            const versionMatch = jsContent.match(/\/\*!\s*FullCalendar.+v([\d.]+)/);
            // console.log('DEBUG', versionMatch);
            if (versionMatch && versionMatch[1]) {
                document.getElementById('fcVersion').textContent = `${versionMatch[1]}`;
            } else {
                document.getElementById('fcVersion').textContent = "Unknown";
            }
        } else {
            console.error('Failed to fetch FullCalendar JS file:', response.status);
            document.getElementById('fcVersion').textContent = "Error fetching version";
        }
    } catch (error) {
        console.error('Error reading FullCalendar version:', error);
        document.getElementById('fcVersion').textContent = "Error";
    }

    // Fetch Bootstrap version from the minified JS file
    try {
        const response = await fetch('/assets/bootstrap/bootstrap.bundle.min.js');
        // console.error('DEBUG: Response Status:', response.status);
        if (response.ok) {
            const jsContent = await response.text();
            // console.log('DEBUG: Bootstrap JS Content:', jsContent.slice(0, 500)); // Zeigt die ersten 500 Zeichen der Datei
            // RegEx für Bootstrap-Version
            const versionMatch = jsContent.match(/\/\*![^]*?Bootstrap v([\d.]+)/);
            // console.log('DEBUG', versionMatch);
            if (versionMatch && versionMatch[1]) {
                document.getElementById('bsVersion').textContent = `${versionMatch[1]}`;
            }else{
                document.getElementById('bsVersion').textContent = "Unknown";
            }
        } else {
            document.getElementById('bsVersion').textContent = "Error fetching version";
            console.error('Failed to fetch Bootstrap JS file:', response.status);
        }
    } catch (error) {
        console.error('Error reading Bootstrap version:', error);
        document.getElementById('bsVersion').textContent = "Error";
    }

    // Fetch OpsGenie integration
    try{
        const integration = calendarConfig.opsGenie
        const schedule = calendarConfig.scheduleName
        const rotation = calendarConfig.rotationName
        if(integration){
            document.getElementById('opsGenieIntegration').textContent = "OpsGenie is integrated";
            document.getElementById('opsGenieSchedule').textContent = schedule;
            document.getElementById('opsGenieRotation').textContent = rotation;
        }else{
            document.getElementById('opsGenieIntegration').textContent = "OpsGenie is not integrated";
            document.getElementById('opsGenieSchedule').textContent = "not integrated";
            document.getElementById('opsGenieRotation').textContent = "not integrated";
        }
    } catch (error) {
        console.error('Error reading OpsGenie integration:', error);
        document.getElementById('bsVersion').textContent = "Error";
    }

    // Fetch psModules
    try{
        calendarConfig.psModules.map(module => {
            if(module.moduleName === "Pode"){
                document.getElementById('podeVersion').textContent = module.moduleVersion;
            }
            if(module.moduleName === "PSSQLite"){
                document.getElementById('psSqliteVersion').textContent = module.moduleVersion;
            }
        });

    } catch (error) {
        console.error('Error reading PowerShell Modules:', error);
        document.getElementById('podeVersion').textContent = "Error reading PowerShell Modules";
        document.getElementById('psSqliteVersion').textContent = "Error reading PowerShell Modules";
    }    
});
