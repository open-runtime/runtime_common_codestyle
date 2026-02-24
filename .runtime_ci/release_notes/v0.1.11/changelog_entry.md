## [0.1.11] - 2026-02-24

### Added
- Added runtime_ci_tooling generated files including CLAUDE.md, SETUP.md, USAGE.md, .gemini commands, and GitHub workflows

### Changed
- Aligned custom_lint_builder constraints for workspace, moved it to dependencies as a git package from open-runtime fork, and added publish_to: none
- Updated runtime_ci_tooling dependency to ^0.12.0 and regenerated CI workflow

### Fixed
- Avoid deprecated LintCode name getters to make lint code version-stable (#17)
- Fixed all analyzer lint issues by removing invalid strict-casts/inference/raw-types language options from the errors section in recommended.yaml