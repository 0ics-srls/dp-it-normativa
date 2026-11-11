-- act_outline order: leading integer first, then the suffix in the C collation, articles without a leading integer last (2 < 2-bis < 5 < 10 < 18 < I)
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
SELECT 'urn:nir:t020;1~art' || a, 'T', 'urn:nir:t020;1', a, 'p', 't', 'x', DATE '2099-01-01' FROM unnest(ARRAY['10', '2-bis', '2', '18', '5', 'I']) AS a;

SELECT (SELECT array_agg(article_num ORDER BY NULLIF(substring(article_num from '^[0-9]+'), '')::int NULLS LAST, substring(article_num from '^[0-9]*(.*)$') COLLATE "C")
          FROM units WHERE act_urn = 'urn:nir:t020;1') = ARRAY['2', '2-bis', '5', '10', '18', 'I'] AS ok
