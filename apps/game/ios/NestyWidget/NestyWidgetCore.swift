import Foundation

// The home-screen widget's pure logic (plan-local-habits §4 "iOS", stage 4
// contract §3). Foundation only: it is compiled into the NestyWidget
// extension and into RunnerTests, which test it against the Dart side's JSON
// goldens (apps/game/test/fixtures/widget_snapshot_v1*.json).
//
// Native code only looks a date up in the snapshot the app wrote. No streak
// rule lives here (hard rule 2's spirit): every state, number and line comes
// already decided and localized from `DailyService.projection`.

/// A day's state, as `DailyService.projection` decided it.
enum NestyWidgetDayState: String, Decodable, Equatable {
  case ready
  case solved
  case paused
  case zero
}

/// The strings shown while the Daily is locked (before Level 2), `{level}`
/// already filled.
struct NestyWidgetLocked: Decodable, Equatable {
  let title: String
  let small: String
  let medium: String
  let a11y: String
}

/// One date's entry: everything the views draw for it, already localized.
struct NestyWidgetDay: Decodable, Equatable {
  let date: String
  var state: NestyWidgetDayState
  let streak: Int
  /// The streak, formatted in the rendered language; null for `zero`.
  let number: String?
  let label: String
  /// Set only for `paused` (`widgetStreakRestingShort`).
  let labelShort: String?
  var title: String
  var sub: String?
  /// The daily's colours as `#RRGGBB`, puzzle order; empty when not computed.
  var dolls: [String]
  var line: String
  var lineShort: String?
  var a11y: String

  init(
    date: String,
    state: NestyWidgetDayState,
    streak: Int,
    number: String?,
    label: String,
    labelShort: String?,
    title: String,
    sub: String?,
    dolls: [String],
    line: String,
    lineShort: String?,
    a11y: String
  ) {
    self.date = date
    self.state = state
    self.streak = streak
    self.number = number
    self.label = label
    self.labelShort = labelShort
    self.title = title
    self.sub = sub
    self.dolls = dolls
    self.line = line
    self.lineShort = lineShort
    self.a11y = a11y
  }

  private enum CodingKeys: String, CodingKey {
    case date, state, streak, number, label, labelShort, title, sub, dolls, line, lineShort, a11y
  }

  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    date = try c.decode(String.self, forKey: .date)
    state = try c.decode(NestyWidgetDayState.self, forKey: .state)
    streak = try c.decode(Int.self, forKey: .streak)
    number = try c.decodeIfPresent(String.self, forKey: .number)
    label = try c.decode(String.self, forKey: .label)
    labelShort = try c.decodeIfPresent(String.self, forKey: .labelShort)
    title = try c.decode(String.self, forKey: .title)
    sub = try c.decodeIfPresent(String.self, forKey: .sub)
    dolls = try c.decodeIfPresent([String].self, forKey: .dolls) ?? []
    line = try c.decode(String.self, forKey: .line)
    lineShort = try c.decodeIfPresent(String.self, forKey: .lineShort)
    a11y = try c.decode(String.self, forKey: .a11y)
  }
}

/// The snapshot the app publishes through `com.futrix.nesty/home_widget`
/// (contract §3, schema v1).
struct NestyWidgetSnapshot: Decodable, Equatable {
  static let supportedVersion = 1

  let v: Int
  let scheme: String
  let lang: String
  let unlocked: Bool
  let locked: NestyWidgetLocked
  /// Oldest first (sorted on decode).
  let days: [NestyWidgetDay]

  private struct Header: Decodable {
    let v: Int
  }

  /// The snapshot in [json], or nil when it can't be drawn: missing, not
  /// JSON, a newer `v`, an unknown state, no days or a bad date. Nil draws
  /// the first-run state (contract §3).
  static func decode(_ json: String?) -> NestyWidgetSnapshot? {
    guard let json, let data = json.data(using: .utf8) else { return nil }
    let decoder = JSONDecoder()
    // The version first, so a newer schema whose keys changed shape still
    // lands on first-run instead of on a half-read v1.
    guard let header = try? decoder.decode(Header.self, from: data),
      header.v == supportedVersion,
      let raw = try? decoder.decode(NestyWidgetSnapshot.self, from: data),
      !raw.days.isEmpty,
      raw.days.allSatisfy({ NestyWidgetCore.isDayKey($0.date) })
    else { return nil }
    return NestyWidgetSnapshot(
      v: raw.v,
      scheme: raw.scheme,
      lang: raw.lang,
      unlocked: raw.unlocked,
      locked: raw.locked,
      days: raw.days.sorted { $0.date < $1.date }
    )
  }

  init(
    v: Int,
    scheme: String,
    lang: String,
    unlocked: Bool,
    locked: NestyWidgetLocked,
    days: [NestyWidgetDay]
  ) {
    self.v = v
    self.scheme = scheme
    self.lang = lang
    self.unlocked = unlocked
    self.locked = locked
    self.days = days
  }
}

/// What one timeline entry draws.
enum NestyWidgetContent: Equatable {
  /// Before the app has written anything (or a snapshot that can't be
  /// decoded): the locked layout with the native strings (design spec §2.6).
  case firstRun
  /// The Daily is locked (before Level 2).
  case locked(NestyWidgetLocked)
  /// The date's entry (or contract §3's fallback past the last entry).
  case day(NestyWidgetDay)
}

/// Which flame art a day draws.
enum NestyWidgetFlame: Equatable {
  case lit
  case unlit
}

/// sRGB components in 0...1.
struct NestyWidgetRGB: Equatable {
  let red: Double
  let green: Double
  let blue: Double
}

enum NestyWidgetCore {
  /// How many midnights the timeline holds after now: the snapshot's eight
  /// days are today … today + 7, so the last entry starts today + 8 (the
  /// fallback), then `.atEnd` asks for a new timeline.
  static let midnightCount = 8

  /// The languages whose glyphs Fredoka and Nunito cover (lead ruling on
  /// gap 10). Turkish, Hindi and Japanese draw the whole widget in the system
  /// rounded face, never a per-glyph mix.
  static let brandFaceLanguages: Set<String> = ["en", "es", "pt", "id", "de", "fr"]

  // MARK: Dates

  /// The local date of [date] as the snapshot writes it (`yyyy-MM-dd`).
  ///
  /// Always Gregorian in [calendar]'s time zone: the snapshot's dates are
  /// ISO dates, and a phone set to the Japanese or Buddhist calendar would
  /// otherwise give an era year.
  static func dayKey(for date: Date, calendar: Calendar) -> String {
    var gregorian = Calendar(identifier: .gregorian)
    gregorian.timeZone = calendar.timeZone
    let parts = gregorian.dateComponents([.year, .month, .day], from: date)
    return String(format: "%04ld-%02ld-%02ld", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
  }

  /// True for a well-formed `yyyy-MM-dd`.
  static func isDayKey(_ key: String) -> Bool {
    let chars = Array(key.utf8)
    guard chars.count == 10, chars[4] == UInt8(ascii: "-"), chars[7] == UInt8(ascii: "-") else {
      return false
    }
    for (i, c) in chars.enumerated() where i != 4 && i != 7 {
      if c < UInt8(ascii: "0") || c > UInt8(ascii: "9") { return false }
    }
    return true
  }

  /// The first instant of each of the [count] local days after [now]'s.
  ///
  /// Each day is reached from noon (which every zone has) and then taken to
  /// its start, so a DST night (Europe/Amsterdam's 23- and 25-hour days, or
  /// the old America/Sao_Paulo days that began at 01:00) lands on the real
  /// start of the next day.
  static func midnights(after now: Date, count: Int = midnightCount, calendar: Calendar) -> [Date] {
    let today = calendar.startOfDay(for: now)
    guard count > 0,
      let noon = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: today)
    else { return [] }
    var out: [Date] = []
    for offset in 1...count {
      guard let day = calendar.date(byAdding: .day, value: offset, to: noon) else { continue }
      out.append(calendar.startOfDay(for: day))
    }
    return out
  }

  /// The timeline's dates: now, then the next [midnightCount] midnights.
  static func timelineDates(now: Date, calendar: Calendar) -> [Date] {
    [now] + midnights(after: now, calendar: calendar)
  }

  // MARK: Lookup

  /// What the widget draws at [date] (contract §3).
  static func content(
    for date: Date,
    snapshot: NestyWidgetSnapshot?,
    calendar: Calendar
  ) -> NestyWidgetContent {
    guard let snapshot, let first = snapshot.days.first, let last = snapshot.days.last else {
      return .firstRun
    }
    guard snapshot.unlocked else { return .locked(snapshot.locked) }
    let key = dayKey(for: date, calendar: calendar)
    if key < first.date { return .day(first) }
    if key > last.date { return .day(pastLastEntry(snapshot)) }
    // The latest entry on or before the date (the days are consecutive, so
    // this is the date's own entry).
    let day = snapshot.days.last { $0.date <= key } ?? first
    return .day(day)
  }

  /// Past the last entry (seven or more days without opening the app): the
  /// last entry, unsolved, with the generic title and no sub or dolls
  /// (contract §3, design spec gap 18). Only `solved` changes state; `paused`
  /// and `zero` already show the ready line, and a native rule can't redo
  /// their labels (no streak rule here).
  // TODO(design): the past-the-last-entry look is the spec's default (gap 18).
  static func pastLastEntry(_ snapshot: NestyWidgetSnapshot) -> NestyWidgetDay {
    guard var day = snapshot.days.last else {
      preconditionFailure("pastLastEntry needs at least one day")
    }
    day.title = snapshot.locked.title
    day.sub = nil
    day.dolls = []
    if day.state == .solved {
      day.state = .ready
      // The ready strings come from a day that is already ready: the same
      // streak's first (its a11y names the same count), else any unsolved
      // one for the line. The projection never solves a day after today, so
      // the last entry is solved only in a hand-made snapshot.
      let sameStreak = snapshot.days.first { $0.state == .ready && $0.streak == day.streak }
      if let donor = sameStreak ?? snapshot.days.first(where: { $0.state != .solved }) {
        day.line = donor.line
        day.lineShort = donor.lineShort
        if sameStreak != nil { day.a11y = donor.a11y }
      }
    }
    return day
  }

  // MARK: View inputs

  /// The flame a day draws: lit only once today's daily is solved.
  static func flame(for state: NestyWidgetDayState) -> NestyWidgetFlame {
    state == .solved ? .lit : .unlit
  }

  /// The line's forms, longest first: the views show the first that fits in
  /// two lines, the last one with an ellipsis (textFit.widget.line).
  static func lineCandidates(_ day: NestyWidgetDay) -> [String] {
    distinct([day.line, day.lineShort])
  }

  /// The label's forms, longest first (`labelShort` only for `paused`).
  static func labelCandidates(_ day: NestyWidgetDay) -> [String] {
    distinct([day.label, day.labelShort])
  }

  /// True when [lang] (`pt_BR`, `pt-BR` or `en`) draws in Fredoka and Nunito.
  static func usesBrandFaces(lang: String) -> Bool {
    let base = lang.split(whereSeparator: { $0 == "_" || $0 == "-" }).first.map(String.init) ?? ""
    return brandFaceLanguages.contains(base.lowercased())
  }

  /// The tap's link, `<scheme>://daily` (contract §4), or nil for a scheme
  /// that is missing or was never expanded from its build setting.
  static func link(scheme: String?) -> URL? {
    guard let scheme, !scheme.isEmpty, !scheme.contains("$("),
      scheme.allSatisfy({ $0.isLetter || $0.isNumber || $0 == "-" || $0 == "+" || $0 == "." })
    else { return nil }
    return URL(string: "\(scheme)://daily")
  }

  /// `#RRGGBB` as components, or nil when it isn't one.
  static func rgb(hex: String) -> NestyWidgetRGB? {
    guard hex.count == 7, hex.first == "#", let value = UInt32(hex.dropFirst(), radix: 16) else {
      return nil
    }
    return NestyWidgetRGB(
      red: Double((value >> 16) & 0xFF) / 255,
      green: Double((value >> 8) & 0xFF) / 255,
      blue: Double(value & 0xFF) / 255
    )
  }

  /// How many dolls of [width] with [gap] between fit in [available], at
  /// most [cap] and at most [total] (design spec gap 15: the first N, no
  /// "+N").
  static func dollCount(available: Double, width: Double, gap: Double, cap: Int, total: Int) -> Int {
    guard available > 0, width > 0 else { return 0 }
    let fit = Int(((available + gap) / (width + gap)).rounded(.down))
    return max(0, min(fit, cap, total))
  }

  private static func distinct(_ values: [String?]) -> [String] {
    var out: [String] = []
    for case let value? in values where !value.isEmpty && !out.contains(value) {
      out.append(value)
    }
    return out
  }
}
