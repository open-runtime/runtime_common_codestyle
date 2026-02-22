// require_explicit_type_annotations_lint.dart
//
// WHY THIS RULE EXISTS:
//   The `var` keyword infers the type from the right-hand side. While convenient
//   for the writer, it creates friction for readers:
//     - AI agents and reviewers must evaluate the RHS expression to know the type
//     - IDEs show inferred types on hover, but code review tools (GitHub, etc.) don't
//     - `var` vs `final` communicates mutability intent; `final Type` makes both
//       explicit simultaneously
//     - This is consistent with the project's strong-typing philosophy throughout
//
//   ALLOWED:
//     `final String name = 'hello';`   — keyword is `final`, type is explicit
//     `const int MAX = 100;`           — keyword is `const`, type is explicit
//
//   FLAGGED:
//     `var name = 'hello';`            — keyword is `var`, type is inferred
//     `var MAX = 100;`                 — keyword is `var`, even with a literal RHS
//
//   NOTE: The built-in `omit_local_variable_types` rule (which enforces using `var`)
//   is set to `ignore` in recommended.yaml so it does not conflict with this rule.
//   Without that override, the two rules would fight: one requiring `var`, the other
//   banning it.

import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

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
    // addVariableDeclarationList fires for every group of variable declarations
    // that share the same keyword and type (e.g., `var a = 1, b = 2;` is one list).
    // The VariableDeclarationList node holds the keyword (var/final/const) and
    // the type annotation (if any), while each VariableDeclaration in .variables
    // holds the individual name = initializer pairs.
    context.registry.addVariableDeclarationList((node) {
      // node.keyword is the leading token: `var`, `final`, or `const`.
      // node.type is the explicit type annotation node (null if inferred).
      //
      // We check keyword.lexeme == 'var' specifically:
      //   - `final` and `const` are fine even without a type: `final x = compute()`
      //     would be flagged by strict-inference (warning level), not this rule.
      //   - `var` is always flagged because it signals deliberate type inference
      //     which this project avoids.
      final keyword = node.keyword;
      if (keyword != null && keyword.lexeme == 'var') {
        // Report on each individual variable declaration within this list.
        // This ensures `var a = 1, b = 2;` produces two separate diagnostics
        // — one per variable — for precise IDE highlighting.
        for (final variable in node.variables) {
          reporter.atNode(variable, _code);
        }
      }
    });
  }
}
