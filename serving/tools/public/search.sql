-- HYBRID SEARCH PATTERN (dp-it-normativa; copied by the other lex packages, only the regconfig, table and columns change).
--   prm   : normalised parameters (k clamped to 1..50 default 10, empty strings are NULL, mode default hybrid, query vector from the Host x-embed).
--   flt   : the rows that pass the filters (collection, act prefix with the tilde, article_num, version date range); both branches read it.
--   lex   : lexical branch, off when mode = semantic or there is neither query nor lexical_raw. Raw tsquery wins over the web-search query.
--           ROW_NUMBER over ts_rank_cd DESC (urn breaks ties), 2*k rows, ts_headline with the legacy options.
--   sem   : semantic branch, off when mode = lexical, there is no query, or the Host bound no vector (degraded: no cap/provider -> NULL).
--           ROW_NUMBER over cosine distance, rows without embedding are skipped, 2*k rows.
--   fused : FULL OUTER JOIN on urn, RRF score = sum 1/(60 + rn) (rn is 1-based = legacy 1/(60 + i + 1)); order by score DESC, lexical position, semantic position.
--   listing: no query and no raw -> filter-only listing ORDER BY urn LIMIT k.
--   result: position p in the final order, score = 1/p, headline = lexical highlight else the 200-character snippet.
WITH prm AS (
    SELECT NULLIF(btrim(@query), '') AS query,
           NULLIF(btrim(@lexical_raw), '') AS raw,
           LEAST(GREATEST(COALESCE(@k, 10), 1), 50)::int AS k,
           COALESCE(NULLIF(btrim(@mode), ''), 'hybrid') AS mode,
           CAST(@q_vec AS vector) AS qv
),
flt AS (
    SELECT u.urn, u.search_vector, u.embedding
      FROM units u
     WHERE (@collection IS NULL OR u.collection = @collection)
       AND (@act IS NULL OR u.urn LIKE @act || '~%')
       AND (@article_num IS NULL OR u.article_num = @article_num)
       AND (@date_from IS NULL OR u.version_date >= @date_from)
       AND (@date_to IS NULL OR u.version_date <= @date_to)
),
tsq AS (
    SELECT CASE WHEN prm.raw IS NOT NULL THEN to_tsquery('italian', prm.raw)
                WHEN prm.query IS NOT NULL THEN websearch_to_tsquery('italian', prm.query)
           END AS q
      FROM prm
),
lex AS (
    SELECT r.urn, r.rn, ts_headline('italian', u.text_raw, tsq.q, 'StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8') AS headline
      FROM (
            SELECT f.urn, row_number() OVER (ORDER BY ts_rank_cd(f.search_vector, tsq.q) DESC, f.urn) AS rn
              FROM flt f, tsq, prm
             WHERE (prm.query IS NOT NULL OR prm.raw IS NOT NULL) AND prm.mode <> 'semantic' AND f.search_vector @@ tsq.q
             ORDER BY rn
             LIMIT (SELECT 2 * k FROM prm)
           ) r
      JOIN units u ON u.urn = r.urn
     CROSS JOIN tsq
),
sem AS (
    SELECT f.urn, row_number() OVER (ORDER BY f.embedding <=> prm.qv, f.urn) AS rn
      FROM flt f, prm
     WHERE prm.query IS NOT NULL AND prm.mode <> 'lexical' AND prm.qv IS NOT NULL AND f.embedding IS NOT NULL
     ORDER BY rn
     LIMIT (SELECT 2 * k FROM prm)
),
fused AS (
    SELECT COALESCE(l.urn, s.urn) AS urn, l.headline,
           COALESCE(1.0 / (60 + l.rn), 0) + COALESCE(1.0 / (60 + s.rn), 0) AS rrf,
           COALESCE(l.rn, 1000000000) AS lex_rn,
           COALESCE(s.rn, 1000000000) AS sem_rn
      FROM lex l
      FULL OUTER JOIN sem s ON s.urn = l.urn
),
picked AS (
    (SELECT urn, headline, row_number() OVER (ORDER BY rrf DESC, lex_rn, sem_rn, urn) AS pos
       FROM fused
      ORDER BY pos
      LIMIT (SELECT k FROM prm))
    UNION ALL
    (SELECT f.urn, NULL::text, row_number() OVER (ORDER BY f.urn)
       FROM flt f, prm
      WHERE prm.query IS NULL AND prm.raw IS NULL
      ORDER BY f.urn
      LIMIT (SELECT k FROM prm))
)
SELECT u.urn,
       u.act,
       u.article_num,
       u.comma_num,
       left(u.text_raw, 200) AS snippet,
       COALESCE(NULLIF(p.headline, ''), left(u.text_raw, 200)) AS headline,
       1.0 / p.pos AS score,
       u.deep_link
  FROM picked p
  JOIN units u ON u.urn = p.urn
 ORDER BY p.pos
