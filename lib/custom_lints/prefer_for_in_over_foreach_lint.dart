import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule that provides enhanced messaging for forEach with function literals
///
/// This rule enhances the built-in avoid_function_literals_in_foreach_calls diagnostic
/// with detailed explanations and refactoring recommendations for both AI agents
/// and human developers.
class PreferForInOverForEachLint extends DartLintRule {
  const PreferForInOverForEachLint() : super(code: _code);

  static const _code = LintCode(
    name: 'prefer_for_in_over_foreach',
    problemMessage:
        'Avoid using forEach with function literals. Prefer tear-offs, for-in loops, or collection for syntax. Function literals in forEach create unnecessary closures, add runtime overhead, and limit control flow (no break/continue).',
    correctionMessage:
        'Refactor to use: (1) Tear-off: list.forEach(print) for simple function calls, (2) For-in loop: for (final item in list) { action(item); } for side effects, or (3) Collection for: [for (final item in list) transform(item)] for transformations.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    context.registry.addMethodInvocation((node) {
      // Check if this is a forEach call
      if (node.methodName.name != 'forEach') return;

      // Check if the target is an iterable (List, Set, Map, etc.)
      final target = node.target;
      if (target == null) return;

      // Check if forEach has arguments (function literal)
      final arguments = node.argumentList.arguments;
      if (arguments.isEmpty) return;

      // Check if the argument is a function expression (closure/literal)
      final firstArg = arguments.first;
      if (firstArg is! FunctionExpression) return;

      // Get the function expression to analyze
      final functionExpr = firstArg;
      final parameters = functionExpr.parameters?.parameters ?? [];
      final paramName = parameters.isNotEmpty ? parameters.first.toString().replaceAll(RegExp('[()]'), '') : 'item';

      // Build refactoring suggestion based on the function body
      final refactoringSuggestion = _buildRefactoringSuggestion(functionExpr, paramName);

      // Report with enhanced message
      reporter.atNode(
        node,
        LintCode(
          name: _code.name,
          problemMessage: _code.problemMessage,
          correctionMessage: refactoringSuggestion,
        ),
      );
    });
  }

  String _buildRefactoringSuggestion(FunctionExpression functionExpr, String paramName) {
    final body = functionExpr.body;

    // Check if it's a simple function call (tear-off candidate)
    if (body is ExpressionFunctionBody) {
      final expression = body.expression;
      if (expression is MethodInvocation) {
        // Check if it's a simple method call on the parameter
        final target = expression.target;
        if (target is SimpleIdentifier && target.name == paramName) {
          final methodName = expression.methodName.name;
          if (methodName != 'toString' && methodName != 'hashCode') {
            return 'Use tear-off: list.forEach($methodName) instead of list.forEach(($paramName) => $paramName.$methodName())';
          }
        } else if (target == null && expression.methodName.name == 'print') {
          // Check if it's a print statement
          return 'Use tear-off: list.forEach(print) instead of list.forEach(($paramName) => print($paramName))';
        }
      } else if (expression is FunctionExpressionInvocation) {
        // Check if it's a function call with the parameter as argument
        final function = expression.function;
        if (function is SimpleIdentifier) {
          return 'Use tear-off: list.forEach(${function.name}) instead of list.forEach(($paramName) => ${function.name}($paramName))';
        }
      }
    }

    // Check if it's building a new collection (collection for candidate)
    if (body is BlockFunctionBody) {
      final statements = body.block.statements;
      // Look for patterns like: newList.add(item) or list.add(item)
      for (final stmt in statements) {
        if (stmt is ExpressionStatement) {
          final expr = stmt.expression;
          if (expr is MethodInvocation) {
            if (expr.methodName.name == 'add' && expr.argumentList.arguments.isNotEmpty) {
              final firstArg = expr.argumentList.arguments.first;
              return 'Use collection for: final newList = [for (final $paramName in list) ${firstArg.toString()}];';
            }
          }
        }
      }
    }

    // Default suggestion: for-in loop
    return 'Use for-in loop: for (final $paramName in list) { /* your code */ }';
  }
}


