import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:nesty_core/nesty_core.dart';
import 'package:nesty_game/core/models/booster.dart';
import 'package:nesty_game/core/models/play_request.dart';
import 'package:nesty_game/core/services/clock/local_date.dart';
import 'package:nesty_game/core/services/save/save_document.dart';
import 'package:nesty_game/core/services/save/save_migrations.dart';

/// Why a stored document was read the way it was (docs/plans/m3-design.md
/// §3.3). Anything but [current] and [absent] means `SaveService` backs the
/// raw text up before its first write.
enum SaveReadKind {
  /// Nothing was stored: a fresh install.
  absent,

  /// A document of the current schema.
  current,

  /// An older schema, migrated forward.
  migrated,

  /// A newer schema (a downgrade): read what is readable.
  newer,

  /// Not JSON, or not a JSON object: the defaults.
  invalid,
}

/// What [SaveDocumentCodec.read] made of the stored text.
@immutable
final class SaveReadResult {
  const SaveReadResult({
    required this.document,
    required this.kind,
    required this.storedSchema,
  });

  /// The document to play with. Never null: an unusable input gives the
  /// fresh-install defaults.
  final SaveDocument document;

  final SaveReadKind kind;

  /// The stored `schema`: [SaveMigrations.noDocument] when absent, and for
  /// an invalid document or one without a readable `schema`, the schema it
  /// was read as.
  final int storedSchema;

  /// The raw text must be kept under `SaveBoxKeys.backup` before the first
  /// overwrite (m3-design §3.2).
  bool get needsBackup =>
      kind == SaveReadKind.migrated ||
      kind == SaveReadKind.newer ||
      kind == SaveReadKind.invalid;

  @override
  String toString() => 'SaveReadResult(${kind.name}, schema $storedSchema)';
}

/// The save document to JSON and back, by hand (no json_serializable;
/// docs/plans/m3-design.md §3.3; schema 2's fields, docs/plans/
/// m7-design.md §3.2; schema 3's `loginGift`, docs/plans/
/// plan-login-gift.md §7.5b).
///
/// Reads are lenient and never throw: a value of the wrong type or out of
/// range falls back to its default, list entries that can't be read are
/// skipped, and top-level keys this schema doesn't know are kept in
/// [SaveDocument.unknown] and written back by [encode]. Unknown keys inside
/// nested objects are dropped (a later schema that nests new fields
/// migrates them).
abstract final class SaveDocumentCodec {
  /// Parses, migrates and decodes the stored [text] (null: nothing
  /// stored).
  static SaveReadResult read(String? text) {
    if (text == null) {
      final migrated = SaveMigrations.migrate(
        const {},
        SaveMigrations.noDocument,
      );
      return SaveReadResult(
        document: decode(migrated),
        kind: SaveReadKind.absent,
        storedSchema: SaveMigrations.noDocument,
      );
    }
    Object? json;
    try {
      json = jsonDecode(text);
    } on FormatException {
      json = null;
    }
    if (json is! Map) {
      return const SaveReadResult(
        document: SaveDocument(),
        kind: SaveReadKind.invalid,
        storedSchema: SaveDocument.currentSchema,
      );
    }
    final raw = _stringKeyed(json);
    // A document without a readable schema is read as the current one.
    final stored = _intOrNull(raw['schema']) ?? SaveDocument.currentSchema;
    if (stored < SaveDocument.currentSchema) {
      return SaveReadResult(
        document: decode(SaveMigrations.migrate(raw, stored < 0 ? 0 : stored)),
        kind: SaveReadKind.migrated,
        storedSchema: stored,
      );
    }
    return SaveReadResult(
      document: decode(raw),
      kind: stored > SaveDocument.currentSchema
          ? SaveReadKind.newer
          : SaveReadKind.current,
      storedSchema: stored,
    );
  }

  /// [doc] as the stored text: [encode], then `jsonEncode`.
  static String write(SaveDocument doc) => jsonEncode(encode(doc));

  /// The JSON object of [doc]: the known keys in the order of
  /// m3-design §3.1 and m7-design §3.1 (schema 3's `loginGift`, schema 4's `dailyArchive` last), then
  /// [SaveDocument.unknown]'s keys
  /// sorted by code unit, so the text is stable. `schema` is always
  /// [SaveDocument.currentSchema].
  static Map<String, Object?> encode(SaveDocument doc) {
    final unknown = doc.unknown.keys.where((k) => !_known.contains(k)).toList()
      ..sort();
    return {
      'schema': SaveDocument.currentSchema,
      'currentLevel': doc.currentLevel,
      'highestLevel': doc.highestLevel,
      'coins': doc.coins,
      'inventory': {'hint': doc.inventory.hint, 'slot': doc.inventory.slot},
      'adsRemoved': doc.adsRemoved,
      'ownedSkins': doc.ownedSkins,
      'selectedSkin': doc.selectedSkin,
      'ownedThemes': doc.ownedThemes,
      'selectedTheme': doc.selectedTheme,
      'museum': doc.museum,
      'museumCollected': {
        for (final MapEntry(:key, :value) in doc.museumCollected.entries)
          key: value.toIso(),
      },
      'daily': _encodeDaily(doc.daily),
      'inProgress': _encodeInProgress(doc.inProgress),
      'adCounters': {
        'winsSinceInterstitial': doc.adCounters.winsSinceInterstitial,
        'lastAdAt': doc.adCounters.lastAdAt,
        'interstitialsShown': doc.adCounters.interstitialsShown,
      },
      'stats': {
        'wins': doc.stats.wins,
        'moves': doc.stats.moves,
        'boostersUsed': doc.stats.boostersUsed,
      },
      'seenIntros': doc.seenIntros,
      'tutorialDone': doc.tutorialDone,
      'bonus': {'next': doc.bonus.next},
      'playerId': doc.playerId,
      'levelBests': doc.levelBests,
      'levelStars': doc.levelStars,
      'starTipShown': doc.starTipShown,
      'records': {
        'families': doc.records.families,
        'dolls': doc.records.dolls,
        'dailies': doc.records.dailies,
        'longestRun': doc.records.longestRun,
        'badges': doc.records.badges,
      },
      'chests': {
        'opened': doc.chests.opened,
        'bonusOpened': doc.chests.bonusOpened,
      },
      'race': {
        'rivals': [
          for (final rival in doc.race.rivals)
            {
              'unlocked': rival.unlocked,
              'wins': rival.wins,
              'raceNo': rival.raceNo,
            },
        ],
      },
      'loginGift': {
        'claims': doc.loginGift.claims,
        'lastClaim': doc.loginGift.lastClaim?.toIso(),
        'latestSeen': doc.loginGift.latestSeen?.toIso(),
      },
      'dailyArchive': {
        'played': [for (final date in doc.dailyArchive.played) date.toIso()],
        'inProgress': _encodeInProgress(doc.dailyArchive.inProgress),
      },
      for (final key in unknown) key: doc.unknown[key],
    };
  }

  /// A document from [raw], leniently (see the class doc). [raw] is taken
  /// as already migrated: its `schema` is not checked.
  static SaveDocument decode(Map<String, Object?> raw) {
    const defaults = SaveDocument();
    final currentLevel = _int(raw['currentLevel'], defaults.currentLevel, 1);
    final ownedSkins = _ids(raw['ownedSkins'], SaveDocument.defaultSkin);
    final selectedSkin = _string(raw['selectedSkin']);
    final ownedThemes = _ids(raw['ownedThemes'], SaveDocument.defaultTheme);
    final museum = _ids(raw['museum'], null);
    return SaveDocument(
      currentLevel: currentLevel,
      highestLevel: _int(raw['highestLevel'], currentLevel, currentLevel),
      coins: _int(raw['coins'], defaults.coins, 0),
      inventory: _decodeInventory(raw['inventory']),
      adsRemoved: _bool(raw['adsRemoved'], defaults.adsRemoved),
      ownedSkins: ownedSkins,
      selectedSkin: selectedSkin != null && ownedSkins.contains(selectedSkin)
          ? selectedSkin
          : SaveDocument.defaultSkin,
      ownedThemes: ownedThemes,
      selectedTheme: _string(raw['selectedTheme']),
      museum: museum,
      museumCollected: _decodeDates(raw['museumCollected'], museum),
      daily: _decodeDaily(raw['daily']),
      inProgress: _decodeInProgress(raw['inProgress']),
      adCounters: _decodeAdCounters(raw['adCounters']),
      stats: _decodeStats(raw['stats']),
      seenIntros: _ids(raw['seenIntros'], null),
      tutorialDone: _bool(raw['tutorialDone'], defaults.tutorialDone),
      bonus: BonusProgress(next: _int(_map(raw['bonus'])?['next'], 1, 1)),
      playerId: _playerId(raw['playerId']),
      levelBests: _decodeBests(raw['levelBests']),
      levelStars: _decodeStars(raw['levelStars']),
      starTipShown: _bool(raw['starTipShown'], defaults.starTipShown),
      records: _decodeRecords(raw['records']),
      chests: _decodeChests(raw['chests']),
      race: _decodeRace(raw['race']),
      loginGift: _decodeLoginGift(raw['loginGift']),
      dailyArchive: _decodeArchive(raw['dailyArchive']),
      unknown: {
        for (final MapEntry(:key, :value) in raw.entries)
          if (!_known.contains(key)) key: value,
      },
    );
  }

  /// A player id as the Settings footer shows it: 8 hex digits in two
  /// groups, `7F3A-21C9` (frame 8.1).
  static final RegExp playerIdPattern = RegExp(r'^[0-9A-F]{4}-[0-9A-F]{4}$');

  static const Set<String> _known = {
    'schema',
    'currentLevel',
    'highestLevel',
    'coins',
    'inventory',
    'adsRemoved',
    'ownedSkins',
    'selectedSkin',
    'ownedThemes',
    'selectedTheme',
    'museum',
    'museumCollected',
    'daily',
    'inProgress',
    'adCounters',
    'stats',
    'seenIntros',
    'tutorialDone',
    'bonus',
    'playerId',
    // Schema 2 (m7-design §3.1; the star rating's two, P3.4).
    'levelBests',
    'levelStars',
    'starTipShown',
    'records',
    'chests',
    'race',
    // Schema 3 (plan-login-gift §7.5b).
    'loginGift',
    'dailyArchive',
    // Spec §13.3 lists `settings`, but they live in the settings box
    // (m3-design §3.1): a stray one is dropped, never written back.
    'settings',
  };

  // --- Nested objects --------------------------------------------------

  static BoosterInventory _decodeInventory(Object? value) {
    final map = _map(value);
    // A missing inventory is a fresh install's; a bad count inside a real
    // one is 0, so a damaged save never hands boosters out again.
    if (map == null) return const BoosterInventory();
    return BoosterInventory(
      hint: _int(map[BoosterKind.hint.storageKey], 0, 0),
      slot: _int(map[BoosterKind.extraSlot.storageKey], 0, 0),
    );
  }

  static Map<String, Object?> _encodeDaily(DailyProgress daily) => {
    'streak': daily.streak,
    'lit': daily.lit,
    'run': daily.run,
    'lastDate': daily.lastDate?.toIso(),
    'freezes': daily.freezes,
    'freezeWeek': daily.freezeWeek,
    'done': [for (final date in daily.done) date.toIso()],
    'frozen': [for (final date in daily.frozen) date.toIso()],
    'noticeDate': daily.noticeDate?.toIso(),
    'chestPending': daily.chestPending,
    'lastSolve': _encodeSolve(daily.lastSolve),
    'inProgress': _encodeInProgress(daily.inProgress),
  };

  static Map<String, Object?>? _encodeSolve(DailySolve? solve) {
    if (solve == null) return null;
    return {
      'date': solve.date.toIso(),
      'moves': solve.moves,
      'families': solve.families,
      'minute': solve.minuteOfDay,
    };
  }

  /// `daily.lastSolve` (m7-design P3.4): null unless its date parses; bad
  /// counts read 0, a minute outside 0–1439 reads null.
  static DailySolve? _decodeSolve(Object? value) {
    final map = _map(value);
    if (map == null) return null;
    final date = LocalDate.tryParse(map['date']);
    if (date == null) return null;
    final minute = _intOrNull(map['minute']);
    return DailySolve(
      date: date,
      moves: _int(map['moves'], 0, 0),
      families: _int(map['families'], 0, 0),
      minuteOfDay: minute != null && minute >= 0 && minute < 24 * 60
          ? minute
          : null,
    );
  }

  /// `dailyArchive`, leniently: a malformed one reads as empty, bad dates
  /// and a bad board are dropped.
  static DailyArchive _decodeArchive(Object? value) {
    final map = _map(value);
    if (map == null) return const DailyArchive();
    return DailyArchive(
      played: _dateList(map['played']),
      inProgress: _decodeInProgress(
        map['inProgress'],
        slot: PlayKind.pastDaily,
      ),
    );
  }

  static DailyProgress _decodeDaily(Object? value) {
    final map = _map(value);
    if (map == null) return const DailyProgress();
    final freezes = _int(map['freezes'], 0, 0);
    // The flame is lit exactly while a run is going (m7-design §8): a
    // missing `lit` follows `run`, and a pair that disagrees reads as
    // paused.
    final run = _int(map['run'], 0, 0);
    final lit = (_boolOrNull(map['lit']) ?? run > 0) && run > 0;
    return DailyProgress(
      streak: _int(map['streak'], 0, 0),
      lit: lit,
      run: lit ? run : 0,
      lastDate: LocalDate.tryParse(map['lastDate']),
      freezes: freezes > DailyProgress.maxFreezes
          ? DailyProgress.maxFreezes
          : freezes,
      freezeWeek: _intOrNull(map['freezeWeek']),
      done: _dateList(map['done']),
      frozen: _dateList(map['frozen']),
      noticeDate: LocalDate.tryParse(map['noticeDate']),
      chestPending: _bool(map['chestPending'], false),
      lastSolve: _decodeSolve(map['lastSolve']),
      inProgress: _decodeInProgress(map['inProgress'], slot: PlayKind.daily),
    );
  }

  static Map<String, Object?>? _encodeInProgress(InProgressLevel? level) {
    if (level == null) return null;
    return {
      'kind': level.request.kind.id,
      'number': level.request.number,
      'levelId': level.levelId,
      'levelVersion': level.levelVersion,
      'tier': level.tier?.id,
      'level': level.level,
      'session': level.session,
      'hinted': level.hinted,
    };
  }

  /// An in-progress board, or null when anything it needs is unreadable
  /// (the level then just starts over, spec §13.3). [slot] says which
  /// slot it came from: a daily board only in `daily`, a past day's only in
  /// `dailyArchive`, the others (null) only at the top level.
  static InProgressLevel? _decodeInProgress(Object? value, {PlayKind? slot}) {
    final map = _map(value);
    if (map == null) return null;
    final kind = PlayKind.tryFromId(map['kind']);
    final number = _intOrNull(map['number']);
    final levelId = _string(map['levelId']);
    final levelVersion = _intOrNull(map['levelVersion']);
    final session = _map(map['session']);
    // A replay or a race is never saved in progress (m7-design §6, P2.4):
    // a stray one is dropped like any unreadable board.
    if (kind == null ||
        kind == PlayKind.replay ||
        kind == PlayKind.race ||
        (kind == PlayKind.daily || kind == PlayKind.pastDaily ? kind : null) !=
            slot ||
        number == null ||
        levelId == null ||
        levelVersion == null ||
        session == null) {
      return null;
    }
    final request = PlayRequest.tryCreate(kind, number);
    if (request == null) return null;
    final level = _map(map['level']);
    // A generated board can't resume without its level.
    if (request.isGenerated && level == null) return null;
    final tierId = _string(map['tier']);
    return InProgressLevel(
      request: request,
      levelId: levelId,
      levelVersion: levelVersion,
      session: session,
      level: request.isGenerated ? level : null,
      tier: tierId == null ? null : Tier.tryFromId(tierId),
      hinted: _bool(map['hinted'], false),
    );
  }

  static AdCounters _decodeAdCounters(Object? value) {
    final map = _map(value);
    if (map == null) return const AdCounters();
    return AdCounters(
      winsSinceInterstitial: _int(map['winsSinceInterstitial'], 0, 0),
      lastAdAt: _int(map['lastAdAt'], 0, 0),
      interstitialsShown: _int(map['interstitialsShown'], 0, 0),
    );
  }

  static SaveStats _decodeStats(Object? value) {
    final map = _map(value);
    if (map == null) return const SaveStats();
    final used = <String, int>{};
    for (final MapEntry(:key, :value)
        in (_map(map['boostersUsed']) ?? const {}).entries) {
      final count = _intOrNull(value);
      if (count != null && count >= 0) used[key] = count;
    }
    return SaveStats(
      wins: _int(map['wins'], 0, 0),
      moves: _int(map['moves'], 0, 0),
      boostersUsed: used,
    );
  }

  /// `levelBests`: non-empty keys with a move count of at least 1 (a win
  /// takes a move); anything else is skipped.
  static Map<String, int> _decodeBests(Object? value) {
    final map = _map(value);
    if (map == null) return const {};
    return {
      for (final MapEntry(:key, :value) in map.entries)
        if (key.isNotEmpty && (_intOrNull(value) ?? 0) >= 1)
          key: _intOrNull(value)!,
    };
  }

  /// `levelStars` (m7-design P3.4): non-empty level ids with an integral
  /// star count of 1–3; anything else is skipped.
  static Map<String, int> _decodeStars(Object? value) {
    final map = _map(value);
    if (map == null) return const {};
    return {
      for (final MapEntry(:key, :value) in map.entries)
        if (key.isNotEmpty &&
            (_intOrNull(value) ?? 0) >= StarRating.minStars &&
            _intOrNull(value)! <= StarRating.maxStars)
          key: _intOrNull(value)!,
    };
  }

  static SaveRecords _decodeRecords(Object? value) {
    final map = _map(value);
    if (map == null) return const SaveRecords();
    return SaveRecords(
      families: _int(map['families'], 0, 0),
      dolls: _int(map['dolls'], 0, 0),
      dailies: _int(map['dailies'], 0, 0),
      longestRun: _int(map['longestRun'], 0, 0),
      // Unknown ids (a newer app's badges) are kept (m7-design §3.2).
      badges: _ids(map['badges'], null),
    );
  }

  static ChestProgress _decodeChests(Object? value) {
    final map = _map(value);
    if (map == null) return const ChestProgress();
    return ChestProgress(
      opened: _numbers(map['opened']),
      bonusOpened: _numbers(map['bonusOpened']),
    );
  }

  /// Exactly [RaceProgress.rivalCount] rivals: a missing or unreadable one
  /// is its fresh default, extra ones are dropped. Rival 1 is always
  /// unlocked, and a rival with a win is too (m7-design §3.2).
  static RaceProgress _decodeRace(Object? value) {
    final stored = _map(value)?['rivals'];
    final list = stored is List ? stored : const <Object?>[];
    return RaceProgress(
      rivals: [
        for (var i = 0; i < RaceProgress.rivalCount; i++)
          _decodeRival(i < list.length ? list[i] : null, i),
      ],
    );
  }

  /// `loginGift` (plan-login-gift §7.5b): a bad count is 0 and a bad date
  /// null. [LoginGiftProgress.latestSeen] is never earlier than
  /// [LoginGiftProgress.lastClaim] (a claim sees its own date), so a
  /// missing or earlier one reads as the last claim's: the clock guard
  /// never loosens below a date already claimed.
  static LoginGiftProgress _decodeLoginGift(Object? value) {
    final map = _map(value);
    if (map == null) return const LoginGiftProgress();
    final lastClaim = LocalDate.tryParse(map['lastClaim']);
    final latestSeen = LocalDate.tryParse(map['latestSeen']);
    return LoginGiftProgress(
      claims: _int(map['claims'], 0, 0),
      lastClaim: lastClaim,
      latestSeen:
          lastClaim != null && (latestSeen == null || latestSeen < lastClaim)
          ? lastClaim
          : latestSeen,
    );
  }

  static RivalProgress _decodeRival(Object? value, int index) {
    final fallback = RaceProgress.defaultRivals[index];
    final map = _map(value);
    if (map == null) return fallback;
    final wins = _int(map['wins'], 0, 0);
    return RivalProgress(
      unlocked:
          index == 0 || wins > 0 || _bool(map['unlocked'], fallback.unlocked),
      wins: wins,
      raceNo: _int(map['raceNo'], 0, 0),
    );
  }

  static Map<String, LocalDate> _decodeDates(
    Object? value,
    List<String> museum,
  ) {
    final map = _map(value);
    if (map == null) return const {};
    return {
      for (final MapEntry(:key, :value) in map.entries)
        if (museum.contains(key)) key: ?LocalDate.tryParse(value),
    };
  }

  // --- Primitives --------------------------------------------------------

  static Map<String, Object?> _stringKeyed(Map<Object?, Object?> map) => {
    for (final MapEntry(:key, :value) in map.entries)
      if (key is String) key: value,
  };

  static Map<String, Object?>? _map(Object? value) =>
      value is Map ? _stringKeyed(value) : null;

  /// An integral JSON number within ±(2^53 − 1), read by value like the
  /// level codec (D29): `3.0` is 3.
  static int? _intOrNull(Object? value) {
    if (value is int) return value;
    if (value is double &&
        value.isFinite &&
        value == value.truncateToDouble() &&
        value.abs() <= 9007199254740991) {
      return value.toInt();
    }
    return null;
  }

  /// [value] as an int of at least [min], else [fallback].
  static int _int(Object? value, int fallback, int min) {
    final read = _intOrNull(value);
    return read == null || read < min ? fallback : read;
  }

  static bool _bool(Object? value, bool fallback) =>
      value is bool ? value : fallback;

  static bool? _boolOrNull(Object? value) => value is bool ? value : null;

  /// Distinct integers of at least 1, ascending.
  static List<int> _numbers(Object? value) {
    if (value is! List) return const [];
    return <int>{
      for (final item in value)
        if ((_intOrNull(item) ?? 0) >= 1) _intOrNull(item)!,
    }.toList()..sort();
  }

  static String? _string(Object? value) =>
      value is String && value.isNotEmpty ? value : null;

  /// A list of distinct non-empty strings, first occurrence kept, with
  /// [always] first when given (it is always owned).
  static List<String> _ids(Object? value, String? always) {
    final ids = <String>[?always];
    if (value is List) {
      for (final item in value) {
        if (item is String && item.isNotEmpty && !ids.contains(item)) {
          ids.add(item);
        }
      }
    }
    return ids;
  }

  /// Distinct dates, sorted, the last [DailyProgress.maxDates] kept.
  static List<LocalDate> _dateList(Object? value) {
    if (value is! List) return const [];
    final dates = <LocalDate>{
      for (final item in value) ?LocalDate.tryParse(item),
    }.toList()..sort();
    return dates.length <= DailyProgress.maxDates
        ? dates
        : dates.sublist(dates.length - DailyProgress.maxDates);
  }

  static String? _playerId(Object? value) =>
      value is String && playerIdPattern.hasMatch(value) ? value : null;
}
