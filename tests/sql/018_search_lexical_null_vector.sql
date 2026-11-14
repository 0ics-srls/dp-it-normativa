-- search mode lexical: the Host skips the query embedding (x-embed.skipWhen) and binds q_vec NULL; the lexical rows are exactly those of a call that had a vector
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, embedding) VALUES
 ('urn:nir:t018;1~art1', 'T', 'urn:nir:t018;1', '1', 'p', 'La licenza edilizia è rilasciata dal comune.', 'x', '2099-01-01', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('urn:nir:t018;1~art2', 'T', 'urn:nir:t018;1', '2', 'p', 'Il permesso sostituisce la licenza edilizia.', 'x', '2099-01-01', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('urn:nir:t018;1~art3', 'T', 'urn:nir:t018;1', '3', 'p', 'La sanzione è applicata dal prefetto.', 'x', '2099-01-01', (ARRAY[1, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));

WITH calls AS (
    SELECT 'with_vector' AS name, 'lexical' AS mode, CAST((ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024) AS text) AS q_vec
    UNION ALL
    SELECT 'null_vector', 'lexical', CAST(NULL AS text)
),
result AS (
    SELECT c.name,
           (SELECT array_agg(f.urn ORDER BY f.rn)
              FROM (SELECT u.urn, row_number() OVER (ORDER BY ts_rank_cd(u.search_vector, websearch_to_tsquery('italian', 'licenza edilizia')) DESC, u.urn) AS rn
                      FROM units u
                     WHERE u.urn LIKE 'urn:nir:t018;1~%' AND c.mode <> 'semantic' AND u.search_vector @@ websearch_to_tsquery('italian', 'licenza edilizia')) f) AS lexical_rows,
           (SELECT count(*) FROM units u
             WHERE u.urn LIKE 'urn:nir:t018;1~%' AND c.mode <> 'lexical' AND CAST(c.q_vec AS vector) IS NOT NULL AND u.embedding IS NOT NULL) AS semantic_rows
      FROM calls c
)
SELECT (SELECT count(*) FROM result) = 2
   AND (SELECT count(DISTINCT lexical_rows) FROM result) = 1
   AND (SELECT lexical_rows FROM result WHERE name = 'null_vector') = ARRAY['urn:nir:t018;1~art1', 'urn:nir:t018;1~art2']
   AND (SELECT max(semantic_rows) FROM result) = 0 AS ok
