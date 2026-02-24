# Version Bump Rationale

**Decision**: patch

The changes introduced since the `v0.1.10` release consist entirely of bug fixes, dependency updates, CI tooling upgrades, and documentation enhancements. There are no breaking changes to the public API and no new features or lint rules were added. Therefore, a patch release is the appropriate version bump.

## Key Changes
* Fixed invalid `strict-casts`, `strict-inference`, and `strict-raw-types` keys from the `errors` section in `lib/recommended.yaml` which were causing analyzer issues.
* Updated deprecated `_code.name` getters in `lib/custom_lints/prefer_for_in_over_foreach_lint.dart` to fix `LintCode` instantiation and make the lint code name version-stable.
* Moved `custom_lint_builder` to a proper git dependency pointing to the `open-runtime` fork (`dart_custom_lint.git`) to align leaf constraints for workspace enablement.
* Bumped `runtime_ci_tooling` dependency to `^0.12.0` (fixes a pipeline failure related to rebase operations).
* Added `publish_to: none` in `pubspec.yaml` as the package uses git dependencies and is not intended for pub.dev.
* Synced `runtime_ci` templates and regenerated GitHub Action workflows (including the new `auto-format` job).
* Added `USAGE.md`, `SETUP.md`, and `CLAUDE.md` to document the package purpose, integration guidelines, and AI assistance instructions.

## Breaking Changes
None

## New Features
None

## References
* Merge pull request #17 (`open-runtime/fix/lintcode-name-compat`)
* Merge branch `feat/enterprise-byok-runtime-ci-sync`
* Various chore commits for CI, documentation, and analyzer lint fixes.
