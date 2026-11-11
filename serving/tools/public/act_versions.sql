SELECT v.valid_from,
       count(*) AS units_changed
  FROM unit_versions v
 WHERE starts_with(v.urn, @act_urn || '~')
 GROUP BY v.valid_from
 ORDER BY v.valid_from
