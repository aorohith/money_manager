enum ImportDiagnosticSeverity { warning, error }

class ImportDiagnostic {
  const ImportDiagnostic({
    required this.rowNumber,
    required this.message,
    this.severity = ImportDiagnosticSeverity.error,
  });

  final int rowNumber;
  final String message;
  final ImportDiagnosticSeverity severity;

  bool get isError => severity == ImportDiagnosticSeverity.error;
}
