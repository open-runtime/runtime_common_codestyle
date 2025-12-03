import 'package:custom_lint_builder/custom_lint_builder.dart' show CustomLintConfigs, LintRule, PluginBase;

import 'prefer_for_in_over_foreach_lint.dart' show PreferForInOverForEachLint;
import 'require_closure_parameter_types_lint.dart' show RequireClosureParameterTypesLint;
import 'require_explicit_type_annotations_lint.dart' show RequireExplicitTypeAnnotationsLint;
import 'require_show_hide_in_exports_lint.dart' show RequireShowHideInExportsLint;
import 'unused_variable_lint.dart' show UnusedVariableLint;

PluginBase createPlugin() => _RuntimeCommonCodestylePlugin();

class _RuntimeCommonCodestylePlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const UnusedVariableLint(),
        const RequireClosureParameterTypesLint(),
        const RequireShowHideInExportsLint(),
        const RequireExplicitTypeAnnotationsLint(),
        const PreferForInOverForEachLint(),
      ];
}
