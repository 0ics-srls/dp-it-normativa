import { TestBed, type ComponentFixture } from '@angular/core/testing';
import { must } from '../../testing/dom';
import { actWire, statusWire } from '../../testing/itn-fixtures';
import { callsOf, stubItnEnvironment } from '../../testing/stub-itn-tools';
import { itnProviders } from '../../providers';
import { ActsScreen } from './acts.screen';

type Handler = (input: object) => unknown;

function setup(acts: Handler, overrides: Parameters<typeof stubItnEnvironment>[1] = {}) {
  const env = stubItnEnvironment(
    { acts_find: acts, ingest_status: () => [statusWire(), statusWire({ collection: 'GU' })] },
    { locale: 'en', ...overrides },
  );
  TestBed.configureTestingModule({ providers: [...itnProviders] });
  const fixture = TestBed.createComponent(ActsScreen);
  fixture.componentRef.setInput('context', env.context());
  return { env, fixture };
}

async function settle(fixture: ComponentFixture<ActsScreen>, ms = 0): Promise<void> {
  await vi.advanceTimersByTimeAsync(ms);
  fixture.detectChanges();
  for (let i = 0; i < 3; i++) {
    await vi.advanceTimersByTimeAsync(0);
    fixture.detectChanges();
  }
}

const root = (fixture: ComponentFixture<ActsScreen>): HTMLElement => fixture.nativeElement as HTMLElement;
const rows = (fixture: ComponentFixture<ActsScreen>): HTMLElement[] => [...root(fixture).querySelectorAll<HTMLElement>('[data-testid="acts-row"]')];

function type(fixture: ComponentFixture<ActsScreen>, value: string): void {
  const input = must(root(fixture), '[data-testid="acts-search"]') as HTMLInputElement;
  input.value = value;
  input.dispatchEvent(new Event('input'));
}

const pagedActs = (total: number): Handler => (input) => {
  const { offset, limit } = input as { offset?: number; limit?: number };
  const from = offset ?? 0;
  return Array.from({ length: Math.min(limit ?? 50, total - from) }, (_, i) =>
    actWire({ act: `ATTO ${String(from + i + 1)}`, urn: `urn:nir:stato:legge:2000-01-01;${String(from + i + 1)}`, total }),
  );
};

describe('ActsScreen', () => {
  beforeEach(() => {
    vi.useFakeTimers();
  });
  afterEach(() => {
    vi.useRealTimers();
  });

  it('should render a row with title, urn, units and last version date when the Tool returns acts', async () => {
    const { fixture } = setup(() => [actWire(), actWire({ act: 'DECRETO 2026', urn: 'urn:nir:stato:decreto:2026-01-01;1', unit_count: 7 })]);
    fixture.detectChanges();
    await settle(fixture);
    const items = rows(fixture);
    expect(items).toHaveLength(2);
    expect(items[0]?.textContent).toContain('LEGGE 27 luglio 2000, n. 212');
    expect(items[0]?.textContent).toContain('urn:nir:stato:legge:2000-07-27;212');
    expect(items[0]?.textContent).toContain('40');
    expect(items[0]?.textContent).toContain('2024');
  });

  it('should call acts_find once with q after the debounce when the user types', async () => {
    const { env, fixture } = setup(() => [actWire()]);
    fixture.detectChanges();
    await settle(fixture);
    type(fixture, 'cos');
    await settle(fixture, 100);
    type(fixture, 'costituzione');
    await settle(fixture, 100);
    expect(callsOf(env, 'acts_find').filter((input) => 'q' in input)).toHaveLength(0);
    await settle(fixture, 400);
    const withQuery = callsOf(env, 'acts_find').filter((input) => 'q' in input);
    expect(withQuery).toEqual([{ q: 'costituzione', limit: 50, offset: 0 }]);
  });

  it('should filter by collection when a collection of ingest_status is selected', async () => {
    const { env, fixture } = setup(() => [actWire()]);
    fixture.detectChanges();
    await settle(fixture);
    const select = must(root(fixture), '[data-testid="acts-collection"]') as HTMLSelectElement;
    expect([...select.options].map((option) => option.value)).toEqual(['', 'NORMATTIVA', 'GU']);
    select.value = 'GU';
    select.dispatchEvent(new Event('change'));
    await settle(fixture);
    expect(callsOf(env, 'acts_find').at(-1)).toEqual({ collection: 'GU', limit: 50, offset: 0 });
  });

  it('should request offset 50 when the next page is chosen', async () => {
    const { env, fixture } = setup(pagedActs(120));
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(50);
    must(root(fixture), '[data-testid="acts-next"]').click();
    await settle(fixture);
    expect(callsOf(env, 'acts_find').at(-1)).toEqual({ limit: 50, offset: 50 });
    expect(rows(fixture)[0]?.textContent).toContain('ATTO 51');
  });

  it('should disable next on the last page and previous on the first page when the total is reached', async () => {
    const { fixture } = setup(pagedActs(30));
    fixture.detectChanges();
    await settle(fixture);
    expect((must(root(fixture), '[data-testid="acts-next"]') as HTMLButtonElement).disabled).toBe(true);
    expect((must(root(fixture), '[data-testid="acts-prev"]') as HTMLButtonElement).disabled).toBe(true);
  });

  it('should show the empty state text when the Tool returns no acts', async () => {
    const { fixture } = setup(() => []);
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(0);
    expect(must(root(fixture), '[data-testid="acts-empty"]').textContent).toContain('No acts');
  });

  it('should show the error state and no rows when the Tool fails', async () => {
    const { fixture } = setup(() => {
      throw new Error('boom');
    });
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(0);
    expect(must(root(fixture), '[data-testid="acts-error"]').textContent).toContain('could not be loaded');
  });

  it('should navigate to the act Screen with the urn when a row is clicked', async () => {
    const navigateScreen = vi.fn();
    const { fixture } = setup(() => [actWire()], { navigateScreen });
    fixture.detectChanges();
    await settle(fixture);
    must(rows(fixture)[0] ?? root(fixture), '[data-testid="acts-open"]').click();
    expect(navigateScreen).toHaveBeenCalledExactlyOnceWith('act', 'urn:nir:stato:legge:2000-07-27;212');
  });

  it('should render Slovak texts when the locale is sk', async () => {
    const { fixture } = setup(() => [], { locale: 'sk' });
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="acts-empty"]').textContent).toContain('Žiadne akty');
  });
});

