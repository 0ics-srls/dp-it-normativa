import { computed, effect, inject, Injectable, signal, untracked } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import type { ActRow } from '../../tools/itn-dto';
import { ItnTools } from '../../tools/itn-tools';
import { urnToSubPath } from '../act/urn-path';

export const ACTS_PAGE_SIZE = 50;
export const SEARCH_DEBOUNCE_MS = 300;

interface ActsQuery {
  readonly q: string;
  readonly collection: string;
  readonly offset: number;
}

@Injectable()
export class ActsStore {
  private readonly tools = inject(ItnTools);
  private readonly context = injectPackageContext();

  readonly acts = signal<readonly ActRow[]>([]);
  readonly collections = signal<readonly string[]>([]);
  readonly total = signal(0);
  readonly loading = signal(false);
  /** Translation key of the failure, null when fine. */
  readonly error = signal<string | null>(null);
  readonly errorDetail = signal('');

  private readonly query = signal<ActsQuery>({ q: '', collection: '', offset: 0 });
  readonly collection = computed(() => this.query().collection);
  readonly offset = computed(() => this.query().offset);
  readonly from = computed(() => (this.total() === 0 ? 0 : this.offset() + 1));
  readonly to = computed(() => Math.min(this.offset() + ACTS_PAGE_SIZE, this.total()));
  readonly hasPrevious = computed(() => this.offset() > 0);
  readonly hasNext = computed(() => this.offset() + ACTS_PAGE_SIZE < this.total());

  private timer: ReturnType<typeof setTimeout> | undefined;
  private request = 0;

  constructor() {
    effect(() => {
      const query = this.query();
      untracked(() => void this.load(query));
    });
    // an effect, not a constructor call: the context input is set after construction
    effect(() => {
      untracked(() => void this.loadCollections());
    });
  }

  /** Debounced: the Tool is called once the user paused typing. */
  search(text: string): void {
    clearTimeout(this.timer);
    this.timer = setTimeout(() => {
      this.query.update((current) => ({ ...current, q: text.trim(), offset: 0 }));
    }, SEARCH_DEBOUNCE_MS);
  }

  selectCollection(collection: string): void {
    this.query.update((current) => ({ ...current, collection, offset: 0 }));
  }

  next(): void {
    if (this.hasNext()) {
      this.query.update((current) => ({ ...current, offset: current.offset + ACTS_PAGE_SIZE }));
    }
  }

  previous(): void {
    if (this.hasPrevious()) {
      this.query.update((current) => ({ ...current, offset: Math.max(0, current.offset - ACTS_PAGE_SIZE) }));
    }
  }

  open(urn: string): void {
    this.context().navigateScreen('act', urnToSubPath(urn));
  }

  private async load(query: ActsQuery): Promise<void> {
    const request = ++this.request;
    this.loading.set(true);
    try {
      const rows = await this.tools.findActs({
        q: query.q === '' ? undefined : query.q,
        collection: query.collection === '' ? undefined : query.collection,
        limit: ACTS_PAGE_SIZE,
        offset: query.offset,
      });
      if (request !== this.request) {
        return;
      }
      this.acts.set(rows);
      this.total.set(rows[0]?.total ?? 0);
      this.error.set(null);
      this.errorDetail.set('');
    } catch (error) {
      if (request !== this.request) {
        return;
      }
      this.acts.set([]);
      this.total.set(0);
      this.error.set('common.error');
      this.errorDetail.set(error instanceof Error ? error.message : String(error));
    } finally {
      if (request === this.request) {
        this.loading.set(false);
      }
    }
  }

  private async loadCollections(): Promise<void> {
    try {
      const rows = await this.tools.ingestStatus();
      const names = rows.map((row) => row.collection).filter((name): name is string => name !== null && name !== '');
      this.collections.set([...new Set(names)]);
    } catch {
      this.collections.set([]);
    }
  }
}
