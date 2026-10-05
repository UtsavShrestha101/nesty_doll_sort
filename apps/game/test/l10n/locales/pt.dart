import '../support/locale_rules.dart';

/// Brazilian Portuguese, você (l10n.md §2.3): `app_pt.arb` holds the
/// catalog and `pt_BR` inherits these rules (§5.3). Refined by T1 from
/// l10n.md §3.3. "já" is too common to deny, and "reiniciar" is the
/// Restart label (§3.2 item 6). The imperative "vença" ("Vença {rival}")
/// differs from the denied "vence" (expires), so it needs no exemption.
const ptRules = LocaleRules(
  code: 'pt',
  pluralCategories: {'one', 'many', 'other'},
  oneIncludesZero: true,
  match: MatchMode.words,
  denied: [
    // Loss.
    'perder*', 'perca', 'perco', 'perda', 'perdid*', 'zera*', 'quebr*',
    'acabou', 'sumiu', 'esgotad*',
    // Guilt and absence.
    'não esqueça', 'esque*', 'sentimos sua falta', 'saudade', 'decepcion*',
    'triste', 'vergonha', 'abandon*',
    // Urgency.
    'rápido', 'rapidamente', 'corra', 'depressa', 'agora', 'antes que',
    'expira*', 'vence', 'vencimento', 'termina', 'acaba',
    'última chance', 'só hoje', 'em breve',
    // Scarcity and FOMO.
    'só', 'somente', 'apenas', 'restam', 'resta', 'limitad*', 'exclusiv*',
    'raro', 'escasso', 'enquanto durar', 'o último',
    // Streak loss.
    'perder sua sequência', 'manter sua sequência', 'salve sua sequência',
  ],
  taunts: [
    'perdedor',
    'perdedora',
    'lento',
    'lenta',
    'muito lento',
    'tartaruga',
    'te venci',
    'ganhei de você',
    'esmagad*',
    'fácil demais',
    'se esforce',
    'desist*',
    'fracass*',
    'derrota*',
    'patético',
    'fraco',
    'desajeitad*',
    'ridícul*',
    'kkk',
    'haha',
    'boa tentativa',
    'mais sorte',
    'você perdeu',
    'humilh*',
    'noob',
  ],
  starDenied: [
    'falhou',
    'falha',
    'fracassou',
    'tente de novo',
    'tente novamente',
    'ruim',
    'errad*',
    'incorret*',
    'insuficiente',
    'não é suficiente',
    'demais',
  ],
  streakWords: ['sequência*'],
  computerStem: 'computador',
  identicalAllowed: {},
  humanStatus: [
    'online',
    'conectad*',
    'digitando',
    'jogador 2',
    'jogadora 2',
    'chat*',
  ],
);
