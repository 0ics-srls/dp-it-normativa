-- article 1 must not pick up article 10: the -com suffix guards the prefix, and LIKE wildcards in a urn are literal text with starts_with
INSERT INTO units (urn, act, act_urn, article_num, comma_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t032;1~art1-com1', 'T', 'urn:nir:t032;1', '1', '1', 'p', 'uno', 'x', '2099-01-01'),
 ('urn:nir:t032;1~art10-com1', 'T', 'urn:nir:t032;1', '10', '1', 'p', 'dieci', 'x', '2099-01-01'),
 ('urn:nir:t_032;1~art1-com1', 'T', 'urn:nir:t_032;1', '1', '1', 'p', 'trattino', 'x', '2099-01-01'),
 ('urn:nir:tx032;1~art1-com1', 'T', 'urn:nir:tx032;1', '1', '1', 'p', 'altro', 'x', '2099-01-01');

SELECT (SELECT array_agg(urn) FROM units WHERE urn = 'urn:nir:t032;1~art1' OR starts_with(urn, 'urn:nir:t032;1~art1' || '-com')) = ARRAY['urn:nir:t032;1~art1-com1']
   AND (SELECT array_agg(urn) FROM units WHERE urn = 'urn:nir:t_032;1~art1' OR starts_with(urn, 'urn:nir:t_032;1~art1' || '-com')) = ARRAY['urn:nir:t_032;1~art1-com1'] AS ok
