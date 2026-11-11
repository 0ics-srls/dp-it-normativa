import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';
import { ActsStore } from './acts.store';

@Component({
  selector: 'dp-it-normativa-acts-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe, DatePipe],
  templateUrl: './acts-view.component.html',
  styleUrl: './acts-view.component.css',
})
export class ActsViewComponent {
  protected readonly store = inject(ActsStore);

  protected onSearch(event: Event): void {
    this.store.search((event.target as HTMLInputElement).value);
  }

  protected onCollection(event: Event): void {
    this.store.selectCollection((event.target as HTMLSelectElement).value);
  }
}
