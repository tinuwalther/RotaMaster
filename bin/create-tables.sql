-- Create the table events
CREATE TABLE IF NOT EXISTS events(
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    person TEXT NOT NULL,
    type TEXT NOT NULL,
    start TEXT NOT NULL,
    end TEXT NOT NULL,
    created TEXT NOT NULL
)

-- Create the table person
CREATE TABLE IF NOT EXISTS person(  
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    firstname TEXT NOT NULL
);

-- Create the table absence
CREATE TABLE IF NOT EXISTS absence(  
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL
);