// require_show_hide_in_exports_lint.dart
//
// WHY THIS RULE EXISTS:
//   Export statements without show/hide clauses re-export everything the target
//   file exports — including symbols added later that the exporting package never
//   intended to surface. This creates several problems:
//
//     - Accidental API surface growth: adding a new helper to a private file
//       silently makes it part of the public API if the barrel file has a bare
//       export for that file.
//     - Namespace pollution: consumers get unexpected names in scope when they
//       import the barrel.
//     - Harder diffs: code review cannot tell whether a symbol change is
//       intentional or accidental.
//     - Tight coupling: internal refactors (rename, split, merge) break consumer
//       imports in unpredictable ways.
//
//   Forcing every export to have `show` or `hide` means the developer must
//   explicitly decide what is public API. The correction message deliberately
//   asks the developer to "analyze the usage within the file" — the intent is
//   that you should LOOK at what the file exports before deciding the clause.
//
// NOTE ON SEVERITY:
//   This rule fires a lint warning (not an error). The built-in analyzer sets
//   unused_element to error, which catches most accidental re-exports at the
//   point of use. This rule catches the structural problem at the export site.

import 'package:analyzer/dart/ast/ast.dart' show HideCombinator, ShowCombinator;
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule that requires explicit show/hide clauses in export statements.
///
/// Every `export 'some_file.dart'` must become either
/// `export 'some_file.dart' show Foo, Bar` or
/// `export 'some_file.dart' hide InternalHelper`.
///
/// This enforces intentional, auditable public API boundaries and prevents
/// accidental re-export of internal symbols as the codebase evolves.
class RequireShowHideInExportsLint extends DartLintRule {
  const RequireShowHideInExportsLint() : super(code: _code);

  // The correctionMessage intentionally asks the developer to study the file —
  // the right fix is not mechanical (just add `show *`) but requires deciding
  // which symbols belong in the public API.
  static const _code = LintCode(
    name: 'require_show_hide_in_exports',
    problemMessage:
        'All exports should use show and hide accordingly. Please analyze the usage of the imported elements within the file and update the export accordingly. Explicit show/hide clauses improve code clarity, prevent accidental exports, and make dependencies more explicit.',
    correctionMessage: 'Add explicit show or hide clauses to the export statement.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // Register a visitor for every ExportDirective in the AST.
    // custom_lint calls this callback once per `export '...'` statement found.
    context.registry.addExportDirective((node) {
      // ExportDirective.combinators holds zero or more ShowCombinator/HideCombinator
      // nodes. A bare export (`export 'foo.dart'`) has an empty combinators list.
      final hasShowClause = node.combinators.any((combinator) => combinator is ShowCombinator);
      final hasHideClause = node.combinators.any((combinator) => combinator is HideCombinator);

      // Only flag exports that have NEITHER show NOR hide — a single clause
      // (even `hide` with one name) satisfies the rule's intent of being explicit.
      if (!hasShowClause && !hasHideClause) {
        reporter.atNode(node, _code);
      }
    });
  }
}
