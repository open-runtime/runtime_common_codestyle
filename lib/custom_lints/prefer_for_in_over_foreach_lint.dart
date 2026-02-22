// prefer_for_in_over_foreach_lint.dart
//
// WHY THIS RULE EXISTS:
//   forEach with function literals is idiomatic in some languages but has real
//   downsides in Dart:
//     - Creates an unnecessary closure allocation on every call site
//     - Blocks control flow (you cannot `break`, `continue`, or `return` from
//       an enclosing function inside a forEach callback)
//     - Less readable than a for-in loop for multi-statement bodies
//     - The Dart linter already has `avoid_function_literals_in_foreach_calls`
//       but its message is generic — this rule provides context-aware suggestions
//
//   This rule is designed to be helpful for BOTH AI agents and human developers
//   by diagnosing which refactoring pattern applies (tear-off vs for-in vs
//   collection-for) based on static analysis of the closure body.

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

  // The _code constant defines the diagnostic shown to developers.
  // The correctionMessage here is the generic fallback; _buildRefactoringSuggestion()
  // generates a context-specific message at runtime that replaces this when possible.
  static const _code = LintCode(
    name: 'prefer_for_in_over_foreach',
    problemMessage:
        'Avoid using forEach with function literals. Prefer tear-offs, for-in loops, or collection for syntax. Function literals in forEach create unnecessary closures, add runtime overhead, and limit control flow (no break/continue).',
    correctionMessage:
        'Refactor to use: (1) Tear-off: list.forEach(print) for simple function calls, (2) For-in loop: for (final item in list) { action(item); } for side effects, or (3) Collection for: [for (final item in list) transform(item)] for transformations.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // Register a visitor for every MethodInvocation node in the AST.
    // custom_lint calls this callback once per method call expression found in the file.
    context.registry.addMethodInvocation((node) {
      // Check if this is a forEach call
      if (node.methodName.name != 'forEach') return;

      // Require an explicit target (e.g., `list.forEach(...)` not just `forEach(...)`).
      // A null target means it's a top-level function call, not an iterable method.
      final target = node.target;
      if (target == null) return;

      // forEach with no arguments is a no-op call — skip it.
      final arguments = node.argumentList.arguments;
      if (arguments.isEmpty) return;

      // Only flag forEach when the argument is a function expression (closure/lambda).
      // forEach with a tear-off (e.g., list.forEach(print)) is already idiomatic and
      // should NOT be flagged — this rule only targets the anti-pattern.
      final firstArg = arguments.first;
      if (firstArg is! FunctionExpression) return;

      // Extract the parameter name from the closure for use in the suggestion string.
      // Falls back to 'item' if the closure has no parameters (unusual but possible).
      final functionExpr = firstArg;
      final parameters = functionExpr.parameters?.parameters ?? [];
      final paramName = parameters.isNotEmpty
          ? parameters.first.toString().replaceAll(RegExp('[()]'), '')
          : 'item';

      // Generate a context-specific suggestion by analyzing the closure body's AST.
      // This gives the developer an actionable, copy-pasteable refactoring hint rather
      // than just a generic "use for-in instead" message.
      final refactoringSuggestion = _buildRefactoringSuggestion(functionExpr, paramName);

      // Report the diagnostic at the entire method invocation node (highlights
      // both the method name and arguments for clear IDE underline placement).
      // A new LintCode is constructed per-report to embed the dynamic suggestion
      // in the correctionMessage shown in quick-fix panels.
      reporter.atNode(
        node,
        LintCode(name: _code.name, problemMessage: _code.problemMessage, correctionMessage: refactoringSuggestion),
      );
    });
  }

  // _buildRefactoringSuggestion analyzes the AST of the function expression body
  // and returns the most specific applicable refactoring pattern.
  //
  // Decision tree:
  //   ExpressionFunctionBody (arrow: `(x) => expr`)
  //     → MethodInvocation on the parameter → tear-off candidate
  //     → FunctionExpressionInvocation with param as arg → tear-off candidate
  //   BlockFunctionBody (braces: `(x) { ... }`)
  //     → Single statement with .add(x) → collection-for candidate
  //   Default → for-in loop suggestion
  String _buildRefactoringSuggestion(FunctionExpression functionExpr, String paramName) {
    final body = functionExpr.body;

    // Arrow function bodies (`(x) => expression`) are tear-off candidates
    // when the expression is a simple method call on the parameter or a
    // top-level function invocation with the parameter as the sole argument.
    if (body is ExpressionFunctionBody) {
      final expression = body.expression;
      if (expression is MethodInvocation) {
        // Pattern: `(item) => item.someMethod()` → suggest `list.forEach(item.someMethod)`
        // Exclude toString/hashCode since those are rarely the intended operation and
        // tear-offs on them would look confusing.
        final target = expression.target;
        if (target is SimpleIdentifier && target.name == paramName) {
          final methodName = expression.methodName.name;
          if (methodName != 'toString' && methodName != 'hashCode') {
            return 'Use tear-off: list.forEach($methodName) instead of list.forEach(($paramName) => $paramName.$methodName())';
          }
        } else if (target == null && expression.methodName.name == 'print') {
          // Pattern: `(item) => print(item)` → suggest `list.forEach(print)`
          // print is a top-level function so its target is null in the AST.
          return 'Use tear-off: list.forEach(print) instead of list.forEach(($paramName) => print($paramName))';
        }
      } else if (expression is FunctionExpressionInvocation) {
        // Pattern: `(item) => myFunc(item)` → suggest `list.forEach(myFunc)`
        // The function being invoked is a SimpleIdentifier (top-level function reference).
        final function = expression.function;
        if (function is SimpleIdentifier) {
          return 'Use tear-off: list.forEach(${function.name}) instead of list.forEach(($paramName) => ${function.name}($paramName))';
        }
      }
    }

    // Block bodies with a single .add() call are collection-for candidates.
    // Pattern: `(item) { newList.add(transform(item)); }` → suggest collection-for
    if (body is BlockFunctionBody) {
      final statements = body.block.statements;
      for (final stmt in statements) {
        if (stmt is ExpressionStatement) {
          final expr = stmt.expression;
          if (expr is MethodInvocation) {
            if (expr.methodName.name == 'add' && expr.argumentList.arguments.isNotEmpty) {
              // Extract the argument passed to .add() for the suggestion string.
              final firstArg = expr.argumentList.arguments.first;
              return 'Use collection for: final newList = [for (final $paramName in list) $firstArg];';
            }
          }
        }
      }
    }

    // Default: suggest a for-in loop with placeholder body.
    // This covers multi-statement closures and other patterns not matched above.
    return 'Use for-in loop: for (final $paramName in list) { /* your code */ }';
  }
}
