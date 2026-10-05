import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';

import 'package:bloc/bloc.dart';
// `show`: a full foundation import makes freezed mix DiagnosticableTreeMixin
// into LanguageState.
import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';
import 'package:nesty_game/core/services/database/database_service.dart';
import 'package:nesty_game/core/services/database/settings_schema.dart';

export 'package:nesty_game/app/localization_cubit/app_locale_resolver.dart';

part 'language_cubit.freezed.dart';
part 'language_state.dart';

/// App-wide locale (spec §10.2 #13 "language", §16).
///
/// The persisted value in [DatabaseService] is the source of truth: this
/// cubit seeds from it and follows its `languageStream`, so a change written
/// from anywhere re-renders the app. A fresh install stores nothing and
/// reads [LocaleSetting.system], which follows the phone's languages
/// ([deviceLocalesChanged], fed by `App`); a language picked in the sheet
/// ([changeLanguage]) pins it. [AppLocaleResolver] turns either into
/// [LanguageState.currentLanguageCode], the language the app renders in.
@lazySingleton
class LanguageCubit extends Cubit<LanguageState> {
  /// [resolver] defaults to [AppLocaleResolver.app] (the catalogs present)
  /// and [deviceLocales] to the engine's list at creation; `App` then feeds
  /// the binding's list and its changes. Tests pass both.
  LanguageCubit(
    DatabaseService database, {
    @ignoreParam AppLocaleResolver? resolver,
    @ignoreParam List<Locale>? deviceLocales,
  }) : this._(
         database,
         resolver ?? AppLocaleResolver.app,
         deviceLocales ?? AppLocaleResolver.platformLocales(),
       );

  LanguageCubit._(
    DatabaseService database,
    AppLocaleResolver resolver,
    List<Locale> deviceLocales,
  ) : _database = database,
      _resolver = resolver,
      _deviceLocales = List.unmodifiable(deviceLocales),
      super(
        _initialState(
          database.languageCode,
          resolver.resolve(database.languageCode, deviceLocales),
        ),
      ) {
    _subscription = _database.languageStream.listen(
      (code) => emit(
        state.copyWith(
          storedLanguageCode: code,
          currentLanguageCode: _resolve(code),
        ),
      ),
    );
  }

  static LanguageState _initialState(String stored, String current) =>
      LanguageState(
        storedLanguageCode: stored,
        currentLanguageCode: current,
        selectedLanguageCode: current,
      );

  final DatabaseService _database;
  final AppLocaleResolver _resolver;
  List<Locale> _deviceLocales;
  late final StreamSubscription<String> _subscription;

  Locale get currentLocale => state.locale;

  void selectLanguage(String languageCode) =>
      emit(state.copyWith(selectedLanguageCode: languageCode, hasError: false));

  /// The phone's preferred languages changed (or `App` read them at
  /// start-up): re-resolves, which only changes the rendered language while
  /// it follows the phone or its pinned language has no catalog.
  void deviceLocalesChanged(List<Locale> locales) {
    _deviceLocales = List.unmodifiable(locales);
    final current = _resolve(state.storedLanguageCode);
    if (current == state.currentLanguageCode) return;
    emit(
      state.copyWith(
        currentLanguageCode: current,
        selectedLanguageCode: current,
      ),
    );
  }

  /// Pins [languageCode] (a sheet tap; [LocaleSetting.system] goes back to
  /// following the phone), applying it optimistically, then persists it.
  ///
  /// Applying first makes the emitted states deterministic: the store's
  /// stream echo of the same code then equals the current state and Cubit
  /// drops it, whenever it arrives. A failed write rolls back.
  Future<void> changeLanguage(String languageCode) async {
    final previous = state;
    final current = _resolve(languageCode);
    emit(
      state.copyWith(
        storedLanguageCode: languageCode,
        currentLanguageCode: current,
        selectedLanguageCode: current,
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

  String _resolve(String setting) => _resolver.resolve(setting, _deviceLocales);

  @override
  @disposeMethod
  Future<void> close() async {
    await _subscription.cancel();
    return super.close();
  }
}
