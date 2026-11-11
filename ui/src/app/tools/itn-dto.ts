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
