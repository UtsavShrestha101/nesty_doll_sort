/// How Home's Daily badge looks (`HomeState.streakLook`; frames 2.1, 12.2;
/// menus spec 1.1): a lit flame with its count, a paused (resting) one, a
/// just-relit one with its once-only ring, or an unlit flame with no number
/// at a streak of 0. Never a lost or red streak (spec-prop §7.5).
enum StreakLook { lit, paused, relit, zero }
