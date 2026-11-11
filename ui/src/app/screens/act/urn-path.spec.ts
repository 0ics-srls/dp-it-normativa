import { subPathToUrn, urnToSubPath } from './urn-path';

describe('urn-path', () => {
  it('should pass a urn with colon, semicolon and dots through unchanged, the Host encodes the route itself (P78-47)', () => {
    const urn = 'urn:nir:stato:decreto.legge:2026-09-10;157';
    expect(urnToSubPath(urn)).toBe(urn);
    expect(subPathToUrn(urn)).toBe(urn);
  });

  it('should keep a leading slash and inner slashes of a non-NIR anchor by escaping only the slash', () => {
    const urn = '/akn/sk/act/2020/1';
    expect(urnToSubPath(urn)).toBe('%2Fakn%2Fsk%2Fact%2F2020%2F1');
    expect(subPathToUrn(urnToSubPath(urn))).toBe(urn);
  });

  it('should leave a percent sign alone, it is a plain character of the decoded route', () => {
    expect(subPathToUrn('urn:x%41')).toBe('urn:x%41');
  });
});
