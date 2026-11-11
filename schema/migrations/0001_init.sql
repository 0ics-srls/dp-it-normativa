-- dp-it-normativa 0001: the five normativa tables. Additive only; applied by the Host as ds_it_normativa_rw with search_path ds_it_normativa, public.
-- No foreign keys (the legacy corpus had none; keys are natural: urn, act_urn). The pgvector extension is provided by the Host.

CREATE TABLE acts (
    act_urn text PRIMARY KEY,
    title text NOT NULL,
    denominazione text,
    year integer,
    number integer,
    kind text NOT NULL,
    collection text,
    versions_count integer NOT NULL,
    first_valid_from date,
    last_valid_from date,
    units_count integer NOT NULL,
    ingested_at timestamptz NOT NULL,
    source_url text
);

CREATE TABLE units (
    urn text PRIMARY KEY,
    act text NOT NULL,
    act_urn text NOT NULL,
    article_num text NOT NULL,
    comma_num text,
    materialized_path text NOT NULL,
    rubrica text,
    text_raw text NOT NULL,
    text_contextual text NOT NULL,
    version_date date NOT NULL,
    collection text,
    embedding vector(1024)
);

CREATE TABLE unit_versions (
    urn text NOT NULL,
    valid_from date NOT NULL,
    valid_to date,
    text_raw text NOT NULL,
    PRIMARY KEY (urn, valid_from),
    CONSTRAINT unit_versions_valid_range_chk CHECK (valid_to IS NULL OR valid_to > valid_from)
);

CREATE TABLE edges (
    from_urn text NOT NULL,
    to_urn text NOT NULL,
    type text NOT NULL,
    PRIMARY KEY (from_urn, to_urn, type)
);

CREATE TABLE akn_documents (
    act_urn text PRIMARY KEY,
    version_date date NOT NULL,
    sha256 text NOT NULL,
    xml text NOT NULL
);
