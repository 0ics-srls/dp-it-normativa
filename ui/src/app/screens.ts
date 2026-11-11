import type { Type } from '@angular/core';
import { ActScreen } from './screens/act/act.screen';
import { ActsScreen } from './screens/acts/acts.screen';
import { StatusScreen } from './screens/status/status.screen';

/** Custom elements of the package: three Screens. */
export const ELEMENTS = {
  'dp-it-normativa-acts': ActsScreen,
  'dp-it-normativa-act': ActScreen,
  'dp-it-normativa-status': StatusScreen,
} as const satisfies Readonly<Record<string, Type<unknown>>>;
