import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';

@Component({
  selector: 'dp-itn-status-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe],
  template: '<h1 data-testid="screen-title">{{ "status.title" | transloco }}</h1>',
})
export class StatusViewComponent {}
