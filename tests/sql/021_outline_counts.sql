-- act_outline counts: comma_count counts only rows that carry a comma, an article without commi counts none, the article urn is the smallest urn cut at -com
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, rubrica, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t021;1~art1-com1', 'T', 'urn:nir:t021;1', '1', '1', 'p', 'Oggetto', 't', 'x', '2099-01-01'),
 ('urn:nir:t021;1~art1-com2', 'T', 'urn:nir:t021;1', '1', '2', 'p', 'Oggetto', 't', 'x', '2099-01-01'),
 ('urn:nir:t021;1~art2', 'T', 'urn:nir:t021;1', '2', NULL, 'p', NULL, 't', 'x', '2099-01-01');

WITH articles AS (
    SELECT article_num, count(comma_num) AS comma_count, regexp_replace(min(urn), '-com[0-9A-Za-z-]*$', '') AS article_urn
      FROM units WHERE urn LIKE 'urn:nir:t021;1~%' GROUP BY article_num)
SELECT (SELECT comma_count FROM articles WHERE article_num = '1') = 2
   AND (SELECT comma_count FROM articles WHERE article_num = '2') = 0
   AND (SELECT article_urn FROM articles WHERE article_num = '1') = 'urn:nir:t021;1~art1' AS ok
