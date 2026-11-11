import { effect, inject, Injectable, signal, untracked } from '@angular/core';
import type { StatusRow } from '../../tools/itn-dto';
import { ItnTools } from '../../tools/itn-tools';

@Injectable()
export class StatusStore {
  private readonly tools = inject(ItnTools);

  readonly rows = signal<readonly StatusRow[]>([]);
  readonly loading = signal(false);
  /** Translation key of the failure, null when fine. */
  readonly error = signal<string | null>(null);
  readonly errorDetail = signal('');

  private request = 0;

  constructor() {
    // an effect, not a constructor call: the context input is set after construction
    effect(() => {
      untracked(() => void this.refresh());
    });
  }

  async refresh(): Promise<void> {
    const request = ++this.request;
    this.loading.set(true);
    try {
      const rows = await this.tools.ingestStatus();
      if (request !== this.request) {
        return;
      }
      this.rows.set(rows);
      this.error.set(null);
      this.errorDetail.set('');
    } catch (error) {
      if (request !== this.request) {
        return;
      }
      this.rows.set([]);
      this.error.set('common.error');
      this.errorDetail.set(error instanceof Error ? error.message : String(error));
    } finally {
      if (request === this.request) {
        this.loading.set(false);
      }
    }
  }
}
