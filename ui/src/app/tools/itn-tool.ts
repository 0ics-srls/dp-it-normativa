/** The Tools the Screens use; every value must exist in `serving/tools/public` (the contract audit proves it). */
export enum ItnTool {
  ActsFind = 'acts_find',
  ActOutline = 'act_outline',
  ActVersions = 'act_versions',
  IngestStatus = 'ingest_status',
  Article = 'article',
  ActAkn = 'act_akn',
}

/** Tool -> the (snake case) input keys its facade method may send; mirrors the `parameters` of the Tool JSON. */
export const TOOL_INPUT_KEYS: Readonly<Record<ItnTool, readonly string[]>> = {
  [ItnTool.ActsFind]: ['q', 'collection', 'limit', 'offset'],
  [ItnTool.ActOutline]: ['urn', 'limit', 'offset'],
  [ItnTool.ActVersions]: ['act_urn'],
  [ItnTool.IngestStatus]: [],
  [ItnTool.Article]: ['urn'],
  [ItnTool.ActAkn]: ['act_urn', 'offset', 'length'],
};
