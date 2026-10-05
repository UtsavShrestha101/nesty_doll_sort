import '../support/locale_rules.dart';

/// Indonesian, kamu (l10n.md §2.3). Never "slot" for a stand: it reads as
/// gambling (§2.2). [MatchMode.indonesian] lets a word carry -nya, -lah,
/// -kah, -pun, -mu or -ku; affixed forms (ke-…-an, ber-, me-, di-) are
/// their own entries, so "kalah" never matches "kalahkan" ("beat", as in
/// raceRivalLocked) or "terkalahkan". "streak" is the loanword the game
/// uses for the daily run (glossary: "hari beruntun" in the plan, "streak"
/// in the copy), so both are streak words.
const idRules = LocaleRules(
  code: 'id',
  pluralCategories: {'other'},
  match: MatchMode.indonesian,
  denied: [
    // Loss.
    'hilang', 'kehilangan', 'lenyap', 'direset', 'reset', 'mereset', 'putus',
    'terputus',
    'rusak',
    'padam',
    'memadamkan',
    'habis',
    'kehabisan',
    'terlewat',
    'ketinggalan',
    // Guilt and absence.
    'jangan', 'jangan lupa', 'lupa', 'kangen', 'rindu', 'kecewa',
    'mengecewakan', 'sedih', 'malu', 'memalukan', 'bersalah', 'menyesal',
    'tinggalkan', 'ditinggal', 'tanpamu',
    // Urgency.
    'cepat', 'lekas', 'buruan', 'buru-buru', 'keburu', 'tergesa-gesa',
    'segera', 'sekarang', 'sebelum', 'kedaluwarsa', 'kadaluarsa',
    'berakhir*', 'batas waktu', 'kesempatan terakhir', 'detik terakhir',
    'hari ini saja', 'sebentar lagi', 'jangan sampai',
    // Scarcity and FOMO.
    'hanya', 'cuma', 'tersisa', 'sisa', 'tinggal', 'terbatas', 'eksklusif',
    'langka', 'selagi ada', 'yang terakhir', 'satu-satunya',
    // Streak loss.
    'pertahankan', 'jaga streak', 'selamatkan', 'streak putus',
  ],
  taunts: [
    'pecundang',
    'lambat',
    'lamban',
    'terlalu lambat',
    'kalah',
    'kamu kalah',
    'payah',
    'lemah',
    'menyerah',
    'menyerahlah',
    'gagal',
    'haha',
    'hahaha',
    'hehe',
    'wkwk',
    'semoga beruntung',
    'memalukan',
    'noob',
    'cupu',
    'cemen',
    'bodoh',
    'menyedihkan',
    'gampang',
  ],
  starDenied: [
    'gagal',
    'coba lagi',
    'buruk',
    'jelek',
    'payah',
    'salah',
    'tidak berhasil',
    'tidak cukup',
    'terlalu banyak',
    'sangat kurang',
  ],
  streakWords: ['beruntun', 'streak*', 'berturut-turut', 'api'],
  computerStem: 'komputer',
  identicalAllowed: {
    'levelTitle': '"Level" is the Indonesian game word (§2.2)',
    'levelWithTier': '"Level" is the Indonesian game word (§2.2)',
    'offlineTitle': '"Offline" is the Indonesian word',
    'navMuseum': '"Museum" is Indonesian',
    'navMuseumShort': '"Museum" is Indonesian',
    'homeMuseumTile': '"Museum" is Indonesian',
    'museumTitle': '"Museum" is Indonesian',
    'homeBonusBadge': 'BONUS is the same word in this language',
    'skinDetailTitle': '"Skin" is the Indonesian game word',
  },
  humanStatus: [
    'online',
    'mengetik',
    'pemain 2',
    'obrolan',
    'chat',
    'pesan',
    'aktif',
    'bergabung',
    'teman',
  ],
);
