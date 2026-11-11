-- a date before the first version has no interval in force (the Tool answers with the reason and a NULL text) while the vigente date comes from the units row
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:t043;1~art5-com1', 'T', 'urn:nir:t043;1', '5', '1', 'p', 'C', 'x', '2010-06-01');
INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES ('urn:nir:t043;1~art5-com1', '2000-07-31', NULL, 'A');

SELECT (SELECT count(*) FROM unit_versions WHERE urn = 'urn:nir:t043;1~art5-com1' AND valid_from <= DATE '1999-12-31' AND (valid_to IS NULL OR DATE '1999-12-31' < valid_to)) = 0
   AND (SELECT version_date FROM units WHERE urn = 'urn:nir:t043;1~art5-com1') = DATE '2010-06-01' AS ok
