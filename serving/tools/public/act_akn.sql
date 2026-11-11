-- substr counts characters, so a multibyte character is never cut at a slice boundary. offset is 0-based; next_offset is NULL once the slice reaches the end.
SELECT d.act_urn,
       d.version_date,
       d.sha256,
       char_length(d.xml)::bigint AS total_length,
       GREATEST(COALESCE(@offset, 0), 0) AS "offset",
       substr(d.xml, (GREATEST(COALESCE(@offset, 0), 0) + 1)::int, LEAST(GREATEST(COALESCE(@length, 100000), 1), 100000)::int) AS slice,
       CASE WHEN GREATEST(COALESCE(@offset, 0), 0) + LEAST(GREATEST(COALESCE(@length, 100000), 1), 100000) < char_length(d.xml)
            THEN GREATEST(COALESCE(@offset, 0), 0) + LEAST(GREATEST(COALESCE(@length, 100000), 1), 100000)
       END AS next_offset
  FROM akn_documents d
 WHERE d.act_urn = @act_urn
