-- vigente date of a unit with history: the units row, else the start of the open row, else the newest start
INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES
 ('urn:nir:t046;1~art5', '2000-01-01', '2005-01-01', 'A'),
 ('urn:nir:t046;1~art5', '2005-01-01', NULL, 'B');

SELECT COALESCE((SELECT version_date FROM units WHERE urn = 'urn:nir:t046;1~art5'),
                (SELECT valid_from FROM unit_versions WHERE urn = 'urn:nir:t046;1~art5' AND valid_to IS NULL),
                (SELECT max(valid_from) FROM unit_versions WHERE urn = 'urn:nir:t046;1~art5')) = DATE '2005-01-01'
   AND COALESCE((SELECT version_date FROM units WHERE urn = 'urn:nir:t046;1~art6'),
                (SELECT valid_from FROM unit_versions WHERE urn = 'urn:nir:t046;1~art6' AND valid_to IS NULL),
                (SELECT max(valid_from) FROM unit_versions WHERE urn = 'urn:nir:t046;1~art6')) IS NULL AS ok
