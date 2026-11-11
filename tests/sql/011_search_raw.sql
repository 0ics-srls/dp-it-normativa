-- search, lexical_raw: a raw tsquery (prefix and distance operators) replaces the web-search query; a malformed one is an error and never an empty result
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t011;1~art1', 'T', 'urn:nir:t011;1', '1', 'p', 'La licenza edilizia è rilasciata dal comune.', 'x', '2099-01-01'),
 ('urn:nir:t011;1~art2', 'T', 'urn:nir:t011;1', '2', 'p', 'Il permesso sostituisce la licenza edilizia.', 'x', '2099-01-01'),
 ('urn:nir:t011;1~art7', 'T', 'urn:nir:t011;1', '7', 'p', 'La licenza urgente edilizia è sospesa.', 'x', '2099-01-01'),
 ('urn:nir:t011;1~art5', 'T', 'urn:nir:t011;1', '5', 'p', 'La sanzione amministrativa è applicata.', 'x', '2099-01-01');

CREATE FUNCTION pg_temp.raw_is_error(raw text) RETURNS boolean LANGUAGE plpgsql AS $$
BEGIN
    PERFORM to_tsquery('italian', raw);
    RETURN false;
EXCEPTION WHEN syntax_error THEN
    RETURN true;
END $$;

SELECT (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t011;1~%' AND search_vector @@ to_tsquery('italian', 'licenz:*'))
         = ARRAY['urn:nir:t011;1~art1', 'urn:nir:t011;1~art2', 'urn:nir:t011;1~art7']
   AND (SELECT array_agg(urn) FROM units WHERE urn LIKE 'urn:nir:t011;1~%' AND search_vector @@ to_tsquery('italian', 'licenza <2> edilizia'))
         = ARRAY['urn:nir:t011;1~art7']
   AND pg_temp.raw_is_error('licenza &')
   AND NOT pg_temp.raw_is_error('licenz:*') AS ok
