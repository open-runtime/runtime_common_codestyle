// runtime_common_codestyle — Public API barrel file
//
// This package provides two separate integration mechanisms for consumers:
//
//   1. YAML configuration (NOT via Dart exports):
//      Consumers add `include: package:runtime_common_codestyle/recommended.yaml`
//      to their analysis_options.yaml. This enables all analyzer rule overrides,
//      the custom_lint plugin, and lint_hard rules. No Dart import needed.
//
//   2. Dart plugin registration (via this file):
//      The `createPlugin` function is the entry point called by the custom_lint
//      runner. When `dart run custom_lint` executes, it looks for this exported
//      symbol to load the plugin. DO NOT rename or remove createPlugin.
//
// Consumers do not typically import this package in Dart code. The export
// exists so custom_lint can discover and instantiate the plugin.

// Plugin factory — required by the custom_lint framework to bootstrap this plugin.
// custom_lint calls createPlugin() to get the PluginBase instance, then calls
// getLintRules() on it to discover which DartLintRule instances to register.
export 'custom_lints/plugin.dart' show createPlugin;

// Custom lint rule classes — exported so consumers can reference them in
// analysis_options.yaml rule configuration and in ignore comments.
// Each class name corresponds to one active lint rule in the plugin.
export 'custom_lints/prefer_for_in_over_foreach_lint.dart' show PreferForInOverForEachLint;
export 'custom_lints/require_closure_parameter_types_lint.dart' show RequireClosureParameterTypesLint;
export 'custom_lints/require_explicit_type_annotations_lint.dart' show RequireExplicitTypeAnnotationsLint;
export 'custom_lints/require_show_hide_in_exports_lint.dart' show RequireShowHideInExportsLint;
export 'custom_lints/unused_variable_lint.dart' show UnusedVariableLint;
// Note: UnusedElementLint is intentionally NOT exported here — it is a placeholder
// whose run() body is empty. Exporting it would confuse consumers into thinking it
// actively detects unused elements; that detection is handled by the built-in
// `unused_element` analyzer diagnostic configured in recommended.yaml.
