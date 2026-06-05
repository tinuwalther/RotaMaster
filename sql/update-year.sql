-- This SQL Script update the Year for start and end
SELECT id,person,"type",start,end,created,author,alias,active,deleted FROM events;

-- Update the year for start
BEGIN TRANSACTION;

UPDATE events
SET
  start = REPLACE(start, '2024-', '2026-')
WHERE
  start LIKE '2024-%';

COMMIT;

-- Update the year for end
BEGIN TRANSACTION;

UPDATE events
SET
  end = REPLACE(end, '2024-', '2026-')
WHERE
  end LIKE '2024-%';

COMMIT;

-- Delete the event with id if its a 'Schaltjahr'
SELECT id,start,end FROM events
WHERE start LIKE '2026-02-29%' OR end LIKE '2026-02-29%';

DELETE FROM events
WHERE id = 77;

-- Update the start date by subtracting 2 days
BEGIN TRANSACTION;

UPDATE events
SET start = datetime(start, '-2 days')
WHERE start IS NOT NULL
  AND start <> '';

COMMIT;

-- Update the end date by subtracting 2 days
BEGIN TRANSACTION;

UPDATE events
SET end = datetime(end, '-2 days')
WHERE end IS NOT NULL
  AND end <> '';

COMMIT;
