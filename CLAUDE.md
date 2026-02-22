# Claude AI Assistant Guide — runtime_common_codestyle

## Package Purpose

`runtime_common_codestyle` is the **centralized code style and linting ruleset** for all
open-runtime packages. It provides two integration points:

1. **`lib/recommended.yaml`** — An analysis configuration that consumers `include:` in their
   own `analysis_options.yaml`. Extends `lint_hard/all.yaml` with project-specific overrides.

2. **Custom lint plugin** — Six `DartLintRule` implementations registered via the `custom_lint`
   plugin system, loaded automatically when `custom_lint` runs in a consumer package.

This package is a **leaf node**: it intentionally has no runtime dependencies on other
monorepo packages. Keep it that way.

## File Structure

```
lib/
├── runtime_common_codestyle.dart   — Barrel export (custom_lint entry point + all rule classes)
├── recommended.yaml                — The analysis_options.yaml include target for consumers
└── custom_lints/
    ├── plugin.dart                 — PluginBase subclass; registers all active lint rules
    ├── prefer_for_in_over_foreach_lint.dart
    ├── require_closure_parameter_types_lint.dart
    ├── require_explicit_type_annotations_lint.dart
    ├── require_show_hide_in_exports_lint.dart
    ├── unused_variable_lint.dart
    └── unused_element_lint.dart    — Placeholder; delegates to built-in analyzer diagnostic
```

## How Consumers Use This Package

### pubspec.yaml — Workspace mode (monorepo, bare constraint)
```yaml
dev_dependencies:
  runtime_common_codestyle: ^0.1.9
  custom_lint: ^0.8.1
```

### pubspec.yaml — Git SSH mode (standalone / CI outside monorepo)
```yaml
dev_dependencies:
  runtime_common_codestyle:
    git:
      url: git@github.com:open-runtime/runtime_common_codestyle.git
      ref: v0.1.9   # always pin to a tag
  custom_lint: ^0.8.1
```

### analysis_options.yaml in the consumer
```yaml
include: package:runtime_common_codestyle/recommended.yaml
# Optional package-specific overrides below:
```

## Adding a New Lint Rule

1. Create `lib/custom_lints/my_new_lint.dart` extending `DartLintRule`
2. Register it in `plugin.dart`'s `getLintRules()` list
3. Export it from `runtime_common_codestyle.dart` using `show MyNewLint`

The `LintCode` `name` field becomes the diagnostic identifier (e.g., in `// ignore: name`).

## Key Design Decisions

### Why both analyzer `errors:` overrides AND custom lint rules?

- **Built-in analyzer errors** (e.g., `unused_element`, `unused_local_variable`) run in the
  same analysis pass — faster, IDE-integrated, and reliable.
- **Custom lint rules** allow richer messaging, context-aware suggestions (like the
  forEach → for-in transformation), and rules the built-in analyzer doesn't support.

The two systems are complementary: the analyzer handles detection speed; custom lint
handles human/AI-friendly messaging and project-specific stylistic rules.

### Why `UnusedElementLint` is a no-op placeholder?

The `run()` method body is deliberately empty. The class exists to:
- Maintain plugin architecture (consistent pattern across all rules)
- Provide the enhanced `problemMessage` text for the built-in `unused_element` diagnostic

Actual detection is delegated to the built-in `unused_element` configured as `error`
in `recommended.yaml`.

### Why are naming convention rules ignored in recommended.yaml?

| Ignored rule | Reason |
|---|---|
| `constant_identifier_names` | FFI, protobuf constants use `SCREAMING_SNAKE_CASE` |
| `non_constant_identifier_names` | Module-scope asset registries use `PascalCase` top-level vars |
| `camel_case_types` | FFI C-type wrappers use `mode_t`-style names |
| `avoid_types_on_closure_parameters` | We WANT explicit closure types (custom rule enforces it) |

### Why is `avoid_print` ignored?

CLI tools, scripts, and development utilities legitimately use `print`. A blanket ban
creates unnecessary noise. Use `debugPrint` only if you need Flutter-specific filtering.

### Why are strict typing rules set to `warning` not `error`?

`strict-casts`, `strict-inference`, and `strict-raw-types` produce many false positives in
generated code even after exclusions. Setting them to `warning` means they're visible but
don't block CI builds. Unused variable rules remain `error` because they indicate
incomplete code, not ambiguous typing scenarios.

## CI/CD with runtime_ci_tooling

Run these from the package root directory:

```bash
# Update CI templates after upgrading runtime_ci_tooling
dart run runtime_ci_tooling:manage_cicd update --force

# Preview what update would change (safe, no writes)
dart run runtime_ci_tooling:manage_cicd update --dry-run

# Triage GitHub issues with AI
dart run runtime_ci_tooling:triage_cli --auto

# Validate CI configuration
dart run runtime_ci_tooling:manage_cicd validate

# Run the release pipeline
dart run runtime_ci_tooling:manage_cicd release
```

## Common Pitfalls

### Pitfall: custom lint rules not running
- Ensure both `runtime_common_codestyle` AND `custom_lint` are in `dev_dependencies`
- Run `dart run custom_lint` explicitly (not just `dart analyze`)
- The `custom_lint` plugin is loaded separately from normal `dart analyze`

### Pitfall: editing recommended.yaml without testing consumers
- Changes to `recommended.yaml` affect every package that includes it
- Test against at least one consumer package before releasing
- Use `dart run custom_lint` in a consumer to verify the plugin still loads

### Pitfall: adding heavy dependencies to this package
- This package is included in every lint consumer's dev deps
- Keep dependencies minimal (currently only `analyzer` and `lint_hard`)
- Never add runtime package dependencies (only dev_dependencies)

### Pitfall: monorepo vs standalone pubspec differences
- Monorepo: bare version constraint (`runtime_common_codestyle: ^0.1.9`)
- Standalone: git SSH (`git: url: git@github.com:open-runtime/runtime_common_codestyle.git`)
- NEVER manually swap between these — use `runtime_aot_tooling` commands in the monorepo
