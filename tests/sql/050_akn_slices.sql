-- act_akn slices: substr counts characters (multibyte safe), three slices reassemble to the xml, the length is capped, an offset beyond the end gives an empty slice and no next offset
INSERT INTO akn_documents (act_urn, version_date, sha256, xml)
VALUES ('urn:nir:t050;1', '2099-01-01', 'h', repeat('<p>àè€</p>', 25));

WITH doc AS (SELECT xml, char_length(xml) AS total FROM akn_documents WHERE act_urn = 'urn:nir:t050;1'),
     slices AS (
         SELECT s.off, substr(d.xml, s.off + 1, 100) AS slice,
                CASE WHEN s.off + 100 < d.total THEN s.off + 100 END AS next_offset
           FROM doc d, generate_series(0, 200, 100) AS s(off))
SELECT (SELECT string_agg(slice, '' ORDER BY off) FROM slices) = (SELECT xml FROM doc)
   AND (SELECT count(*) FROM slices WHERE char_length(slice) = 100) = 2
   AND (SELECT total FROM doc) = 250
   AND (SELECT substr(xml, 901, 100) FROM doc) = ''
   AND (SELECT CASE WHEN 900 + 100 < total THEN 1 END FROM doc) IS NULL AS ok
