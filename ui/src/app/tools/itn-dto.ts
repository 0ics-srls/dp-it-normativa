/** One act (title group) of `acts_find`. `total` is the number of matching acts, repeated on every row. */
export interface ActRow {
  readonly act: string;
  readonly urn: string;
  readonly unitCount: number;
  readonly version: Date | null;
  readonly total: number;
}

/** Wire name (camelCase) of the date members, per row type. */
export const ACT_DATES: readonly string[] = ['version'];

/** One collection of `ingest_status`. */
export interface StatusRow {
  readonly collection: string | null;
  readonly acts: number;
  readonly units: number;
  readonly unitsWithoutEmbedding: number;
  readonly lastIngestedAt: Date | null;
}

export const STATUS_DATES: readonly string[] = ['lastIngestedAt'];

/** One article of `act_outline`; `totalArticles` is the count for the whole act, repeated on every row. */
export interface OutlineRow {
  readonly act: string;
  readonly urn: string;
  readonly articleNum: string;
  readonly rubrica: string | null;
  readonly commaCount: number;
  readonly totalArticles: number;
}

/** One comma (or the whole article when it has no commi) of `article`. */
export interface CommaRow {
  readonly urn: string;
  readonly commaNum: string | null;
  readonly text: string;
  readonly deepLink: string;
  readonly isCitable: boolean;
}

/** One version boundary of `act_versions`. */
export interface VersionRow {
  readonly validFrom: Date | null;
  readonly unitsChanged: number;
}

export const VERSION_DATES: readonly string[] = ['validFrom'];

/** Size and identity of the stored AKN of an act (`act_akn`, slice of length 1: the text itself is not used). */
export interface AknMeta {
  readonly actUrn: string;
  readonly versionDate: Date | null;
  readonly sha256: string;
  readonly totalLength: number;
}

export const AKN_DATES: readonly string[] = ['versionDate'];
