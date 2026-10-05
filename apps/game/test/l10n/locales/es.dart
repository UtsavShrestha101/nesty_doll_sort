import '../support/locale_rules.dart';

/// Spanish, neutral Latin American, tú (l10n.md §2.3, Q162). Refined by T1
/// from l10n.md §3.3. "reiniciar" is the Restart label, so only the streak
/// forms are denied (§3.2 item 6). "vence" is also the imperative of
/// "vencer" ("Vence a {rival}"), so only the deadline forms are denied;
/// the rival lines use "gana a" instead.
const esRules = LocaleRules(
  code: 'es',
  pluralCategories: {'one', 'many', 'other'},
  match: MatchMode.words,
  denied: [
    // Loss.
    'perder*', 'pierd*', 'pérdida', 'perdid*', 'se reinicia', 'reiniciada',
    'romper*', 'rota', 'roto', 'se rompe', 'se acabó', 'desaparec*',
    'agotad*',
    // Guilt and absence.
    'no olvides', 'olvid*', 'te extrañamos', 'extrañ*', 'te echamos de menos',
    'decepcion*', 'triste', 'vergüenza', 'abandon*',
    // Urgency.
    'rápido', 'rápidamente', 'date prisa', 'apúrate', 'apresúrate', 'ahora',
    'ya mismo', 'antes de que', 'cuanto antes', 'expira*',
    'vencerá', 'se vence', 'vencimiento', 'caduca', 'termina', 'se acaba',
    'última oportunidad', 'solo hoy', 'sólo hoy', 'pronto',
    // Scarcity and FOMO.
    'solo', 'sólo', 'únicamente', 'solamente', 'quedan', 'queda', 'limitad*',
    'exclusiv*', 'raro', 'escaso', 'mientras dure', 'el último',
    // Streak loss.
    'pierdes tu racha', 'romper tu racha', 'salva tu racha', 'mantén tu racha',
    'conserva tu racha',
  ],
  taunts: [
    'perdedor',
    'perdedora',
    'lento',
    'lenta',
    'muy lento',
    'tortuga',
    'te gané',
    'te vencí',
    'aplastad*',
    'fácil',
    'esfuérzate',
    'ríndete',
    'fracas*',
    'derrota*',
    'patético',
    'débil',
    'torpe',
    'inútil',
    'ridícul*',
    'jaja',
    'buen intento',
    'mejor suerte',
    'perdiste',
    'humill*',
    'novato',
  ],
  starDenied: [
    'fallaste',
    'fallo',
    'fallido',
    'inténtalo de nuevo',
    'vuelve a intentarlo',
    'mal',
    'malo',
    'mala',
    'pobre',
    'incorrecto',
    'insuficiente',
    'no es suficiente',
    'demasiados',
  ],
  streakWords: ['racha*'],
  computerStem: 'computador',
  identicalAllowed: {
    'homeBonusBadge': '"BONUS" is the Spanish loanword on the Home badge',
  },
  humanStatus: [
    'en línea',
    'conectad*',
    'escribiendo',
    'jugador 2',
    'jugadora 2',
    'chat*',
  ],
);
