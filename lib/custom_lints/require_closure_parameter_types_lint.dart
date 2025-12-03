import 'package:analyzer/dart/ast/ast.dart'
    show AstNode, FunctionExpression, SimpleFormalParameter, VariableDeclaration;
import 'package:analyzer/dart/element/element.dart' show VariableElement;
import 'package:analyzer/dart/element/type.dart' show FunctionType;
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule that requires type annotations on closure parameters
///
/// This rule enforces strong typing by requiring explicit type annotations
/// on all function expression (closure) parameters, ensuring code clarity
/// and type safety.
/// Exception: Skips function expressions assigned to function-typed variables,
/// as the type is already explicit in the variable declaration.
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
      // Skip if this function expression is assigned to a function-typed variable
      if (_isAssignedToFunctionTypedVariable(node)) {
        return;
      }

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
          // Skip if this function expression is assigned to a function-typed variable
          if (_isAssignedToFunctionTypedVariable(argument)) {
            continue;
          }

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

  /// Checks if a function expression is assigned to a function-typed variable
  bool _isAssignedToFunctionTypedVariable(FunctionExpression node) {
    // Traverse up the AST to find if this is an initializer of a VariableDeclaration
    AstNode? current = node.parent;
    while (current != null) {
      // Check if this is a VariableDeclaration with a function-typed variable
      if (current is VariableDeclaration) {
        final fragment = current.declaredFragment;
        final element = fragment?.element;
        if (element is VariableElement) {
          final type = element.type;
          // Check if the variable type is a function type
          if (type is FunctionType) {
            return true;
          }
        }
      }
      current = current.parent;
    }
    return false;
  }
}
