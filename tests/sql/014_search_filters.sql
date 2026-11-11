-- search filters: collection, act prefix (the tilde keeps act ;212 apart from act ;2122), article_num, version date range inclusive on both ends
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, collection) VALUES
 ('urn:nir:t014;212~art1', 'T', 'urn:nir:t014;212', '1', 'p', 'a', 'x', '2020-01-01', 'NORMATTIVA'),
 ('urn:nir:t014;212~art2', 'T', 'urn:nir:t014;212', '2', 'p', 'b', 'x', '2021-06-01', 'CODICI'),
 ('urn:nir:t014;212~art3', 'T', 'urn:nir:t014;212', '3', 'p', 'c', 'x', '2022-12-31', 'NORMATTIVA'),
 ('urn:nir:t014;2122~art1', 'T', 'urn:nir:t014;2122', '1', 'p', 'd', 'x', '2020-01-01', 'NORMATTIVA');

SELECT (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t014%' AND collection = 'CODICI') = ARRAY['urn:nir:t014;212~art2']
   AND (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t014%' AND urn LIKE 'urn:nir:t014;212' || '~%')
         = ARRAY['urn:nir:t014;212~art1', 'urn:nir:t014;212~art2', 'urn:nir:t014;212~art3']
   AND (SELECT count(*) FROM units WHERE urn LIKE 'urn:nir:t014%' AND article_num = '1') = 2
   AND (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t014;212~%' AND version_date >= DATE '2021-06-01')
         = ARRAY['urn:nir:t014;212~art2', 'urn:nir:t014;212~art3']
   AND (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t014;212~%' AND version_date <= DATE '2021-06-01')
         = ARRAY['urn:nir:t014;212~art1', 'urn:nir:t014;212~art2']
   AND (SELECT array_agg(urn) FROM units WHERE urn LIKE 'urn:nir:t014;212~%' AND version_date >= DATE '2021-06-01' AND version_date <= DATE '2021-06-01')
         = ARRAY['urn:nir:t014;212~art2'] AS ok
