-- refs without edges: an empty json array (never NULL) next to the literal flag false
SELECT (SELECT COALESCE(json_agg(json_build_object('from', e.from_urn, 'to', e.to_urn, 'type', e.type)), '[]'::json)::text
          FROM edges e WHERE e.from_urn = 'urn:nir:t040;1~art1') = '[]'
   AND (SELECT false) = false AS ok
