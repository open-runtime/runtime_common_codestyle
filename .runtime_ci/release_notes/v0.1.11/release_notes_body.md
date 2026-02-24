# runtime_common_codestyle v0.1.11

> Bug fix release — 2026-02-24

## Bug Fixes

- **LintCode name getters** — Fixed compatibility with newer versions of `analyzer`/`custom_lint_builder` by using a static string `_ruleName` instead of the deprecated `_code.name` getter to make the lint code name version-stable. ([#17](https://github.com/open-runtime/runtime_common_codestyle/pull/17))
- **Analyzer configuration** — Fixed analyzer lint issues by removing invalid `strict-casts`, `strict-inference`, and `strict-raw-types` language options from the `errors` section in `lib/recommended.yaml`.
- **Dependency constraints** — Moved `custom_lint_builder` to a proper git dependency pointing to the `open-runtime` fork (`dart_custom_lint.git`) to align leaf constraints for workspace enablement.
- **CI tooling updates** — Bumped `runtime_ci_tooling` dependency to `^0.12.0` to fix a pipeline failure related to rebase operations and regenerated CI workflows.
- **Documentation** — Added `USAGE.md`, `SETUP.md`, and `CLAUDE.md` to document the package purpose, integration guidelines, and AI assistance instructions.
- **Package publishing** — Added `publish_to: none` in `pubspec.yaml` as the package uses git dependencies and is not intended for pub.dev.

## Upgrade

```bash
dart pub upgrade runtime_common_codestyle
```

## Issues Addressed

No linked issues for this release.
## Contributors

Thanks to everyone who contributed to this release:
- @tsavo-at-pieces
## Full Changelog

[v0.1.10...v0.1.11](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.10...v0.1.11)
