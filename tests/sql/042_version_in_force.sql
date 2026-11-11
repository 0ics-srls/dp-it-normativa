-- version in force: valid_from <= d and (valid_to is open or d < valid_to), so d = valid_to already belongs to the next interval
INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES
 ('urn:nir:t042;1~art5-com1', '2000-07-31', '2005-01-01', 'A'),
 ('urn:nir:t042;1~art5-com1', '2005-01-01', '2010-06-01', 'B'),
 ('urn:nir:t042;1~art5-com1', '2010-06-01', NULL, 'C');

CREATE FUNCTION pg_temp.text_at(d date) RETURNS text LANGUAGE sql AS $$
    SELECT text_raw FROM unit_versions WHERE urn = 'urn:nir:t042;1~art5-com1' AND valid_from <= d AND (valid_to IS NULL OR d < valid_to)
$$;

SELECT pg_temp.text_at(DATE '2003-01-01') = 'A'
   AND pg_temp.text_at(DATE '2000-07-31') = 'A'
   AND pg_temp.text_at(DATE '2005-01-01') = 'B'
   AND pg_temp.text_at(DATE '2099-12-31') = 'C' AS ok
