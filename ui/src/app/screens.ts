import type { Type } from '@angular/core';
import { ActScreen } from './screens/act/act.screen';
import { ActsScreen } from './screens/acts/acts.screen';
import { StatusScreen } from './screens/status/status.screen';

/** Custom elements of the package: three Screens. */
export const ELEMENTS = {
  'dp-itn-acts': ActsScreen,
  'dp-itn-act': ActScreen,
  'dp-itn-status': StatusScreen,
} as const satisfies Readonly<Record<string, Type<unknown>>>;
