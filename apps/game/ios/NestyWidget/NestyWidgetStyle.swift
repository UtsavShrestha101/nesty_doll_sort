import SwiftUI
import UIKit

// The widget's look: tokens.json `habits.widget` (colors, layout) and the
// design spec §2.1–2.4 (build/local-habits/reports/stage4-widget-design-spec.md)
// with the lead's rulings.

/// How the system is drawing the widget right now.
struct WidgetLook: Equatable {
  /// The dark palette: dark mode, or StandBy (iOS 17), which drops the
  /// container background and keeps the content on black.
  var dark: Bool
  /// iOS 18's tinted home screen (`widgetRenderingMode == .accented`).
  var tinted: Bool

  static let light = WidgetLook(dark: false, tinted: false)
}

extension Color {
  /// `#RRGGBB` (tokens.json values) with an opacity.
  init(widgetHex hex: UInt32, opacity: Double = 1) {
    self.init(
      .sRGB,
      red: Double((hex >> 16) & 0xFF) / 255,
      green: Double((hex >> 8) & 0xFF) / 255,
      blue: Double(hex & 0xFF) / 255,
      opacity: opacity
    )
  }

  init(widgetRGB rgb: NestyWidgetRGB) {
    self.init(.sRGB, red: rgb.red, green: rgb.green, blue: rgb.blue, opacity: 1)
  }
}

/// tokens.json `habits.widget.colors`.
struct WidgetPalette {
  let title: Color
  let number: Color
  let label: Color
  let line: Color
  let divider: Color

  static func of(_ look: WidgetLook) -> WidgetPalette {
    if look.tinted {
      // TODO(design): the tinted frames (14.4f) draw mock values; the real
      // tint is the system's, these are the spec's whites (gap 9).
      return WidgetPalette(
        title: Color.white.opacity(0.92),
        number: Color.white,
        label: Color.white.opacity(0.7),
        line: Color.white.opacity(0.92),
        divider: Color.white.opacity(0.22)
      )
    }
    if look.dark {
      // TODO(design): StandBy uses the dark tokens (label #E3C9A4), not the
      // frame's #C9B49A, and keeps them on a light phone (gaps 6, 17).
      return WidgetPalette(
        title: Color(widgetHex: 0xFFF4E0),
        number: Color(widgetHex: 0xFFF4E0),
        label: Color(widgetHex: 0xE3C9A4),
        line: Color(widgetHex: 0xF6E2C2),
        divider: Color(widgetHex: 0xFFECCD, opacity: 0.18)
      )
    }
    return WidgetPalette(
      title: Color(widgetHex: 0x5B3A21),
      number: Color(widgetHex: 0x5B3A21),
      label: Color(widgetHex: 0x8A5B3A),
      line: Color(widgetHex: 0x6E4526),
      divider: Color(widgetHex: 0x8A5B3A, opacity: 0.18)
    )
  }
}

/// The container's gradient (180deg, top to bottom). Tinted mode shows the
/// system's background, so it draws nothing there.
struct WidgetBackground: View {
  let look: WidgetLook

  var body: some View {
    if look.tinted {
      Color.clear
    } else if look.dark {
      LinearGradient(
        gradient: Gradient(colors: [Color(widgetHex: 0x3A2414), Color(widgetHex: 0x24150B)]),
        startPoint: .top,
        endPoint: .bottom
      )
    } else {
      LinearGradient(
        gradient: Gradient(colors: [Color(widgetHex: 0xFFF9EE), Color(widgetHex: 0xFCEBD0)]),
        startPoint: .top,
        endPoint: .bottom
      )
    }
  }
}

/// The widget's three faces (tokens.json `habits.widget.layout`).
enum WidgetFace {
  /// Fredoka 700: the number, titles and the line.
  case display
  /// Nunito 800: the label and the sub.
  case label
  /// Nunito 700: the locked small line.
  case body

  var postScriptName: String {
    switch self {
    case .display: return "Fredoka-Bold"
    case .label: return "Nunito-ExtraBold"
    case .body: return "Nunito-Bold"
    }
  }

  var systemWeight: Font.Weight {
    switch self {
    case .display, .body: return .bold
    case .label: return .heavy
    }
  }

  /// True when the bundled font registered (UIAppFonts); else the system
  /// rounded face draws (design spec §9).
  var isBundled: Bool {
    WidgetFace.registered[self] ?? false
  }

  private static let registered: [WidgetFace: Bool] = {
    var out: [WidgetFace: Bool] = [:]
    for face in [WidgetFace.display, .label, .body] {
      out[face] = UIFont(name: face.postScriptName, size: 12) != nil
    }
    return out
  }()

  /// The font at [size]. [brand] is the lead ruling on gap 10: Fredoka and
  /// Nunito for en, es, pt, pt_BR, id, de and fr; the whole widget in the
  /// system rounded face for tr, hi and ja.
  // TODO(design): no widget face is drawn for tr, hi or ja (gap 10).
  func font(size: CGFloat, brand: Bool) -> Font {
    if brand, isBundled {
      return .custom(postScriptName, fixedSize: size)
    }
    return .system(size: size, weight: systemWeight, design: .rounded)
  }

  /// The face's natural line height at [size], so a CSS line-height can be
  /// matched with `lineSpacing`.
  func naturalLineHeight(size: CGFloat, brand: Bool) -> CGFloat {
    if brand, isBundled, let font = UIFont(name: postScriptName, size: size) {
      return font.lineHeight
    }
    return UIFont.systemFont(ofSize: size, weight: systemWeight.uiWeight).lineHeight
  }
}

extension Font.Weight {
  fileprivate var uiWeight: UIFont.Weight {
    switch self {
    case .heavy: return .heavy
    case .bold: return .bold
    default: return .regular
    }
  }
}

/// One text style of the widget: a face, a size (scaled with Dynamic Type,
/// capped by the root) and a CSS line height.
struct WidgetTextStyle {
  let face: WidgetFace
  let size: CGFloat
  let lineHeight: CGFloat
  let relativeTo: Font.TextStyle

  // tokens.json habits.widget.layout.small
  static let smallNumber = WidgetTextStyle(face: .display, size: 36, lineHeight: 1, relativeTo: .largeTitle)
  static let smallLabel = WidgetTextStyle(face: .label, size: 12, lineHeight: 1.1, relativeTo: .caption)
  static let smallLine = WidgetTextStyle(face: .display, size: 14, lineHeight: 1.2, relativeTo: .subheadline)
  static let lockedTitle = WidgetTextStyle(face: .display, size: 17, lineHeight: 1.15, relativeTo: .headline)
  static let lockedSmallLine = WidgetTextStyle(face: .body, size: 13, lineHeight: 1.3, relativeTo: .footnote)
  // tokens.json habits.widget.layout.medium
  static let mediumNumber = WidgetTextStyle(face: .display, size: 42, lineHeight: 1, relativeTo: .largeTitle)
  static let mediumLabel = WidgetTextStyle(face: .label, size: 12, lineHeight: 1.15, relativeTo: .caption)
  static let mediumTitle = WidgetTextStyle(face: .display, size: 17, lineHeight: 1.15, relativeTo: .headline)
  static let mediumSub = WidgetTextStyle(face: .label, size: 12.5, lineHeight: 1.2, relativeTo: .caption)
  static let mediumLine = WidgetTextStyle(face: .display, size: 15, lineHeight: 1.2, relativeTo: .subheadline)
}

/// A text in a [WidgetTextStyle], its size scaled with Dynamic Type.
struct WidgetText: View {
  let text: String
  let style: WidgetTextStyle
  let brand: Bool
  /// Monospaced digits (the streak number, `font-variant-numeric:
  /// tabular-nums`).
  var tabular = false
  @ScaledMetric private var size: CGFloat

  init(_ text: String, style: WidgetTextStyle, brand: Bool, tabular: Bool = false) {
    self.text = text
    self.style = style
    self.brand = brand
    self.tabular = tabular
    _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
  }

  var body: some View {
    let font = style.face.font(size: size, brand: brand)
    let natural = style.face.naturalLineHeight(size: size, brand: brand)
    Text(text)
      .font(tabular ? font.monospacedDigit() : font)
      .lineSpacing(max(0, size * style.lineHeight - natural))
  }
}

/// The first of [candidates] that fits in [lines] lines, the last one cut
/// with an ellipsis (textFit.widget: "two lines, then ellipsis", with the
/// copy.md short forms in between). iOS 14–15 have no `ViewThatFits`, so they
/// draw the first form in [lines] lines with an ellipsis.
struct WidgetFitText: View {
  let candidates: [String]
  let style: WidgetTextStyle
  let brand: Bool
  let lines: Int
  @ScaledMetric private var size: CGFloat

  init(_ candidates: [String], style: WidgetTextStyle, brand: Bool, lines: Int) {
    self.candidates = candidates
    self.style = style
    self.brand = brand
    self.lines = lines
    _size = ScaledMetric(wrappedValue: style.size, relativeTo: style.relativeTo)
  }

  var body: some View {
    if #available(iOS 16.0, *), candidates.count > 1 {
      let natural = style.face.naturalLineHeight(size: size, brand: brand)
      let lineBox = max(natural, size * style.lineHeight)
      ViewThatFits(in: .vertical) {
        WidgetText(candidates[0], style: style, brand: brand)
          .fixedSize(horizontal: false, vertical: true)
        WidgetText(candidates[candidates.count - 1], style: style, brand: brand)
          .lineLimit(lines)
      }
      .frame(maxHeight: ceil(CGFloat(lines) * lineBox) + 1)
    } else {
      WidgetText(candidates.first ?? "", style: style, brand: brand).lineLimit(lines)
    }
  }
}

/// The first of [candidates] that fits on one line, the last one cut with an
/// ellipsis (the small label and copy.md's short form for "resting").
struct WidgetFitLine: View {
  let candidates: [String]
  let style: WidgetTextStyle
  let brand: Bool

  var body: some View {
    if #available(iOS 16.0, *), candidates.count > 1 {
      ViewThatFits(in: .horizontal) {
        WidgetText(candidates[0], style: style, brand: brand)
          .lineLimit(1)
          .fixedSize(horizontal: true, vertical: false)
        WidgetText(candidates[candidates.count - 1], style: style, brand: brand)
          .lineLimit(1)
      }
    } else {
      WidgetText(candidates.first ?? "", style: style, brand: brand).lineLimit(1)
    }
  }
}

/// Caps Dynamic Type at xxLarge (about 1.24×) for the 1.3× rule (design spec
/// §2.4, gap 19).
struct WidgetTypeCap: ViewModifier {
  @Environment(\.sizeCategory) private var category

  private static let order: [ContentSizeCategory] = [
    .extraSmall, .small, .medium, .large, .extraLarge, .extraExtraLarge,
    .extraExtraExtraLarge, .accessibilityMedium, .accessibilityLarge,
    .accessibilityExtraLarge, .accessibilityExtraExtraLarge,
    .accessibilityExtraExtraExtraLarge,
  ]

  func body(content: Content) -> some View {
    if #available(iOS 15.0, *) {
      // TODO(design): the cap at xxLarge is the spec's default (gap 19).
      content.dynamicTypeSize(...DynamicTypeSize.xxLarge)
    } else {
      let cap = WidgetTypeCap.order.firstIndex(of: .extraExtraLarge) ?? 5
      let index = WidgetTypeCap.order.firstIndex(of: category) ?? 3
      content.environment(\.sizeCategory, index > cap ? .extraExtraLarge : category)
    }
  }
}
