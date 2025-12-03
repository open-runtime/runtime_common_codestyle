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
    // Check function expressions (closures)
    context.registry.addFunctionExpression((node) {
      final parameters = node.parameters?.parameters ?? [];
      for (final parameter in parameters) {
        if (parameter is SimpleFormalParameter) {
          // Check if the parameter has a type annotation
          if (parameter.type == null) {
            // Report error at the parameter location
            reporter.atNode(parameter, _code);
          }
        }
      }
    });

    // Also check for inline function expressions in method calls
    context.registry.addMethodInvocation((node) {
      // Check arguments that are function expressions
      for (final argument in node.argumentList.arguments) {
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
