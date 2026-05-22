# Changelog

All notable changes to this project are documented in this file.

## [Unreleased]

### Added
- Repository governance baseline documents:
  - `CONTRIBUTING.md`
  - `SECURITY.md`
  - `SUPPORT.md`
  - `CODE_OF_CONDUCT.md`
  - `CODEOWNERS`
- Expanded issue and pull request templates
- CI workflow for Nginx and shell syntax validation

### Changed
- Fixed invalid Dependabot configuration to monitor GitHub Actions updates
- Fixed invalid regex in `nginx/snippets/8G_firewall.conf` that caused `nginx -t` failure
