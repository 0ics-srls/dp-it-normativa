/**
 * The act route parameter. The Host owns the URL encoding of `subPath` (a segment is encoded once when the Console builds the address, decoded once when it
 * reads it back), so a urn goes through as it is. Pre-encoding it made the address bar show `%253A` (P78-47). Only the slash needs care: it separates route
 * segments and a leading one is dropped, so the slash of a non-NIR anchor (`/akn/sk/act/...`) travels as `%2F`.
 */
export function urnToSubPath(urn: string): string {
  return urn.replaceAll('/', '%2F');
}

export function subPathToUrn(subPath: string): string {
  return subPath.replaceAll('%2F', '/');
}
