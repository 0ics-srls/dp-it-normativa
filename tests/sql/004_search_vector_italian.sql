-- the generated search vector uses the italian configuration: the stem of "licenziamento" matches "licenziare"
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date)
VALUES ('urn:nir:test:legge:2099;3~art18', 'Statuto', 'urn:nir:test:legge:2099;3', '18', '2099-3/art18',
        'Il datore di lavoro non puo licenziare il lavoratore senza giusta causa', 'Statuto > Il datore di lavoro non puo licenziare il lavoratore senza giusta causa', '2099-01-01');

SELECT count(*) = 1 AS ok FROM units WHERE search_vector @@ websearch_to_tsquery('italian', 'licenziamento') AND urn = 'urn:nir:test:legge:2099;3~art18'
