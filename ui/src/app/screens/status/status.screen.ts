import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectItnScreen, screenContextProvider } from '../../shared/connect-screen';
import { ItnTools } from '../../tools/itn-tools';
import { StatusStore } from './status.store';
import { StatusViewComponent } from './status-view.component';

/** Root of the `dp-itn-status` Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-itn-status',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [StatusViewComponent],
  providers: [screenContextProvider(() => StatusScreen), ItnTools, StatusStore],
  template: '<dp-itn-status-view />',
})
export class StatusScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectItnScreen(this.context);
  }
}
