import { DatePipe } from '@angular/common';
import { ChangeDetectionStrategy, Component, inject } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';
import { ActStore } from './act.store';

@Component({
  selector: 'dp-itn-act-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe, DatePipe],
  templateUrl: './act-view.component.html',
  styleUrl: './act-view.component.css',
})
export class ActViewComponent {
  protected readonly store = inject(ActStore);
}
