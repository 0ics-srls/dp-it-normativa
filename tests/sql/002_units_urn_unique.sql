-- a second unit with the same urn is refused (the row lives in this rolled back transaction)
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:test:legge:2099;1~art1', 'Legge test', 'urn:nir:test:legge:2099;1', '1', '2099-1/art1', 'testo', 'Legge test > testo', '2099-01-01');

DO $$
BEGIN
    INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
    VALUES ('urn:nir:test:legge:2099;1~art1', 'Legge test', 'urn:nir:test:legge:2099;1', '1', '2099-1/art1', 'altro', 'Legge test > altro', '2099-01-01');
    RAISE EXCEPTION 'duplicate urn was accepted';
EXCEPTION WHEN unique_violation THEN
    NULL;
END $$;

SELECT count(*) = 1 AS ok FROM units WHERE urn = 'urn:nir:test:legge:2099;1~art1'
