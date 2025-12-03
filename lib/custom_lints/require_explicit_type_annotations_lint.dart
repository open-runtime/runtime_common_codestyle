import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

/// Custom lint rule that requires explicit type annotations instead of 'var'
///
/// This rule enforces strong typing by requiring explicit type annotations
/// on all variable declarations, preventing the use of 'var' keyword.
/// Allows 'final Type x =' and 'const Type x =' which already have explicit types.
class RequireExplicitTypeAnnotationsLint extends DartLintRule {
  const RequireExplicitTypeAnnotationsLint() : super(code: _code);

  static const _code = LintCode(
    name: 'require_explicit_type_annotations',
    problemMessage:
        'Variable declarations must use explicit type annotations instead of "var". Use "final Type x =" or "const Type x =" to improve code clarity and type safety. Explicit types help both AI agents and human developers understand the code better.',
    correctionMessage: 'Replace "var" with an explicit type annotation (e.g., "final String x =" or "const int x =").',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // Check VariableDeclarationList which contains the keyword (var, final, const)
    context.registry.addVariableDeclarationList((node) {
      // Check if the declaration uses 'var' keyword
      final keyword = node.keyword;
      if (keyword != null && keyword.lexeme == 'var') {
        // Report on each variable in the list
        for (final variable in node.variables) {
          reporter.atNode(variable, _code);
        }
      }
    });
  }
}
