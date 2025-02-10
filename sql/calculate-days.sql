SELECT
    SUM(days) AS total_pikett_days
FROM
    (
        SELECT days FROM v_events_days
        WHERE person LIKE 'plant%'
        AND type = 'Pikett'
    ) subquery;
