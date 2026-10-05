import '../support/locale_rules.dart';

/// Hindi, आप, everyday Hindi with the game words players use (l10n.md
/// §2.3, Q166). Provisional lists from l10n.md §3.3, nukta stripped
/// ([MatchMode.devanagari] strips it from the copy too): T4 refined them,
/// R4 extended them. "पहले" alone also means "first" (`raceStartHint`), so
/// only its before-a-deadline forms are denied (§3.2 item 6).
const hiRules = LocaleRules(
  code: 'hi',
  pluralCategories: {'one', 'other'},
  oneIncludesZero: true,
  match: MatchMode.devanagari,
  denied: [
    // Loss.
    'खो दें', 'खो देंगे', 'खो जाएगा', 'खोया', 'खोई', 'खो दिया', 'टूट*',
    'रीसेट', 'खत्म', 'गायब', 'नुकसान',
    // Guilt and absence.
    'मत भूलें', 'मत भूलना', 'भूल गए', 'याद आ रही', 'निराश', 'दुखी', 'शर्म',
    'छोड़ दिया',
    // Urgency.
    'जल्दी', 'जल्द', 'अभी', 'फौरन', 'तुरंत', 'से पहले', 'पहले कि', 'समाप्त',
    'आखिरी मौका', 'सिर्फ आज', 'केवल आज', 'समय सीमा',
    // Scarcity and FOMO.
    'सिर्फ', 'केवल', 'बचे', 'सीमित', 'एक्सक्लूसिव', 'दुर्लभ', 'आखिरी',
    // Streak loss.
    'स्ट्रीक खो', 'स्ट्रीक टूट', 'स्ट्रीक बचाएं', 'स्ट्रीक बनाए रखें',
    // T4 additions: other natural forms of the same ideas.
    'खो गया', 'खो गई', 'खो गए', 'देर न करें', 'अंतिम मौका', 'चूक', 'सिर्फ़ आज',
    'याद दिला रहे', 'हम आपको याद',
    // R4 additions (review): hurry, slipping away and missing-you wordings.
    'फटाफट', 'देर हो', 'गंवा*', 'मिट जा*', 'हाथ से निकल*', 'आपकी याद',
    'गिने-चुने',
  ],
  taunts: [
    'हार गए',
    'तुम हारे',
    'आप हारे',
    'धीमा',
    'बहुत धीमा',
    'कमजोर',
    'हार मान',
    'नाकाम',
    'बेकार',
    'शर्मनाक',
    'हाहा',
    'अच्छी कोशिश',
    'अगली बार किस्मत',
    'हारे',
    'हारा',
    'नालायक',
    // R4 additions (review): other forms of lost, fell behind and gloating.
    'हार गया',
    'हार गई',
    'हारी',
    'पिछड़*',
    'आसान था',
    'बुरी तरह',
  ],
  starDenied: [
    'असफल',
    'नाकाम',
    'फिर से कोशिश',
    'दोबारा कोशिश',
    'खराब',
    'गलत',
    'काफी नहीं',
    'बहुत ज्यादा',
    // R4 additions (review).
    'कमजोर',
    'अधूरा',
  ],
  streakWords: ['स्ट्रीक', 'लगातार'],
  computerStem: 'कंप्यूटर',
  humanStatus: ['ऑनलाइन', 'टाइप कर रहा', 'खिलाड़ी 2', 'चैट'],
);
