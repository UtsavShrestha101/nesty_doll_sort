# VoiceOver checklist (the owner, on an iPhone)

Phase 5's close, updated 2026-10-04 for m7-4. The iOS simulator has no
VoiceOver, so this needs a physical iPhone. The lines under each screen are
what the app's own strings say (`app_en.arb`, the semantics tests). The
Android half ran on the emulator (`talkback.sh`: 26 of 36 screens match the
app's semantics node for node, the rest expected), but TalkBack logged no
speech there, so what is spoken is still unheard. Treat a mismatch as a
finding, not as a certain bug.

## Turn it on

- Settings, Accessibility, VoiceOver, or the Accessibility Shortcut (triple-click the side button).
- Swipe right: next item. Swipe left: previous. Double-tap: press the focused item.
- Two-finger swipe up: read everything from the top. Three-finger swipe: scroll.

## Screens, in the order of the semantics tour

1. **Splash and level 1.** The first screen reads the Nesty name or its error card with "Try again". Level 1's tutorial card reads "Step n of 3. <title>" as one node (its chip and title are silent on their own) and has Skip. Before the HUD the board has one unlabelled node (its keyboard Focus node); confirm VoiceOver doesn't stop on an empty element there. TalkBack skips it.
2. **Home.** "Play level N, <tier>"; the chapter card ("Chapter N, <name>, E of T stars. Opens chapters."); "vs Computer, computer player"; the coin pill ("N coins. Get more coins"); the streak badge ("N-day streak", or "..., paused"). A freeze reads as "1 streak freeze" or "N streak freezes", never "left".
3. **Vs Computer.**
   - Rival select: each card reads "Pebble, Computer" (then Button, Comet); a locked card says it is locked; the button reads "Start race against Pebble".
   - Rival select now reads "<rival>, computer rival. <skill>." with no ". " seam; a locked card reads "Locked computer rival. Beat Button to unlock."; the picked card adds "Selected" and is also a checked radio, so listen for it said twice (Q172).
   - In a race: the strip reads "Pebble, Computer: D of T families"; "Race started against Pebble, a computer player." is announced; a restart announces "The computer is starting over."
   - The win and loss cards read "Rival N, Computer" and the stars ("N of 3 stars", "New best, N of 3 stars").
4. **Daily.** "Daily puzzle, <date>"; the streak card reads its count, state and freezes as one sentence; each day reads "Day N, done", "Today, day N", "Tomorrow, day N" or "Day N, chest"; Play reads "Play, N coins"; Share reads "Share today's result".
5. **Museum.** "N of T families home"; a niche reads "<name>, collected", "<name>, next, chapter C, N levels to go" or "Chapter C, levels A to B, locked"; the figurine modal has Close.
6. **Shop.** Buy buttons read "Buy, N coins"; a skin or theme detail has Close; "Not enough coins" has two actions and nothing behind it should be reachable.
7. **Settings.** Rows read their label and state; the reminder's time chip reads "Reminder time, every day at 7:00 PM. Change time." (on the offer too); the Language row reads "<autonym>, <detail>"; Reduce motion and the reminder rows are switches.
8. **Chapters.** A row reads "Chapter N, <name>, levels A to B, E of T stars" with its expanded or collapsed state (locked: "..., locked"); a level reads "Level N, won, best M moves", "Level N, play next" or "Level N, locked", plus "has a milestone chest" or "last level of the chapter".
9. **Records.** Each stat reads "<label>, <value>"; a race row reads "Pebble, computer player, races won: N" or "..., not unlocked yet"; a badge reads "<name>, earned" or "<name>, not earned yet. <hint>".
10. **Level overlays** (level 16's intro, Out of Moves, Pause, level 10's chest). Only the overlay should be reachable: nothing of the board or the HUD underneath. The chest reads "Chest. Inside: <contents>."
11. **The badge toast** ("Badge earned · <name>. <line>", on a win card). It stays 10 s, not 2.5 s, while VoiceOver is on (D249). Check that it is announced once, without moving focus off the win card, and that you can still swipe to it before it leaves.

## What to report

The screen, what VoiceOver said, and what you expected. A node that is silent, says the same thing twice, says a rival's name without "Computer", or lets you reach a screen behind a sheet is a finding.

## The known limit

The board can't be played with a screen reader: it has no nodes for its slots (Q154, review R12; default: v1.1, with a store-listing line). Every menu works.
