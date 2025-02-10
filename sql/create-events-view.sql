-- Create the view for events
CREATE VIEW IF NOT EXISTS v_events
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

-- Create the view with calculated days of events
CREATE VIEW IF NOT EXISTS v_events_days
AS
SELECT 
  e.id,
  e.person,
  e.type,
  e.start,
  e.end,
  CASE 
    WHEN e.type = 'Pikett' THEN CAST((strftime('%s', e.end) - strftime('%s', e.start)) AS INTEGER) / 86400
    WHEN DATE(e.start) = DATE(e.end) AND (strftime('%H', e.end) - strftime('%H', e.start)) < 24 THEN 1
    WHEN DATE(e.start) != DATE(e.end) AND (strftime('%H', e.end) - strftime('%H', e.start)) < 24 THEN 
      CAST((strftime('%s', e.end) - strftime('%s', e.start)) AS INTEGER) / 86400 + 1
    ELSE 
      CAST((strftime('%s', e.end) - strftime('%s', e.start)) AS INTEGER) / 86400
  END AS days
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE e.active = 1
  AND CAST((strftime('%w', e.start) NOT IN (0, 6)) AS INTEGER)
  AND e.active = 1
ORDER BY
  e.id ASC;

-- Create the view for deleted events
CREATE VIEW IF NOT EXISTS v_events_deleted
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
