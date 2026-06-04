# Developer resources

Non-app code and documentation — kept out of the repo root for a cleaner layout.

| Path | Contents |
|------|----------|
| [docs/README.md](docs/README.md) | Module documentation index |
| [tool/](tool/) | CLI scripts (SMS corpus debug, import sample cleaner) |
| [TESTING.md](TESTING.md) | Testing standards and pre-merge gate |

## Tools

```bash
# SMS parser corpus debug (from repo root)
dart run dev/tool/corpus_debug.dart

# Clean 1Money Excel export for import testing
python3 dev/tool/clean_import_sample.py --src /path/to/export.xlsx --out /path/to/cleaned.xlsx
```
