-- One row per act title (legacy find-acts): base URN, stored units, newest version date; total counts all matching acts, not the page.
SELECT u.act,
       min(u.act_urn) AS urn,
       count(*) AS unit_count,
       max(u.version_date) AS version,
       count(*) OVER () AS total
  FROM units u
 WHERE (NULLIF(btrim(@q), '') IS NULL OR u.act ILIKE '%' || btrim(@q) || '%')
   AND (@collection IS NULL OR u.collection = @collection)
 GROUP BY u.act
 ORDER BY u.act
 LIMIT LEAST(GREATEST(COALESCE(@limit, 50), 1), 1000) OFFSET GREATEST(COALESCE(@offset, 0), 0)
