/// Registry of Hive typeIds used by this app.
///
/// typeIds and field indexes are a storage contract with data already on
/// players' devices:
/// * never reuse a typeId, even after the type is deleted — list it under
///   "Retired" instead;
/// * never reuse a field index; add fields with the next unused index and
///   leave gaps when removing;
/// * changing a field's type needs a migration step in bootstrap.
///
/// No custom type is stored yet: settings are primitives (bool/String), which
/// Hive handles without adapters. When a type needs one, declare it with
/// hive_ce's `@GenerateAdapters([AdapterSpec<Foo>()])` in
/// `core/services/database/hive_adapters.dart`, pass
/// `reservedTypeIds: HiveTypeIds.reserved`, run build_runner, commit the
/// generated `hive_adapters.g.yaml` schema (it pins every typeId and field
/// index), record the id below and call `Hive.registerAdapters()` in
/// `HiveDatabaseService.open`.
abstract final class HiveTypeIds {
  /// Ids registered by `Hive.initFlutter()` for Flutter's `Color` (200) and
  /// `TimeOfDay` (201) adapters (hive_ce_flutter). Never assign these.
  static const Set<int> reserved = {200, 201};

  // Assigned: none yet. Next free id: 0.
  // Retired: none.
}
