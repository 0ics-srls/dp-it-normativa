-- search degraded: no query vector (the Host bound NULL) switches the semantic list off; the lexical list alone is returned and nothing raises
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, embedding) VALUES
 ('urn:nir:t016;1~art1', 'T', 'urn:nir:t016;1', '1', 'p', 'La licenza edilizia è rilasciata.', 'x', '2099-01-01', NULL),
 ('urn:nir:t016;1~art2', 'T', 'urn:nir:t016;1', '2', 'p', 'La sanzione è applicata.', 'x', '2099-01-01', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH prm AS (SELECT CAST(NULL AS text) AS q_vec),
     sem AS (
         SELECT u.urn FROM units u, prm
          WHERE u.urn LIKE 'urn:nir:t016;1~%' AND CAST(prm.q_vec AS vector) IS NOT NULL AND u.embedding IS NOT NULL
          ORDER BY u.embedding <=> CAST(prm.q_vec AS vector) LIMIT 10),
     lex AS (SELECT urn FROM units WHERE urn LIKE 'urn:nir:t016;1~%' AND search_vector @@ websearch_to_tsquery('italian', 'licenza'))
SELECT (SELECT count(*) FROM sem) = 0
   AND (SELECT array_agg(urn) FROM lex) = ARRAY['urn:nir:t016;1~art1'] AS ok
