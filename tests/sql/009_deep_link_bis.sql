-- P78-46: Normattiva resolves an inserted article only without the hyphen (`~art25bis` is Art. 25-bis, `~art25-bis` silently shows Art. 25)
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:stato:legge:1970-05-20;300~art18-bis-com2', 'Statuto', 'urn:nir:stato:legge:1970-05-20;300', '18-bis', '2', '1970-05-20-300/art18bis/c2', 't', 'Statuto > t', '2099-01-01');
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:stato:legge:1970-05-20;300~art18-quinquies', 'Statuto', 'urn:nir:stato:legge:1970-05-20;300', '18-quinquies', '1970-05-20-300/art18quinquies', 't', 'Statuto > t', '2099-01-01');

SELECT (SELECT deep_link FROM units WHERE urn = 'urn:nir:stato:legge:1970-05-20;300~art18-bis-com2') = 'https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:1970-05-20;300~art18bis'
   AND (SELECT deep_link FROM units WHERE urn = 'urn:nir:stato:legge:1970-05-20;300~art18-quinquies') = 'https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:1970-05-20;300~art18quinquies' AS ok
