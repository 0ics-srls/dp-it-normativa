-- an urn that is neither a unit, an article nor an act of stored units, and has no history, is not found
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:t045;1~art7', 'T', 'urn:nir:t045;1', '7', 'p', 'uno', 'x', '2021-03-04');

SELECT NOT EXISTS (SELECT 1 FROM units WHERE urn = 'urn:nir:t045;2~art1' OR starts_with(urn, 'urn:nir:t045;2~art1' || '-com') OR starts_with(urn, 'urn:nir:t045;2~art1' || '~'))
   AND NOT EXISTS (SELECT 1 FROM unit_versions WHERE urn = 'urn:nir:t045;2~art1') AS ok
