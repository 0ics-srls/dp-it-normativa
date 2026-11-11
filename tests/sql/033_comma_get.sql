-- comma: one unit by its exact urn, the deep link drops the comma fragment, an unknown comma is absent
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t033;1~art5-com1', 'T', 'urn:nir:t033;1', '5', '1', 'p', 'primo', 'x', '2099-01-01'),
 ('urn:nir:t033;1~art5-com2', 'T', 'urn:nir:t033;1', '5', '2', 'p', 'secondo', 'x', '2099-01-01');

SELECT (SELECT count(*) FROM units WHERE urn = 'urn:nir:t033;1~art5-com2') = 1
   AND (SELECT text_raw FROM units WHERE urn = 'urn:nir:t033;1~art5-com2') = 'secondo'
   AND (SELECT deep_link FROM units WHERE urn = 'urn:nir:t033;1~art5-com2') = 'https://www.normattiva.it/uri-res/N2Ls?urn:nir:t033;1~art5'
   AND (SELECT count(*) FROM units WHERE urn = 'urn:nir:t033;1~art5-com9') = 0 AS ok
