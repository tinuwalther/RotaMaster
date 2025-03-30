SELECT
    SUM(days) AS total_pikett_days
FROM
    (
        SELECT days FROM v_events_days
        WHERE person LIKE 'plant%'
        AND type = 'Pikett'
    ) subquery;


SELECT * FROM v_events_days;

SELECT person, COUNT(*) AS AssignmentCount FROM v_events_days GROUP BY person
