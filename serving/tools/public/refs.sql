-- Always one row. graph_populated is the literal false (honest flag, legacy parity): an empty list does not prove the unit cites nothing.
SELECT @urn AS urn,
       false AS graph_populated,
       COALESCE((SELECT jsonb_agg(jsonb_build_object('from', e.from_urn, 'to', e.to_urn, 'type', e.type) ORDER BY e.to_urn, e.type)
                   FROM edges e
                  WHERE e.from_urn = @urn), '[]'::jsonb) AS edges
