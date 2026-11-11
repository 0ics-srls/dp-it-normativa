-- search, lexical side: web-search syntax (phrase, OR, minus, implicit AND) over the italian vector, and the legacy ts_headline options mark the hit with the guillemets
INSERT INTO units (urn, act, act_urn, article_num, materialized_path, text_raw, text_contextual, version_date) VALUES
 ('urn:nir:t010;1~art1', 'T', 'urn:nir:t010;1', '1', 'p', 'La licenza edilizia è rilasciata dal comune entro trenta giorni.', 'x', '2099-01-01'),
 ('urn:nir:t010;1~art2', 'T', 'urn:nir:t010;1', '2', 'p', 'Il permesso di costruire sostituisce la licenza edilizia nei casi previsti.', 'x', '2099-01-01'),
 ('urn:nir:t010;1~art3', 'T', 'urn:nir:t010;1', '3', 'p', 'Il comune può rilasciare autorizzazioni paesaggistiche per gli interventi.', 'x', '2099-01-01'),
 ('urn:nir:t010;1~art5', 'T', 'urn:nir:t010;1', '5', 'p', 'La sanzione amministrativa è applicata dal prefetto.', 'x', '2099-01-01'),
 ('urn:nir:t010;1~art7', 'T', 'urn:nir:t010;1', '7', 'p', 'La licenza urgente edilizia è sospesa.', 'x', '2099-01-01');

SELECT (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t010;1~%' AND search_vector @@ websearch_to_tsquery('italian', '"licenza edilizia"'))
         = ARRAY['urn:nir:t010;1~art1', 'urn:nir:t010;1~art2']
   AND (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t010;1~%' AND search_vector @@ websearch_to_tsquery('italian', 'sanzione OR comune'))
         = ARRAY['urn:nir:t010;1~art1', 'urn:nir:t010;1~art3', 'urn:nir:t010;1~art5']
   AND (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t010;1~%' AND search_vector @@ websearch_to_tsquery('italian', 'licenza -comune'))
         = ARRAY['urn:nir:t010;1~art2', 'urn:nir:t010;1~art7']
   AND (SELECT array_agg(urn ORDER BY urn) FROM units WHERE urn LIKE 'urn:nir:t010;1~%' AND search_vector @@ websearch_to_tsquery('italian', 'licenza comune'))
         = ARRAY['urn:nir:t010;1~art1']
   AND (SELECT ts_headline('italian', text_raw, websearch_to_tsquery('italian', 'sanzione'), 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8')
          FROM units WHERE urn = 'urn:nir:t010;1~art5') LIKE '%«sanzione»%' AS ok
