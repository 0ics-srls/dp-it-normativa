import { ChangeDetectionStrategy, Component, input } from '@angular/core';
import { type PackageScreenContext } from '@olx/package-ui-sdk';
import { connectItnScreen, screenContextProvider } from '../../shared/connect-screen';
import { ItnTools } from '../../tools/itn-tools';
import { ActsStore } from './acts.store';
import { ActsViewComponent } from './acts-view.component';

/** Root of the `dp-it-normativa-acts` Screen. The root only wires the context; the view injects what needs it (avoids NG0200). */
@Component({
  selector: 'dp-it-normativa-acts',
  changeDetection: ChangeDetectionStrategy.OnPush,
  imports: [ActsViewComponent],
  providers: [screenContextProvider(() => ActsScreen), ItnTools, ActsStore],
  template: '<dp-it-normativa-acts-view />',
})
export class ActsScreen {
  readonly context = input.required<PackageScreenContext>();

  constructor() {
    connectItnScreen(this.context);
  }
}
