import '../support/locale_rules.dart';

/// Japanese, です/ます, no あなた (l10n.md §2.3). Provisional lists from
/// l10n.md §3.3, matched as substrings: T4 refined them, R4 extended them.
/// "だけ" is too common to deny (§3.2 item 6); the rival's pace reads
/// ゆっくり, never 遅い, so no exemption is needed.
const jaRules = LocaleRules(
  code: 'ja',
  pluralCategories: {'other'},
  match: MatchMode.substrings,
  denied: [
    // Loss.
    '失う', '失っ', '失わ', 'なくな', '消え', '途切れ', 'リセット', 'ゼロに戻',
    '台無し',
    // Guilt and absence.
    '忘れ', '寂し', 'さみし', 'がっかり', '残念', '悲し', '恥', '見捨て',
    // Urgency.
    '急いで', '早く', '今すぐ', 'すぐに', '前に', '期限', '終了', '終わり',
    'ラストチャンス', '最後のチャンス', '今日だけ', '本日限り', 'まもなく',
    // Scarcity and FOMO.
    '残りわずか', '残り', '限定', '期間限定', 'レア', '今だけ', 'なくなり次第',
    '最後の1つ',
    // Streak loss.
    '連続記録が途切れ', '連続が途切れ', '連続記録を守', '連続を失',
    // T4 additions: other natural forms of the same ideas.
    '失くし', '無くな', '見逃', 'もうすぐ', '急ぎ', '今日限り', '急い',
    // R4 additions (review): more hurry, loss, missing-you and scarcity forms.
    'お早めに', '急げ', '今のうちに', '逃さ', '逃す', '失い', '途絶え', 'さびし',
    'わずか', 'ラスト',
  ],
  taunts: [
    '負け',
    '遅い',
    '遅すぎ',
    '弱い',
    '楽勝',
    'ざまあ',
    '情けない',
    'あきらめ',
    '失敗',
    '敗北',
    '下手',
    '笑',
    'ざこ',
    '雑魚',
    'だめ',
    '勝てない',
    // R4 additions (review): slow in kana, gloating and condescension.
    'おそい',
    'のろい',
    'のろま',
    'ヘタ',
    'へたくそ',
    '余裕',
    'ドンマイ',
  ],
  starDenied: [
    '失敗', 'もう一度挑戦', 'やり直して', 'ダメ', 'だめ', '悪い', '間違', '足りない',
    '多すぎ',
    // R4 addition (review).
    '不十分',
  ],
  streakWords: ['連続'],
  computerStem: 'コンピューター',
  humanStatus: ['オンライン', '入力中', 'プレイヤー2', 'チャット'],
  identicalAllowed: {
    'introNew': 'NEW is the stock chip for a new feature in Japanese games',
  },
);
