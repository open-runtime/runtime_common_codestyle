# Version Bump Rationale

**Decision**: patch

## Reasoning
The commit modifies the internal repository tooling by updating the `.gemini/commands/triage.toml` file. It introduces safety guards to prevent the Gemini CLI triage script from accidentally operating on upstream repositories in fork contexts. Since this is an internal tooling fix and does not alter the package's public API or introduce new features to the package itself, a `patch` bump is appropriate.

## Key Changes
- Added a shell-level organization guard to verify that the repository belongs to `open-runtime` or `pieces-app` before proceeding with triage operations.
- Updated all `gh` CLI commands to explicitly use the `--repo` flag, overriding implicit remote resolution.
- Added logic to fetch and review existing comments to avoid posting duplicate triage comments on issues.

## Breaking Changes
None.

## New Features
None.

## References
- Commit: `fix(triage): add --repo + org allowlist to triage.toml to prevent upstream leakage`
