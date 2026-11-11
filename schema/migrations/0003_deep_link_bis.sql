-- dp-it-normativa 0003: the Normattiva deep link of an inserted article (bis, ter, quater, ...) has no hyphen.
-- Checked against www.normattiva.it (P78-46): `~art25bis` opens Art. 25-bis, `~art25-bis` silently opens Art. 25 (the wrong article).
-- The comma fragment is still dropped first; only the letters suffix of the article token is joined (`~art25-bis` -> `~art25bis`).
-- Re-running is harmless: the column keeps its definition and is recomputed from urn.
ALTER TABLE units ALTER COLUMN deep_link SET EXPRESSION AS (
    CASE WHEN urn LIKE 'urn:nir:%'
         THEN 'https://www.normattiva.it/uri-res/N2Ls?'
              || regexp_replace(regexp_replace(urn, '-com[0-9A-Za-z-]*$', ''), '(~art[0-9]+)-([a-z]+)$', '\1\2')
    END);
