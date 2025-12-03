import 'package:custom_lint_builder/custom_lint_builder.dart';

import 'require_closure_parameter_types_lint.dart';
import 'require_explicit_type_annotations_lint.dart';
import 'require_show_hide_in_exports_lint.dart';
import 'unused_variable_lint.dart';

PluginBase createPlugin() => _RuntimeCommonCodestylePlugin();

class _RuntimeCommonCodestylePlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) => [
        const UnusedVariableLint(),
        const RequireClosureParameterTypesLint(),
        const RequireShowHideInExportsLint(),
        const RequireExplicitTypeAnnotationsLint(),
      ];
}
