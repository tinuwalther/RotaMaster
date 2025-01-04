# CHANGELOG

## 2024-12-30

### 1. OpsGenie integration

Adding the OpsGenie integration with add and remove override. To remove the override, the events table requires a column for the OpsGenie override alias.

New structure in table events:

````sql
-- Add column alias
ALTER TABLE events 
  ADD alias TEXT;
````

and in view v_events:

````sql
-- Delete View v_events
DROP VIEW v_events;
````

````sql
-- Create the view for events with alias
CREATE VIEW v_events
AS 
SELECT 
  e.id,
  e.person,
  e.type,
  e.start,
  e.end,
  e.alias,
  p.login,
  p.firstname,
  p.name,
  p.email,
  e.created,
  e.author
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE e.active = 1
ORDER BY 
  e.id ASC;
````

### 2. Mark deleted events

Adding a column for deleted records instead to remove the record.

New structure in table events:

````sql
-- Add column active
ALTER TABLE events 
  ADD active INTEGER NOT NULL 
  DEFAULT 1;
````

````sql
-- Add column deleted
ALTER TABLE events 
  ADD deleted TEXT;
````

and create a new view v_events_deleted:

````sql  
-- Create the view for deleted events
CREATE VIEW v_events_deleted
AS 
SELECT 
  e.id,
  e.person,
  e.type,
  e.start,
  e.end,
  e.alias,
  p.login,
  p.firstname,
  p.name,
  p.email,
  e.created,
  e.deleted,
  e.author
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE e.active = 0
ORDER BY 
  e.id ASC;
````

### 3. Re-create View for Pikett

Re-create the View for Pikett.

````sql
DROP VIEW v_pikett;
````

````sql
-- Create the view for pikett
CREATE VIEW v_pikett
AS 
SELECT 
  e.person,
  e.type,
  e.alias,
  e.start,
  e.end,
  e.deleted,
  p.login,
  p.email
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE
  e.type = 'Pikett'
ORDER BY 
  e.start ASC;
````
