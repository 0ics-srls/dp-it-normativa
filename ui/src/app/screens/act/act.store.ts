import { computed, effect, inject, Injectable, signal, untracked } from '@angular/core';
import { injectPackageContext } from '@olx/package-ui-sdk';
import type { AknMeta, CommaRow, OutlineRow, VersionRow } from '../../tools/itn-dto';
import { ItnTools } from '../../tools/itn-tools';
import { subPathToUrn } from './urn-path';

export const OUTLINE_PAGE_SIZE = 50;
const NORMATTIVA_LINK = 'https://www.normattiva.it/uri-res/N2Ls?';

/** Normattiva deep link of an act, empty for anchors that are not `urn:nir:` (no public page). */
export function normattivaLink(urn: string): string {
  return urn.startsWith('urn:nir:') ? `${NORMATTIVA_LINK}${urn}` : '';
}

@Injectable()
export class ActStore {
  private readonly tools = inject(ItnTools);
  private readonly context = injectPackageContext();

  readonly urn = computed(() => subPathToUrn(this.context().subPath));
  readonly link = computed(() => normattivaLink(this.urn()));

  readonly outline = signal<readonly OutlineRow[]>([]);
  readonly outlineLoading = signal(false);
  readonly outlineError = signal<string | null>(null);
  readonly outlineDetail = signal('');
  readonly offset = signal(0);
  readonly totalArticles = computed(() => this.outline()[0]?.totalArticles ?? 0);
  readonly title = computed(() => this.outline()[0]?.act ?? this.urn());
  readonly hasPrevious = computed(() => this.offset() > 0);
  readonly hasNext = computed(() => this.offset() + OUTLINE_PAGE_SIZE < this.totalArticles());
  readonly from = computed(() => (this.totalArticles() === 0 ? 0 : this.offset() + 1));
  readonly to = computed(() => Math.min(this.offset() + OUTLINE_PAGE_SIZE, this.totalArticles()));

  readonly versions = signal<readonly VersionRow[]>([]);
  readonly versionsError = signal(false);
  readonly selectedVersion = signal<VersionRow | null>(null);

  readonly akn = signal<AknMeta | null>(null);
  readonly aknError = signal(false);

  /** Article urn -> its commi, loaded on first expand and kept. */
  readonly commas = signal<Readonly<Record<string, readonly CommaRow[]>>>({});
  readonly expanded = signal<readonly string[]>([]);
  readonly articleErrors = signal<readonly string[]>([]);

  private outlineRequest = 0;
  private readonly loadingArticles = new Set<string>();

  constructor() {
    effect(() => {
      const urn = this.urn();
      untracked(() => {
        this.offset.set(0);
        this.resetAct();
        if (urn !== '') {
          void this.loadVersions(urn);
          void this.loadAkn(urn);
        }
      });
    });
    effect(() => {
      const urn = this.urn();
      const offset = this.offset();
      untracked(() => void this.loadOutline(urn, offset));
    });
  }

  next(): void {
    if (this.hasNext()) {
      this.offset.update((offset) => offset + OUTLINE_PAGE_SIZE);
    }
  }

  previous(): void {
    if (this.hasPrevious()) {
      this.offset.update((offset) => Math.max(0, offset - OUTLINE_PAGE_SIZE));
    }
  }

  selectVersion(version: VersionRow): void {
    this.selectedVersion.set(version);
  }

  back(): void {
    this.context().navigateScreen('acts');
  }

  /** Shows or hides the commi of an article; the Tool is called only the first time. */
  async toggle(articleUrn: string): Promise<void> {
    if (this.expanded().includes(articleUrn)) {
      this.expanded.update((list) => list.filter((urn) => urn !== articleUrn));
      return;
    }
    this.expanded.update((list) => [...list, articleUrn]);
    if (articleUrn in this.commas() || this.loadingArticles.has(articleUrn)) {
      return;
    }
    this.loadingArticles.add(articleUrn);
    try {
      const rows = await this.tools.article(articleUrn);
      this.commas.update((all) => ({ ...all, [articleUrn]: rows }));
      this.articleErrors.update((list) => list.filter((urn) => urn !== articleUrn));
    } catch {
      this.articleErrors.update((list) => [...list, articleUrn]);
      this.expanded.update((list) => list.filter((urn) => urn !== articleUrn));
    } finally {
      this.loadingArticles.delete(articleUrn);
    }
  }

  private resetAct(): void {
    this.outline.set([]);
    this.versions.set([]);
    this.versionsError.set(false);
    this.selectedVersion.set(null);
    this.akn.set(null);
    this.aknError.set(false);
    this.commas.set({});
    this.expanded.set([]);
    this.articleErrors.set([]);
  }

  private async loadOutline(urn: string, offset: number): Promise<void> {
    const request = ++this.outlineRequest;
    if (urn === '') {
      this.outlineLoading.set(false);
      return;
    }
    this.outlineLoading.set(true);
    try {
      const rows = await this.tools.actOutline({ urn, limit: OUTLINE_PAGE_SIZE, offset });
      if (request !== this.outlineRequest) {
        return;
      }
      this.outline.set(rows);
      this.outlineError.set(null);
      this.outlineDetail.set('');
    } catch (error) {
      if (request !== this.outlineRequest) {
        return;
      }
      this.outline.set([]);
      this.outlineError.set('common.error');
      this.outlineDetail.set(error instanceof Error ? error.message : String(error));
    } finally {
      if (request === this.outlineRequest) {
        this.outlineLoading.set(false);
      }
    }
  }

  private async loadVersions(urn: string): Promise<void> {
    try {
      const rows = await this.tools.actVersions(urn);
      if (urn === this.urn()) {
        this.versions.set(rows);
      }
    } catch {
      this.versionsError.set(true);
    }
  }

  private async loadAkn(urn: string): Promise<void> {
    try {
      const meta = await this.tools.aknMeta(urn);
      if (urn === this.urn()) {
        this.akn.set(meta);
      }
    } catch {
      this.aknError.set(true);
    }
  }
}
