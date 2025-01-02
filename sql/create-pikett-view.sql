-- Create the view for pikett with email
CREATE VIEW v_pikett
AS 
SELECT 
  e.person,
  e.type,
  e.start,
  e.end,
  p.login,
  p.email
FROM
  events e
  INNER JOIN person p ON (p.name || ' ' || p.firstname) = e.person
WHERE
  e.type = 'Pikett'
ORDER BY 
  e.start ASC;