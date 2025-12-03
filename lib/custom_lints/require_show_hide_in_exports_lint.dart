import 'package:analyzer/dart/ast/ast.dart' show HideCombinator, ShowCombinator;
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule that requires explicit show/hide clauses in export statements
///
/// This rule enforces explicit visibility control in exports by requiring
/// show or hide clauses, ensuring that only intended symbols are exported
/// and improving code clarity and maintainability.
class RequireShowHideInExportsLint extends DartLintRule {
  const RequireShowHideInExportsLint() : super(code: _code);

  static const _code = LintCode(
    name: 'require_show_hide_in_exports',
    problemMessage:
        'All exports should use show and hide accordingly. Please analyze the usage of the imported elements within the file and update the export accordingly. Explicit show/hide clauses improve code clarity, prevent accidental exports, and make dependencies more explicit.',
    correctionMessage: 'Add explicit show or hide clauses to the export statement.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addExportDirective((node) {
      // Check if the export has show or hide clauses
      final hasShowClause = node.combinators.any((combinator) => combinator is ShowCombinator);
      final hasHideClause = node.combinators.any((combinator) => combinator is HideCombinator);

      // If neither show nor hide is present, report a warning
      if (!hasShowClause && !hasHideClause) {
        reporter.atNode(node, _code);
      }
    });
  }
}
