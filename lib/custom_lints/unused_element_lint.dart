import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule placeholder for unused_element detection
///
/// This rule is a placeholder. The actual unused element detection is handled by:
/// 1. Built-in `unused_element` diagnostic (set to warning in recommended.yaml)
///    - Reports warnings for static members and public API elements that may be used externally
/// 2. `UnusedVariableLint` (custom lint)
///    - Reports errors for local unused variables in function bodies with detailed messaging
///
/// The built-in unused_element diagnostic is set to warning to avoid blocking builds
/// for public API elements (like static members) that are often used from other files.
/// Local variables are handled separately by UnusedVariableLint with error severity.
class UnusedElementLint extends DartLintRule {
  const UnusedElementLint() : super(code: _code);

  static const _code = LintCode(
    name: 'unused_element_public_api',
    problemMessage:
        'This element appears unused but may be part of the public API used from other files. Static members and public class members are often used externally. If it is truly unused, remove it. If it is used from other files, ensure it is properly exported.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // This is a placeholder rule. The actual detection is handled by:
    // - Built-in unused_element diagnostic (warning for public API elements)
    // - UnusedVariableLint (error for local variables in function bodies)
    //
    // We keep this rule registered to maintain the plugin structure, but the
    // built-in analyzer diagnostic handles the actual detection and reporting.
  }
}
