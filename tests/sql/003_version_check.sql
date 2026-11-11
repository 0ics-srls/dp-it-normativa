-- a history row that closes on or before it opens is refused; an open row (valid_to NULL) and a proper interval are accepted
INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES ('urn:nir:test:legge:2099;2~art1', '2099-01-01', '2099-06-01', 'a');
INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES ('urn:nir:test:legge:2099;2~art1', '2099-06-01', NULL, 'b');

DO $$
BEGIN
    INSERT INTO unit_versions (urn, valid_from, valid_to, text_raw) VALUES ('urn:nir:test:legge:2099;2~art2', '2099-06-01', '2099-06-01', 'x');
    RAISE EXCEPTION 'empty interval was accepted';
EXCEPTION WHEN check_violation THEN
    NULL;
END $$;

SELECT count(*) = 2 AS ok FROM unit_versions WHERE urn = 'urn:nir:test:legge:2099;2~art1'
