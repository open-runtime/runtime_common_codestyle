# Usage Guide — runtime_common_codestyle

## Quick Start

### 1 — Add to pubspec.yaml

**Workspace mode (monorepo — bare version constraint):**
```yaml
dev_dependencies:
  runtime_common_codestyle: ^0.1.9
  custom_lint: ^0.8.1
```

**Git SSH mode (standalone packages / CI outside monorepo):**
```yaml
dev_dependencies:
  runtime_common_codestyle:
    git:
      url: git@github.com:open-runtime/runtime_common_codestyle.git
      ref: v0.1.9     # always pin to a tag; never use a branch ref in production
  custom_lint: ^0.8.1
```

> In the monorepo the `external_workspace_packages.yaml` config maps the package name to
> the local path at `packages/libraries/dart/runtime_common_codestyle`. Workspace resolution
> handles switching between git and local automatically via `aot_tools external manage`.

### 2 — Configure analysis_options.yaml

```yaml
include: package:runtime_common_codestyle/recommended.yaml

# Add any package-specific overrides below the include:
# analyzer:
#   errors:
#     some_rule: warning  # downgrade from error to warning for this package
```

### 3 — Run analysis

```bash
# Standard Dart analysis (picks up all analyzer rules from recommended.yaml)
dart analyze

# Custom lint rules (require the separate custom_lint runner)
dart run custom_lint
```

> `dart analyze` and `dart run custom_lint` are separate processes. Both must pass in CI.

---

## What's Included

### Base ruleset — `lint_hard/all.yaml`

All rules from the [`lint_hard`](https://pub.dev/packages/lint_hard) package are included.
This is a strict, comprehensive ruleset that enforces Effective Dart + additional rules.

### Analyzer configuration overrides

| Category | Rules | Severity |
|---|---|---|
| **Errors (fail build)** | `unused_local_variable`, `unused_element`, `unused_field`, `unused_import`, `unused_shown_name` | `error` |
| **Warnings (visible, don't fail)** | `strict-casts`, `strict-inference`, `strict-raw-types` | `warning` |
| **Ignored** | `lines_longer_than_80_chars`, `avoid_dynamic_calls`, `constant_identifier_names`, `non_constant_identifier_names`, `avoid_slow_async_io`, `avoid_print`, `avoid_types_on_closure_parameters`, `camel_case_types`, `comment_references`, `unnecessary_statements` | `ignore` |
| **Enabled linter rules** | `always_put_required_named_parameters_first` | `true` |
| **Disabled linter rules** | `curly_braces_in_flow_control_structures`, `always_put_control_body_on_new_line`, `unnecessary_parenthesis`, `sort_pub_dependencies`, `avoid_classes_with_only_static_members` | `false` |

### Custom lint rules (via custom_lint plugin)

| Rule identifier | Severity | Description |
|---|---|---|
| `prefer_for_in_over_foreach` | warning | Flags `forEach` with function literals; provides context-aware refactoring suggestion (tear-off, for-in, or collection-for) |
| `require_closure_parameter_types` | warning | Requires explicit type annotations on all closure/lambda parameters |
| `require_explicit_type_annotations` | warning | Bans the `var` keyword; requires `final Type` or `const Type` |
| `require_show_hide_in_exports` | warning | Requires `show` or `hide` on every `export` directive |
| `unused_variable_unfinished_implementation` | warning | Enhanced message for unused non-final, non-private variables (suggests finishing or removing with a comment) |
| `unused_element_public_api` | info | Placeholder; actual detection handled by built-in `unused_element` |

### Excluded files (automatically skipped from analysis)

| Pattern | What it covers |
|---|---|
| `**/*.g.dart` | json_serializable, build_runner generated files |
| `**/*.gr.dart` | auto_route generated files |
| `**/*.freezed.dart` | Freezed generated files |
| `**/*.pb.dart`, `**/*.pbenum.dart` | Protobuf generated files |
| `**/*.mocks.dart` | Mockito generated mocks |
| `**/*.reflectable.dart` | Reflectable generated files |
| `**/generated_plugin_registrant.dart` | Flutter plugin registry |
| `**/example/**` | Package example directories |
| `**/scripts/**` | Build and utility scripts |
| `**/test_reflectable/**` | Reflectable test fixtures |

---

## Suppressing Rules

### Suppress a custom lint rule for one line
```dart
// ignore: require_explicit_type_annotations
final x = computeValue();
```

### Suppress for an entire file
```dart
// ignore_for_file: prefer_for_in_over_foreach
```

### Suppress a built-in analyzer rule for one line
```dart
final dynamic result = processData(); // ignore: avoid_dynamic_calls
```

### Downgrade a rule in your package's analysis_options.yaml
```yaml
include: package:runtime_common_codestyle/recommended.yaml

analyzer:
  errors:
    # Change severity from error → warning for this specific package
    unused_element: warning
    # Disable a custom lint rule entirely for this package
    require_show_hide_in_exports: ignore
```

---

## Naming Conventions

The recommended.yaml **allows** (does not enforce) these project-wide conventions:

| Convention | Example | When to use |
|---|---|---|
| `SCREAMING_SNAKE_CASE` | `const MAX_RETRY_COUNT = 3` | Constants, static finals, enum values |
| `PascalCase` top-level vars | `final ModuleAssets TesseractAssets = ...` | Module-scope singleton registries |
| `snake_case` functions | `String get_standardized_color(String name)` | Legacy utility functions |
| Normal `camelCase` | `final String myValue = ...` | All standard identifiers |

Use `// ignore: constant_identifier_names` only when the convention is genuinely non-standard.
Most code should use normal Dart `camelCase` and `PascalCase` conventions.

---

## Naming Convention for Variable Shadowing

The project uses a shadowing convention for deeply nested closures:

```dart
final String name = 'outer';
someList.map((String _name) {   // _ prefix = shadowing 'name' one level
  otherList.map((String __name) {  // __ prefix = shadowing two levels
    // use __name here
  });
});
```

This convention is documented but NOT enforced by the analyzer (no lint rule checks it).

---

## forEach Refactoring Patterns

The `prefer_for_in_over_foreach` rule will suggest one of three patterns:

### Pattern 1 — Tear-off (simplest)
```dart
// Before (flagged):
items.forEach((String item) => print(item));

// After (preferred):
items.forEach(print);
```

### Pattern 2 — For-in loop (side effects, early exit)
```dart
// Before (flagged):
items.forEach((String item) {
  process(item);
  notify(item);
});

// After (preferred):
for (final String item in items) {
  process(item);
  notify(item);
  if (item.isDone) break;  // can now use break/continue
}
```

### Pattern 3 — Collection-for (building a new collection)
```dart
// Before (flagged):
final List<String> results = [];
items.forEach((String item) {
  results.add(transform(item));
});

// After (preferred):
final List<String> results = [for (final String item in items) transform(item)];
```

---

## Unused Variable Convention

When removing an unused variable, leave a comment explaining WHY it was there:

```dart
// Removed: `final String connectionId = response.id;`
// Was intended to cache the connection ID for retry logic, but the retry
// mechanism was moved to the interceptor layer in commit abc123. Safe to remove.
```

This helps future developers (and AI agents) understand the code's evolution.

---

## Troubleshooting

### Custom lint rules not running

```bash
# Ensure pub cache is fresh
dart pub get

# Run custom lint explicitly (it's a separate process from dart analyze)
dart run custom_lint

# If still not working, clear the custom_lint cache
rm -rf .dart_tool/custom_lint
dart run custom_lint
```

### `unused_element` false positives for public API

Public class members that are used externally (from other packages) may trigger
`unused_element` warnings within the defining package. This is expected behavior.
Suppress with:

```dart
// ignore: unused_element
static final String _INTERNAL_KEY = 'key';  // used by consumers
```

Or suppress per-file if your entire file is a public API module:
```dart
// ignore_for_file: unused_element
```

### Lines longer than 80 characters

The `lines_longer_than_80_chars` rule is ignored. Use the project formatter with 120
character line length:

```bash
dart format . --line-length 120
```

### `var` keyword not allowed

Replace `var` with explicit types:

```dart
// Before (flagged by require_explicit_type_annotations):
var count = 0;
var items = <String>[];

// After:
int count = 0;
final List<String> items = [];
```
