import { provideZonelessChangeDetection, type EnvironmentProviders, type Provider } from '@angular/core';
import { providePackagePrimeNG } from '@olx/package-ui-sdk';
import { provideItnI18n } from './i18n/provide-itn-i18n';

/**
 * Application-level providers of the package. No router (Screens render from `subPath`); `ItnTools` is provided by
 * each root because it needs the context that root connects.
 */
export const itnProviders: readonly (Provider | EnvironmentProviders)[] = [
  providePackagePrimeNG({ packageName: 'it-normativa' }),
  provideItnI18n(),
  provideZonelessChangeDetection(),
];
