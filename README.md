# runtime_common_codestyle

Centralized code style, linting configuration, and custom lint rules for all
[open-runtime](https://github.com/open-runtime) Dart packages.

## What It Provides

| Component | File | Description |
|---|---|---|
| **Lint configuration** | `lib/recommended.yaml` | Extends `lint_hard/all.yaml` with project-specific overrides |
| **Custom lint plugin** | `lib/custom_lints/plugin.dart` | Six lint rules via the `custom_lint` plugin system |

## Quick Start

### 1 — Add to pubspec.yaml

```yaml
dev_dependencies:
  runtime_common_codestyle: ^0.1.9
  custom_lint: ^0.8.1
```

### 2 — Configure analysis_options.yaml

```yaml
include: package:runtime_common_codestyle/recommended.yaml
```

### 3 — Run

```bash
dart analyze           # standard analysis (analyzer rules)
dart run custom_lint   # custom lint rules
```

## Custom Lint Rules

| Rule | Description |
|---|---|
| `prefer_for_in_over_foreach` | Flags `forEach` with closures; suggests tear-offs, for-in loops, or collection-for |
| `require_closure_parameter_types` | Requires explicit type annotations on all closure parameters |
| `require_explicit_type_annotations` | Bans `var`; requires `final Type` or `const Type` |
| `require_show_hide_in_exports` | Requires `show` or `hide` on every `export` directive |
| `unused_variable_unfinished_implementation` | Enhanced unused variable message with implementation guidance |

## Documentation

- **[SETUP.md](SETUP.md)** — Developer setup, CI tooling configuration, workflow descriptions
- **[USAGE.md](USAGE.md)** — Consumer integration guide, rule reference, suppression patterns
- **[CLAUDE.md](CLAUDE.md)** — AI assistant guide: architecture, design decisions, pitfalls
- **[CHANGELOG.md](CHANGELOG.md)** — Version history

## Repository

- **GitHub:** https://github.com/open-runtime/runtime_common_codestyle
- **Pub.dev:** https://pub.dev/packages/runtime_common_codestyle
