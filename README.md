# dp-it-normativa

Data package `it-normativa`: Italian legislation (Normattiva acts and Gazzetta Ufficiale acts), searchable by text, by meaning or both, and navigable by URN:NIR. Schema `ds_it_normativa`, version 0.1.0 (data package, no Screens yet; the UI comes with 0.2.0).

## Pipeline

`detect -> grab -> convert -> ingest -> embed`, one item per act (chunk size 1 after detect).

| Step | Class | What it does |
|---|---|---|
| detect | `dp-it-normativa-detect` | Reads the Source `acts`, emits the acts not yet in the Source state (item key `<kind>:<denominazione>:<anno>:<numero>`, `gu:<codiceRedazionale>`). The kind (`normattiva` or `gu`) is inferred from the shape of the acts. |
| grab | `dp-it-normativa-grab` | Normattiva: the async export of the open-data API (AKN zip with the original and every vigenza). Gazzetta Ufficiale: the stampa form (HTML of the whole act). One connection, paced. |
| convert | `dp-it-normativa-convert` | Parses every version (Python port of the legacy `AknReader`, `GuHtmlReader`), builds the versions plan (SCD-2) and writes `.plan.json` plus the latest AKN. |
| ingest | `dp-it-normativa-ingest` | Loads the plan: units, `unit_versions`, `acts`, `akn_documents` in one transaction per act. The embedding is kept when the text is unchanged and cleared when it changed. |
| embed | `dp-lex-embed` | Embeds `units.text_contextual` with `jina-embeddings-v3` (1024 dimensions) within `tokenBudget`. |

## Source types

| Key | Config |
|---|---|
| `normattiva-acts` | `acts[]` of `{denominazione, anno, numero}` (max 50), `collection` (default `NORMATTIVA`), `refreshToken`, `tokenBudget` (default 30000) |
| `gu-acts` | `acts[]` of `{dataGU, codiceRedazionale}`, `collection`, `refreshToken`, `tokenBudget` (default 30000) |

`tokenBudget` is the hard stop of Jina tokens one embedding Run may spend; the Host fills the schema default when a Source is created or updated.

## Tools

Gateway names are `it-normativa_<tool>`. Each Tool is pure SQL with named parameters. Legacy names are the old LexCorpus MCP/REST tools.

| Tool | Legacy | Purpose |
|---|---|---|
| `it-normativa_search` | `search` | Hybrid search: full text (italian) + vector, fused with RRF (k = 60); `mode` hybrid, lexical or semantic; `lexical_raw` for tsquery syntax; filters collection, act, article_num, date_from, date_to; filter-only listing ordered by URN |
| `it-normativa_act_outline` | `get_act_outline` | Articles of an act in legal order (2, 2-bis, 5, 10), comma counts, paging |
| `it-normativa_acts_find` | `find-acts` (REST only) | Acts by title words, with unit counts and newest version date |
| `it-normativa_article` | `get_article` | One article with its commi |
| `it-normativa_comma` | `get_comma` | One comma, verbatim text, deep link (inserted articles as `~art25bis`, the form Normattiva resolves), `is_citable` |
| `it-normativa_refs` | `follow_refs` | Outgoing edges; `graph_populated` is always false (the graph is not built) |
| `it-normativa_version_at_date` | `get_version_at_date` | Text in force at a date from `unit_versions`; `supported` false when only the current version is stored |
| `it-normativa_act_akn` | new | Stored Akoma Ntoso XML in slices (`offset`, `length`, `next_offset`) |
| `it-normativa_guide` | `guide` | The manual (normativa half of the legacy guide, with the package tool names) |
| `it-normativa_act_versions` | new | Version start dates of an act (UI timeline) |
| `it-normativa_ingest_status` | new | Units, acts and units without embedding per collection (UI status) |

### Hybrid search pattern

Two CTEs (`lex`, `sem`) rank with `ROW_NUMBER()` over their own order and take `2*k` rows; `fused` is a `FULL OUTER JOIN` with the RRF score `1/(60+rank)` per list, ordered by score, then lexical position, then semantic position. The lexical side is off when `mode = semantic` or there is no query; the semantic side is off when `mode = lexical`, there is no query or the Host bound no vector (degraded: the answer is lexical only and carries a warning). The reported `score` is `1/position` of the fused order. The header of `serving/tools/public/search.sql` is the reference copied by the other lex packages.

### Parity with the legacy tools

Constants copied from the legacy code: `ts_headline` options `StartSel=«,StopSel=»,MaxFragments=2,MaxWords=28,MinWords=8`, 200-character snippet, RRF 60, `k` 1..50, outline `limit` 1..200, `acts_find` `limit` 1..1000, the `version_at_date` reasons, int.TryParse comma order. Deliberate differences: `urn` filters use `starts_with` instead of `LIKE` (no wildcard reading of a URN); the lexical ranking breaks ties by URN; a `mode=lexical` call does not embed the query (`x-embed.skipWhen`, since 0.2.8): the Host binds `q_vec` NULL.

## Data contract and tests

`serving/dataset.odcs.yaml` declares the five tables (the `units.embedding` column carries the vector search hints). Package tests: `tests/sql` (rolled back transactions, each inserts its own rows) and `tests/tools`. The Tool SQL itself is exercised in the Registry test project (`DpItNormativaToolDb`), because a package SQL test cannot call a Tool.

## Licences

Texts come from Normattiva and the Gazzetta Ufficiale. Both state that the electronic texts may be reproduced citing the source, that they are free of charge and not authentic (only the printed Gazzetta Ufficiale is official). The Manifest declares `source-attribution-required` for each source; a named open-data licence of dati.normattiva.it is not confirmed and must be checked before any public Grant.
