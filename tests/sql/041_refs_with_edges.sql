-- refs with edges: only the edges that start at the urn, as {from, to, type}
INSERT INTO edges (from_urn, to_urn, type) VALUES
 ('urn:nir:t041;1~art1', 'urn:nir:t041;1~art2', 'cita'),
 ('urn:nir:t041;1~art1', 'urn:nir:t041;1~art3', 'modifica'),
 ('urn:nir:t041;1~art2', 'urn:nir:t041;1~art1', 'cita');

SELECT (SELECT json_array_length(COALESCE(json_agg(json_build_object('from', e.from_urn, 'to', e.to_urn, 'type', e.type)), '[]'::json))
          FROM edges e WHERE e.from_urn = 'urn:nir:t041;1~art1') = 2
   AND (SELECT count(*) FROM edges e WHERE e.from_urn = 'urn:nir:t041;1~art1' AND e.to_urn = 'urn:nir:t041;1~art1') = 0 AS ok
