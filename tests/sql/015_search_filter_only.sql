-- search without a text query: the filtered listing is ordered by urn and capped at k, with score 1 / position
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, collection)
SELECT 'urn:nir:t015;1~art' || g, 'T', 'urn:nir:t015;1', g::text, 'p', 't' || g, 'x', DATE '2099-01-01', 'T015' FROM generate_series(1, 5) g;

WITH listing AS (
    SELECT urn, row_number() OVER (ORDER BY urn) AS pos FROM units WHERE collection = 'T015' ORDER BY urn LIMIT 3)
SELECT (SELECT array_agg(urn ORDER BY pos) FROM listing) = ARRAY['urn:nir:t015;1~art1', 'urn:nir:t015;1~art2', 'urn:nir:t015;1~art3']
   AND (SELECT round(sum(1.0 / pos), 6) FROM listing) = round(1.0 + 1.0 / 2 + 1.0 / 3, 6) AS ok
