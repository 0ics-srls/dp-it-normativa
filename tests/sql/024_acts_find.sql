-- acts_find: ILIKE on the act title, optional collection, one row per act with unit_count and the newest version date, ordered by act
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, collection) VALUES
 ('urn:nir:t024;1~art1', 'T024 Costituzione', 'urn:nir:t024;1', '1', 'p', 'a', 'x', '2020-01-01', 'T024C'),
 ('urn:nir:t024;1~art2', 'T024 Costituzione', 'urn:nir:t024;1', '2', 'p', 'b', 'x', '2022-05-05', 'T024C'),
 ('urn:nir:t024;2~art1', 'T024 Legge', 'urn:nir:t024;2', '1', 'p', 'c', 'x', '2021-01-01', 'T024N');

WITH found AS (
    SELECT act, min(act_urn) AS urn, count(*) AS unit_count, max(version_date) AS version, count(*) OVER () AS total
      FROM units WHERE act LIKE 'T024%' AND act ILIKE '%' || 'COSTITUZ' || '%' GROUP BY act),
     grouped AS (
    SELECT act, count(*) AS unit_count, max(version_date) AS version FROM units WHERE act LIKE 'T024%' AND collection = 'T024N' GROUP BY act)
SELECT (SELECT array_agg(act) FROM found) = ARRAY['T024 Costituzione']
   AND (SELECT unit_count FROM found) = 2
   AND (SELECT version FROM found) = DATE '2022-05-05'
   AND (SELECT urn FROM found) = 'urn:nir:t024;1'
   AND (SELECT array_agg(act) FROM grouped) = ARRAY['T024 Legge'] AS ok
