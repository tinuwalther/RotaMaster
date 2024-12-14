-- Create the view for events with email
CREATE VIEW v_events
AS 
SELECT 
  e.id,
  e.person,
  e.type,
  e.start,
  e.end,
  p.login,
  p.firstname,
  p.name,
  p.email,
  e.created,
  e.author
FROM
  events e
  INNER JOIN person p ON (p.firstname || " " || p.name) = e.person
ORDER BY 
  e.id ASC;