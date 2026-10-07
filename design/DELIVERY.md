# nesty-design-m7-5

Cumulative handoff root: every m7-4 file plus the changes below. Nothing here changes a game rule: prices, rewards, limits, unlocks and the gift track stay as the game has them.

## Part 1 · The daily gift (App Flow section 13)

**New files**
- `prototypes/NestyGift.dc.html`: the 17 frames of section 13 (scenes `homeReady` … `rmChest`).
- `ui/gift/gift_glyph.svg`: the gift button glyph, a small SVG (24 × 24, filled `#6E4526`, drawn to sit with the FILL 1 / weight 600 icons). It is not `redeem`.
- `ui/chest/chip_slot.svg`: the “+1 slot” chip disc, 30 dp, in the coin and hint discs’ style (green gradient, 2 dp bottom shade, white add box).
- `ui/sprites/slot_flight.svg`: the extra slot’s flight sprite, 48 dp, in `hint_flight`’s style. Day 7’s slot flies.
- `audio/gift_claim.wav`: 0.80 s, −7.7 dBFS peak. Plays on Claim.
- The three SVGs are also under `prototypes/ui/` for the frames.

**Changed files**
- `prototypes/Nesty App Flow.dc.html`: section 13 (13.1, 13.1b, 13.3, 13.3b, 13.5, 13.4, 13.2, 13.5b, 13.5c, 13.6, 13.6b, 13.6c, 13.6d, 13.7, 13.8, 13.5r, 13.6r).
- `prototypes/NestyHub.dc.html`: two additive props, `gift` (`ready` / `rest`) and `coins`. Unset, every existing frame draws as before.
- `tokens.json`: `gift` (button, ready dot, sheet, the four tile states, tally, claim, chest, reduce motion, 16:9 values under `gift.short`), `layout.home.giftButton`, `layout.homeShort.giftButton`, `chest.slotChip`, `type.gift`, `color.gift*` and `color.slotDisc*`, `sound.events.giftClaim`, `haptics.giftClaim`, `textFit.giftChestTitle`, `textFit.giftSheet`.
- `copy.md`: `## Daily gift` and its short forms.
- `audio/AUDIO.md`: `## SFX m7-5`. `generator/nesty-sfx.js` (and `prototypes/nesty-sfx.js`): `gift_claim`.
- `lottie/LOTTIE.md`: two rows in “When each one plays”. No new Lottie.

**Decisions**
- **Placement:** in the top row, left of the gear, 6 dp apart, as the game draws it. Home’s top row is where the small personal controls live, and it keeps the gift away from the Daily Puzzle tile and its flame. The short phone (13.1b) uses the same row at y 26; nothing else on 2.1b moves.
- **Ready mark:** a 12 dp gold dot with a 2.5 dp cream ring, static. Gold reads as a treat rather than an alert.
- **Sheet:** the stand-in’s grid, kept and finished. It is a grid in a sheet, so it can’t be read as 5.1’s strip. Done days sink and keep their gift at half strength with a green check; today has a 3 dp orange ring (the Claim colour); later days are plain white tiles. Day 7 is the wide tile with the closed chest and both rewards as chips.
- **Where a hint or a slot goes:** a tally slides out under the coin pill for the flight and steps its count up, then slides back after 1.2 s. The player sees the gift arrive and the new total. The booster itself waits in the booster bar.
- **Day 7 chest:** the 5.6 card and `ui_chest`, titled “Day 7 gift” (short form “Day 7”). No gift-specific tint: the house orange of 10.3b and 5.6. “A week of gifts” is withdrawn: it doesn’t fit, and the track counts claims, not weeks. Open, then Collect; no Double it.
- **Sound:** one short sound of its own, `gift_claim`. Without it a hint day would be silent, and `coins` would be wrong for a hint. Coin days add `coins` as the first coin lands; Day 7 reuses the chest’s sounds.

## Part 2 · The questions from the m7-4 runs

**Changed**
1. **Frame-only colours** (`color`, `$m75`): new `museumNextName` #FFEFD6, `trackShade`, `segmentEdge`, `rowDash`, `shadowWarm`, plus `shadow.cabinet`, `shadow.segmentTrack`, `shadow.segmentSelected`. Already named in m7-4: the toast kinds are `toastSuccess*`, `toastInfo*`, `toastBadge*`; the lit streak card is `streakCardTop` / `Bottom` / `Edge` (no frame draws #FFF2E6, #FFE7D0 or #E6B79A); the divider is `divider`; the won cell is `tileCream`; the lock is `lockGlyph`; the spotlight panel is `spotlightPanel`; the icons’ brown is `iconBrown`. The rival-select locked line is `textSecondary` (#8A5B3A), as the frame draws it.
2. **Type per surface:** a new `type` block for Home, Chapters, the Museum, Records, the Shop and the gift. The CSS stays the spec; these names index it.
3. **The chest flights:** the values were in `motion.chest.collect` since m7-4. The ring is `pillRing`: `0 0 0 4px rgba(255,214,110,.8), 0 0 18px 6px rgba(255,205,80,.6)`, on in 80 ms as the first coin lands (700 ms), off over 240 ms after the last. The trail is 6 dp `#FFF1C9` dots, 5 behind the coins and 3 behind the hint, 0.95 to 0.35, fading in 200 ms.
5. **Win ribbons:** the CSS is right. `ui_win_ribbon` now draws a 290 × 56 band with tails to 334, and its rects are named `band_rect`, `edge_rect` and `hi_rect` (also in `ui_chapter_ribbon`). `tokens.winRibbon.size`.
6. **Chest rays:** `ui_chest`’s rays are #FFD98A, at about 57 % at the peak, and 1.3× wider. The loop is unchanged.
7. **Chapter ribbon:** the Lottie stays and 4.7 is one line drawn over it. Recolour it with the named fills from m7-4 (`band_fill`, `edge_fill`, `tail_fill`, `fold_fill`) and the chapter palette, not a colour matrix. Its rects now have names for width.
8. **Tutorial hand:** no new file; play `ui_tap_hand` at 0.6 on its fingertip (`layout.tutorial.hand`).
9. **Case-break shatter:** the flash in `fx_glass_unlock` and `fx_glass_unlock_tall` is now a dome, not a rounded slab.
10. **Generating card:** `ui_spinner` is recoloured to the frame’s orange arc on a cream track (also used in 7.5). The 12.5 frame’s card was 272 wide by mistake (padding outside its 236); it is now 236.
11. **Splash top:** a fade covers the chapter-1 arch: `layout.splash.topFade`, solid `#FBEAD0` to 120 dp, clear at 240 dp.
14. **Wobble before a move:** the wobble eases to 0 over the first 80 ms of `doll_move`, overlapped, so the move starts at once without a snap (`motion.pick.wobbleToMoveMs`).
16. **Race strip:** both forms drawn, 9.3h (the count without dots) and 9.3i (the tag on the second line), in `prototypes/NestyStrip.dc.html`. In 9.3i the state comes back as a 16 dp glyph after the tag (`more_horiz`, `replay`, `check_circle`); the dots never shrink. `layout.rivalStrip.forms`.
18. **Figurine spotlight:** 300 tall, 200 on phones under 760 dp (`layout.museumDetail.spotlight`).
21. **Chapters on open:** `layout.chapters.scroll.foldedAbove: 3`, with the game’s rule for short phones.
22. **Capped win on 16:9:** the reason takes the tip’s row, with the families at 64 dp (new frame 11.2g, scene `winShortCap`).
26. **Freeze chip at zero:** the game is right. “No freeze” at zero, “{count} streak freeze(s)” otherwise; 5.2b now draws “No freeze”, and `copy.md` has both strings.
28. **Turkish titles:** Baloo 2 v1.700 (`Baloo2[wght].ttf` from google/fonts, the file Hindi already pins) for every Fredoka role in `tr`, whole strings. It covers ğ Ğ İ ş Ş and ₹. `font.scripts.latnTr`.

**Choices (keep)**
4. The Restart suggestion keeps the Undo’s soft gold glow (3.4), so every suggested booster looks the same.
10. The generating card stays centred in the safe area (no `layout.generating.top`).
12. The all-home Museum card: `museum_full.svg` at 92 dp is its centrepiece.
13. The undo: `doll_move` reversed, 260 ms, one `whoosh`, 130 ms under Reduce motion.
15. The relit twinkles at 22 and 14 dp.
17. The “Not enough coins” dialog stays centred; `layout.noCoins.top` now says so.
19. The Museum’s Play button at 38 inside a 48 dp box.
20. Chapters’ “levels to go” under the bar.
23. The board pieces at their limits: the tall case capped at the pitch − 2 dp, a 96-wide ice overlapping by up to 2.4 dp, and `fourShelves` pieces scaled with the dolls.
24. The badge toast’s earned line, the race win’s line and the Computer tag on 9.7b’s portrait.
25. The chest card at 10 of 10 drops its “N levels to the chest” line.
27. “Owned” (`a11y_skin_owned`).
