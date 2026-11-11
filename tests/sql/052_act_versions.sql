-- act_versions: version starts of the units of one act (the tilde prefix keeps other acts out), with the number of units that start there
INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES
 ('urn:nir:t052;1~art1', '2000-07-31', '2010-01-01', 'a'), ('urn:nir:t052;1~art1', '2010-01-01', NULL, 'b'),
 ('urn:nir:t052;1~art2', '2000-07-31', NULL, 'a'),
 ('urn:nir:t052;12~art1', '2015-05-05', NULL, 'altro');

WITH timeline AS (
    SELECT v.valid_from, count(*) AS units_changed
      FROM unit_versions v WHERE starts_with(v.urn, 'urn:nir:t052;1' || '~') GROUP BY v.valid_from)
SELECT (SELECT array_agg(valid_from ORDER BY valid_from) FROM timeline) = ARRAY[DATE '2000-07-31', DATE '2010-01-01']
   AND (SELECT array_agg(units_changed ORDER BY valid_from) FROM timeline) = ARRAY[2::bigint, 1::bigint] AS ok
