# PSRotaMaster

Absence and Duty Planer for Teams built on Pode, based on Prompting ChatGPT. Maybee some features does not exists or does not work. I changed from Pode.web to Pode, because it's easier to implement JavaScript-code.

![PSRotaMasterIndex](./public/img/PSRotaMasterIndex.png)

## PS calendar view

![PSRotaMasterPSMonth](./public/img/PSRotaMasterPSMonth.png)

No more functionality yet!

## Full calendar view

Based on the [JavaScript Calendar](https://fullcalendar.io/)

In this calendar view, you can view the events of the current month, scroll to another month, and add new events.

To add new event, type the name of the person to serach for. The list of persons and the absence-types are stored in the server.psd1 in the root folder of the project. The Type of absence can be selected from the dropdown-field.

Each time the page is loaded, the system checks whether the file for the next year's holidays already exists. If the file does not yet exist, the public holidays in Switzerland are calculated for the cantons of Bern, Zurich, St. Gallen and Graubünden and the file is created with these values. You never have to worry about it again, the public holidays are simply there.

![PSRotaMasterIndex](./public/img/PSRotaMasterFull.png)

To show the whole year, click on the left button 'year', or if you prefere a list of the events of the current month, click on the right button 'list'.

![PSRotaMasterFullYear](./public/img/PSRotaMasterFullYear.png)

If you want to create the holidays for a different year, you can call the API with the desired year. 

For example with PowerShell: ````Invoke-WebRequest -Uri http://localhost:8080/api/year/new -Method Post -Body 2025````

## Year calendar view

![PSRotaMasterIndex](./public/img/PSRotaMasterYear.png)

No more functionality yet!

## Folders

The following folders are required by RotaMaster.

### bin

Contains the start-command/script.

### db

Contains the database.

### errors

Contains the default error page.

### logs

Contains the logs.

### pages

Contains the PowerShell-Pages for Pode.web to render the html-pages from.

### public

Contains the assets (bootstrap, css, js).

### upload

For uploaded files.

## JavaScript

[Year calendar examples](https://year-calendar.github.io/rc-year-calendar/examples)

[Bootstrap Year calendar](https://github.com/year-calendar/js-year-calendar?tab=readme-ov-file)

[Full Calendar](https://fullcalendar.io/docs)
