# Nesty copy (m7)

All the new copy for the m7 round, one line per string: `- <id>: <text>`. Ids are the request's ids where it gives them (badge ids, rival numbers, chapter numbers, museum file ids) and short slugs otherwise. Placeholders in braces are filled by the game: `{count}`, `{moves}`, `{date}`, `{day}`, `{time}`, `{rival}`, `{level}`, `{chapter}`, `{first}`, `{last}`, `{total}`, `{price}`, `{glyphs}`, `{badge}`, `{best}`, `{step}`, `{name}`, `{skill}`, `{booster}`, `{title}`, `{size}`, `{levels}`, `{how}`, `{contents}`, `{label}`, `{value}`. A plural is two lines, `one:` and `other:`. Curly quotes and the `·` separator are part of the strings.

## Changes in m7-5
- **Daily gift (new, App Flow section 13):** every string is in `## Daily gift`, its screen-reader lines included (`gift_a11y_*`), and its short forms are in `## Short forms`. It never says streak, missed, lose, reset, start over, ends or today only.
- **Streak freeze chip:** `streak_freeze_chip` and `streak_freeze_chip_none` are the strings the game ships (“{count} streak freeze(s)”, “No freeze”). The paused Daily (5.2b) now draws “No freeze”, in the same chip width.
- **Confirmed:** `a11y_skin_owned` is “Owned”, read after the skin’s name.

## Changes in m7-4
- **Placeholders for fixed numbers:** `daily_locked`, `rival_locked_mode`, `museum_intro`, `chapter_stars_total`, `records_stars_value` and `splash_storage_body` take the number from the game; `oom_undo_spent` and `slot_limit` are plurals now.
- **Rival lines:** `rival_n_skill` names a pace (Gentle, Steady, Lively), so no rival is called slow and no two read alike.
- **New ids for strings the frames already drew:** `strip_ready`, `race_pause_title`, `reminder_picker_title`, `relaxed_free_chip`, `museum_all_home_sub`, `museum_next_chip`, `gen_busy`, `tut_step_1_title` / `_body`, `tut_step_2_title` / `_body`. New strings: `rival_unlocked_race` and `rival_unlocked_later` (9.6), `settings_reminder_turn_off` (10.2f).
- **Records:** `records_families` is “Families completed”, a lifetime count shown with the family counter’s doll mark. `records_families_value` is withdrawn.
- **A11y:** every screen-reader string is in `## A11y`. The ones from G.5, G.9 and G.11 moved there unchanged, next to new labels for the icon-only controls.
- **Short forms:** `## Short forms` lists the fallbacks tokens.json → `textFit` names.
- **Respect rules:** `rival_2_personality`, `rival_3_personality`, `race_win_body` and `race_quit_body` are rewritten without “Slow”, “Quick”, “before”, “ends” or “lost”, so no exemptions are needed (frames updated).
- **More ids:** `chest_gain_tag`, the Daily chest row (`daily_chest_*`), `chapter_stars_total_all`, `reminder_not_now`; `museum_intro` takes `{levels}`. `records_three_star_levels` is withdrawn (no cell in 10.6).
- **A11y, second pass:** badge how-to lines (read only by a screen reader), the finale level, the chest’s contents, Share, the notification channel, Home’s cards and tile, the Museum’s niches and count, Records’ cells and race rows, rival select’s Beaten and Start, Reduce motion, the reminder time chip and “+Slot, 2 of 2 used”.

## G.1
Figurine family names, keyed by the museum file id (`museum/<id>.svg`).
- 01_classic: The Classic Family
- 02_sailor: The Sailor Family
- 03_baker: The Baker Family
- 04_astronaut: The Astronaut Family
- 05_gardener: The Gardener Family
- 06_snow: The Snow Family
- 07_circus: The Circus Family
- 08_musician: The Musician Family
- 09_royal: The Royal Family
- 10_explorer: The Explorer Family

## G.2
Flavor text, italic in the figurine detail (6.2). The Sailor line is the existing one.
- 01_classic: “The smallest one wins every game of hide-and-seek.”
- 02_sailor: “They keep a seashell in the smallest doll, just in case.”
- 03_baker: “They bake every loaf in four sizes, so nobody has to share.”
- 04_astronaut: “They count down from the biggest to the smallest before every trip to the moon.”
- 05_gardener: “Each hat hides a seed they’re saving for spring.”
- 06_snow: “When nobody is looking, they stack up into a snowman.”
- 07_circus: “Their best act is climbing inside each other, to great applause.”
- 08_musician: “They play one song in four sizes. The smallest takes the high notes.”
- 09_royal: “Every crown fits inside the next one, which saves a lot of room.”
- 10_explorer: “They’ve mapped every shelf in the shop, and they’re not done yet.”

## G.3
Skin descriptions for the Shop card and the skin detail (7.3, 7.4), in the style of Ocean’s line.
- classic: Painted flowers, gold dots and a little bow.
- ocean: Sailor collars, tiny anchors and wave trims.
- space: Round helmets, tiny antennas and ringed planets.
- sweets: Frosting drips, sprinkles and candy stripes.
- forest: Pointy ears, pearl-trimmed hoods and falling leaves.
- winter: Pompom hats, snowflakes and pearly trims.

## G.4
Chapter names. The chapter ribbon reads `CHAPTER {chapter} · <name>`.
- 7: Puppet Theater
- 8: Autumn Bandstand
- 9: Castle Library
- 10: Sunrise Lookout

## G.5
vs Computer. Every rival surface also carries the “Computer” tag and its glyph, so no line has to say it.
- tag_computer: Computer
- rival_1_name: Pebble
- rival_1_personality: Takes its time and enjoys every doll along the way.
- rival_1_skill: Gentle pace
- rival_2_name: Button
- rival_2_personality: Checks each move twice, then makes it.
- rival_2_skill: Steady pace
- rival_3_name: Comet
- rival_3_personality: Lively, tidy and hard to catch.
- rival_3_skill: Lively pace
- rival_reward:
  - one: Win {count} coin
  - other: Win {count} coins
- rival_locked: Beat {rival} to unlock
- rival_locked_mode: After Level {level}
- mode_title: vs Computer
- mode_sub: Race a computer on the same puzzle
- race_start: Start
- race_start_hint: Same puzzle, two boards. Complete every family first.
- strip_ready: Ready when you are
- strip_thinking: Thinking…
- strip_starting_over: Starting over
- strip_families: {count}/{total}
- strip_finished: Finished
- strip_after_you_won: You finished first
- race_win_title: You won the race!
- race_win_body: Every family is complete. {rival} was still sorting.
- race_win_coins:
  - one: +{count} coin
  - other: +{count} coins
- race_lose_title: So close! Rematch?
- race_lose_body: {rival} finished first this time. A rematch costs nothing.
- race_rematch: Rematch
- race_new: New race
- rival_unlocked_title: New rival unlocked!
- rival_unlocked_body: {rival} is ready to race.
- rival_unlocked_race: Race {rival}
- rival_unlocked_later: Not now
- race_quit_title: Leave this race?
- race_quit_body: The race stops here. No coins, and you keep everything.
- race_quit_yes: Leave race
- race_quit_no: Keep racing


Screen labels (m7-2):
- home_tile_versus: vs Computer
- rival_new: New
- race_pause_title: vs Computer · {rival}
- race_pause_rival: {rival} is paused too.
- race_pause_leave: Leave race
- race_failed_title: The shelves need a moment
- race_failed_body: This race didn’t set up. Try again, or pick another race.
- race_failed_retry: Try again
- race_failed_back: Back to races
## G.6
Daily share text (I.1): text only, through the phone’s share sheet. It names the day, the families by their belly-symbol emoji, the moves and the streak day. It never shows the board or a move. `{glyphs}` is one emoji per family in the puzzle, in the order the families appear on the board, joined with a space. Each DollColor id has its own emoji, the same symbol that is on the doll’s belly, so no two families look alike and nothing depends on color:
- glyph_red: ❤️
- glyph_orange: 🌼
- glyph_yellow: ☀️
- glyph_green: 🍃
- glyph_teal: 🌊
- glyph_blue: 💧
- glyph_purple: ⭐
- glyph_pink: 🎀
- glyph_navy: 🌙
- glyph_brown: 🌰
- glyph_gold: 👑

The template, three lines:
- share_line_1: Nesty Daily · {date}
- share_line_2: {glyphs}
- share_line_3:
  - one: Solved in {moves} move · Day {day} 🔥
  - other: Solved in {moves} moves · Day {day} 🔥
- share_line_3_no_streak:
  - one: Solved in {moves} move
  - other: Solved in {moves} moves
- share_button: Share

Example: `Nesty Daily · Sep 30` / `❤️ 💧 🍃 ⭐ 🌙` / `Solved in 18 moves · Day 12 🔥`. Use `share_line_3_no_streak` when the streak is 0 or paused. `{date}` is the locale’s abbreviated month and day (`MMMd`): “Sep 30”, “30. Sept.”, “9月30日”.

## G.7
Daily reminder (I.2).
- reminder_offer_title: Want a note when tomorrow’s puzzle is ready?
- reminder_offer_body: One quiet note a day, at a time you pick. You can turn it off in Settings.
- reminder_time_chip: Every day at {time}
- reminder_change_time: Change time
- reminder_picker_title: Reminder time
- reminder_yes: Yes, remind me
- reminder_no: No thanks
- reminder_set: Reminder set for {time}.
- reminder_denied_title: Notifications are off for Nesty
- reminder_denied_body: Turn them on in your phone’s settings, and your note will arrive at {time}.
- reminder_not_now: Not now
- settings_reminder: Daily reminder
- settings_reminder_on: Every day at {time}
- settings_reminder_off: Off
- settings_reminder_blocked: Off in your phone’s settings
- settings_open_phone_settings: Open phone settings
- settings_reminder_turn_off: Turn off
- notification_channel_name: Daily puzzle
- notification_channel_description: One note a day when a new daily puzzle is ready.
- notification_title: Nesty
- notification_1: Today’s puzzle is on the shelf.
- notification_2: A fresh daily puzzle is ready when you are.
- notification_3: New dolls are waiting to be nested. Today’s puzzle is ready.

`{time}` is the proposed time: the hour the player solved the daily, rounded down to the hour. 7:00 PM in the frames is only an example.

- settings_reminder_time: Time
- settings_reduce_motion: Reduce motion
- settings_reduce_motion_off: Off
- settings_reduce_motion_on: On
- settings_reduce_motion_system: System
## G.8
Badges (I.6). Cosmetic, earned once over the player’s lifetime. The one-liner says how it was earned.
- first_family: Snug as a Doll
- first_family_line: You nested your first family.
- glass_breaker: Glass Act
- glass_breaker_line: You opened your first glass case.
- ice_melter: Ice Breaker
- ice_melter_line: You freed a doll from the ice.
- tall_order: Tall Order
- tall_order_line: You won a level with size-5 dolls.
- grand_nest: Grand Nest
- grand_nest_line: You won a level with size-6 dolls.
- level_100: Halfway Home
- level_100_line: You won level 100.
- level_200: Top Shelf
- level_200_line: You won level 200, the very last one.
- dailies_7: Puzzle Pal
- dailies_7_line: You solved 7 daily puzzles.
- dailies_30: Old Friend
- dailies_30_line: You solved 30 daily puzzles.
- first_race: First Past the Shelf
- first_race_line: You beat the computer in a race.
- all_rivals: Rival Round-Up
- all_rivals_line: You beat every computer rival.
- museum_full: Full House
- museum_full_line: Every family is home in your Museum.
- badge_earned_toast: Badge earned · {badge}
- badge_locked_line: Not earned yet

- records_badges: Badges
## G.9
Milestone chest (I.3), shared with the day-7 streak chest (5.6). The contents are always shown before the chest opens.
- chest_milestone_title: Milestone chest
- chest_milestone_body: A chest for reaching level {level}. Here’s what’s inside.
- chest_bonus_body: A chest for bonus level {level}. Here’s what’s inside.
- chest_streak_title: 7-day streak!
- chest_coins:
  - one: +{count} coin
  - other: +{count} coins
- chest_hints:
  - one: +{count} hint
  - other: +{count} hints
- chest_open: Open
- chest_collect: Collect
- chest_progress:
  - one: {count} level to the chest
  - other: {count} levels to the chest

Relaxed mode (I.2).
- relaxed_title: Relaxed mode
- relaxed_sub: Unlimited free undo
- relaxed_on: Relaxed mode is on. Undo as often as you like.
- relaxed_undo_row: Free, as often as you like
- relaxed_free_chip: Free

Gentle streak (I.7). A missed day never lowers the number, and a freeze keeps the flame lit.
- streak_days:
  - one: {count} day
  - other: {count} days
- streak_lit: Your flame is lit. See you tomorrow.
- streak_paused_chip: Paused
- streak_paused: Your {count}-day streak is resting. Solve today’s puzzle to light it again.
- streak_relit_title: Streak relit!
- streak_relit_body: Your {count}-day streak is glowing again.
- streak_freeze_used: A freeze kept your flame lit.
- streak_zero: Solve today’s puzzle to light your first flame.
- streak_freeze_chip:
  - one: {count} streak freeze
  - other: {count} streak freezes
- streak_freeze_chip_none: No freeze

- chest_streak_body: Seven days in a row. Here’s what’s inside.
- chest_double: Double it
## G.10
Lines the stand-ins ship as placeholders, confirmed or replaced.
- museum_intro: Every chapter has a doll family. Win all {levels} of its levels to bring that family home.
- museum_next_to_go:
  - one: {count} level to go
  - other: {count} levels to go
- museum_next_line:
  - one: Chapter {chapter} · {count} level to go
  - other: Chapter {chapter} · {count} levels to go
- museum_locked_shelf: Chapter {chapter} · Levels {first}–{last}
- museum_locked_shelf_short: Ch {chapter} · {first}–{last}
- museum_all_home: Every family is home.
- museum_all_home_sub: Full House · all {count} families
- museum_next_chip:
  - one: {count} to go
  - other: {count} to go
- chapters_progress: Level {level} of {total}
- coins_needed_title: A few more coins
- coins_needed_body:
  - one: You need {count} more coin
  - other: You need {count} more coins
- coins_needed_where: Coins come from winning levels, the daily puzzle and chests.
- coins_needed_shop: Go to Shop
- coins_needed_later: Not now

- museum_next: Next family
- museum_play: Play Level {level}
- museum_locked_line_1: Chapter {chapter}
- museum_locked_line_2: Levels {first}–{last}
- chapters_title: Chapters
- chapters_won: {count} won
- records_title: Records
- records_levels_won: Levels won
- records_families: Families completed
- records_dolls_nested: Dolls nested
- records_dailies: Daily puzzles solved
- records_longest_streak: Longest streak
- records_races: Races won
- records_best_moves: Best moves by level
- records_stars_value: {count} of {total}
## G.11
Star rating (K). Stars sit inside the celebration and never replace it.
- replay_target: 3 stars at {moves} moves or fewer
- new_best: New best!
- stars_tip: Fewer moves earn more stars. Replay any level from Chapters.
- stars_helper_note: Wins with a hint or an extra slot earn up to 2 stars.
- chapter_stars_total: {count}/{total}
- chapter_stars_total_all: {count}/{total}
- chapter_all_three_stars: Every level at 3 stars
- records_stars: Stars
- moves_line: Moves {moves} · Best {best}
- moves_line_first: Moves {moves}
- level_best: Best {best}
- level_play: Play
- replay_reason: A replay for fun: coins come from new levels.
- replay_back: Back to Chapters

## H
The Forest Bear skin (`skins/forest-bear`).
- forest_bear_name: Forest Bear
- forest_bear_description: Round bear ears, cozy hoods and acorns in the leaves.
- forest_bear_price: 2,500

## E
States that needed new lines (m7-3).
- daily_locked: After Level {level}
- home_bonus_badge: BONUS
- home_bonus_kicker: BONUS ENDLESS
- home_bonus_name: Bonus levels
- bonus_win_label: Bonus Level {level}
- gen_busy: Setting up the shelves…
- chest_gain_tag: +{count}
- daily_chest_title:
  - one: Day 7 chest · {count} coin
  - other: Day 7 chest · {count} coins
- daily_chest_to_go:
  - one: {count} day to go
  - other: {count} days to go
- daily_chest_to_go_today:
  - one: {count} day to go, counting today
  - other: {count} days to go, counting today
- daily_chest_opened: Opened today
- gen_failed_title: The shelves need a moment
- gen_failed_body: This level didn’t set up. Try again, or head back home.
- gen_failed_retry: Try again
- gen_failed_home: Back to Home
- stuck_restart: Try Restart? You can keep playing too.
- oom_undo_spent:
  - one: Your {count} free undo is used
  - other: Your {count} free undos are used
- slot_limit:
  - one: One extra slot is the most for one level.
  - other: {count} extra slots is the most for one level.
- tut_step_chip: STEP {step} OF 3
- tut_step_1_title: Tap the small doll
- tut_step_1_body: Dolls nest into the same color, one size bigger.
- tut_step_2_title: Now tap the big one
- tut_step_2_body: The small doll drops inside with a clack.
- tut_step_3_title: Finish the family
- tut_step_3_body: Put the last doll in. A family is done when every size is nested.
- splash_storage_title: Your phone is nearly full
- splash_storage_body: Nesty needs about {size} MB to set up the shelves. Free some space, then try again.
- splash_content_title: The shelves didn’t unpack
- splash_content_body: Something went wrong while loading. Try again, or restart Nesty.
- splash_retry: Try again

## Daily gift
Section 13 (m7-5). One gift a day from a 7-day track that counts claims, not dates. The voice is warm and calm: no clock, no “today only”, nothing about missing a day, and no streak words, so it never reads as the Daily puzzle. `{n}` is the day or the amount, `{gift}` one of the gift phrases below.

Visible:
- gift_sheet_title: Daily gift
- gift_sheet_sub: One gift a day, at your own pace.
- gift_day: Day {n}
- gift_claim: Claim
- gift_claimed_today: Today’s gift is yours.
- gift_tomorrow: Tomorrow: {gift}
- gift_next: Next gift: {gift}

`gift_tomorrow` follows `gift_claimed_today` once today’s gift is claimed (13.4). `gift_next` is the waiting line when the phone’s clock went back (13.8): it shows alone, with no Claim button and no date.

Gift phrases, the values of `{gift}`:
- gift_coins:
  - one: {n} coin
  - other: {n} coins
- gift_hints:
  - one: {n} hint
  - other: {n} hints
- gift_slots:
  - one: {n} extra slot
  - other: {n} extra slots
- gift_join: {first} + {second}

Day 7 joins its two phrases with `gift_join`: “100 coins + 1 extra slot”, so the line reads “Tomorrow: 100 coins + 1 extra slot”.

The Day 7 chest (13.6), which keeps `chest_open`, `chest_collect` and `chest_coins` from G.9:
- gift_chest_title: Day 7 gift
- gift_chest_body: A chest for Day 7. Here’s what’s inside.
- gift_chest_slot_chip:
  - one: +{count} slot
  - other: +{count} slots

Screen reader:
- gift_a11y_button_ready: Daily gift. A gift is ready.
- gift_a11y_button: Daily gift
- gift_a11y_tile: Day {n}, {gift}. {state}
- gift_a11y_state_done: Claimed
- gift_a11y_state_today: Today’s gift
- gift_a11y_state_later: Coming up
- gift_a11y_chest_contents: {first}, {second}
- gift_a11y_claimed: Gift claimed: {gift}.
- gift_a11y_added: {gift} added. You have {count}.

`gift_a11y_tile` reads, for example, “Day 4, 40 coins. Today’s gift.” The Day 7 tile and the chest read their two phrases joined by `gift_a11y_chest_contents`, “100 coins, 1 extra slot”, which fills `{contents}` in `a11y_chest_contents` (“Chest. Inside: 100 coins, 1 extra slot.”). `gift_a11y_claimed` is a polite announcement once the claim lands; `gift_a11y_added` is read when a hint or an extra slot reaches the tally, with the new total (“1 hint added. You have 3.”). Home never announces a ready gift by itself; the button label carries it.

## A11y
Screen-reader strings for the m7 screens. Announcements (the rival’s progress, toasts, “Reminder set”) are polite: read once, after the current speech, and they never move focus. Buttons with visible text use that text; these cover icon-only controls and states the eye reads from colour or position.

The Daily gift’s screen-reader strings (`gift_a11y_*`) sit with the rest of its copy in `## Daily gift`.

Moved here unchanged:
- a11y_race_start: Race started against {rival}, a computer player.
- a11y_rival_family: The computer completed a family: {count} of {total}
- a11y_rival_starting_over: The computer is starting over.
- a11y_rival_finished: The computer completed every family.
- a11y_race_won: You won the race.
- a11y_race_lost: The computer finished first.
- a11y_undo_unlimited: Undo, unlimited
- a11y_stars: {count} of 3 stars
- a11y_stars_new_best: New best, {count} of 3 stars

Board and HUD:
- a11y_pause: Pause
- a11y_coins:
  - one: {count} coin. Opens the Shop.
  - other: {count} coins. Opens the Shop.
- a11y_family_counter: {count} of {total} families complete
- a11y_booster_undo:
  - one: Undo, {count} left
  - other: Undo, {count} left
- a11y_booster_hint:
  - one: Hint, {count} left
  - other: Hint, {count} left
- a11y_booster_slot:
  - one: Extra slot, {count} left
  - other: Extra slot, {count} left
- a11y_booster_price: {booster}, {price} coins
- a11y_booster_ad: {booster}, watch a video
- a11y_booster_slot_used: +Slot, {count} of {total} used
- a11y_booster_suggested: {booster}, suggested
- a11y_booster_restart: Restart the level
- a11y_tut_step: Step {step} of 3. {title}

Screens:
- a11y_back: Back
- a11y_close: Close
- a11y_settings: Settings
- a11y_streak:
  - one: {count}-day streak
  - other: {count}-day streak
- a11y_streak_paused:
  - one: {count}-day streak, paused
  - other: {count}-day streak, paused
- a11y_freezes:
  - one: {count} streak freeze left
  - other: {count} streak freezes left
- a11y_rival_card: {rival}, computer rival. {skill}.
- a11y_rival_locked: Locked computer rival. Beat {rival} to unlock.
- a11y_rival_selected: Selected
- a11y_rival_strip: {rival}, computer: {count} of {total} families
- a11y_chapter_row: Chapter {chapter}, {name}. {count} of {total} stars.
- a11y_chapter_locked: Chapter {chapter}, {name}. Locked.
- a11y_level_won:
  - one: Level {level}, {count} star. Best {best} moves.
  - other: Level {level}, {count} stars. Best {best} moves.
- a11y_level_current: Level {level}, next to play
- a11y_level_locked: Level {level}, locked
- a11y_level_chest: A chest at this level
- a11y_figurine_home: {name}, home in your Museum
- a11y_figurine_locked: {name}, not home yet. Chapter {chapter}.
- a11y_badge_earned: {badge}, earned
- a11y_badge_locked: {badge}, not earned yet. {how}

More screens:
- a11y_level_finale: The last level of the chapter
- a11y_chest_contents: Chest. Inside: {contents}.
- a11y_share_daily: Share today’s result
- a11y_home_chapter: Chapter {chapter}, {name}. {count} of {total} stars. Opens Chapters.
- a11y_home_bonus: Bonus levels. {count} of {total} stars. Opens Chapters.
- a11y_home_versus: vs Computer. Race a computer on the same puzzle.
- a11y_home_versus_locked: vs Computer, locked. After Level {level}.
- a11y_figurine_next:
  - one: {name}, next to come home. {count} level to go.
  - other: {name}, next to come home. {count} levels to go.
- a11y_museum_count: {count} of {total} families home
- a11y_record_cell: {label}: {value}
- a11y_race_row:
  - one: {rival}, computer. {count} win.
  - other: {rival}, computer. {count} wins.
- a11y_race_row_locked: {rival}, computer. Locked.
- a11y_rival_beaten: Beaten
- a11y_race_start_button: Start race against {rival}
- a11y_reduce_motion_group: Reduce motion
- a11y_reminder_time_chip: Reminder time, every day at {time}. Change time.
- a11y_skin_owned: Owned

`{contents}` joins the chest’s chip labels with commas (“100 coins, 1 hint”). `a11y_skin_owned` is read after the skin’s name; the card itself shows Equip. `a11y_booster_suggested` is for 12.7’s glowing Restart: nothing reads “Suggested” on screen, the ring alone marks it.

Badge how-to, read after `a11y_badge_locked` as `{how}`. They are for screen readers only; the visible line stays “Not earned yet”.
- first_family_how: Nest a whole family.
- glass_breaker_how: Open a glass case.
- ice_melter_how: Free a doll from the ice.
- tall_order_how: Win a level with size-5 dolls.
- grand_nest_how: Win a level with size-6 dolls.
- level_100_how: Win level {level}.
- level_200_how: Win level {level}.
- dailies_7_how: Solve {count} daily puzzles.
- dailies_30_how: Solve {count} daily puzzles.
- first_race_how: Beat the computer in a race.
- all_rivals_how: Beat every computer rival.
- museum_full_how: Bring every family home to your Museum.

## Short forms
Fallbacks for tight surfaces (tokens.json → `textFit`). The game uses a short form only when the full string doesn’t fit at the surface’s minimum scale. The full strings from earlier rounds are listed so each short form has its pair. Where English needs no shortening the two are the same; translators may shorten them.
- win_title: Level Complete!
- win_title_short: Complete!
- race_win_title_short: You won!
- race_lose_title_short: So close!
- chapter_ribbon: CHAPTER {chapter} · {name}
- chapter_ribbon_short: {name}
- tier_hard: HARD
- tier_super: SUPER HARD
- tier_super_short: SUPER
- tier_bonus: BONUS
- booster_undo: Undo
- booster_undo_short: Undo
- booster_hint: Hint
- booster_hint_short: Hint
- booster_slot: +Slot
- booster_slot_short: +1
- booster_restart: Restart
- booster_restart_short: Restart
- tab_shop: Shop
- tab_shop_short: Shop
- tab_home: Home
- tab_home_short: Home
- tab_museum: Museum
- tab_museum_short: Museum

HARD and BONUS have no short form: they drop to their glyph. The booster bar and 12.9 read “+Slot”; the sheets keep “+1 Slot” as their title.

Daily gift (m7-5), for a German text about 30 % longer:
- gift_sheet_title: Daily gift
- gift_sheet_title_short: Gifts
- gift_chest_title: Day 7 gift
- gift_chest_title_short: Day 7
- gift_slots_short:
  - one: {n} slot
  - other: {n} slots
- gift_chest_slot_chip_short:
  - one: +{count}
  - other: +{count}

The chest ribbon takes `gift_chest_title_short` when the full title doesn’t fit at 0.85 on a 360 dp phone (“Tag-7-Geschenk” fits; longer translations don’t). Day 7’s phrase uses `gift_slots_short` when “Tomorrow: …” would wrap past two lines. The “+1 slot” chip falls back to “+1” beside its disc, as `booster_slot_short` does. Tile amounts are numbers and never shorten.
