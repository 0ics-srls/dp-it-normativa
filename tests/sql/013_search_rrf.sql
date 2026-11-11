-- search, RRF (k = 60, 1-based positions): a row in both lists beats rows in one, a tie goes to the lexical side, score = 1 / fused position
WITH lex(urn, rn) AS (VALUES ('a', 1), ('b', 2), ('c', 3)),
     sem(urn, rn) AS (VALUES ('d', 1), ('b', 2)),
     fused AS (
         SELECT COALESCE(l.urn, s.urn) AS urn,
                COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
                COALESCE(l.rn, 1000000000) AS lex_rn,
                COALESCE(s.rn, 1000000000) AS sem_rn
           FROM lex l FULL OUTER JOIN sem s ON s.urn = l.urn),
     picked AS (SELECT urn, row_number() OVER (ORDER BY rrf DESC, lex_rn, sem_rn, urn) AS pos FROM fused)
SELECT (SELECT array_agg(urn ORDER BY pos) FROM picked) = ARRAY['b', 'a', 'd', 'c']
   AND (SELECT round(sum(1.0 / pos), 6) FROM picked) = round(1.0 + 1.0 / 2 + 1.0 / 3 + 1.0 / 4, 6) AS ok
