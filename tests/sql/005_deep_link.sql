-- the deep link is the Normattiva link up to the article (comma dropped); an anchor that is not a urn:nir urn has none
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:stato:legge:1970-05-20;300~art18-com1', 'Statuto', 'urn:nir:stato:legge:1970-05-20;300', '18', '1', '1970-05-20-300/art18/c1', 't', 'Statuto > t', '2099-01-01');
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:stato:legge:1970-05-20;300', 'Statuto', 'urn:nir:stato:legge:1970-05-20;300', '0', '1970-05-20-300', 't', 'Statuto > t', '2099-01-01');
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('akn:/it/act/legge/2099/9/art1', 'Altro', 'akn:/it/act/legge/2099/9', '1', 'x/art1', 't', 'Altro > t', '2099-01-01');

SELECT (SELECT deep_link FROM units WHERE urn = 'urn:nir:stato:legge:1970-05-20;300~art18-com1') = 'https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:1970-05-20;300~art18'
   AND (SELECT deep_link FROM units WHERE urn = 'urn:nir:stato:legge:1970-05-20;300') = 'https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:1970-05-20;300'
   AND (SELECT deep_link IS NULL FROM units WHERE urn = 'akn:/it/act/legge/2099/9/art1') AS ok
