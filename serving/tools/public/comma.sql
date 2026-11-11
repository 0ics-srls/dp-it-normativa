SELECT u.urn,
       u.comma_num,
       u.text_raw AS text,
       u.deep_link,
       (starts_with(u.urn, 'urn:nir:') OR starts_with(u.urn, '/akn/sk/')) AS is_citable
  FROM units u
 WHERE u.urn = @urn
