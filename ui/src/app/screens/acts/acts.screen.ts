import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectItnScreen, screenContextProvider } from '../../shared/connect-screen';
import { ActsViewComponent } from './acts-view.component';

/** Root of the `dp-itn-acts` Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-itn-acts',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ActsViewComponent],
  providers: [screenContextProvider(() => ActsScreen)],
  template: '<dp-itn-acts-view />',
})
export class ActsScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectItnScreen(this.context);
  }
}
