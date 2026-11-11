-- act_outline of an unknown act is empty, and the tilde keeps act 21 apart from act 212
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t023;212~art1', 'T', 'urn:nir:t023;212', '1', 'p', 't', 'x', '2099-01-01');

SELECT (SELECT count(*) FROM units WHERE urn LIKE 'urn:nir:t023;999' || '~%') = 0
   AND (SELECT count(*) FROM units WHERE urn LIKE 'urn:nir:t023;21' || '~%') = 0
   AND (SELECT count(*) FROM units WHERE urn LIKE 'urn:nir:t023;212' || '~%') = 1 AS ok
