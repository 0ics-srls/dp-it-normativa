import { TestBed, type ComponentFixture } from '@angular/core/testing';
import { must } from '../../testing/dom';
import { aknWire, articleWire, outlineWire, versionWire } from '../../testing/itn-fixtures';
import { callsOf, stubItnEnvironment } from '../../testing/stub-itn-tools';
import { itnProviders } from '../../providers';
import { ActScreen } from './act.screen';

type Handler = (input: object) => unknown;

const URN = 'urn:nir:stato:legge:2000-07-27;212';

interface Handlers {
  readonly outline?: Handler;
  readonly article?: Handler;
  readonly versions?: Handler;
  readonly akn?: Handler;
}

function setup(handlers: Handlers = {}, subPath: string = encodeURIComponent(URN)) {
  const env = stubItnEnvironment(
    {
      act_outline:
        handlers.outline ??
        (() => [
          outlineWire({ article_num: '1', urn: `${URN}~art1`, rubrica: 'Princìpi generali', comma_count: 3, total_articles: 3 }),
          outlineWire({ article_num: '2', urn: `${URN}~art2`, rubrica: 'Definizioni', comma_count: 0, total_articles: 3 }),
          outlineWire({ article_num: '2-bis', urn: `${URN}~art2-bis`, rubrica: 'Estensione', comma_count: 1, total_articles: 3 }),
        ]),
      article: handlers.article ?? (() => [articleWire(), articleWire({ comma_num: '2', text: 'Secondo comma.' })]),
      act_versions:
        handlers.versions ??
        (() => [versionWire(), versionWire({ valid_from: '2010-01-01', units_changed: 5 }), versionWire({ valid_from: '2024-01-15', units_changed: 2 })]),
      act_akn: handlers.akn ?? (() => [aknWire()]),
    },
    { locale: 'en', subPath },
  );
  TestBed.configureTestingModule({ providers: [...itnProviders] });
  const fixture = TestBed.createComponent(ActScreen);
  fixture.componentRef.setInput('context', env.context());
  return { env, fixture };
}

async function settle(fixture: ComponentFixture<ActScreen>): Promise<void> {
  for (let i = 0; i < 4; i++) {
    await vi.waitFor(() => undefined);
    await Promise.resolve();
    fixture.detectChanges();
  }
}

const root = (fixture: ComponentFixture<ActScreen>): HTMLElement => fixture.nativeElement as HTMLElement;
const all = (fixture: ComponentFixture<ActScreen>, selector: string): HTMLElement[] => [...root(fixture).querySelectorAll<HTMLElement>(selector)];

describe('ActScreen', () => {
  it('should render the outline articles in the order of the Tool with rubrica and comma count when the act loads', async () => {
    const { env, fixture } = setup();
    fixture.detectChanges();
    await settle(fixture);
    const rows = all(fixture, '[data-testid="act-article"]');
    expect(rows.map((row) => row.querySelector('[data-testid="act-article-num"]')?.textContent.trim())).toEqual(['1', '2', '2-bis']);
    expect(rows[0]?.textContent).toContain('Princìpi generali');
    expect(rows[0]?.textContent).toContain('3');
    expect(callsOf(env, 'act_outline')).toEqual([{ urn: URN, limit: 50, offset: 0 }]);
    expect(must(root(fixture), '[data-testid="act-title"]').textContent).toContain('LEGGE 27 luglio 2000, n. 212');
    expect(must(root(fixture), '[data-testid="act-urn"]').textContent).toContain(URN);
  });

  it('should request offset 50 when the next outline page is chosen and the act has more articles', async () => {
    const { env, fixture } = setup({ outline: () => [outlineWire({ total_articles: 120 })] });
    fixture.detectChanges();
    await settle(fixture);
    must(root(fixture), '[data-testid="act-next"]').click();
    await settle(fixture);
    expect(callsOf(env, 'act_outline').at(-1)).toEqual({ urn: URN, limit: 50, offset: 50 });
  });

  it('should call article once and show the commi when an article is expanded twice', async () => {
    const { env, fixture } = setup();
    fixture.detectChanges();
    await settle(fixture);
    const toggle = must(all(fixture, '[data-testid="act-article"]')[0] ?? root(fixture), '[data-testid="act-expand"]');
    toggle.click();
    await settle(fixture);
    expect(callsOf(env, 'article')).toEqual([{ urn: `${URN}~art1` }]);
    expect(root(fixture).textContent).toContain('Secondo comma.');
    toggle.click();
    await settle(fixture);
    toggle.click();
    await settle(fixture);
    expect(callsOf(env, 'article')).toHaveLength(1);
  });

  it('should show one boundary per version date with the changed unit count when the timeline loads', async () => {
    const { env, fixture } = setup();
    fixture.detectChanges();
    await settle(fixture);
    const items = all(fixture, '[data-testid="act-version"]');
    expect(items).toHaveLength(3);
    expect(items[1]?.textContent).toContain('2010-01-01');
    expect(items[1]?.textContent).toContain('5');
    expect(callsOf(env, 'act_versions')).toEqual([{ act_urn: URN }]);
  });

  it('should show only the boundary date and the count when a version date is selected', async () => {
    const { fixture } = setup();
    fixture.detectChanges();
    await settle(fixture);
    must(all(fixture, '[data-testid="act-version"]')[2] ?? root(fixture), '[data-testid="act-version-select"]').click();
    await settle(fixture);
    const detail = must(root(fixture), '[data-testid="act-version-detail"]').textContent;
    expect(detail).toContain('2024-01-15');
    expect(detail).toContain('2');
  });

  it('should render the Normattiva link with target _blank and rel noopener noreferrer when the urn is an urn:nir', async () => {
    const { fixture } = setup();
    fixture.detectChanges();
    await settle(fixture);
    const link = must(root(fixture), '[data-testid="act-deeplink"]') as HTMLAnchorElement;
    expect(link.getAttribute('href')).toBe(`https://www.normattiva.it/uri-res/N2Ls?${URN}`);
    expect(link.getAttribute('target')).toBe('_blank');
    expect(link.getAttribute('rel')).toBe('noopener noreferrer');
  });

  it('should show no link when the urn is not an urn:nir anchor', async () => {
    const { fixture } = setup({}, encodeURIComponent('/akn/sk/act/2020/1'));
    fixture.detectChanges();
    await settle(fixture);
    expect(root(fixture).querySelector('[data-testid="act-deeplink"]')).toBeNull();
  });

  it('should read the AKN meta with a slice of length 1 and show size, hash and version date when the act has AKN', async () => {
    const { env, fixture } = setup();
    fixture.detectChanges();
    await settle(fixture);
    expect(callsOf(env, 'act_akn')).toEqual([{ act_urn: URN, offset: 0, length: 1 }]);
    const meta = must(root(fixture), '[data-testid="act-akn"]').textContent;
    expect(meta).toContain('71234');
    expect(meta).toContain('ab12cd34ef56');
    expect(meta).toContain('2024-01-15');
  });

  it('should show a hint and call no Tool when the urn is missing', async () => {
    const { env, fixture } = setup({}, '');
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="act-missing"]').textContent).toContain('act from the list');
    expect(env.calls).toHaveLength(0);
  });

  it('should show the error state when the outline Tool fails and keep the timeline when it works', async () => {
    const { fixture } = setup({
      outline: () => {
        throw new Error('boom');
      },
    });
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="act-error"]').textContent).toContain('could not be loaded');
    expect(all(fixture, '[data-testid="act-version"]')).toHaveLength(3);
  });

  it('should show the empty text when the act has no articles', async () => {
    const { fixture } = setup({ outline: () => [] });
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="act-empty"]').textContent).toContain('No articles');
  });
});
