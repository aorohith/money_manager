import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:money_manager/core/database/isar_service.dart';
import 'package:money_manager/features/import/data/models/import_preview_row.dart';
import 'package:money_manager/features/import/data/models/import_session.dart';
import 'package:money_manager/features/import/data/services/import_service.dart';
import 'package:money_manager/features/import/domain/usecases/import_transactions_usecase.dart';

final importServiceProvider = Provider<ImportService>((ref) {
  return ImportService(ref.read(isarProvider));
});

final importTransactionsUseCaseProvider = Provider<ImportTransactionsUseCase>((
  ref,
) {
  return ImportTransactionsUseCase(ref.read(isarProvider));
});

final importControllerProvider =
    StateNotifierProvider<ImportController, ImportFlowState>((ref) {
      return ImportController(
        service: ref.read(importServiceProvider),
        importUseCase: ref.read(importTransactionsUseCaseProvider),
      );
    });

class ImportFlowState {
  const ImportFlowState({
    this.session,
    this.previewRows = const [],
    this.result,
    this.isLoading = false,
    this.errorMessage,
  });

  final ImportSession? session;
  final List<ImportPreviewRow> previewRows;
  final ImportCommitResult? result;
  final bool isLoading;
  final String? errorMessage;

  int get selectedCount => previewRows.where((row) => row.canCommit).length;
  int get duplicateCount => previewRows
      .where((row) => row.status == ImportPreviewStatus.duplicate)
      .length;
  int get errorCount => previewRows
      .where((row) => row.status == ImportPreviewStatus.error)
      .length;

  ImportFlowState copyWith({
    ImportSession? session,
    List<ImportPreviewRow>? previewRows,
    ImportCommitResult? result,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ImportFlowState(
      session: session ?? this.session,
      previewRows: previewRows ?? this.previewRows,
      result: result ?? this.result,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ImportController extends StateNotifier<ImportFlowState> {
  ImportController({
    required ImportService service,
    required ImportTransactionsUseCase importUseCase,
  }) : _service = service,
       _importUseCase = importUseCase,
       super(const ImportFlowState());

  final ImportService _service;
  final ImportTransactionsUseCase _importUseCase;

  Future<void> parse(File file) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final session = await _service.parse(file);
      final previewRows = await _service.buildPreview(session);
      state = ImportFlowState(session: session, previewRows: previewRows);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Import failed: $error',
      );
    }
  }

  void toggleRow(int index, bool selected) {
    final rows = [...state.previewRows];
    final row = rows[index];
    if (row.status == ImportPreviewStatus.error) return;
    rows[index] = row.copyWith(selected: selected);
    state = state.copyWith(previewRows: rows);
  }

  Future<void> commit() async {
    final session = state.session;
    if (session == null) return;

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final result = await _importUseCase(
        session: session,
        previewRows: state.previewRows,
      );
      state = state.copyWith(isLoading: false, result: result);
    } catch (error) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Commit failed: $error',
      );
    }
  }

  void reset() => state = const ImportFlowState();
}
