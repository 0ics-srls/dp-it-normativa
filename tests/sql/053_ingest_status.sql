-- ingest_status: per collection the acts, the units, the units without embedding and the newest ingest time
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, collection, embedding) VALUES
 ('urn:nir:t053;1~art1', 'T', 'urn:nir:t053;1', '1', 'p', 'a', 'x', '2099-01-01', 'T053', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('urn:nir:t053;1~art2', 'T', 'urn:nir:t053;1', '2', 'p', 'b', 'x', '2099-01-01', 'T053', NULL),
 ('urn:nir:t053;2~art1', 'T', 'urn:nir:t053;2', '1', 'p', 'c', 'x', '2099-01-01', 'T053', NULL);
INSERT INTO acts (act_urn, title, kind, collection, versions_count, units_count, ingested_at) VALUES
 ('urn:nir:t053;1', 'T1', 'normattiva', 'T053', 1, 2, TIMESTAMPTZ '2099-03-01 10:00:00+00'),
 ('urn:nir:t053;2', 'T2', 'normattiva', 'T053', 1, 1, TIMESTAMPTZ '2099-02-01 10:00:00+00');

WITH status AS (
    SELECT u.collection, count(DISTINCT u.act_urn) AS acts, count(*) AS units, count(*) FILTER (WHERE u.embedding IS NULL) AS units_without_embedding,
           (SELECT max(a.ingested_at) FROM acts a WHERE a.collection = u.collection) AS last_ingested_at
      FROM units u WHERE u.collection = 'T053' GROUP BY u.collection)
SELECT (SELECT acts FROM status) = 2 AND (SELECT units FROM status) = 3 AND (SELECT units_without_embedding FROM status) = 2
   AND (SELECT last_ingested_at FROM status) = TIMESTAMPTZ '2099-03-01 10:00:00+00' AS ok
