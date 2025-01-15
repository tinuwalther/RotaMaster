-- Create indexes
CREATE INDEX idx_events_person
ON events (person);

CREATE INDEX idx_events_type
ON events (type);

CREATE INDEX idx_person_login
ON person (login);

CREATE INDEX idx_absence_name
ON absence (name);