// plugin.dart — custom_lint plugin entry point for runtime_common_codestyle
//
// This file is the root of the custom lint plugin system. When a consumer package
// runs `dart run custom_lint`, the framework:
//   1. Reads the consumer's analysis_options.yaml for `plugins: [custom_lint]`
//   2. Scans dev_dependencies for packages that export `createPlugin`
//   3. Calls createPlugin() to get the PluginBase instance
//   4. Calls getLintRules(configs) to get the list of active DartLintRule objects
//   5. Runs each rule's run() method against every Dart file in the consumer package
//
// To add a new lint rule:
//   1. Create lib/custom_lints/my_rule_lint.dart extending DartLintRule
//   2. Add it to the getLintRules() list below
//   3. Export it from runtime_common_codestyle.dart with `show MyRuleLint`

import 'package:custom_lint_builder/custom_lint_builder.dart' show CustomLintConfigs, LintRule, PluginBase;

import 'prefer_for_in_over_foreach_lint.dart' show PreferForInOverForEachLint;
import 'require_closure_parameter_types_lint.dart' show RequireClosureParameterTypesLint;
import 'require_explicit_type_annotations_lint.dart' show RequireExplicitTypeAnnotationsLint;
import 'require_show_hide_in_exports_lint.dart' show RequireShowHideInExportsLint;
import 'unused_variable_lint.dart' show UnusedVariableLint;

// createPlugin is the required entry point symbol discovered by the custom_lint framework.
// It must be a top-level function (not a method) and must return a PluginBase.
// The name `createPlugin` is a convention required by custom_lint — do not rename it.
PluginBase createPlugin() => _RuntimeCommonCodestylePlugin();

// _RuntimeCommonCodestylePlugin is private — consumers never instantiate it directly.
// The custom_lint framework holds the singleton returned by createPlugin().
class _RuntimeCommonCodestylePlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
    // Order matters for display in the IDE and CLI output but not for correctness.
    // Rules are listed from most impactful (unused code) to most stylistic (for-in preference).

    // Catches non-final, non-private variables that are never read —
    // often signals unfinished implementations that got abandoned mid-way.
    const UnusedVariableLint(),

    // Enforces explicit type annotations on all closure parameters —
    // prevents implicit `dynamic` types in map/where/forEach callbacks.
    const RequireClosureParameterTypesLint(),

    // Enforces explicit show/hide on export directives —
    // prevents accidental re-export of internal symbols.
    const RequireShowHideInExportsLint(),

    // Bans the `var` keyword — requires `final Type` or `const Type` —
    // makes all type information explicit and visible at the declaration site.
    const RequireExplicitTypeAnnotationsLint(),

    // Flags forEach with function literals and suggests better alternatives —
    // tear-offs, for-in loops, or collection-for syntax.
    const PreferForInOverForEachLint(),
  ];
}
