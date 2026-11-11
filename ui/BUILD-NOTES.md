# ui/dist build notes

Recorded for the 0.2.0 release (open-lex-it plan-c, blocks 20-24). The Host never builds; the committed `dist` is the registered artifact.

| Item | Value |
|---|---|
| Command | `npm ci && npm run build` |
| SDK | `@olx/package-ui-sdk` 0.2.1 from `vendor/olx-package-ui-sdk-0.2.1.tgz` (built from tag `v0.2.1` of `0ics-srls/package-ui-sdk`, see below) |
| `du -sb dist` | 456531 bytes (limit `PackageUi:MaxBytes` 5 MB) |
| `main.js` | 413325 bytes (limit per file 1.5 MB) |
| chunks | none (single bundle, no lazy chunks) |
| `styles.css` | 0 bytes (the package relies on the Host PrimeNG theme) |
| `3rdpartylicenses.txt` | 43188 bytes |
| `prerendered-routes.json` | 18 bytes |
| files in `dist` / tracked by git | 4 / 4 |
| `grep -c "zone.js" dist/main.js` | 0 (zoneless) |
| Custom elements | `dp-it-normativa-acts`, `dp-it-normativa-act`, `dp-it-normativa-status` (the SDK requires the prefix `dp-<package name>-`) |
| Determinism | a second `npm run build` leaves `git status --short ui/dist` empty (`outputHashing: none`) |

## How the SDK tarball was made

Tag `v0.2.1` of the SDK exists, but its `package.json` still says version 0.2.0 (the tag only fixes the `@angular/cdk` peer and drops `legacy-peer-deps`),
and the submodule in the open-lex-it checkout is at 0.2.0. The tarball was built in a scratch clone, not in the submodule:

1. `git clone <package-ui-sdk> scratch && git checkout v0.2.1`
2. set `version` to `0.2.1` in `projects/package-ui-sdk/package.json` (scratch copy only)
3. `npm ci && npm run build:lib`
4. `npm pack` in `dist/package-ui-sdk` -> `olx-package-ui-sdk-0.2.1.tgz`, copied to `ui/vendor/`

`package-lock.json` pins the tarball by its sha512.
