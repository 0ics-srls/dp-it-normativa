import { join, resolve } from 'node:path';
import { APP_ROOT, scanSources, type ScannedFile } from '../app/testing/source-scan';
import { ItnTool, TOOL_INPUT_KEYS } from '../app/tools/itn-tool';
import { forbiddenHits, loadToolDirectory, missingTools, type ToolDirectory } from './audit';

const PACKAGE_ROOT = resolve(process.cwd(), '..');
const SRC_ROOT = join(process.cwd(), 'src');
const USED: readonly string[] = Object.values(ItnTool);

const production = (root: string, patterns: readonly RegExp[]): readonly ScannedFile[] =>
  scanSources(root, patterns).filter((file) => {
    const path = file.path.replaceAll('\\', '/');
    return !path.endsWith('.spec.ts') && !path.includes('/testing/') && !path.includes('/contract-audit/');
  });

const sources = (): readonly ScannedFile[] => production(SRC_ROOT, [/\.ts$/, /\.html$/]);

describe('contract audit', () => {
  const tools = loadToolDirectory(PACKAGE_ROOT);

  it('should find every ItnTool value declared as a Tool with its json when the package is read', () => {
    expect(missingTools(USED, tools)).toEqual([]);
  });

  it('should only send input keys the Tool declares when a facade method builds its input', () => {
    for (const tool of Object.values(ItnTool)) {
      const declared = tools.get(tool)?.parameterKeys ?? [];
      for (const key of TOOL_INPUT_KEYS[tool]) {
        expect(declared, `${tool}.${key}`).toContain(key);
      }
    }
  });

  it('should give every used Tool the public audience when audited (the package is read-only)', () => {
    for (const tool of Object.values(ItnTool)) {
      expect(tools.get(tool)?.audience, tool).toBe('public');
    }
  });

  it('should find no forbidden browser access when scanning ts and html under src', () => {
    expect(forbiddenHits(sources())).toEqual([]);
  });

  it('should never define a custom element when scanning src', () => {
    const hits = sources().filter((file) => file.content.includes('customElements.define'));
    expect(hits.map((file) => file.path)).toEqual([]);
  });

  it('should use no inline style attribute or style binding when scanning templates', () => {
    const hits = sources().filter((file) => /\sstyle\s*=|\[style[.\]]|\[ngStyle\]/.test(file.content));
    expect(hits.map((file) => file.path)).toEqual([]);
  });

  it('should fail with a readable message when a Tool is removed from an in-memory copy of the package', () => {
    const copy: ToolDirectory = new Map(tools);
    copy.delete(ItnTool.ActsFind);
    const missing = missingTools(USED, copy);
    expect(missing).toEqual([`Tool "acts_find" is used by the UI but not declared in serving/tools/{operator,public}`]);
  });

  it('should list the pattern and file when a forbidden call appears in a fixture source', () => {
    const hits = forbiddenHits([{ path: 'x.ts', content: 'const r = fetch(url);' }]);
    expect(hits).toEqual(['x.ts: fetch(']);
  });

  it('should scan real sources and read real Tools when the audit runs (no vacuous pass)', () => {
    expect(sources().length).toBeGreaterThan(10);
    expect(tools.size).toBeGreaterThanOrEqual(Object.keys(ItnTool).length);
  });

  it('should keep APP_ROOT under src when scanning', () => {
    expect(APP_ROOT.startsWith(SRC_ROOT)).toBe(true);
  });
});
