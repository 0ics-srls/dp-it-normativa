import { ChangeDetectionStrategy, Component } from '@angular/core';
import { TranslocoPipe } from '@jsverse/transloco';

@Component({
  selector: 'dp-itn-act-view',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [TranslocoPipe],
  template: '<h1 data-testid="screen-title">{{ "act.title" | transloco }}</h1>',
})
export class ActViewComponent {}
