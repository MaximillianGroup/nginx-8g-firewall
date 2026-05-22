# Contributing Guide

Thanks for improving `nginx-8g-firewall`.

## Before opening a pull request

1. Keep changes focused and minimal.
2. Update documentation when behavior or usage changes.
3. Run repository validations locally:
   - `bash -n install.sh`
   - `nginx -t` against your target deployment config
4. Ensure examples remain operational and deterministic.

## Pull request requirements

Pull requests should include:

- What changed
- Why it changed
- Risk level (low/medium/high)
- Validation evidence (commands + outcomes)
- Rollback plan when behavior changes

## Scope and standards

- Prefer production-safe defaults.
- Preserve compatibility unless a change is unsafe.
- Avoid dead code and orphaned docs.
- Do not commit temporary/debug files.
- Keep rule intent explicit and maintainable.

