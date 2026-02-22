// require_closure_parameter_types_lint.dart
//
// WHY THIS RULE EXISTS:
//   Dart allows closure parameters without type annotations, relying on type
//   inference to determine the type. While type inference is powerful, untyped
//   closure parameters create several problems:
//     - Readers (human or AI) must trace the enclosing context to understand
//       what type `x` is in `list.map((x) => x.value)` — explicit types make
//       this self-documenting: `list.map((Item x) => x.value)`
//     - IDE autocomplete is degraded for untyped parameters
//     - Inference failures in complex generic contexts produce confusing errors
//     - This rule enforces the same strong-typing philosophy as
//       `require_explicit_type_annotations` (which bans `var`) but for closures
//
//   Note: `recommended.yaml` also sets `avoid_types_on_closure_parameters: ignore`
//   to ensure the built-in rule does NOT fight against this custom rule. Without
//   that override, the two rules would conflict on the same code.

import 'package:analyzer/dart/ast/ast.dart' show FunctionExpression, SimpleFormalParameter;
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule that requires type annotations on closure parameters
///
/// This rule enforces strong typing by requiring explicit type annotations
/// on all function expression (closure) parameters, ensuring code clarity
/// and type safety.
class RequireClosureParameterTypesLint extends DartLintRule {
  const RequireClosureParameterTypesLint() : super(code: _code);

  static const _code = LintCode(
    name: 'require_closure_parameter_types',
    problemMessage:
        'Function expression parameters must have explicit type annotations for strong typing. Add type annotations to all closure parameters to improve code clarity and type safety.',
    correctionMessage: 'Add explicit type annotations to all closure parameters.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // Hook 1: addFunctionExpression — fires for standalone function expressions
    // (closures defined as variables, passed directly, returned from functions, etc.)
    // Example: `final f = (x) => x + 1;` → flags `x`
    context.registry.addFunctionExpression((node) {
      final parameters = node.parameters?.parameters ?? [];
      for (final parameter in parameters) {
        if (parameter is SimpleFormalParameter) {
          // SimpleFormalParameter is a plain positional or named parameter.
          // FieldFormalParameter (`this.field`) and SuperFormalParameter (`super.field`)
          // are excluded by the type check — they don't need explicit type annotations
          // since their type is derived from the field declaration.
          if (parameter.type == null) {
            // Report at the parameter node itself, not the enclosing expression,
            // so the IDE underlines exactly the untyped parameter identifier.
            reporter.atNode(parameter, _code);
          }
        }
      }
    });

    // Hook 2: addMethodInvocation — also fires for inline function expressions
    // passed as arguments in method calls. This catches cases where the AST
    // visits the MethodInvocation before the FunctionExpression child, which
    // can happen in some custom_lint versions depending on visitor ordering.
    // Having both hooks ensures no closure is missed regardless of AST walk order.
    // Example: `list.map((x) => x.value)` → flags `x`
    context.registry.addMethodInvocation((node) {
      // Walk through all arguments of this method call
      for (final argument in node.argumentList.arguments) {
        // Only check arguments that are function expressions (closures)
        if (argument is FunctionExpression) {
          final parameters = argument.parameters?.parameters ?? [];
          for (final parameter in parameters) {
            if (parameter is SimpleFormalParameter) {
              if (parameter.type == null) {
                reporter.atNode(parameter, _code);
              }
            }
          }
        }
      }
    });
  }
}
