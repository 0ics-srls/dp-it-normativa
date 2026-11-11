-- act_outline paging: limit/offset cut the ordered list while the window total stays the number of articles of the act
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
SELECT 'urn:nir:t022;1~art' || g, 'T', 'urn:nir:t022;1', g::text, 'p', 't', 'x', DATE '2099-01-01' FROM generate_series(1, 7) g;

WITH articles AS (
    SELECT article_num, count(*) OVER () AS total_articles
      FROM (SELECT DISTINCT article_num FROM units WHERE urn LIKE 'urn:nir:t022;1~%') d),
     page AS (SELECT * FROM articles ORDER BY article_num::int LIMIT 3 OFFSET 3)
SELECT (SELECT array_agg(article_num ORDER BY article_num::int) FROM page) = ARRAY['4', '5', '6']
   AND (SELECT count(DISTINCT total_articles) FROM page) = 1
   AND (SELECT min(total_articles) FROM page) = 7 AS ok
