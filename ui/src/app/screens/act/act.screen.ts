import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectItnScreen, screenContextProvider } from '../../shared/connect-screen';
import { ItnTools } from '../../tools/itn-tools';
import { ActStore } from './act.store';
import { ActViewComponent } from './act-view.component';

/** Root of the `dp-itn-act` Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-itn-act',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ActViewComponent],
  providers: [screenContextProvider(() => ActScreen), ItnTools, ActStore],
  template: '<dp-itn-act-view />',
})
export class ActScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectItnScreen(this.context);
  }
}
