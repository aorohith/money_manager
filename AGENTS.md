# Agent guide (Cursor & other AI tools)

This repo expects **every implementation chat** to improve persistent context, not only code.

## Read first

| Resource | Use for |
|----------|---------|
| [dev/docs/README.md](dev/docs/README.md) | Module docs index and doc sync checklist |
| [.cursor/rules/](.cursor/rules/) | Always-on constraints (`alwaysApply: true`) |

## Before you finish a task

1. **Code + tests** — `mandatory-testing-for-features.mdc`
2. **Docs** — Update `dev/docs/` when behaviour, routes, or data model changed (`keep-context-in-sync.mdc`)
3. **Rules** — Learn/unlearn in `.cursor/rules/` when patterns or mistakes should persist (`learn-from-mistakes.mdc`)
4. **Summary** — End with **"What I learned / unlearned"** (docs + rules paths, or explicit *none*)

## Always-applied rules (high signal)

- `keep-context-in-sync.mdc` — docs + rules + summary discipline
- `learn-from-mistakes.mdc` — capture lessons; prune stale rules
- `mandatory-testing-for-features.mdc` — tests and verification
- `single-source-of-truth-constants.mdc` — shared tunables in one place
- `variable-content-layout-safety.mdc` + `flutter-overflow-safety.mdc` — UI overflow

File-scoped rules (e.g. `sms-merchant-extraction.mdc`) apply when matching paths are in scope.

## Doc template (new module pages)

Follow the nine sections in [dev/docs/README.md](dev/docs/README.md): Purpose, Entry points, Folder map, Key types, Data flow, Dependencies, How to extend, Tests, Related docs.
