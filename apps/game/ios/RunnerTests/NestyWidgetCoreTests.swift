import XCTest

// NestyWidgetCore.swift and NestyWidgetStore.swift are compiled into this
// target (tools/ios/add_widget_target.rb), and the Dart side's goldens
// (apps/game/test/fixtures/widget_snapshot_v1*.json, rewritten with
// NESTY_UPDATE_GOLDEN=1) are its resources, so a change to the snapshot's
// shape fails here as well as in the host tests.
final class NestyWidgetCoreTests: XCTestCase {
  // MARK: Fixtures

  private func golden(_ name: String) throws -> String {
    let bundle = Bundle(for: NestyWidgetCoreTests.self)
    let url = try XCTUnwrap(bundle.url(forResource: name, withExtension: "json"), "\(name).json")
    return try String(contentsOf: url, encoding: .utf8)
  }

  private func snapshot(_ name: String) throws -> NestyWidgetSnapshot {
    try XCTUnwrap(NestyWidgetSnapshot.decode(try golden(name)), "\(name) decodes")
  }

  private func calendar(_ zone: String) -> Calendar {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: zone)!
    return calendar
  }

  private func date(_ iso: String) -> Date {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.date(from: iso)!
  }

  /// Noon on [day] (`yyyy-MM-dd`) in [calendar]'s zone.
  private func noon(_ day: String, _ calendar: Calendar) -> Date {
    let parts = day.split(separator: "-").map { Int($0)! }
    return calendar.date(
      from: DateComponents(year: parts[0], month: parts[1], day: parts[2], hour: 12))!
  }

  private func day(_ content: NestyWidgetContent) -> NestyWidgetDay? {
    if case .day(let day) = content { return day }
    return nil
  }

  // MARK: Decode

  func testDecodesTheReadyGolden() throws {
    let s = try snapshot("widget_snapshot_v1")
    XCTAssertEqual(s.v, 1)
    XCTAssertEqual(s.scheme, "nesty-dev")
    XCTAssertEqual(s.lang, "en")
    XCTAssertTrue(s.unlocked)
    XCTAssertEqual(s.locked.title, "Daily puzzle")
    XCTAssertEqual(s.locked.small, "Opens after Level 2")
    XCTAssertEqual(s.days.count, 8)
    XCTAssertEqual(s.days.map(\.date).first, "2026-10-08")
    XCTAssertEqual(s.days.map(\.date).last, "2026-10-15")
    let today = s.days[0]
    XCTAssertEqual(today.state, .ready)
    XCTAssertEqual(today.streak, 4)
    XCTAssertEqual(today.number, "4")
    XCTAssertNil(today.labelShort)
    XCTAssertEqual(today.dolls, ["#2F3E8F", "#F2893B"])
    XCTAssertEqual(today.lineShort, "Ready to play")
    let tomorrow = s.days[1]
    XCTAssertEqual(tomorrow.state, .paused)
    XCTAssertEqual(tomorrow.labelShort, "resting")
    XCTAssertEqual(s.days[2].dolls, [])
  }

  func testDecodesTheLockedGolden() throws {
    let s = try snapshot("widget_snapshot_v1_locked")
    XCTAssertFalse(s.unlocked)
    XCTAssertEqual(s.days[0].state, .zero)
    XCTAssertNil(s.days[0].number)
    let content = NestyWidgetCore.content(
      for: noon("2026-10-08", calendar("Europe/Amsterdam")),
      snapshot: s,
      calendar: calendar("Europe/Amsterdam"))
    XCTAssertEqual(content, .locked(s.locked))
  }

  func testDecodesTheSolvedGolden() throws {
    let s = try snapshot("widget_snapshot_v1_solved")
    XCTAssertEqual(s.days[0].state, .solved)
    XCTAssertEqual(NestyWidgetCore.flame(for: s.days[0].state), .lit)
    XCTAssertEqual(s.days[1].state, .ready)
    XCTAssertEqual(NestyWidgetCore.flame(for: s.days[1].state), .unlit)
    XCTAssertEqual(s.days[0].lineShort, "Solved!")
  }

  func testMalformedSnapshotsDrawFirstRun() {
    let bad: [String?] = [
      nil, "", "{", "null", "[]", "42", "{\"v\":1}",
      // An unknown state.
      #"{"v":1,"scheme":"x","lang":"en","unlocked":true,"locked":{"title":"t","small":"s","medium":"m","a11y":"a"},"days":[{"date":"2026-10-08","state":"broken","streak":1,"number":"1","label":"l","title":"t","sub":"s","dolls":[],"line":"l","lineShort":"l","a11y":"a"}]}"#,
      // No days.
      #"{"v":1,"scheme":"x","lang":"en","unlocked":true,"locked":{"title":"t","small":"s","medium":"m","a11y":"a"},"days":[]}"#,
      // A date that isn't yyyy-MM-dd.
      #"{"v":1,"scheme":"x","lang":"en","unlocked":true,"locked":{"title":"t","small":"s","medium":"m","a11y":"a"},"days":[{"date":"8/10/2026","state":"ready","streak":1,"number":"1","label":"l","title":"t","sub":"s","dolls":[],"line":"l","lineShort":"l","a11y":"a"}]}"#,
    ]
    for json in bad {
      XCTAssertNil(NestyWidgetSnapshot.decode(json), json ?? "nil")
      XCTAssertEqual(
        NestyWidgetCore.content(
          for: Date(), snapshot: NestyWidgetSnapshot.decode(json), calendar: .current),
        .firstRun)
    }
  }

  func testANewerVersionDrawsFirstRun() throws {
    let v1 = try golden("widget_snapshot_v1")
    let v2 = v1.replacingOccurrences(of: "\"v\": 1", with: "\"v\": 2")
    XCTAssertNotEqual(v1, v2, "the golden writes \"v\": 1")
    XCTAssertNil(NestyWidgetSnapshot.decode(v2))
    // A v2 whose shape changed entirely.
    XCTAssertNil(NestyWidgetSnapshot.decode(#"{"v":2,"entries":{}}"#))
  }

  // MARK: Lookup

  func testEachDateFindsItsEntry() throws {
    let s = try snapshot("widget_snapshot_v1")
    for zone in ["Europe/Amsterdam", "America/Sao_Paulo", "Asia/Tokyo", "Pacific/Honolulu"] {
      let cal = calendar(zone)
      for entry in s.days {
        for hour in [0, 12, 23] {
          var parts = cal.dateComponents([.year, .month, .day], from: noon(entry.date, cal))
          parts.hour = hour
          parts.minute = hour == 23 ? 59 : 0
          let at = cal.date(from: parts)!
          XCTAssertEqual(
            day(NestyWidgetCore.content(for: at, snapshot: s, calendar: cal)), entry,
            "\(zone) \(entry.date) \(hour)h")
        }
      }
    }
  }

  func testBeforeTheFirstEntryShowsTheFirst() throws {
    let s = try snapshot("widget_snapshot_v1")
    let cal = calendar("Europe/Amsterdam")
    XCTAssertEqual(
      day(NestyWidgetCore.content(for: noon("2026-10-01", cal), snapshot: s, calendar: cal)),
      s.days[0])
  }

  func testPastTheLastEntryKeepsTheStreakWithTheGenericTitle() throws {
    let s = try snapshot("widget_snapshot_v1")
    let cal = calendar("Europe/Amsterdam")
    for later in ["2026-10-16", "2026-11-30"] {
      let shown = try XCTUnwrap(
        day(NestyWidgetCore.content(for: noon(later, cal), snapshot: s, calendar: cal)))
      let last = s.days[7]
      XCTAssertEqual(shown.date, last.date)
      XCTAssertEqual(shown.state, .paused, "a paused streak stays paused")
      XCTAssertEqual(shown.number, last.number)
      XCTAssertEqual(shown.label, last.label)
      XCTAssertEqual(shown.title, s.locked.title)
      XCTAssertNil(shown.sub)
      XCTAssertEqual(shown.dolls, [])
      XCTAssertEqual(shown.line, last.line)
    }
  }

  func testPastTheLastEntryASolvedDayBecomesReady() throws {
    let solved = try snapshot("widget_snapshot_v1_solved")
    // A hand-made snapshot whose last entry is solved (the projection never
    // solves a day after today).
    let ready = solved.days[1]
    let template = solved.days[0]
    let last = NestyWidgetDay(
      date: "2026-10-10", state: .solved, streak: ready.streak, number: ready.number,
      label: template.label, labelShort: nil, title: template.title, sub: template.sub,
      dolls: template.dolls, line: template.line, lineShort: template.lineShort,
      a11y: template.a11y)
    let s = NestyWidgetSnapshot(
      v: 1, scheme: "nesty-dev", lang: "en", unlocked: true, locked: solved.locked,
      days: [ready, last].sorted { $0.date < $1.date })
    let past = NestyWidgetCore.pastLastEntry(s)
    XCTAssertEqual(past.state, .ready)
    XCTAssertEqual(NestyWidgetCore.flame(for: past.state), .unlit)
    XCTAssertEqual(past.number, ready.number)
    XCTAssertEqual(past.line, ready.line)
    XCTAssertEqual(past.lineShort, ready.lineShort)
    XCTAssertEqual(past.a11y, ready.a11y)
    XCTAssertEqual(past.title, solved.locked.title)
    XCTAssertNil(past.sub)
  }

  func testDayKeyIsGregorianWhateverTheCalendar() {
    var japanese = Calendar(identifier: .japanese)
    japanese.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    XCTAssertEqual(
      NestyWidgetCore.dayKey(for: date("2026-10-08T03:00:00Z"), calendar: japanese), "2026-10-08")
    XCTAssertEqual(
      NestyWidgetCore.dayKey(for: date("2026-10-07T15:30:00Z"), calendar: japanese), "2026-10-08")
  }

  // MARK: Midnights

  func testTheTimelineIsNowThenEightMidnights() {
    let cal = calendar("Europe/Amsterdam")
    let now = date("2026-10-08T13:20:00Z")
    let dates = NestyWidgetCore.timelineDates(now: now, calendar: cal)
    XCTAssertEqual(dates.count, 9)
    XCTAssertEqual(dates[0], now)
    for (a, b) in zip(dates, dates.dropFirst()) {
      XCTAssertLessThan(a, b)
    }
    XCTAssertEqual(
      dates.dropFirst().map { NestyWidgetCore.dayKey(for: $0, calendar: cal) },
      ["2026-10-09", "2026-10-10", "2026-10-11", "2026-10-12", "2026-10-13", "2026-10-14",
       "2026-10-15", "2026-10-16"])
    // Just before midnight, the next one is minutes away.
    let late = date("2026-10-08T21:59:00Z")  // 23:59 in Amsterdam
    XCTAssertEqual(
      NestyWidgetCore.midnights(after: late, calendar: cal).first, date("2026-10-08T22:00:00Z"))
  }

  func testAmsterdamDSTNights() {
    let cal = calendar("Europe/Amsterdam")
    // Autumn: 2026-10-25 has 25 hours.
    let autumn = NestyWidgetCore.midnights(after: date("2026-10-24T08:00:00Z"), calendar: cal)
    XCTAssertEqual(autumn[0], date("2026-10-24T22:00:00Z"))  // 10-25 00:00 +02:00
    XCTAssertEqual(autumn[1], date("2026-10-25T23:00:00Z"))  // 10-26 00:00 +01:00
    XCTAssertEqual(autumn[1].timeIntervalSince(autumn[0]), 25 * 3600)
    XCTAssertEqual(autumn[2].timeIntervalSince(autumn[1]), 24 * 3600)
    // Spring: 2026-03-29 has 23 hours.
    let spring = NestyWidgetCore.midnights(after: date("2026-03-28T08:00:00Z"), calendar: cal)
    XCTAssertEqual(spring[0], date("2026-03-28T23:00:00Z"))  // 03-29 00:00 +01:00
    XCTAssertEqual(spring[1], date("2026-03-29T22:00:00Z"))  // 03-30 00:00 +02:00
    XCTAssertEqual(spring[1].timeIntervalSince(spring[0]), 23 * 3600)
    for midnight in autumn + spring {
      XCTAssertEqual(cal.component(.hour, from: midnight), 0)
      XCTAssertEqual(cal.component(.minute, from: midnight), 0)
    }
  }

  func testSaoPauloDSTNights() {
    // Brazil's old DST began at midnight (2018-11-04 had no 00:00; the day
    // began at 01:00) and ended at midnight (2019-02-16 23:00 came twice).
    let cal = calendar("America/Sao_Paulo")
    let start = NestyWidgetCore.midnights(after: date("2018-11-03T13:00:00Z"), calendar: cal)
    XCTAssertEqual(start[0], date("2018-11-04T03:00:00Z"))  // 11-04 01:00 -02:00
    XCTAssertEqual(NestyWidgetCore.dayKey(for: start[0], calendar: cal), "2018-11-04")
    XCTAssertEqual(start[1], date("2018-11-05T02:00:00Z"))  // 11-05 00:00 -02:00
    XCTAssertEqual(start[1].timeIntervalSince(start[0]), 23 * 3600)
    let end = NestyWidgetCore.midnights(after: date("2019-02-15T13:00:00Z"), calendar: cal)
    XCTAssertEqual(end[0], date("2019-02-16T02:00:00Z"))  // 02-16 00:00 -02:00
    XCTAssertEqual(end[1], date("2019-02-17T03:00:00Z"))  // 02-17 00:00 -03:00
    XCTAssertEqual(end[1].timeIntervalSince(end[0]), 25 * 3600)
    XCTAssertEqual(
      end.prefix(2).map { NestyWidgetCore.dayKey(for: $0, calendar: cal) },
      ["2019-02-16", "2019-02-17"])
    // Every entry is the start of its own day, and each is a new day.
    for list in [start, end] {
      XCTAssertEqual(list.count, 8)
      let keys = list.map { NestyWidgetCore.dayKey(for: $0, calendar: cal) }
      XCTAssertEqual(Set(keys).count, 8)
      for midnight in list {
        XCTAssertEqual(cal.startOfDay(for: midnight), midnight)
      }
    }
  }

  // MARK: View inputs

  func testFullAndShortCandidates() throws {
    let s = try snapshot("widget_snapshot_v1")
    XCTAssertEqual(
      NestyWidgetCore.lineCandidates(s.days[0]), ["Today’s puzzle is ready", "Ready to play"])
    XCTAssertEqual(NestyWidgetCore.labelCandidates(s.days[0]), ["day streak"])
    XCTAssertEqual(NestyWidgetCore.labelCandidates(s.days[1]), ["day streak · resting", "resting"])
    let solved = try snapshot("widget_snapshot_v1_solved")
    XCTAssertEqual(
      NestyWidgetCore.lineCandidates(solved.days[0]), ["Solved. See you tomorrow.", "Solved!"])
  }

  func testFacesFollowTheLeadRuling() {
    for lang in ["en", "es", "pt", "pt_BR", "pt-BR", "id", "de", "fr"] {
      XCTAssertTrue(NestyWidgetCore.usesBrandFaces(lang: lang), lang)
    }
    for lang in ["tr", "hi", "ja", "", "xx"] {
      XCTAssertFalse(NestyWidgetCore.usesBrandFaces(lang: lang), lang)
    }
  }

  func testTheLink() {
    XCTAssertEqual(NestyWidgetCore.link(scheme: "nesty-dev")?.absoluteString, "nesty-dev://daily")
    XCTAssertEqual(NestyWidgetCore.link(scheme: "nesty")?.absoluteString, "nesty://daily")
    XCTAssertNil(NestyWidgetCore.link(scheme: nil))
    XCTAssertNil(NestyWidgetCore.link(scheme: ""))
    XCTAssertNil(NestyWidgetCore.link(scheme: "$(APP_URL_SCHEME)"))
    XCTAssertNil(NestyWidgetCore.link(scheme: "nesty dev"))
  }

  func testDollColoursAndCount() {
    XCTAssertEqual(
      NestyWidgetCore.rgb(hex: "#2F3E8F"),
      NestyWidgetRGB(red: 47.0 / 255, green: 62.0 / 255, blue: 143.0 / 255))
    XCTAssertNil(NestyWidgetCore.rgb(hex: "2F3E8F"))
    XCTAssertNil(NestyWidgetCore.rgb(hex: "#2F3E8"))
    XCTAssertNil(NestyWidgetCore.rgb(hex: "#GGGGGG"))
    // systemSmall on a 390-wide phone: 126 wide, six fit.
    XCTAssertEqual(
      NestyWidgetCore.dollCount(available: 126, width: 15, gap: 4, cap: 6, total: 11), 6)
    // The 320-wide phones: 109 wide, five fit.
    XCTAssertEqual(
      NestyWidgetCore.dollCount(available: 109, width: 15, gap: 4, cap: 6, total: 11), 5)
    // systemMedium's right column: 172.5 wide, seven of eight fit.
    XCTAssertEqual(
      NestyWidgetCore.dollCount(available: 172.5, width: 19, gap: 5, cap: 8, total: 11), 7)
    XCTAssertEqual(
      NestyWidgetCore.dollCount(available: 400, width: 19, gap: 5, cap: 8, total: 3), 3)
    XCTAssertEqual(NestyWidgetCore.dollCount(available: 0, width: 19, gap: 5, cap: 8, total: 3), 0)
  }

  // MARK: Store

  func testTheStoreRoundTripsAndRefusesAnUnexpandedGroup() throws {
    let suite = "nesty.widget.tests.\(UUID().uuidString)"
    let store = try XCTUnwrap(NestyWidgetStore(group: suite))
    defer {
      store.clear()
      UserDefaults().removePersistentDomain(forName: suite)
    }
    XCTAssertNil(store.read())
    let json = try golden("widget_snapshot_v1")
    XCTAssertTrue(store.write(json))
    XCTAssertEqual(store.read(), json)
    XCTAssertEqual(NestyWidgetSnapshot.decode(store.read())?.days.count, 8)
    XCTAssertNil(NestyWidgetStore(group: nil))
    XCTAssertNil(NestyWidgetStore(group: ""))
    XCTAssertNil(NestyWidgetStore(group: "$(APP_GROUP_ID)"))
    XCTAssertEqual(NestyWidgetStore.snapshotKey, "nesty_widget_snapshot")
  }
}
