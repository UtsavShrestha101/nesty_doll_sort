# Nesty copy (m7)

All the new copy for the m7 round, one line per string: `- <id>: <text>`. Ids are the request's ids where it gives them (badge ids, rival numbers, chapter numbers, museum file ids) and short slugs otherwise. Placeholders in braces are filled by the game: `{count}`, `{moves}`, `{date}`, `{day}`, `{time}`, `{rival}`, `{level}`, `{chapter}`, `{first}`, `{last}`, `{total}`, `{price}`, `{glyphs}`. A plural is two lines, `one:` and `other:`. Curly quotes and the `·` separator are part of the strings.

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
- rival_1_skill: Relaxed · Slow
- rival_2_name: Button
- rival_2_personality: Checks each move twice before it makes it.
- rival_2_skill: Careful · Slow
- rival_3_name: Comet
- rival_3_personality: Quick, tidy and hard to catch.
- rival_3_skill: Careful · Quick
- rival_reward:
  - one: Win {count} coin
  - other: Win {count} coins
- rival_locked: Beat {rival} to unlock
- rival_locked_mode: After Level 20
- mode_title: vs Computer
- mode_sub: Race a computer on the same puzzle
- race_start: Start
- race_start_hint: Same puzzle, two boards. Complete every family first.
- strip_thinking: Thinking…
- strip_starting_over: Starting over
- strip_families: {count}/{total}
- strip_finished: Finished
- strip_after_you_won: You finished first
- race_win_title: You won the race!
- race_win_body: You completed every family before {rival}.
- race_win_coins:
  - one: +{count} coin
  - other: +{count} coins
- race_lose_title: So close! Rematch?
- race_lose_body: {rival} finished first this time. A rematch costs nothing.
- race_rematch: Rematch
- race_new: New race
- rival_unlocked_title: New rival unlocked!
- rival_unlocked_body: {rival} is ready to race.
- race_quit_title: Leave this race?
- race_quit_body: The race ends here. No coins, and nothing lost.
- race_quit_yes: Leave race
- race_quit_no: Keep racing
- a11y_race_start: Race started against {rival}, a computer player.
- a11y_rival_family: The computer completed a family: {count} of {total}
- a11y_rival_starting_over: The computer is starting over.
- a11y_rival_finished: The computer completed every family.
- a11y_race_won: You won the race.
- a11y_race_lost: The computer finished first.


Screen labels (m7-2):
- home_tile_versus: vs Computer
- rival_new: New
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

Example: `Nesty Daily · Sep 30` / `❤️ 💧 🍃 ⭐ 🌙` / `Solved in 18 moves · Day 12 🔥`. Use `share_line_3_no_streak` when the streak is 0 or paused.

## G.7
Daily reminder (I.2).
- reminder_offer_title: Want a note when tomorrow’s puzzle is ready?
- reminder_offer_body: One quiet note a day, at a time you pick. You can turn it off in Settings.
- reminder_time_chip: Every day at {time}
- reminder_change_time: Change time
- reminder_yes: Yes, remind me
- reminder_no: No thanks
- reminder_set: Reminder set for {time}.
- reminder_denied_title: Notifications are off for Nesty
- reminder_denied_body: Turn them on in your phone’s settings, and your note will arrive at {time}.
- settings_reminder: Daily reminder
- settings_reminder_on: Every day at {time}
- settings_reminder_off: Off
- settings_reminder_blocked: Off in your phone’s settings
- settings_open_phone_settings: Open phone settings
- notification_title: Nesty
- notification_1: Today’s puzzle is on the shelf.
- notification_2: A fresh daily puzzle is ready when you are.
- notification_3: New dolls are waiting to be nested. Today’s puzzle is ready.

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
- a11y_undo_unlimited: Undo, unlimited

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

- chest_streak_body: Seven days in a row. Here’s what’s inside.
- chest_double: Double it
## G.10
Lines the stand-ins ship as placeholders, confirmed or replaced.
- museum_intro: Every chapter has a doll family. Win all 20 of its levels to bring that family home.
- museum_next_to_go:
  - one: {count} level to go
  - other: {count} levels to go
- museum_next_line:
  - one: Chapter {chapter} · {count} level to go
  - other: Chapter {chapter} · {count} levels to go
- museum_locked_shelf: Chapter {chapter} · Levels {first}–{last}
- museum_locked_shelf_short: Ch {chapter} · {first}–{last}
- museum_all_home: Every family is home.
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
- records_families: Families home
- records_families_value: {count} of 10
- records_dolls_nested: Dolls nested
- records_dailies: Daily puzzles solved
- records_longest_streak: Longest streak
- records_races: Races won
- records_best_moves: Best moves by level
- records_stars_value: {count} of 600
## G.11
Star rating (K). Stars sit inside the celebration and never replace it.
- a11y_stars: {count} of 3 stars
- a11y_stars_new_best: New best, {count} of 3 stars
- replay_target: 3 stars at {moves} moves or fewer
- new_best: New best!
- stars_tip: Fewer moves earn more stars. Replay any level from Chapters.
- stars_helper_note: Wins with a hint or an extra slot earn up to 2 stars.
- chapter_stars_total: {count}/60
- chapter_all_three_stars: Every level at 3 stars
- records_stars: Stars
- records_three_star_levels: Levels with 3 stars
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
- daily_locked: After Level 2
- home_bonus_badge: BONUS
- home_bonus_kicker: BONUS ENDLESS
- home_bonus_name: Bonus levels
- bonus_win_label: Bonus Level {level}
- gen_failed_title: The shelves need a moment
- gen_failed_body: This level didn’t set up. Try again, or head back home.
- gen_failed_retry: Try again
- gen_failed_home: Back to Home
- stuck_restart: Try Restart? You can keep playing too.
- oom_undo_spent: Your 2 free undos are used
- slot_limit: Two extra slots is the most for one level.
- tut_step_chip: STEP {step} OF 3
- tut_step_3_title: Finish the family
- tut_step_3_body: Put the last doll in. A family is done when every size is nested.
- splash_storage_title: Your phone is nearly full
- splash_storage_body: Nesty needs about 60 MB to set up the shelves. Free some space, then try again.
- splash_content_title: The shelves didn’t unpack
- splash_content_body: Something went wrong while loading. Try again, or restart Nesty.
- splash_retry: Try again
