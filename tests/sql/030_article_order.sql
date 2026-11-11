-- article order: pure-digit commi by number (1, 2, 10), every other comma label (2-bis) after them, ties by urn
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date)
SELECT 'urn:nir:t030;1~art5-com' || c, 'T', 'urn:nir:t030;1', '5', c, 'p', 't', 'x', DATE '2099-01-01' FROM unnest(ARRAY['10', '2-bis', '2', '1']) AS c;

SELECT (SELECT array_agg(comma_num ORDER BY CASE WHEN comma_num ~ '^[0-9]{1,9}$' THEN comma_num::int END NULLS LAST, urn)
          FROM units WHERE urn = 'urn:nir:t030;1~art5' OR starts_with(urn, 'urn:nir:t030;1~art5' || '-com')) = ARRAY['1', '2', '10', '2-bis'] AS ok
