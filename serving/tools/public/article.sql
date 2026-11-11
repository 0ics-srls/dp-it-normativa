-- The article unit (no commi) or its comma units. starts_with, not LIKE: a urn is literal text and art1 must not reach art10 (the -com suffix stops that).
-- Comma order is the legacy int.TryParse one: pure digits by number, any other label after them, then by urn.
SELECT u.act,
       u.article_num,
       u.rubrica,
       regexp_replace(u.urn, '-com[0-9A-Za-z-]*$', '') AS article_urn,
       u.urn,
       u.comma_num,
       u.text_raw AS text,
       u.deep_link,
       (starts_with(u.urn, 'urn:nir:') OR starts_with(u.urn, '/akn/sk/')) AS is_citable
  FROM units u
 WHERE u.urn = @urn OR starts_with(u.urn, @urn || '-com')
 ORDER BY CASE WHEN u.comma_num ~ '^[0-9]{1,9}$' THEN u.comma_num::int END NULLS LAST, u.urn
