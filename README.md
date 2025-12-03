# Runtime Common Code Style

Common code style and analysis rules for the OpenRuntime monorepo. This package provides a centralized `analysis_options.yaml` configuration that enforces consistent coding standards across all packages.

## Usage

Add this package as a dev dependency in your `pubspec.yaml`:

```yaml
dev_dependencies:
  runtime_common_codestyle:
    path: ../../libraries/dart/runtime_common_codestyle
```

Then include it in your `analysis_options.yaml`:

```yaml
include: package:runtime_common_codestyle/recommended.yaml
```

## Code Style Rules

### Naming Conventions

This package enforces the following naming conventions:

#### SCREAMING_SNAKE_CASE
Used for:
- Constants (`static const String LOG_DIR = 'logs'`)
- Enum values (`enum Status { ACTIVE, INACTIVE }`)
- Static final fields (`static final Map<int, String> CLIENT_COLORS = ...`)

#### PascalCase
Used for:
- Top-level declarations (module-level variables, classes, functions)
- Examples: `final ModuleAssets TesseractInferenceAssets = ...`
- Examples: `final ModuleTests VertexTextErrorDetectorTests = ...`

#### snake_case
Used for:
- Regular functions (rust-like naming convention)
- Examples: `String get_standardized_color(String name) { ... }`
- Examples: `void process_message() { ... }`

#### camelCase
Used for:
- Instance variables
- Local variables
- Standard Dart conventions apply

### Variable Shadowing

Variable shadowing is allowed with the following conventions:
- `_variable` - One level of shadowing (e.g., shadowing a parameter with a local variable)
- `__variable` - Two levels of shadowing (e.g., nested shadowing)

This is a documented convention and not enforced by the analyzer.

### Strong Typing

The configuration enforces strong typing with:
- `strict-casts: true` - Prevents implicit casts
- `strict-inference: true` - Requires explicit type annotations
- `strict-raw-types: true` - Prevents use of raw types

However, `omit_local_variable_types` is ignored to allow verbose explicit types (which is preferred).

### Trailing Commas

Trailing commas are enforced via `always_put_required_named_parameters_first: true`. This ensures consistent formatting and makes diffs cleaner.

Example:
```dart
final ModuleAssets Assets = ModuleAssets(
  local: [],
  github: [],
  gcp: [],  // ← trailing comma required
);
```

### Line Length

While the analyzer allows lines longer than 80 characters, the formatter enforces a 120 character limit via `dart format --line-length=120`.

## Excluded Files

The following patterns are excluded from analysis:
- Generated files (`*.g.dart`, `*.gr.dart`, `*.freezed.dart`, `*.pb.dart`, etc.)
- Example directories
- External dependencies

## Migration

To migrate an existing package:

1. Add `runtime_common_codestyle` as a dev dependency
2. Replace your `analysis_options.yaml` content with:
   ```yaml
   include: package:runtime_common_codestyle/recommended.yaml
   ```
3. Run `dart pub get`
4. Run `dart analyze` to verify no new issues

## Inspiration

This package follows the same pattern as [runtime_lints](https://github.com/open-runtime/runtime_lints) - a simple package that exports analysis configuration without any code.

