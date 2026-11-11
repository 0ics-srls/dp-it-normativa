-- search, semantic side: ascending cosine distance, rows without embedding are skipped (two orthogonal axes plus one in between)
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date, embedding) VALUES
 ('urn:nir:t012;1~art1', 'T', 'urn:nir:t012;1', '1', 'p', 'uno', 'x', '2099-01-01', (ARRAY[1, 0]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('urn:nir:t012;1~art2', 'T', 'urn:nir:t012;1', '2', 'p', 'due', 'x', '2099-01-01', (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024)),
 ('urn:nir:t012;1~art3', 'T', 'urn:nir:t012;1', '3', 'p', 'tre', 'x', '2099-01-01', (ARRAY[0.8, 0.6]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024));
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t012;1~art4', 'T', 'urn:nir:t012;1', '4', 'p', 'quattro', 'x', '2099-01-01');

SELECT (SELECT array_agg(urn ORDER BY embedding <=> (ARRAY[0, 1]::real[] || array_fill(0::real, ARRAY[1022]))::vector(1024), urn)
          FROM units WHERE urn LIKE 'urn:nir:t012;1~%' AND embedding IS NOT NULL)
         = ARRAY['urn:nir:t012;1~art2', 'urn:nir:t012;1~art3', 'urn:nir:t012;1~art1'] AS ok
