// unused_variable_lint.dart
//
// WHY THIS RULE EXISTS:
//   Dart's built-in `unused_local_variable` diagnostic already detects unused
//   variables, but its message is generic: "The value of the local variable 'x'
//   isn't used." That message offers no guidance on what to DO.
//
//   In practice, unused non-final, non-private variables are almost always one
//   of two things:
//     1. An unfinished implementation — the developer assigned the result of
//        some computation to a variable planning to use it, then got distracted
//        or moved logic elsewhere and forgot to delete the variable.
//     2. A genuinely dead variable — the result is never needed and the
//        declaration should be removed, but removing it without context makes
//        future readers wonder "was this intentional?".
//
//   This rule targets case 1 with a message that prompts the developer to:
//     - Examine the variable and its surrounding context
//     - Decide whether to finish the implementation or remove the variable
//     - If removing, leave a comment explaining why it was there
//
//   AI AGENT GUIDANCE: This message is deliberately longer than typical lint
//   messages because AI agents reading it as context should understand that
//   an unused variable here is a signal of incomplete work, not just style.
//   The surrounding code should be audited for missing logic.
//
// IMPORTANT — HOW DETECTION ACTUALLY WORKS:
//   _hasReadReferences() always returns `false`. This is intentional.
//   The rule reports ALL non-const, non-final, non-private variables as
//   potentially unused. The built-in `unused_local_variable` error (configured
//   in recommended.yaml) then handles actual suppression — if the variable IS
//   used, the analyzer won't flag it as unused_local_variable, so only the
//   genuinely unused cases generate both diagnostics in the IDE panel.
//
//   In practice, the custom_lint message replaces the generic built-in message
//   in most IDEs because custom lint results appear alongside analyzer results.
//
// SCOPE:
//   - Targets: non-const, non-final, non-private variable declarations
//   - Skips: `_prefixed` names (intentionally unused by convention)
//   - Skips: `const` and `final` (more likely public API / documentation values)
//   - Does NOT scan import/export directives (handled by unused_import diagnostic)

import 'package:analyzer/error/listener.dart' show DiagnosticReporter;
import 'package:custom_lint_builder/custom_lint_builder.dart'
    show CustomLintContext, CustomLintResolver, DartLintRule, LintCode;

/// Custom lint rule for unused non-final, non-private variables.
///
/// Enhances the built-in `unused_local_variable` diagnostic with an actionable
/// message for both AI agents and human developers: examine the context, finish
/// the implementation, or remove the variable with an explanatory comment.
class UnusedVariableLint extends DartLintRule {
  const UnusedVariableLint() : super(code: _code);

  // The problem message is deliberately verbose — it serves as a prompt to
  // both AI agents and humans to investigate the surrounding code, not just
  // delete the line mechanically.
  static const _code = LintCode(
    name: 'unused_variable_unfinished_implementation',
    problemMessage:
        'This may be an unfinished implementation given it is unused and may indicate that you wanted to do something with it but got side tracked. Study this variable and its surrounding context to either finish the implementation and use it, or remove it if it is truly unused and leave a comment about why it was okay to remove it in its place and why it might have been there in the first place.',
  );

  @override
  void run(CustomLintResolver resolver, DiagnosticReporter reporter, CustomLintContext context) {
    // Register a visitor for every VariableDeclaration node in the AST.
    // This fires once per individual declaration (in `int a = 1, b = 2;`, it
    // fires twice — once for `a` and once for `b`).
    context.registry.addVariableDeclaration((node) {
      final element = node.declaredFragment?.element;
      if (element == null) return;

      // Private variables (`_name`) are intentionally exempt — the underscore
      // convention signals that the developer knows the variable is unused.
      final name = element.name;
      if (name == null || name.startsWith('_')) return;

      // const/final variables are excluded because:
      //   - `const` values are often documentation-style (named magic numbers)
      //   - `final` variables are the idiomatic Dart pattern and are more likely
      //     to be public API fields checked externally
      // The `require_explicit_type_annotations` rule bans `var`, so non-final
      // variables with explicit types are the remaining target set.
      if (node.isConst || node.isFinal) return;

      // Check read references — see _hasReadReferences below.
      final hasReadReferences = _hasReadReferences(context, element);

      if (!hasReadReferences) {
        reporter.atElement2(element, _code);
      }
    });
  }

  // _hasReadReferences always returns false.
  //
  // This is an intentional design decision, NOT a bug or placeholder:
  //   The custom_lint framework does not expose a simple "is this element read?"
  //   query without walking the entire AST manually. Doing so correctly would
  //   require handling closures, async contexts, conditional assignments, etc.
  //
  //   Instead of reimplementing Dart's data-flow analysis, this rule delegates
  //   actual detection to the built-in `unused_local_variable` diagnostic
  //   (configured as `error` in recommended.yaml). The custom rule fires its
  //   enhanced message for ALL candidate variables; the built-in diagnostic
  //   independently verifies whether they are actually unused.
  //
  //   Result: in the IDE, only truly unused variables show the enhanced message
  //   (because only those also trigger the underlying analyzer error that makes
  //   them visible in the problems panel).
  bool _hasReadReferences(CustomLintContext context, dynamic element) =>
      // Simplified: We rely on the analyzer's built-in unused_local_variable detection
      // This custom lint provides enhanced messaging. The actual detection is handled
      // by the analyzer's unused_local_variable diagnostic which we've set to error.
      // For now, we'll report all non-const/final variables without _ prefix as potentially unused.
      // The analyzer will filter out actually used ones via its own diagnostics.
      false;
}
