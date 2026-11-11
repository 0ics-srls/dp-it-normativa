-- no stored history: a unit, its article (-com prefix) and its act (tilde prefix) all resolve to a unit and so to its version date
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t044;1~art7-com1', 'T', 'urn:nir:t044;1', '7', '1', 'p', 'uno', 'x', '2021-03-04');

SELECT NOT EXISTS (SELECT 1 FROM unit_versions WHERE urn = 'urn:nir:t044;1~art7')
   AND (SELECT min(version_date) FROM units WHERE urn = 'urn:nir:t044;1~art7-com1' OR starts_with(urn, 'urn:nir:t044;1~art7-com') OR starts_with(urn, 'urn:nir:t044;1~art7' || '~')) = DATE '2021-03-04'
   AND (SELECT min(version_date) FROM units WHERE urn = 'urn:nir:t044;1' OR starts_with(urn, 'urn:nir:t044;1' || '-com') OR starts_with(urn, 'urn:nir:t044;1' || '~')) = DATE '2021-03-04' AS ok
