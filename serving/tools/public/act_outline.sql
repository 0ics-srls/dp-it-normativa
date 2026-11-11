-- One row per article of the act (units grouped by article_num). Legal order: leading integer first, then the suffix in the C collation, no leading integer last.
SELECT max(u.act) AS act,
       regexp_replace(min(u.urn), '-com[0-9A-Za-z-]*$', '') AS urn,
       u.article_num,
       max(u.rubrica) AS rubrica,
       count(u.comma_num) AS comma_count,
       count(*) OVER () AS total_articles
  FROM units u
 WHERE u.urn LIKE @urn || '~%'
 GROUP BY u.article_num
 ORDER BY NULLIF(substring(u.article_num from '^[0-9]+'), '')::int NULLS LAST,
          substring(u.article_num from '^[0-9]*(.*)$') COLLATE "C"
 LIMIT LEAST(GREATEST(COALESCE(@limit, 50), 1), 200) OFFSET GREATEST(COALESCE(@offset, 0), 0)
