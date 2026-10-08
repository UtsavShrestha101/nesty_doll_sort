# Retention research, round 3 (2026-10-08)

The owner asked for features that bring players back. This round looks for ideas that are **not already** in
[engagement-research.md](engagement-research.md) (ER1–ER12), [local-habits-brainstorm.md](local-habits-brainstorm.md),
[themes-characters-story.md](themes-characters-story.md) (TC1–TC14) or the M7 set (E1–E14). Nothing here is
picked or a rule. A picked item needs owner-approved spec-prop text before code where it touches a rule, Claude Design's
frames and copy, and the D169 test trio. Logged as D300; the owner's questions are Q192–Q193; the items are in BACKLOG "Retention research, round 3". Every idea was checked against the respect rules (E1, D92), the kid path
(D260) and "local first" (D269).

## How this was made

- Web searches on hybrid-casual and sort-puzzle metas, Royal Match's live ops, daily quests, difficulty research,
  NYT Games, Finch, UGC level editors, the iOS 26 Games app, Google Play's 2025 surfaces, retention benchmarks and EU
  rules. Sources are at the end. Several search hits were thin SEO pages; their numbers are not used.
- Each hit was checked against the existing plans with a grep, so already-planned or already-rejected ideas are
  listed under "Left out" instead of proposed again.

## 1. What the research says

- **Benchmarks.** GameAnalytics' 2025 data (16,262 titles): the top 10 % reach about 40 % D1 and 11–12 % D7. The
  median D7 is under 4 %, and all three figures fell again in 2025. Deconstructor of Fun reports Finch at 54 % D1 and
  37 % D7, ahead of Royal Match (40 % and 25 %). Royal Match leads match-3 at D30 (16.5 %, PocketGamer.biz).
- **The top earners retain through pressure.** Royal Match layers short-term urgency (Lava Quest: seven first-try wins
  or lose your progress), weekly contests and a two-month album. Sensor Tower finds its weekend revenue spikes come
  from event conversion, not more players. These are the patterns Nesty's never list rules out (engagement-research §5).
- **Easier puzzles keep at-risk players.** In a field experiment with over 300,000 players of a mobile puzzle game
  over 12 weeks, players at risk of churning were given easier puzzles. Engagement, retention and spending all rose,
  in the short and the long run (Ascarza, Netzer and Runge, Columbia). SayGames adds that churn often clusters where a
  new mechanic arrives with no transition, not where numbers are hard.
- **Post-game analysis keeps solvers thinking.** WordleBot compares your game with the best line and the average
  solver. NYT treats seven-day and 30-day daily play as its key metric.
- **A character living while you're away.** Finch's pet never dies and never shames. It has adventures by day and
  sleeps at night, and the widget shows it. Animal Crossing and Neko Atsume tie the world to the real clock: things
  happen while you're gone, with nothing lost.
- **Creating outlasts consuming.** Level-maker games report that players who build a level retain far better than
  those who only play. This is self-selection as much as cause, and the sources are weak, so treat it as direction,
  not size.
- **Satisfying replays travel.** "Oddly satisfying" and ASMR clips are a major short-video genre, and sort games ride it.
- **The stores now re-engage for you.** App Store In-App Events show an event card to people who downloaded the game,
  including those who deleted it. Google Play's 2025 "You" tab and the Engage SDK show recently played games' content
  and rewards on the store and the home screen. The iOS 26 Games app adds friends' Challenges (already ER11b).
- **The rules are tightening.** The EU consumer network published principles on in-game currencies (clear prices,
  no hidden costs, care for children), and the Digital Fairness Act, with its draft expected at the end of 2026,
  targets addictive design. Both back keeping the never list.

## 2. Proposals (RR1–RR7)

| Id | Idea | Size | Rule text? | Fits after |
|---|---|---|---|---|
| RR1 | Solve coach | M | yes (§7.1/§10 line) | wave 1, with ER1 |
| RR2 | Helping hand | S–M | yes (economy) | wave 1 |
| RR3 | A living Home | M + art | no | the local habits (pairs with the widget) |
| RR4 | Nest Maker | L | yes | after ER4 |
| RR5 | Satisfying replay clip | L | §10 line | wave 2 |
| RR6 | Store re-engagement surfaces | S–M | no | M8 |
| RR7 | Next-up peek on the win card | S | no | any time |

### RR1. Solve coach (WordleBot for nesting)

- After a win, an optional "See a shorter way" button replays the solver's line from the level's start on the board,
  next to "Your moves: N".
- On the daily, it appears only once the daily is solved. It never appears after a loss, and it never opens by itself.
- Copy frames it as a trick to learn, never as a grade. The stars already carry the comparison.
- **Today:** the game has no solution replay (checked 2026-10-08); only the admin plans one.
- **Reuses:** the solver isolate, `BoardTimeline` playing `MoveEvent`s, E7's replay and the par from D125. The admin
  already "shows the optimal solution, plays it back" (spec §6.1), so the core path exists.
- **Why:** mastery motivation and WordleBot. It turns a 1★ win into a lesson for the next level.
- **Respect check:** no score, no pressure, opt-in. Q88 kept the daily card to "Moves N", so the coach lives behind a
  tap and never on the card.

### RR2. Helping hand

- On the third restart or out-of-moves of the same level, one free hint is offered: no ad, no coins, no purchase.
  At most once per level.
- A tools-side companion: run the casual bots (§6.4) over each chapter's intro levels and flag where a new mechanic
  makes them restart much more. These are SayGames' "mechanic switch" walls, found offline before M4's analytics.
- **Why:** the Columbia field experiment above. Nesty's levels are fixed (§5.3 rule 8), so the gentle form of DDA is
  help, not a changed board.
- **Reuses:** `GameplayBloc` already counts tries per level in `_attemptNumber`: 1 on load, plus one on each restart.
  It feeds only analytics today. The hint is the existing hint path.
- **Respect check:** the never list bans *offers* shown because a player failed. A free gift is not an offer, but the
  owner should confirm it reads that way (Q192).

### RR3. A living Home

- Home follows the phone's clock: morning light, day, evening lamps, night.
- At night, the dolls on Home are asleep, and a tap wakes them with a yawn. Nothing is gained or lost, and nothing
  waits to be collected.
- The widget (local habit 4) shows the same state, Finch-style, so the home screen has a reason to be glanced at
  without a notification.
- **Reuses:** `AppClock` and the theme backgrounds. A lighting overlay plus TC7's idle layer keeps the art cost to one
  overlay set and a few Lottie segments, not 10 themes × 4 backgrounds. TC1's mascot already sleeps after long play.
- **Respect check:** no rule, no reward, off under reduce motion. Bedtime cues also support ER5's healthy play.

### RR4. Nest Maker (player-made puzzles)

- Build a board from the mechanics you have unlocked.
- The validator (rules 1–8) and the solver must prove it solvable before it can be played or shared.
- Share it as an ER4 challenge code; a friend plays it offline.
- **Reuses:** the core codec, validator and solver, `BoardLayout`, and M5's level-editor work (shared editor widgets
  would serve both).
- **Kid path:** codes carry no free text. A puzzle's name is picked from a word list, and sharing sits behind the
  parental gate.
- **Respect check:** pays nothing and has no likes, plays or rankings.
- **Why:** the self-expression gap (engagement-research §1, gap 4), and a content source that never runs out. It needs
  ER4 first.

### RR5. Satisfying replay clip

- A 6–10 s sped-up replay of a solve with its sounds, saved or shared as a video (GIF as a fallback). Campaign levels
  only, so it never spoils the daily.
- **Reuses:** the replay through `BoardTimeline`.
- **Needs:** an encoder, either platform code (AVAssetWriter and MediaCodec behind a channel) or a package with its
  rule-9 reason. Check the candidate's maintenance first.
- **Kid path:** behind the parental gate, like E3's share.
- **Why:** the satisfying-clip genre, and it doubles as free user acquisition. It extends the local habits' optional
  picture share.

### RR6. Store re-engagement surfaces

- **App Store In-App Events** for each new chapter drop (M4) or returning season (ER8). Each is App Store Connect
  metadata plus a deep link, with no countdown copy.
- **Google Play promotional content**, and the Engage SDK or the "You" tab's continuation card ("Continue level 57").
  Eligibility for games and the kid path's Families policy need checking first. Google puts integration at about a
  week.
- **Why:** they reach lapsed players, even those who deleted the app, with no push notification.
- These need the owner's store accounts, so they sit with M8.

### RR7. Next-up peek on the win card

- When the next level introduces a mechanic or closes a chapter, the win card adds one line and a silhouette:
  "Next: something icy…".
- **Why:** an open loop at the session's end is the cheapest pull to return (the Zeigarnik effect). The evidence is
  general, not genre-specific.
- **Today:** the win card shows only the levels left to the next chest (`win_overlay.dart`). The mechanic intro
  (`intro_mechanic_card.dart`) appears on the new level itself, never before it.
- **Respect check:** nothing expires and nothing is withheld.

## 3. Left out

| Seen in research | Where it stands |
|---|---|
| Win streaks and Lava Quest | Rejected: engagement-research §5 (shames a loss) |
| Daily quests and missions (Two Dots +11 % revenue; Redecor +11 % D14 and D30) | Left out by local-habits as a second daily obligation. A non-expiring version is ER2's milestones |
| Sticker albums, season passes, leagues, team events with bots | Rejected: engagement-research §5 |
| Game Center and Play Games achievements, iOS 26 Challenges | Already ER11b (M4/M8) |
| Renovation and decorate metas | Already TC14 Nest House |
| Story and journey maps | Already TC4a and TC4b |
| Friend quests and online co-op | Need a server; Later, after M4 |
| A toddler sorting mode (ages 2–5) | Many preschool sort apps exist, but Nesty's kid path is about safety, not a new age band. Ask the owner before designing for under-5s |

## 4. Open questions

1. **Q192.** Is RR2's free hint after repeated restarts within the never list ("no offers shown because a player failed")?
   The default: yes, because nothing is sold and no ad is shown.
2. **Q193.** Which RR items to build, and where do they slot in D237's order? The default: RR3 and RR7 with the local habits, RR1 and RR2 in
   engagement wave 1, RR4 and RR5 in wave 2, and RR6 with M8.

## Sources

- [GameAnalytics benchmarks 2025 (summary)](https://gamedevreports.substack.com/p/gameanalytics-mobile-gaming-benchmarks)
- [PocketGamer.biz: Royal Match leads match-3 D30 retention](https://www.pocketgamer.biz/dream-games-royal-match-leads-match-3-d30-retention-at-165)
- [Sensor Tower: Royal Match's live-ops calendar, 2026](https://sensortower.com/blog/what-royal-matchs-calendar-teaches-about-live-ops-in-2026)
- [Deconstructor of Fun: win streaks](https://www.deconstructoroffun.com/blog/2024/8/5/win-streak-the-gift-that-keeps-on-giving)
- [Deconstructor of Fun: Finch's widgets](https://www.deconstructoroffun.com/blog/x0hd2ssr80y5n7gv0w967pg7hwd7tl)
- [Columbia Business School: easier games, more revenue](https://business.columbia.edu/research-brief/digital-future/easier-games-more-revenue) and [the paper](https://business.columbia.edu/sites/default/files-efs/citation_file_upload/ascarza_netzer_runge_2023-12-04.pdf)
- [SayGames: difficulty in hybrid puzzles](https://blog.say.games/posts/how-to-work-with-difficulty-in-hybrid-puzzles-so-players-dont-leave--but-stay-and-pay)
- [Cost Center: metagame mechanics for sort puzzles](https://costcenter.net/post/metagame-mechanics-for-sort-puzzles)
- [Liquid & Grit: casual report (missions)](https://www.liquidandgrit.com/october-2023-casual-report/)
- [Nieman Lab: NYT and Connections](https://niemanlab.org/2023/09/the-new-york-times-finds-a-match-with-the-word-game-connections)
- [Apple: the Games app](https://www.apple.com/newsroom/2025/06/introducing-the-apple-games-app-a-personalized-home-for-games/) and [WWDC25 Game Center](https://developer.apple.com/videos/play/wwdc2025/214/)
- [AppTweak: In-App Events](https://www.apptweak.com/en/aso-blog/what-are-in-app-events-how-do-they-impact-aso)
- [Google Play 2025 notes](https://android-developers.googleblog.com/2025/12/notes-from-google-play-2025.html) and [Engage SDK](https://developer.android.com/guide/playcore/engage/otherverticals)
- [Shacknews: time in Animal Crossing](https://shacknews.com/article/117080/how-does-time-work-in-animal-crossing-new-horizons) and [Neko Atsume MDA](https://mechanicsofmagic.com/2024/04/07/mda-neko-atsume/)
- [IZEA: the oddly satisfying trend](https://izea.com/resources/oddly-satisfying-trend-tiktok/)
- [Gleiss Lutz: EU guidelines on in-game currencies](https://www.gleisslutz.com/en/know-how/new-guidelines-game-currencies-digital-consumer-protection-and-expanding-taboo-dark-patterns) and [European Commission: online games](https://commission.europa.eu/topics/consumers/consumer-rights-and-complaints/enforcement-consumer-protection/coordinated-actions/social-media-online-games-and-search-engines_en)
