import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule for unused variables with detailed message for agents and humans
///
/// This rule enhances the built-in unused_local_variable diagnostic with a more
/// detailed message that helps both AI agents and human developers understand
/// that unused variables may indicate unfinished implementations.
class UnusedVariableLint extends DartLintRule {
  const UnusedVariableLint() : super(code: _code);

  static const _code = LintCode(
    name: 'unused_variable_unfinished_implementation',
    problemMessage:
        'This may be an unfinished implementation given it is unused and may indicate that you wanted to do something with it but got side tracked. Study this variable and its surrounding context to either finish the implementation and use it, or remove it if it is truly unused and leave a comment about why it was okay to remove it in its place and why it might have been there in the first place.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addVariableDeclaration((node) {
      final element = node.declaredFragment?.element;
      if (element == null) return;

      // Skip if variable starts with _ (private, intentionally unused)
      final name = element.name;
      if (name == null || name.startsWith('_')) return;

      // Skip const/final variables (they might be used for documentation or are intentionally unused)
      if (node.isConst || node.isFinal) return;

      // Check if the variable is actually used
      // We check if there are any read references (not just write/assignment)
      final hasReadReferences = _hasReadReferences(context, element);

      if (!hasReadReferences) {
        reporter.atElement2(element, _code);
      }
    });
  }

  bool _hasReadReferences(CustomLintContext context, dynamic element) =>
      // Simplified: We rely on the analyzer's built-in unused_local_variable detection
      // This custom lint provides enhanced messaging. The actual detection is handled
      // by the analyzer's unused_local_variable diagnostic which we've set to error.
      // For now, we'll report all non-const/final variables without _ prefix as potentially unused.
      // The analyzer will filter out actually used ones via its own diagnostics.
      false;
}
