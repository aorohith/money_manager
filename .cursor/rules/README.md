# Project Rulebook

This folder contains Cursor rules (`*.mdc` files) that the agent must
follow on every turn. The rulebook is **designed to be portable across
projects** — each rule cleanly separates the universal *principle* from
the stack-specific *recipe*, so dropping it into a new repo only
requires swapping one or two files.

## Layered design

Rules live in two layers:

| Layer | Purpose | Portable? | Files |
|---|---|---|---|
| **Process** | How we work (testing discipline, capturing lessons) | Yes — drop into any project as-is | `mandatory-testing-for-features.mdc`, `learn-from-mistakes.mdc` |
| **Principle** | Framework-agnostic engineering principles | Yes — drop in as-is | `variable-content-layout-safety.mdc` |
| **Recipe** | Stack-specific implementation of a principle | No — replace per project | `flutter-overflow-safety.mdc` |

Recipes always link back to the principle rule that owns the "why".
When you port the rulebook to a new project, you keep the process and
principle layers untouched and write a new recipe layer for the new
stack (`react-overflow-safety.mdc`, `swiftui-overflow-safety.mdc`,
etc.).

## Index

- **`mandatory-testing-for-features.mdc`** — every behaviour change
  ships with happy-path + edge-case + regression tests, all run and
  passing before declaring done.
- **`learn-from-mistakes.mdc`** — every reported bug or missed test
  triggers a **learn** action (capture the lesson) AND every stale or
  wrong rule triggers an **unlearn** action (revise or delete). The
  rulebook grows AND shrinks; both directions are mandatory.
- **`variable-content-layout-safety.mdc`** — universal layout
  principles for any data-driven UI surface (lists, sheets, dialogs).
- **`flutter-overflow-safety.mdc`** — Flutter recipe implementing the
  layout-safety principles above.

## Porting to a new project

Step-by-step:

1. **Copy the process layer as-is**:
   - `mandatory-testing-for-features.mdc`
   - `learn-from-mistakes.mdc`
   - `README.md` (this file)

2. **Copy the principle layer as-is**:
   - `variable-content-layout-safety.mdc`
   - …and any other `*-principle` files you've added since.

3. **Replace the recipe layer**. Delete the stack-specific files
   (e.g. `flutter-*.mdc`) and write new ones for your stack:
   - Match the naming pattern `<stack>-<topic>.mdc`
     (`react-overflow-safety.mdc`, `nextjs-overflow-safety.mdc`, …).
   - Open the principle rule, list each principle, and write the
     stack-specific recipe.
   - Update the `globs:` frontmatter to match the new project's source
     paths (e.g. `src/**/*.{ts,tsx}`).

4. **Adjust paths**. Each rule references one or two project-specific
   conventions — check for:
   - Test directory layout (`test/`, `__tests__/`, `tests/`, …).
   - Source directory (`lib/`, `src/`, `app/`, …).
   - Test runner (`flutter test`, `npm test`, `pytest`, …).

5. **Sanity-check `globs:` frontmatter** on every `.mdc` file so rules
   only attach to relevant files.

## Adding a new rule

Use the `create-rule` skill (see `~/.cursor/skills-cursor/create-rule/`
or the user's plugin equivalent). Decide which layer the rule belongs
to before writing it:

- **Process / principle** → no project-specific paths, no framework
  APIs. Write it once and forget about it.
- **Recipe** → name it `<stack>-<topic>.mdc` and have it reference the
  principle rule it implements.

Every rule must include:

- One-sentence `description:` in frontmatter (used by the agent picker).
- Concrete do/don't examples (no vague "be careful with X").
- A test pattern that catches the failure mode the rule prevents.

## Maintenance — learn AND unlearn

This rulebook is a living document. Per `learn-from-mistakes.mdc`:

- **Learn** — every bug or regression triggers an extended rule, a
  new rule, or a stronger test.
- **Unlearn** — every stale, wrong, or noisy rule must be revised or
  deleted. A rule that hasn't prevented a bug but creates friction is
  net-negative; remove it.

Over time the rulebook should *converge* on the team's actual hard-won
knowledge — not just *grow* into a pile of generic best-practice
slogans. If the rulebook is bigger this month than last but didn't
prevent any new bugs, you're doing it wrong.
