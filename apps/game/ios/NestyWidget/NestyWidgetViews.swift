import SwiftUI
import WidgetKit

// The widget's views: systemSmall and systemMedium in the six states (ready,
// solved, paused, zero, locked, first-run), light, dark, iOS 17's StandBy and
// iOS 18's tinted look. Frame 14.4 (design/prototypes/NestyWidget.dc.html)
// through the design spec §2.2–2.4 and its lead rulings.

struct NestyWidgetEntryView: View {
  let entry: NestyWidgetEntry
  @Environment(\.widgetFamily) private var family
  @Environment(\.colorScheme) private var colorScheme

  var body: some View {
    if #available(iOS 17.0, *) {
      ContainerRoot(entry: entry, family: family, colorScheme: colorScheme)
    } else {
      let look = WidgetLook(dark: colorScheme == .dark, tinted: false)
      WidgetBody(entry: entry, family: family, look: look)
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(WidgetBackground(look: look))
    }
  }
}

/// iOS 17+: the gradient goes in `containerBackground`, so StandBy can drop
/// it, and tinted mode shows the system's.
@available(iOS 17.0, *)
private struct ContainerRoot: View {
  let entry: NestyWidgetEntry
  let family: WidgetFamily
  let colorScheme: ColorScheme
  @Environment(\.widgetRenderingMode) private var renderingMode
  @Environment(\.showsWidgetContainerBackground) private var showsBackground

  var body: some View {
    let look = WidgetLook(
      dark: colorScheme == .dark || !showsBackground,
      tinted: renderingMode == .accented
    )
    WidgetBody(entry: entry, family: family, look: look)
      .padding(16)
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
      .containerBackground(for: .widget) { WidgetBackground(look: look) }
  }
}

/// The content for the entry's state and size, one tap target and one
/// accessibility element.
private struct WidgetBody: View {
  let entry: NestyWidgetEntry
  let family: WidgetFamily
  let look: WidgetLook

  var body: some View {
    let medium = family == .systemMedium
    let palette = WidgetPalette.of(look)
    Group {
      switch entry.content {
      case .firstRun:
        // TODO(design): the first-run state isn't drawn (gap 3); it borrows
        // the locked layout with the gallery description as its line.
        let title = NSLocalizedString("widgetLockedTitle", comment: "")
        let line = NSLocalizedString("widgetGalleryDescription", comment: "")
        if medium {
          LockedMedium(title: title, line: line, look: look, palette: palette, brand: entry.brand)
        } else {
          LockedSmall(title: title, line: line, look: look, palette: palette, brand: entry.brand)
        }
      case .locked(let locked):
        if medium {
          LockedMedium(
            title: locked.title, line: locked.medium, look: look, palette: palette, brand: entry.brand)
        } else {
          LockedSmall(
            title: locked.title, line: locked.small, look: look, palette: palette, brand: entry.brand)
        }
      case .day(let day):
        if medium {
          DayMedium(day: day, look: look, palette: palette, brand: entry.brand)
        } else {
          DaySmall(day: day, look: look, palette: palette, brand: entry.brand)
        }
      }
    }
    .modifier(WidgetTypeCap())
    .modifier(WidgetAccessibility(label: entry.accessibilityText))
    .widgetURL(entry.link)
  }
}

// MARK: - Day (ready, solved, paused, zero)

/// systemSmall (design spec §2.2). The tiers for a short widget (an
/// iPhone SE, or large text): the dolls go first, then the line takes its
/// short form on one line (gap 4).
private struct DaySmall: View {
  let day: NestyWidgetDay
  let look: WidgetLook
  let palette: WidgetPalette
  let brand: Bool

  var body: some View {
    // TODO(design): the short-widget tiers are the spec's default (gap 4).
    if #available(iOS 16.0, *) {
      ViewThatFits(in: .vertical) {
        layout(dolls: true, compactLine: false)
        layout(dolls: false, compactLine: false)
        layout(dolls: false, compactLine: true)
      }
    } else {
      // No ViewThatFits before iOS 16: the tiers by the content height
      // (126 on a 390-wide phone, 116 on an SE, 109 on the 320-wide ones).
      GeometryReader { proxy in
        layout(dolls: proxy.size.height >= 122, compactLine: proxy.size.height < 96)
      }
    }
  }

  private func layout(dolls: Bool, compactLine: Bool) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack(alignment: .center, spacing: 5) {
        FlameImage(flame: NestyWidgetCore.flame(for: day.state), size: 36, look: look)
        if let number = day.number {
          StreakNumber(text: number, style: .smallNumber, look: look, palette: palette, brand: brand)
        }
      }
      .frame(height: 40)
      // TODO(design): one line, then the short form (gap 12).
      WidgetFitLine(candidates: NestyWidgetCore.labelCandidates(day), style: .smallLabel, brand: brand)
        .foregroundColor(palette.label)
        .padding(.top, 3)
      if dolls && !day.dolls.isEmpty {
        DollsRow(dolls: day.dolls, width: 15, height: 20, gap: 4, cap: 6, look: look)
          .padding(.top, 12)
      }
      Spacer(minLength: 0)
      DayLine(day: day, style: .smallLine, compact: compactLine, brand: brand)
        .foregroundColor(palette.line)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// systemMedium (design spec §2.3): `left 104 | 14 | 1.5 divider | 14 |
/// right`.
private struct DayMedium: View {
  let day: NestyWidgetDay
  let look: WidgetLook
  let palette: WidgetPalette
  let brand: Bool

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      VStack(alignment: .leading, spacing: 0) {
        FlameImage(flame: NestyWidgetCore.flame(for: day.state), size: 46, look: look)
        Spacer(minLength: 0)
        if let number = day.number {
          StreakNumber(text: number, style: .mediumNumber, look: look, palette: palette, brand: brand)
        }
        // TODO(design): the label wraps to two lines in the 104 column, then
        // takes its short form (gap 11).
        WidgetFitText(
          NestyWidgetCore.labelCandidates(day), style: .mediumLabel, brand: brand, lines: 2
        )
        .foregroundColor(palette.label)
        .padding(.top, day.number == nil ? 0 : 4)
      }
      .frame(width: 104, alignment: .leading)
      .frame(maxHeight: .infinity, alignment: .topLeading)
      ColumnDivider(palette: palette)
      rightColumn
    }
  }

  @ViewBuilder private var rightColumn: some View {
    if #available(iOS 16.0, *) {
      ViewThatFits(in: .vertical) {
        right(dolls: true, compactLine: false)
        right(dolls: false, compactLine: false)
        right(dolls: false, compactLine: true)
      }
    } else {
      GeometryReader { proxy in
        right(dolls: proxy.size.height >= 112, compactLine: proxy.size.height < 80)
      }
    }
  }

  private func right(dolls: Bool, compactLine: Bool) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      WidgetText(day.title, style: .mediumTitle, brand: brand)
        .lineLimit(1)
        .truncationMode(.tail)
        .foregroundColor(palette.title)
      if let sub = day.sub {
        WidgetText(sub, style: .mediumSub, brand: brand)
          .lineLimit(1)
          .foregroundColor(palette.label)
          .padding(.top, 3)
      }
      if dolls && !day.dolls.isEmpty {
        DollsRow(dolls: day.dolls, width: 19, height: 26, gap: 5, cap: 8, look: look)
          .padding(.top, 12)
      }
      Spacer(minLength: 0)
      DayLine(day: day, style: .mediumLine, compact: compactLine, brand: brand)
        .foregroundColor(palette.line)
    }
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

/// The state line at the bottom: two lines, then the short form, then an
/// ellipsis; [compact] is the tight tier's one line in the short form.
private struct DayLine: View {
  let day: NestyWidgetDay
  let style: WidgetTextStyle
  let compact: Bool
  let brand: Bool

  var body: some View {
    let candidates = NestyWidgetCore.lineCandidates(day)
    if compact {
      WidgetText(candidates.last ?? day.line, style: style, brand: brand)
        .lineLimit(1)
        .truncationMode(.tail)
    } else {
      WidgetFitText(candidates, style: style, brand: brand, lines: 2)
    }
  }
}

/// The streak: tabular digits, one line, never below 0.8 (textFit.widget
/// .number; 1000+ comes grouped in the snapshot). Accented in tinted mode.
// TODO(design): 1000+ relies on the 0.8 floor alone (gap 16).
private struct StreakNumber: View {
  let text: String
  let style: WidgetTextStyle
  let look: WidgetLook
  let palette: WidgetPalette
  let brand: Bool

  var body: some View {
    WidgetText(text, style: style, brand: brand, tabular: true)
      .lineLimit(1)
      .minimumScaleFactor(0.8)
      .foregroundColor(palette.number)
      .modifier(Accentable(on: look.tinted))
  }
}

// MARK: - Locked and first-run

/// systemSmall before Level 2: daily_mark 42, the title, the line (design
/// spec §2.2 "Locked"). No short form.
private struct LockedSmall: View {
  let title: String
  let line: String
  let look: WidgetLook
  let palette: WidgetPalette
  let brand: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      DailyMark(size: 42, look: look)
      Spacer(minLength: 0)
      WidgetText(title, style: .lockedTitle, brand: brand)
        .lineLimit(1)
        .truncationMode(.tail)
        .foregroundColor(palette.title)
      WidgetText(line, style: .lockedSmallLine, brand: brand)
        .lineLimit(2)
        .truncationMode(.tail)
        .foregroundColor(palette.label)
        .padding(.top, 4)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
  }
}

/// systemMedium before Level 2: daily_mark 56 in a 64 column; the title and
/// the medium line on the right (design spec §2.3 "Locked medium").
private struct LockedMedium: View {
  let title: String
  let line: String
  let look: WidgetLook
  let palette: WidgetPalette
  let brand: Bool

  var body: some View {
    HStack(alignment: .top, spacing: 14) {
      VStack(alignment: .leading, spacing: 0) {
        DailyMark(size: 56, look: look)
        Spacer(minLength: 0)
      }
      .frame(width: 64, alignment: .leading)
      .frame(maxHeight: .infinity, alignment: .topLeading)
      ColumnDivider(palette: palette)
      VStack(alignment: .leading, spacing: 0) {
        WidgetText(title, style: .mediumTitle, brand: brand)
          .lineLimit(1)
          .truncationMode(.tail)
          .foregroundColor(palette.title)
        Spacer(minLength: 0)
        WidgetText(line, style: .mediumLine, brand: brand)
          .lineLimit(2)
          .truncationMode(.tail)
          .foregroundColor(palette.line)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
  }
}

// MARK: - Pieces

/// The medium layout's divider: 1.5 wide, radius 1, full height.
private struct ColumnDivider: View {
  let palette: WidgetPalette

  var body: some View {
    RoundedRectangle(cornerRadius: 1)
      .fill(palette.divider)
      .frame(width: 1.5)
      .frame(maxHeight: .infinity)
  }
}

/// The flame (44 dp art drawn at 36 or 46). Tinted: flame_lit as a template
/// in the accent, at 45 % when unlit (design spec §2.4, gap 9).
private struct FlameImage: View {
  let flame: NestyWidgetFlame
  let size: CGFloat
  let look: WidgetLook

  var body: some View {
    if look.tinted {
      tinted
        .frame(width: size, height: size)
        .opacity(flame == .lit ? 1 : 0.45)
        .modifier(Accentable(on: true))
    } else {
      Image(artName)
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: size, height: size)
    }
  }

  private var artName: String {
    switch flame {
    case .lit: return "WidgetFlameLit"
    // The dark art in dark mode and in StandBy (gap 17).
    case .unlit: return look.dark ? "WidgetFlameUnlitDark" : "WidgetFlameUnlit"
    }
  }

  @ViewBuilder private var tinted: some View {
    if #available(iOS 18.0, *) {
      Image("WidgetFlameLit")
        .resizable()
        .widgetAccentedRenderingMode(.accented)
        .aspectRatio(contentMode: .fit)
    } else {
      Image("WidgetFlameLit")
        .renderingMode(.template)
        .resizable()
        .aspectRatio(contentMode: .fit)
    }
  }
}

/// daily_mark, as drawn; at 0.8 in tinted mode.
private struct DailyMark: View {
  let size: CGFloat
  let look: WidgetLook

  var body: some View {
    art
      .aspectRatio(contentMode: .fit)
      .frame(width: size, height: size)
      .opacity(look.tinted ? 0.8 : 1)
  }

  @ViewBuilder private var art: some View {
    if #available(iOS 18.0, *), look.tinted {
      Image("WidgetDailyMark").resizable().widgetAccentedRenderingMode(.fullColor)
    } else {
      Image("WidgetDailyMark").resizable()
    }
  }
}

/// The date's daily colours, as many as fit (at most [cap]), bottom-aligned.
/// Tinted: desaturated.
// TODO(design): more colours than fit show the first N, no "+N" (gap 15).
private struct DollsRow: View {
  let dolls: [String]
  let width: CGFloat
  let height: CGFloat
  let gap: CGFloat
  let cap: Int
  let look: WidgetLook

  var body: some View {
    let colors = dolls.compactMap(NestyWidgetCore.rgb(hex:))
    GeometryReader { proxy in
      let count = NestyWidgetCore.dollCount(
        available: Double(proxy.size.width),
        width: Double(width),
        gap: Double(gap),
        cap: cap,
        total: colors.count
      )
      HStack(alignment: .bottom, spacing: gap) {
        ForEach(0..<count, id: \.self) { index in
          doll
            .aspectRatio(contentMode: .fit)
            .frame(width: width, height: height)
            .foregroundColor(Color(widgetRGB: colors[index]))
        }
      }
    }
    .frame(height: height)
  }

  @ViewBuilder private var doll: some View {
    if #available(iOS 18.0, *), look.tinted {
      Image("WidgetDoll").renderingMode(.template).resizable()
        .widgetAccentedRenderingMode(.accentedDesaturated)
    } else {
      Image("WidgetDoll").renderingMode(.template).resizable()
    }
  }
}

/// `widgetAccentable()` where it exists (iOS 16+).
private struct Accentable: ViewModifier {
  let on: Bool

  func body(content: Content) -> some View {
    if #available(iOS 16.0, *) {
      content.widgetAccentable(on)
    } else {
      content
    }
  }
}

/// One accessibility element labelled from the snapshot's `a11y` (design
/// spec §5); first-run reads its visible texts.
private struct WidgetAccessibility: ViewModifier {
  let label: String?

  func body(content: Content) -> some View {
    if let label {
      content
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(label))
    } else {
      content.accessibilityElement(children: .combine)
    }
  }
}
