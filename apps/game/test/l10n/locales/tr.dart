import '../support/locale_rules.dart';

/// Turkish, sen (l10n.md §2.3). Every entry is a stem and folds case the
/// Turkish way (İ→i, I→ı); [MatchMode.turkishStems] matches each as a
/// prefix of a word. "önce" alone also means "first" (raceStartHint), so
/// only the before-a-deadline forms ("bitmeden", "dolmadan", "geç kalma")
/// are denied. Stems that would catch ordinary UI words are written long
/// enough to avoid them (T3 round: "kaldı" also catches "kaldır", so a
/// copy line that needs "kaldır" must be re-worded, not exempted).
const trRules = LocaleRules(
  code: 'tr',
  pluralCategories: {'one', 'other'},
  match: MatchMode.turkishStems,
  denied: [
    // Loss.
    'kaybet', 'kayıp', 'kaybol', 'sıfırlan', 'sıfırla', 'bozul', 'kırıl',
    'kaçır', 'elden gi', 'yok ol', 'mahrum', 'eksik kal', 'söndür', 'sönüyor',
    // Guilt and absence.
    'unutma', 'unuttu', 'özledi', 'özleyece', 'hayal kırıklığı', 'üzgün',
    'üzül', 'utan', 'terk', 'suçlu', 'kırgın', 'ayıp', 'sensiz',
    // Urgency.
    'acele', 'acil', 'çabuk', 'hızlı', 'şimdi', 'hemen', 'bitmeden',
    'dolmadan', 'geç kalma', 'sona er', 'süresi dol', 'süre dol', 'son şans',
    'son dakika', 'son gün', 'sadece bugün', 'yalnızca bugün', 'yakında',
    'zaman daral', 'zamanı daral', 'kapanıyor',
    // Scarcity and FOMO.
    'sadece', 'yalnızca', 'yalnız', 'kaldı', 'sınırlı', 'özel teklif',
    'nadir', 'son fırsat', 'tek fırsat', 'tükeni', 'tükenir', 'tükeniyor',
    'kıt',
    // Streak loss.
    'serini kaybet', 'serini koru', 'serini kurtar', 'seri bozul',
    'seri bitme', 'seri sıfır',
  ],
  taunts: [
    'kaybeden',
    'ezik',
    'çok yavaş',
    'yavaş',
    'yendim',
    'yenildin',
    'ezildi',
    'pes et',
    'pes',
    'vazgeç',
    'başarısız',
    'yenilgi',
    'acınası',
    'zayıf',
    'haha',
    'hehe',
    'iyi denemeydi',
    'bol şans',
    'kaybettin',
    'utanç',
    'rezil',
    'çaylak',
    'beceriksiz',
    'berbat',
    'tembel',
    'amatör',
    'kolay geldi',
    'üzgünüm',
    // Slang for you are toast. The bare past form is not denied: with alev
    // (flame) it is the natural phrase for a lit streak flame.
    'yandın',
  ],
  starDenied: [
    'başarısız',
    'tekrar dene',
    'yeniden dene',
    'kötü',
    'yanlış',
    'yeterli değil',
    'yetersiz',
    'çok fazla',
    'berbat',
    'olmadı',
    'hata',
  ],
  streakWords: ['seri', 'ardışık', 'alev'],
  computerStem: 'bilgisayar',
  identicalAllowed: {
    'homeBonusBadge': 'BONUS is the same word in this language',
  },
  humanStatus: [
    'çevrimiçi',
    'yazıyor',
    'oyuncu 2',
    'sohbet',
    'mesaj',
    'aktif',
    'bağlandı',
    'ayrıldı',
    'arkadaş',
  ],
);
