-- Two legacy branches. History branch: the exact urn has unit_versions rows; the interval with valid_from <= date < valid_to (open valid_to = still in force) wins.
-- Vigente date: the units row, else the start of the open history row, else the newest start. Stub branch: no history, so only the vigente date of any matching unit (exact, article by -com, act by tilde).
WITH hist AS (
    SELECT v.valid_from, v.valid_to, v.text_raw FROM unit_versions v WHERE v.urn = @urn
),
vigente AS (
    SELECT COALESCE((SELECT u.version_date FROM units u WHERE u.urn = @urn),
                    (SELECT h.valid_from FROM hist h WHERE h.valid_to IS NULL ORDER BY h.valid_from DESC LIMIT 1),
                    (SELECT max(h.valid_from) FROM hist h)) AS d
),
in_force AS (
    SELECT h.* FROM hist h WHERE h.valid_from <= @date AND (h.valid_to IS NULL OR @date < h.valid_to) ORDER BY h.valid_from DESC LIMIT 1
),
stub AS (
    SELECT min(u.version_date) AS d
      FROM units u
     WHERE u.urn = @urn OR starts_with(u.urn, @urn || '-com') OR starts_with(u.urn, @urn || '~')
)
SELECT @urn AS urn,
       @date AS at_date,
       true AS supported,
       CASE WHEN f.valid_from IS NULL THEN 'nessuna versione vigente alla data' ELSE '' END AS reason,
       vg.d AS vigente_date,
       f.text_raw AS text,
       f.valid_from,
       f.valid_to
  FROM vigente vg
  LEFT JOIN in_force f ON true
 WHERE EXISTS (SELECT 1 FROM hist)
UNION ALL
SELECT @urn,
       @date,
       false,
       'Historical version reconstruction is not supported in V1; only the vigente (current) version is stored.',
       s.d,
       NULL::text,
       NULL::date,
       NULL::date
  FROM stub s
 WHERE NOT EXISTS (SELECT 1 FROM hist) AND s.d IS NOT NULL
