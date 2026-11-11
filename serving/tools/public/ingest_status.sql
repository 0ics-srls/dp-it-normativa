SELECT u.collection,
       count(DISTINCT u.act_urn) AS acts,
       count(*) AS units,
       count(*) FILTER (WHERE u.embedding IS NULL) AS units_without_embedding,
       (SELECT max(a.ingested_at) FROM acts a WHERE a.collection IS NOT DISTINCT FROM u.collection) AS last_ingested_at
  FROM units u
 GROUP BY u.collection
 ORDER BY u.collection
