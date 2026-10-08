import SwiftUI
import WidgetKit

// The home-screen widget (local habits stage 4, plan-local-habits §4 "iOS",
// frame 14.4): the streak and today's daily at a glance, static, one tap
// target. It only shows what the app wrote (the snapshot in the App Group,
// stage 4 contract §2–3) and looks today's date up in it; nothing counts down
// and nothing is computed here (the respect rules, D92).

/// One timeline entry: the date it starts at and what it draws.
struct NestyWidgetEntry: TimelineEntry {
  let date: Date
  let content: NestyWidgetContent
  /// Fredoka and Nunito, or the system rounded face (lead ruling on gap 10).
  let brand: Bool
  /// `<scheme>://daily` (contract §4).
  let link: URL?

  /// The one accessibility label (design spec §5); nil for first-run, whose
  /// visible texts read as they are.
  var accessibilityText: String? {
    switch content {
    case .firstRun: return nil
    case .locked(let locked): return locked.a11y
    case .day(let day): return day.a11y
    }
  }

  /// The state before the app has written anything (and the gallery's
  /// preview): the language is the one iOS picked for the extension's own
  /// strings, and the scheme is the extension's Info.plist one.
  static func firstRun(at date: Date) -> NestyWidgetEntry {
    let language = Bundle.main.preferredLocalizations.first ?? "en"
    return NestyWidgetEntry(
      date: date,
      content: .firstRun,
      brand: NestyWidgetCore.usesBrandFaces(lang: language),
      link: NestyWidgetCore.link(scheme: NestyWidgetStore.scheme())
    )
  }

  /// The entry at [date] for [snapshot] (nil: first-run).
  static func make(
    at date: Date,
    snapshot: NestyWidgetSnapshot?,
    calendar: Calendar
  ) -> NestyWidgetEntry {
    guard let snapshot else { return firstRun(at: date) }
    return NestyWidgetEntry(
      date: date,
      content: NestyWidgetCore.content(for: date, snapshot: snapshot, calendar: calendar),
      brand: NestyWidgetCore.usesBrandFaces(lang: snapshot.lang),
      link: NestyWidgetCore.link(scheme: snapshot.scheme)
        ?? NestyWidgetCore.link(scheme: NestyWidgetStore.scheme())
    )
  }
}

struct NestyWidgetProvider: TimelineProvider {
  func placeholder(in context: Context) -> NestyWidgetEntry {
    .firstRun(at: Date())
  }

  /// The gallery shows the first-run state (design spec §7); any other
  /// snapshot is the real entry for now, so a transient snapshot never
  /// flashes the first-run look over a placed widget.
  // TODO(design): the gallery preview is the first-run state, localized by
  // the native strings (gap 20).
  func getSnapshot(in context: Context, completion: @escaping (NestyWidgetEntry) -> Void) {
    if context.isPreview {
      completion(.firstRun(at: Date()))
      return
    }
    completion(.make(at: Date(), snapshot: readSnapshot(), calendar: .current))
  }

  /// Now and the next eight local midnights, `.atEnd`: the day rolls over
  /// with the app closed and spends no reload budget. The app reloads the
  /// timelines after every write (a solve, a new day, a language change).
  func getTimeline(in context: Context, completion: @escaping (Timeline<NestyWidgetEntry>) -> Void) {
    let calendar = Calendar.current
    let snapshot = readSnapshot()
    let entries = NestyWidgetCore.timelineDates(now: Date(), calendar: calendar).map {
      NestyWidgetEntry.make(at: $0, snapshot: snapshot, calendar: calendar)
    }
    completion(Timeline(entries: entries, policy: .atEnd))
  }

  private func readSnapshot() -> NestyWidgetSnapshot? {
    NestyWidgetSnapshot.decode(NestyWidgetStore.from()?.read())
  }
}

@main
struct NestyDailyWidget: Widget {
  /// Never rename: a placed widget is found by its kind.
  static let kind = "NestyDailyWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: NestyDailyWidget.kind, provider: NestyWidgetProvider()) { entry in
      NestyWidgetEntryView(entry: entry)
    }
    // Generated from the ARBs by gen_widget_strings (<lang>.lproj).
    .configurationDisplayName(Text("widgetGalleryName"))
    .description(Text("widgetGalleryDescription"))
    .supportedFamilies([.systemSmall, .systemMedium])
    .nestyOwnMargins()
  }
}

extension WidgetConfiguration {
  /// iOS 17 adds content margins; the widget pads 16 itself on every
  /// version (tokens.json `habits.widget.ios.contentMargins`).
  fileprivate func nestyOwnMargins() -> some WidgetConfiguration {
    if #available(iOS 17.0, *) {
      return contentMarginsDisabled()
    } else {
      return self
    }
  }
}
