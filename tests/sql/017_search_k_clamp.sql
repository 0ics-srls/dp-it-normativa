-- search k: clamped to 1..50, default 10 when absent (the Tool JSON default applies the 10; the clamp expression covers the rest)
SELECT LEAST(GREATEST(COALESCE(NULL::bigint, 10), 1), 50) = 10
   AND LEAST(GREATEST(COALESCE(0::bigint, 10), 1), 50) = 1
   AND LEAST(GREATEST(COALESCE(-5::bigint, 10), 1), 50) = 1
   AND LEAST(GREATEST(COALESCE(1000::bigint, 10), 1), 50) = 50
   AND LEAST(GREATEST(COALESCE(7::bigint, 10), 1), 50) = 7 AS ok
