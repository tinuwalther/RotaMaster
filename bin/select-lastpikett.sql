-- Active: 1734172081002@@127.0.0.1@3306
SELECT 
  e.person,
  e.type,
  e.start,
  e.end,
  p.login,
  p.email
FROM
  events e
  INNER JOIN person p ON (p.firstname || " " || p.name) = e.person
WHERE
  (p.firstname || " " || p.name) LIKE "%freddie mercury%" AND e.type = 'Pikett'
ORDER BY 
  e.start DESC
LIMIT 1;