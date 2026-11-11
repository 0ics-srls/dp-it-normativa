/** Wire rows (snake case, like the Tool SQL returns them) for the specs. */
export type WireRow = Record<string, unknown>;

export function actWire(over: WireRow = {}): WireRow {
  return {
    act: 'LEGGE 27 luglio 2000, n. 212',
    urn: 'urn:nir:stato:legge:2000-07-27;212',
    unit_count: 40,
    version: '2024-01-15',
    total: 3,
    ...over,
  };
}

export function outlineWire(over: WireRow = {}): WireRow {
  return {
    act: 'LEGGE 27 luglio 2000, n. 212',
    urn: 'urn:nir:stato:legge:2000-07-27;212~art1',
    article_num: '1',
    rubrica: 'Princìpi generali',
    comma_count: 3,
    total_articles: 3,
    ...over,
  };
}

export function versionWire(over: WireRow = {}): WireRow {
  return { valid_from: '2000-07-27', units_changed: 40, ...over };
}

export function statusWire(over: WireRow = {}): WireRow {
  return {
    collection: 'NORMATTIVA',
    acts: 2,
    units: 120,
    units_without_embedding: 0,
    last_ingested_at: '2026-11-10T09:30:00Z',
    ...over,
  };
}

export function articleWire(over: WireRow = {}): WireRow {
  return {
    act: 'LEGGE 27 luglio 2000, n. 212',
    article_num: '1',
    rubrica: 'Princìpi generali',
    article_urn: 'urn:nir:stato:legge:2000-07-27;212~art1',
    urn: 'urn:nir:stato:legge:2000-07-27;212~art1-com1',
    comma_num: '1',
    text: 'Le disposizioni della presente legge costituiscono princìpi generali.',
    deep_link: 'https://www.normattiva.it/uri-res/N2Ls?urn:nir:stato:legge:2000-07-27;212~art1',
    is_citable: true,
    ...over,
  };
}

export function aknWire(over: WireRow = {}): WireRow {
  return {
    act_urn: 'urn:nir:stato:legge:2000-07-27;212',
    version_date: '2024-01-15',
    sha256: 'ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12cd34ef56ab12',
    total_length: 71234,
    offset: 0,
    slice: '<',
    next_offset: 1,
    ...over,
  };
}
