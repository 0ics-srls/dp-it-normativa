-- an article without commi is a single unit whose urn is the article urn and whose comma is NULL
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:t031;1~art3', 'T', 'urn:nir:t031;1', '3', 'p', 'solo articolo', 'x', '2099-01-01');

SELECT (SELECT count(*) FROM units WHERE urn = 'urn:nir:t031;1~art3' OR starts_with(urn, 'urn:nir:t031;1~art3' || '-com')) = 1
   AND (SELECT comma_num IS NULL FROM units WHERE urn = 'urn:nir:t031;1~art3')
   AND (SELECT regexp_replace(urn, '-com[0-9A-Za-z-]*$', '') FROM units WHERE urn = 'urn:nir:t031;1~art3') = 'urn:nir:t031;1~art3' AS ok
