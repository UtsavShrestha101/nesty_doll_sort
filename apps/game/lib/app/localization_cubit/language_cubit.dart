import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bloc/bloc.dart';
// `show`: a full foundation import makes freezed mix DiagnosticableTreeMixin
// into LanguageState.
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';

part 'language_cubit.freezed.dart';
part 'language_state.dart';

/// App-wide locale (spec §10.2 #13 "language", §16).
///
/// The persisted value in [DatabaseService] is the source of truth: this
/// cubit seeds from it and follows its `languageStream`, so a change written
/// from anywhere re-renders the app.
@lazySingleton
class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit(DatabaseService database)
    : _database = database,
      super(
        LanguageState(
          currentLanguageCode: database.languageCode,
          selectedLanguageCode: database.languageCode,
        ),
      ) {
    _subscription = _database.languageStream.listen(
      (code) => emit(state.copyWith(currentLanguageCode: code)),
    );
  }

  final DatabaseService _database;
  late final StreamSubscription<String> _subscription;

  Locale get currentLocale => state.locale;

  void selectLanguage(String languageCode) =>
      emit(state.copyWith(selectedLanguageCode: languageCode, hasError: false));

  /// Applies [languageCode] optimistically, then persists it.
  ///
  /// Applying first makes the emitted states deterministic: the store's
  /// stream echo of the same code then equals the current state and Cubit
  /// drops it, whenever it arrives. A failed write rolls back.
  Future<void> changeLanguage(String languageCode) async {
    final previous = state;
    emit(
      state.copyWith(
        currentLanguageCode: languageCode,
        selectedLanguageCode: languageCode,
        isLoading: true,
        hasError: false,
      ),
    );
    try {
      await _database.setLanguage(languageCode);
      if (isClosed) return;
      emit(state.copyWith(isLoading: false));
    } on Object catch (error, stackTrace) {
      developer.log(
        'Failed to persist language $languageCode',
        name: 'nesty.language',
        error: error,
        stackTrace: stackTrace,
      );
      // developer.log never reaches the `flutter run` terminal.
      if (kDebugMode) {
        debugPrint('[nesty.language] persisting $languageCode failed: $error');
      }
      if (isClosed) return;
      emit(previous.copyWith(isLoading: false, hasError: true));
    }
  }

  @override
  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
