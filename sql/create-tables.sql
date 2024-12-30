-- Create the table events
CREATE TABLE IF NOT EXISTS events(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    person TEXT NOT NULL,
    type TEXT NOT NULL,
    start TEXT NOT NULL,
    end TEXT NOT NULL,
    alias TEXT,
    created TEXT NOT NULL DEFAULT current_timestamp,
    author TEXT NOT NULL
)

-- Create the table person
CREATE TABLE IF NOT EXISTS person(  
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    login TEXT NOT NULL,
    name TEXT NOT NULL,
    firstname TEXT NOT NULL,
    email TEXT NOT NULL,
    active INTEGER NOT NULL DEFAULT 1,
    workload INTEGER NOT NULL DEFAULT 100,
    created TEXT NOT NULL DEFAULT current_timestamp,
    author TEXT NOT NULL
);

-- Create the table absence
CREATE TABLE IF NOT EXISTS absence(  
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    created TEXT NOT NULL DEFAULT current_timestamp,
    author TEXT NOT NULL
);

-- Create the table configuration
CREATE TABLE IF NOT EXISTS config(  
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    opsgenie_apikey TEXT NOT NULL,
    opsgenie_schedname TEXT NOT NULL,
    opsgenie_rotaname TEXT NOT NULL,
    created TEXT NOT NULL DEFAULT current_timestamp,
    author TEXT NOT NULL
);