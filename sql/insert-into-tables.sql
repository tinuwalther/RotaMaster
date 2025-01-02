-- Inser some absences
INSERT INTO 'absence' ('name','author') VALUES
    ('Blockiert','Administrator'),
    ('Ferien','Administrator'),
    ('bez. Absenz','Administrator'),
    ('unbz. Urlaub','Administrator'),
    ('GLZ Kompensation','Administrator'),
    ('Aus/Weiterbildung','Administrator'),
    ('Militär/ZV/EO','Administrator'),
    ('Krankheit','Administrator'),
    ('Unfall','Administrator'),
    ('Pikett','Administrator'),
    ('Pikett-Peer','Administrator');

-- Insert some person
INSERT INTO 'person' ('login','firstname','name','email','author') VALUES
    ('fmercury','Freddie','Mercury',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('oosbourne','Ozzy','Osbourne',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('rplant','Robert','Plant',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('kcobain','Kurt','Cobain',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('acooper','Alice','Cooper',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('rjdio','Ronnie James','Dio',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('bdickinso','Bruce','Dickinson',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('tlindeman','Till','Lindemann',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('mmanson','Marilyn','Manson',LOWER(firstname || '.' || name || '@company.com'),'Administrator'),
    ('jmorrison','Jim','Morrison',LOWER(firstname || '.' || name || '@company.com'),'Administrator');