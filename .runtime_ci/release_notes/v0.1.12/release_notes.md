# runtime_common_codestyle v0.1.12

> Bug fix release — 2026-02-24

## Bug Fixes

- **Triage command upstream leakage prevention** — Introduced strict shell-level organization guards (`open-runtime` and `pieces-app`) and explicit `--repo` flagging to the `.gemini/commands/triage.toml` tool. This ensures the script cannot accidentally operate on upstream forks, and additionally checks for existing comments to avoid posting duplicate triage summaries.

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

[v0.1.11...v0.1.12](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.11...v0.1.12)
