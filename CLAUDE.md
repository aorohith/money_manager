# Claude Code Guide — Money Manager

Personal finance Flutter app: local-first (Isar), PIN/biometric auth, SMS transaction parsing (Android), budgets, goals, analytics, import.

## Read first

| Resource | Use for |
|----------|---------|
| [dev/docs/README.md](dev/docs/README.md) | Full module doc index |
| [dev/docs/architecture/data-model.md](dev/docs/architecture/data-model.md) | All Isar collections + relationships |
| [dev/docs/architecture/overview.md](dev/docs/architecture/overview.md) | Clean Architecture, Riverpod, feature-first layout |
| [AGENTS.md](AGENTS.md) | Agent workflow checklist (also applies here) |

## Stack

- **Flutter / Dart** — `lib/` is source, `test/` is tests
- **Isar** — local DB; run `dart run build_runner build --delete-conflicting-outputs` after any `@collection` change
- **Riverpod** — state management; providers in `domain/providers/`
- **GoRouter** — routing; shell in `core/router/`
- **Clean Architecture** — `data/` (models, repos) → `domain/` (providers, services) → `presentation/` (screens, widgets)

## Before you finish any task

1. **Tests** — add happy-path + edge case + regression tests; run them; confirm passing.
2. **Docs** — update `dev/docs/` when behaviour, routes, or data model changed (see table below).
3. **Rules** — update `.cursor/rules/` if you found a new repeatable pattern or a stale rule.
4. **Summary** — end with **"What I learned / unlearned"** (file paths or explicit *none*).

### Docs update table

| Change | Doc(s) to update |
|--------|-----------------|
| New / changed Isar collection or field | `dev/docs/architecture/data-model.md` + `main.dart` schema list in that doc |
| New / changed route | Feature doc route table + `dev/docs/architecture/navigation-and-auth.md` |
| New / changed feature behaviour | `dev/docs/features/<feature>.md` |
| New / changed `lib/core/*` | `dev/docs/core/<module>.md` |
| New platform / Kotlin channel | `dev/docs/platform/` |
| New test layout or corpus | `dev/docs/testing/` |

Use the 9-section template (Purpose, Entry points, Folder map, Key types, Data flow, Dependencies, How to extend, Tests, Related docs) for any new doc page.

---

## Always-applied rules

These rules fire on every task. Read them carefully — they encode hard-won lessons.

### 1 · Testing discipline

Every behaviour change ships with:
- A **happy-path** test.
- At least one **edge / error** test (empty, boundary, async failure).
- A **regression** test for any area the change touches indirectly.

Run `dart analyze` + `flutter test` on touched files before declaring done.

### 2 · Single source of truth for constants

If a value appears in more than one file, or a user-facing string contains it, it must live in a single `abstract final class` constant:
- Feature-scoped → `lib/features/<feature>/domain/<feature>_config.dart`
- App-wide → `lib/core/constants/`

Never redeclare `static const _pinLength = 4` per screen. Every screen, validator, formatter, and copy string reads from the shared constant.

### 3 · Variable-content layout safety (Flutter)

Any `Column`/`ListView`/sheet that renders data-driven content **must** be safe for 20+ items on a short-height viewport.

**Modal bottom sheets:**
```dart
showModalBottomSheet(
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.85),
  builder: (ctx) => LayoutBuilder(
    builder: (ctx, constraints) => SizedBox(
      height: constraints.maxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Text('Title'),
          Expanded(child: ListView.separated(key: Key('list'), ...)),
          FilledButton(...),
        ],
      ),
    ),
  ),
);
```

- **Never** size the sheet body from parent `MediaQuery.height * X` — the drag handle and safe-area inset eat ~52 px inside the sheet.
- **Never** add an inner `SafeArea`; `useSafeArea: true` already handles it.
- Long text beside a growing sibling → `Expanded + maxLines: 1 + TextOverflow.ellipsis`.

### 4 · Date-range boundary safety

Isar date filters must use an **inclusive lower bound**:
```dart
.dateGreaterThan(from, include: true)  // ✅  includes midnight
.dateLessThan(to)                       // ✅  exclusive upper bound
```
Using `.dateGreaterThan(from)` (exclusive) drops expenses logged exactly at midnight — the bug we hit in analytics.

### 5 · Icon tree-shake safety

Never call `IconData(dynamicValue, fontFamily: 'MaterialIcons')` at runtime. Persist `icon.codePoint`; resolve via a central `codePoint → const Icons.*` map with a fallback:
```dart
static IconData fromCodePoint(int cp) => _icons[cp] ?? Icons.category_rounded;
```

### 6 · Android compileSdk compatibility

In `android/build.gradle.kts`, enforce a minimum compileSdk for all library subprojects so transitive plugins don't fail with `resource android:attr/lStar not found`:
```kotlin
subprojects {
  afterEvaluate {
    if (project.plugins.hasPlugin("com.android.library")) {
      extensions.configure<com.android.build.gradle.LibraryExtension> {
        if (compileSdk < 34) compileSdk = 34
      }
    }
  }
}
```

### 7 · SMS merchant extraction

Indian DLT bank SMS put the counterparty in many positions: `by NAME`, `Info.VPS*MERCHANT`, `Beneficiary:`, `NAME credited`, `to VPA@handle`. Always use the priority-ordered extraction chain in `lib/core/sms/extraction/merchant_extractor.dart`.

Key pitfalls:
- **`to` inside merchant names** — use `(?<![A-Za-z])to\s+` so "ZOMATO" doesn't match.
- **Amount regex** — use `\d+(?:,\d{2,3})*(?:\.\d{1,2})?`; `\d{1,3}` silently truncates values like `1000`.
- **UPI VPA extraction** — `standaloneVpaRe` captures numeric handles like `9562802757@superyes`; threading `counterpartyVpa` into `MerchantIdentityModel.upiHandles` links cross-app payments.
- Add a corpus fixture for every new SMS template before shipping regex changes (`test/fixtures/sms_corpus/corpus.json`).

### 8 · PDF export unicode safety

Always embed a Unicode font (Noto Sans from assets) via `pw.ThemeData.withFont`. Set an explicit `maxPages` on `pw.MultiPage`. Default Helvetica does not render `₹`.

### 9 · Learn / unlearn — keep the rulebook sharp

- **Learn:** every bug, surprise test failure, or non-obvious invariant → add or extend `.cursor/rules/<topic>.mdc` AND add a regression test.
- **Unlearn:** every stale, wrong, or duplicated rule → rewrite or delete it in the **same task**.
- Never leave a rule marked "deprecated" in the folder — either fix it or delete it.
- Every task summary MUST include a **"What I learned / unlearned"** section.

---

## Isar schema checklist (when adding/changing collections)

1. Add / edit the `@collection` class under `lib/features/<feature>/data/models/`.
2. Run `dart run build_runner build --delete-conflicting-outputs`.
3. Add `MyModelSchema` to `IsarService.open([...])` in `lib/main.dart`.
4. Update `dev/docs/architecture/data-model.md` (collections table + relationships diagram).

---

## What I learned / unlearned (session that created this file)

- **Docs:** `dev/docs/architecture/data-model.md` updated — added `MerchantIdentityModel` (9th collection). SMS docs updated for merchant resolver and VPA extraction.
- **Rules:** `.cursor/rules/sms-merchant-extraction.mdc` extended with UPI VPA extraction notes.
- **Learned:** `MerchantIdentityModel` requires `@Index()` on `nameAliases` and `upiHandles` (list fields) for Isar element-level queries to work.
- **Learned:** `standaloneVpaRe` must precede the name-extraction loop so numeric VPAs (`9562802757@superyes`) are captured even when no merchant name is found.
- **Unlearned:** none.
