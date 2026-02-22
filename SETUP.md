# Setup Guide — runtime_common_codestyle

## Prerequisites

- **Dart SDK** >= 3.9.0 (`dart --version` to check)
- **Git SSH access** to the `open-runtime` GitHub organization (for git-mode dependencies)
- **Dart pub cache** populated for `lint_hard`, `analyzer`, `custom_lint_builder`

## Development Setup

### Option A — Inside the monorepo (workspace mode)

```bash
# From the monorepo root
cd packages/libraries/dart/runtime_common_codestyle
dart pub get
```

Workspace resolution handles all dependency linking automatically. No git SSH needed for
other open-runtime packages when working in the monorepo.

### Option B — Standalone clone (outside monorepo)

```bash
git clone git@github.com:open-runtime/runtime_common_codestyle.git
cd runtime_common_codestyle
dart pub get
```

## Verifying the Setup

```bash
# Check analysis runs without errors
dart analyze

# Run the custom lint plugin against this package itself
dart run custom_lint

# Confirm the recommended.yaml is valid YAML
dart run --enable-experiment=macros dart:convert < lib/recommended.yaml 2>/dev/null \
  && echo "Valid YAML" || echo "Check YAML syntax"
```

Expected output from `dart analyze`: zero errors (some warnings are acceptable for strict
typing rules which are intentionally configured as warnings).

## CI Tooling Setup

This package uses `runtime_ci_tooling` for CI/CD automation. The tooling requires:

1. A `GEMINI_API_KEY` environment variable for AI-powered triage
2. A `GITHUB_TOKEN` or `GH_TOKEN` for GitHub API access

### Initialize on a fresh clone

```bash
# From the package root
dart run runtime_ci_tooling:manage_cicd init
dart run runtime_ci_tooling:manage_cicd setup
dart run runtime_ci_tooling:manage_cicd validate
```

### Update CI templates after upgrading runtime_ci_tooling

When you bump the `runtime_ci_tooling` version in `pubspec.yaml`:

```bash
dart pub get
dart run runtime_ci_tooling:manage_cicd update --force
```

The `--force` flag overwrites all managed files (Gemini commands, CI workflows, config keys)
from the latest templates. Use `--dry-run` first to preview changes:

```bash
dart run runtime_ci_tooling:manage_cicd update --dry-run
```

## GitHub Actions Workflows

Three workflows are managed by `runtime_ci_tooling` in `.github/workflows/`:

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yaml` | Every PR/push | `dart analyze`, `dart format --set-exit-if-changed`, custom lint |
| `release.yaml` | Manual / tagged | Changelog generation, pub publish, GitHub release creation |
| `issue-triage.yaml` | Issue opened | AI-powered issue triage using Gemini |

## Configuration Files

| File | Purpose | Edit? |
|------|---------|-------|
| `.runtime_ci/config.json` | CI/CD runtime config (repo, Gemini, labels, release) | Yes — project-specific |
| `.runtime_ci/autodoc.json` | Autodoc module discovery config | Auto-managed by `update` |
| `.runtime_ci/template_versions.json` | Tracks template hashes for drift detection | Do not edit manually |
| `analysis_options.yaml` | Self-analysis (uses this package's own `recommended.yaml`) | Rarely |
| `release-please-config.json` | Legacy release-please config (superseded by CI tooling) | No |

## Updating the Package Version

1. Make your code changes
2. Update `CHANGELOG.md` manually or via `dart run runtime_ci_tooling:manage_cicd release-notes`
3. Bump `version` in `pubspec.yaml`
4. Commit and push to a branch
5. Create a PR — CI will validate
6. After merge, tag the commit: `git tag v0.x.y && git push --tags`
7. The release workflow creates the GitHub release automatically

## Dependency Updates

When updating `lint_hard`, `analyzer`, or `custom_lint_builder`:

```bash
# Update pubspec.yaml version constraint, then:
dart pub upgrade

# Verify no breaking API changes in custom lint rules
dart run custom_lint

# Test against a consumer package to ensure the plugin still loads correctly
# (cd into any package that uses this one, run: dart run custom_lint)
```

Common breaking change areas:
- `DiagnosticReporter` API (renamed from `ErrorReporter` in older versions)
- `DartLintRule` method signatures
- `CustomLintContext.registry` hook names (e.g., `addMethodInvocation`)
- `declaredFragment` vs `declaredElement` (changed across analyzer versions)
