# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.12] - 2026-02-24

### Fixed
- Added `--repo` + org allowlist to triage.toml to prevent upstream leakage

## [0.1.11] - 2026-02-24

### Added
- Added runtime_ci_tooling generated files including CLAUDE.md, SETUP.md, USAGE.md, .gemini commands, and GitHub workflows

### Changed
- Aligned custom_lint_builder constraints for workspace, moved it to dependencies as a git package from open-runtime fork, and added publish_to: none
- Updated runtime_ci_tooling dependency to ^0.12.0 and regenerated CI workflow

### Fixed
- Avoid deprecated LintCode name getters to make lint code version-stable (#17)
- Fixed all analyzer lint issues by removing invalid strict-casts/inference/raw-types language options from the errors section in recommended.yaml

## [0.1.5](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.4...v0.1.5) (2025-12-03)


### Miscellaneous

* auto-release runtime_common_codestyle ([66d077e](https://github.com/open-runtime/runtime_common_codestyle/commit/66d077e6c16b9b5dba872c3059d5067829b4026f))
* **runtime_common_codestyle:** upgrade lint_hard to ^6.0.0 and move custom_lint packages to dev_dependencies ([#14](https://github.com/open-runtime/runtime_common_codestyle/issues/14)) ([7f46fbe](https://github.com/open-runtime/runtime_common_codestyle/commit/7f46fbed5fe6393f43c719083340e7ff5729121e))

## [0.1.4](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.3...v0.1.4) (2025-12-03)


### Miscellaneous

* auto-release runtime_common_codestyle ([#10](https://github.com/open-runtime/runtime_common_codestyle/issues/10)) ([96c493f](https://github.com/open-runtime/runtime_common_codestyle/commit/96c493fd46f302ae562274bdd352787efe2d62d0))
* **runtime_common_codestyle:** add .gitignore and remove generated files ([3a80c4b](https://github.com/open-runtime/runtime_common_codestyle/commit/3a80c4bf0f7e8134e72a17f7bbe5aa1cbb89ec2a))

## [0.1.3](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.2...v0.1.3) (2025-12-03)


### Features

* **runtime_common_codestyle:** add unused element lint and improve closure parameter type detection ([9ba4faf](https://github.com/open-runtime/runtime_common_codestyle/commit/9ba4faff56add6c700e452f051669782eeeefa53))


### Bug Fixes

* resolve merge conflict in .dart_tool/package_graph.json ([939d6e5](https://github.com/open-runtime/runtime_common_codestyle/commit/939d6e521542f0163984668a4fdd5f6bf32680ed))
* resolve merge conflicts with main ([191ed38](https://github.com/open-runtime/runtime_common_codestyle/commit/191ed38e2edb54eca534aae4e8a03d01e81e51c6))
* **runtime_common_codestyle:** add missing protobuf file exclusions and remove trailing whitespace ([0234d62](https://github.com/open-runtime/runtime_common_codestyle/commit/0234d621c89608e286abcf17111d663cbaec8e12))

## [0.1.2](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.1...v0.1.2) (2025-12-03)


### Bug Fixes

* address PR review comments ([#3](https://github.com/open-runtime/runtime_common_codestyle/issues/3)) ([ede760f](https://github.com/open-runtime/runtime_common_codestyle/commit/ede760f91f92ec58e4cd25e8fbe8e9fde4ec0d2e))

## [0.1.1](https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.0...v0.1.1) (2025-12-03)


### Features

* initial release of runtime_common_codestyle package ([d51c83c](https://github.com/open-runtime/runtime_common_codestyle/commit/d51c83cfc595bf0841440caea8a802204a6063c9))
* update codestyle rules - disable additional linter rules ([#2](https://github.com/open-runtime/runtime_common_codestyle/issues/2)) ([321584f](https://github.com/open-runtime/runtime_common_codestyle/commit/321584f4170acd63f12eb9a9bb3831d5039610d0))

## [0.1.0] - 2025-01-XX

### Features

- Initial release of `runtime_common_codestyle` package
- Centralized code style and analysis rules for OpenRuntime monorepo
- Enforces trailing commas, strong typing, and custom naming conventions
- Allows SCREAMING_SNAKE_CASE constants, PascalCase top-level declarations, and snake_case functions
- Configures strict type checking (strict-casts, strict-inference, strict-raw-types)
- Includes comprehensive exclusion patterns for generated files

### Documentation

- Added README.md with usage instructions and naming convention documentation

[0.1.12]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.11...v0.1.12
[0.1.11]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.5...v0.1.11
[0.1.5]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.4...v0.1.5
[0.1.4]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.3...v0.1.4
[0.1.3]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.2...v0.1.3
[0.1.2]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.1...v0.1.2
[0.1.1]: https://github.com/open-runtime/runtime_common_codestyle/compare/v0.1.0...v0.1.1
[0.1.0]: https://github.com/open-runtime/runtime_common_codestyle/releases/tag/v0.1.0
