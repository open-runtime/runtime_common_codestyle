// unused_element_lint.dart
//
// WHY THIS FILE EXISTS (and why run() is empty):
//   This class is a PLACEHOLDER. Its run() body is intentionally empty and
//   will never report a diagnostic on its own.
//
//   The original intent was to provide enhanced messaging for unused public API
//   elements (classes, top-level functions, static members) — similar to what
//   UnusedVariableLint does for local variables. However, detecting unused
//   public API elements correctly is significantly harder:
//
//     - Public members may be used from OTHER packages (cross-package usage
//       is invisible to in-package static analysis).
//     - The analyzer's built-in `unused_element` diagnostic already handles
//       intra-package detection and is configured to `warning` severity in
//       recommended.yaml (not `error`, because public API elements should not
//       fail the build just because they aren't used locally).
//
//   Attempting to re-implement unused_element detection in custom_lint would
//   produce noisy false positives on public API symbols, which would undermine
//   developer trust in the entire plugin.
//
// CURRENT ARCHITECTURE:
//   Unused element detection is handled by two mechanisms:
//     1. Built-in `unused_element` (analyzer) — set to `warning` in recommended.yaml.
//        Covers top-level functions, classes, static members, typedefs, etc.
//        Does NOT fail the build (warning only) because public API is expected.
//     2. `UnusedVariableLint` (custom lint, this plugin) — covers local variables
//        inside function/method bodies with enhanced messaging. Set to trigger
//        on all non-const, non-final, non-private variable declarations.
//
// WHY KEEP THE CLASS IF IT DOES NOTHING:
//   1. The LintCode (`unused_element_public_api`) is referenced in USAGE.md
//      as a documented rule identifier. Consumers may suppress it with
//      `// ignore: unused_element_public_api`. Removing the class would
//      silently make those suppressions invalid.
//   2. It provides a clear extension point if detection logic is added later.
//      The `_code` definition and class skeleton are already wired into
//      plugin.dart's getLintRules() list — adding detection is a one-file change.
//   3. It is NOT exported from runtime_common_codestyle.dart — consumers cannot
//      accidentally reference the class in their own code.
//
// TO IMPLEMENT DETECTION IN FUTURE:
//   Add AST visitor registrations inside run() using context.registry.
//   Consider registering addTopLevelVariableDeclaration, addClassDeclaration,
//   addFunctionDeclaration — but ONLY for private symbols (public ones are
//   legitimately used cross-package and should remain as built-in warnings).

import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Placeholder lint rule for unused public API element detection.
///
/// This rule is registered in the plugin but its run() method is intentionally
/// empty. Actual unused element detection is delegated to:
///   - Built-in `unused_element` analyzer diagnostic (warning, configured in recommended.yaml)
///   - `UnusedVariableLint` (enhanced messaging for local variables)
///
/// The LintCode `unused_element_public_api` is documented so consumers can
/// reference it in ignore comments without errors.
class UnusedElementLint extends DartLintRule {
  const UnusedElementLint() : super(code: _code);

  static const _code = LintCode(
    name: 'unused_element_public_api',
    problemMessage:
        'This element appears unused but may be part of the public API used from other files. Static members and public class members are often used externally. If it is truly unused, remove it. If it is used from other files, ensure it is properly exported.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // Intentionally empty — see file header for full explanation.
    //
    // Detection is handled by the built-in `unused_element` diagnostic (warning)
    // and `UnusedVariableLint` (error, for local variables only).
    //
    // Do NOT add visitor registrations here for public symbols — they produce
    // false positives on cross-package API surfaces.
  }
}
