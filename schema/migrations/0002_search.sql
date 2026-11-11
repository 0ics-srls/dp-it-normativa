-- dp-it-normativa 0002: full-text (italian), deep link, vector index, lookup indexes, out-of-line Akoma Ntoso storage.

ALTER TABLE units ADD COLUMN search_vector tsvector GENERATED ALWAYS AS (to_tsvector('italian', text_raw)) STORED;

-- Normattiva link up to the article: urn + "~artN" with the comma fragment dropped; anchors that are not urn:nir urns have no link.
ALTER TABLE units ADD COLUMN deep_link text GENERATED ALWAYS AS (
    CASE WHEN urn LIKE 'urn:nir:%'
         THEN 'https://www.normattiva.it/uri-res/N2Ls?' || regexp_replace(urn, '-com[0-9A-Za-z-]*$', '')
    END) STORED;

CREATE INDEX units_search_vector_idx ON units USING gin (search_vector);
CREATE INDEX units_embedding_hnsw_idx ON units USING hnsw (embedding vector_cosine_ops);
CREATE INDEX units_act_urn_idx ON units (act_urn);
CREATE INDEX units_urn_pattern_idx ON units (urn text_pattern_ops);
CREATE INDEX units_version_date_idx ON units (version_date);
CREATE INDEX units_collection_idx ON units (collection);
CREATE INDEX unit_versions_urn_idx ON unit_versions (urn);
CREATE INDEX edges_to_urn_idx ON edges (to_urn);

ALTER TABLE akn_documents ALTER COLUMN xml SET STORAGE EXTERNAL;
