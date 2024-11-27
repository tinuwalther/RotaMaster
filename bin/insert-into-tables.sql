-- Inser some absences
INSERT INTO 'absence' ('name') VALUES
    ('Blockiert'),
    ('Ferien'),
    ('bez. Absenz'),
    ('unbz. Urlaub'),
    ('GLZ Kompensation'),
    ('Aus/Weiterbildung'),
    ('Militär/ZV/EO'),
    ('Krankheit'),
    ('Unfall'),
    ('Pikett'),
    ('Pikett-Peer');

-- Insert some person
INSERT INTO 'person' ('login','firstname','name','author') VALUES
    ('fmercury','Freddie','Mercury','Administrator'),
    ('oosbourne','Ozzy','Osbourne','Administrator'),
    ('rplant','Robert','Plant','Administrator'),
    ('kcobain','Kurt','Cobain','Administrator'),
    ('acooper','Alice','Cooper','Administrator'),
    ('rjdio','Ronnie James','Dio','Administrator'),
    ('bdickinso','Bruce','Dickinson','Administrator'),
    ('tlindeman','Till','Lindemann','Administrator'),
    ('mmanson','Marilyn','Manson','Administrator'),
    ('jmorrison','Jim','Morrison','Administrator');