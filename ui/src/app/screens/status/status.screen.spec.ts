import { TestBed, type ComponentFixture } from '@angular/core/testing';
import { must } from '../../testing/dom';
import { statusWire } from '../../testing/itn-fixtures';
import { callsOf, stubItnEnvironment } from '../../testing/stub-itn-tools';
import { itnProviders } from '../../providers';
import { StatusScreen } from './status.screen';

type Handler = (input: object) => unknown;

function setup(status: Handler, locale: 'sk' | 'en' | 'it' = 'en') {
  const env = stubItnEnvironment({ ingest_status: status }, { locale });
  TestBed.configureTestingModule({ providers: [...itnProviders] });
  const fixture = TestBed.createComponent(StatusScreen);
  fixture.componentRef.setInput('context', env.context());
  return { env, fixture };
}

async function settle(fixture: ComponentFixture<StatusScreen>): Promise<void> {
  for (let i = 0; i < 4; i++) {
    await vi.waitFor(() => undefined);
    await Promise.resolve();
    fixture.detectChanges();
  }
}

const root = (fixture: ComponentFixture<StatusScreen>): HTMLElement => fixture.nativeElement as HTMLElement;
const rows = (fixture: ComponentFixture<StatusScreen>): HTMLElement[] => [...root(fixture).querySelectorAll<HTMLElement>('[data-testid="status-row"]')];

describe('StatusScreen', () => {
  it('should render one row per collection with acts, units and last ingest when the Tool returns rows', async () => {
    const { env, fixture } = setup(() => [statusWire(), statusWire({ collection: 'GU', acts: 7, units: 900 })]);
    fixture.detectChanges();
    await settle(fixture);
    const items = rows(fixture);
    expect(items).toHaveLength(2);
    expect(items[0]?.textContent).toContain('NORMATTIVA');
    expect(items[0]?.textContent).toContain('120');
    expect(items[0]?.textContent).toContain('2026-11-10');
    expect(items[1]?.textContent).toContain('GU');
    expect(items[1]?.textContent).toContain('900');
    expect(callsOf(env, 'ingest_status')).toEqual([{}]);
  });

  it('should show the warning badge only on rows with units without embedding when the counts differ', async () => {
    const { fixture } = setup(() => [statusWire({ units_without_embedding: 0 }), statusWire({ collection: 'GU', units_without_embedding: 12 })]);
    fixture.detectChanges();
    await settle(fixture);
    const [clean, dirty] = rows(fixture);
    expect(clean?.querySelector('[data-testid="status-warning"]')).toBeNull();
    const badge = must(dirty ?? root(fixture), '[data-testid="status-warning"]');
    expect(badge.textContent).toContain('12');
    expect(badge.getAttribute('role')).toBe('status');
  });

  it('should call the Tool again and show the new rows when refresh is clicked', async () => {
    let call = 0;
    const { env, fixture } = setup(() => (++call === 1 ? [statusWire()] : [statusWire(), statusWire({ collection: 'GU' })]));
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(1);
    must(root(fixture), '[data-testid="status-refresh"]').click();
    await settle(fixture);
    expect(callsOf(env, 'ingest_status')).toHaveLength(2);
    expect(rows(fixture)).toHaveLength(2);
  });

  it('should show the empty state when the Tool returns no collections', async () => {
    const { fixture } = setup(() => []);
    fixture.detectChanges();
    await settle(fixture);
    expect(rows(fixture)).toHaveLength(0);
    expect(must(root(fixture), '[data-testid="status-empty"]').textContent).toContain('Nothing has been ingested');
  });

  it('should show the error state and keep refresh available when the Tool fails', async () => {
    const { fixture } = setup(() => {
      throw new Error('boom');
    });
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="status-error"]').textContent).toContain('could not be loaded');
    expect((must(root(fixture), '[data-testid="status-refresh"]') as HTMLButtonElement).disabled).toBe(false);
  });

  it('should render Italian texts when the locale is it', async () => {
    const { fixture } = setup(() => [], 'it');
    fixture.detectChanges();
    await settle(fixture);
    expect(must(root(fixture), '[data-testid="status-empty"]').textContent).toContain('Nessun dato');
  });
});
