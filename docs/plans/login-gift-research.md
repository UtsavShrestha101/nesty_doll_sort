# Login rewards: what other games do (research, 2026-10-05)

Status: research for the owner's request of 2026-10-05 ("a daily / weekly
login reward, the same as other games"). The plan is
[plan-login-gift.md](plan-login-gift.md). The owner approved the plan
on 2026-10-05 (D268, Q182). One web-research pass. Game facts come mostly
from help centres, wikis and guides, and the weak ones are marked.

## The genre pattern

| Game | Cycle | Missed day | What counts | Claim | Source |
|---|---|---|---|---|---|
| Homescapes | 7-day weekly gift + a 30-day monthly bonus; coins, power-ups, stars; from level 11 | The weekly cycle restarts at Day 1; the monthly count keeps going | Opening the game and tapping the calendar | A calendar in the home scene, once a day; needs internet and the right device time | [Playrix help](https://playrix.helpshift.com/hc/en/14-homescapes/faq/16309-daily-bonus-1780683562/?l=en) |
| Candy Crush Saga | One booster-wheel spin a day | (unverified) | Opening | A wheel (random) | [wiki](https://candycrush.fandom.com/wiki/Daily_Booster_Wheel), weak |
| Toon Blast | Daily bonus by card reveal | (unverified) | Opening | Hidden choice (random) | [wiki](https://toonblast.fandom.com/wiki/Coins), weak |
| Royal Match | No verified login calendar. The Royal Pass is 30 monthly steps whose bonuses lapse | n/a | Playing | Pass track | [Dream Games help](https://dreamgames.helpshift.com/hc/en/3-royal-match/faq/112-royal-pass/) |
| Pokémon GO | First stop spin a day; a bigger bonus on day 7 | Resets (not re-checked) | An action, not opening | In play | [Niantic help](https://niantic.helpshift.com/hc/en/6-pokemon-go/faq/105-daily-bonuses/) |
| Monopoly GO | Daily treats grow with consecutive days | (unverified) | Opening | Popup | guide, weak |
| Genshin / HoYoLAB | A monthly check-in; the currency lands on check-ins 4, 11, 18 | **Nothing lost:** a reward is picked by how many check-ins you have, not by the date | Checking in | A calendar page | [Game8](https://game8.co/games/Genshin-Impact/archives/321404), guide |
| Puzzle & Dragons | A streak, plus lifetime logins (100, 1,000 days) | The lifetime count never drops | Opening | Popup | [Game Developer](https://www.gamedeveloper.com/business/the-science-craft-of-designing-daily-rewards----and-why-ftp-games-need-them) |
| Duolingo | A streak (one lesson a day) and a freeze | The freeze covers one day | A finished lesson | In the lesson flow | [Duolingo help](https://www.duolingo.com/help/what-is-a-streak) |

Woodoku, Block Blast, Ball and Water Sort, Goods Sort, Screw Jam, Triple
Match 3D, Two Dots, Pocket Camp and the Apple Arcade puzzlers gave nothing
verifiable; don't cite them.

**So the norm is:**
- a 7-day calendar whose rewards grow toward a bigger Day 7, opened on launch;
- sometimes a 30-day layer on top;
- a missed day restarts the week;
- the reward is often doubled for watching an ad (common in the genre, but not
  verified for any game above).

**The exception** is the cumulative calendar (HoYoLAB, P&D's lifetime count),
which nothing takes away.

## Where the norm meets Nesty's rules

The respect rules (D92, spec-prop §1.1) decide which version Nesty can copy:
- **Rule 6, a missed day never takes away anything earned.** A restart to
  Day 1 takes away a week's progress. Only the cumulative version passes.
- **Rule 2, every reward is shown before it is claimed.** Wheels and card
  reveals fail it. A calendar showing all seven days passes.
- **Rule 3, no countdown or scarcity.** So no "ends in 3 h" and no expiring
  gift.
- **§1, nothing nudges.** So no auto-popup that nags and no loss copy ("don't
  lose your gifts").

## Regulation

- **PEGI, the interactive-risk criteria (announced 12 March 2026, for new
  submissions from June 2026):** features that reward coming back (daily
  quests, login streaks) get a "play by appointment" note, at PEGI 7 or above.
  If players are **penalised** for not coming back (lost content, reduced
  progress), the minimum is **PEGI 12**
  ([Reed Smith](https://www.reedsmith.com/articles/pegi-launches-interactive-risk-categories-overhauls-age-ratings-for-loot-boxes-in-game-spending-and-communication-features/),
  [Lewis Silkin](https://www.lewissilkin.com/insights/2026/03/18/pegi-announces-major-update-to-age-rating-criteria-what-games-businesses-need-to-102mn9y)).
  - The daily streak and its chest probably earn Nesty the note already.
  - A resetting calendar is the standard PEGI 12 case. A cumulative one keeps
    Nesty at 7.
  - One summary adds that countdowns also trigger 12. That is single-sourced,
    and the final pegi.info text was not read (BACKLOG M8 holds the PEGI
    item).
- **ICO Children's Code, Standard 5:**
  - The engagement guidance says to "present options to continue playing or
    otherwise engaging with your service neutrally without suggesting that
    children will lose out if they don't".
  - Reward loops are among the harms it lists.
  - A calendar with loss copy or expiry fails it
    ([ICO](https://ico.org.uk/for-organisations/uk-gdpr-guidance-and-resources/childrens-information/childrens-code-guidance-and-resources/age-appropriate-design-a-code-of-practice-for-online-services/5-detrimental-use-of-data/)).
  - The kid path (D260) is the audience this matters for.
- **EU CPC key principles on in-game currencies (March 2025):** non-binding,
  and about bought currency. Earned gift coins aren't priced. The
  no-pressure and children's-vulnerability principles still apply to the copy
  ([EC PDF](https://commission.europa.eu/document/download/8af13e88-6540-436c-b137-9853e7fe866a_en?filename=Key+principles+on+in-game+virtual+currencies.pdf)).
- **Not checked:** Google Play Families and Apple's Kids Category rules for
  login rewards.

## Day boundary and clock changes (offline)

- Servers use server time, which is the only full defence. Nesty is offline
  until M4.
- **Local midnight** is the boundary, the same as the daily puzzle. A UTC
  reset would roll the day over in the afternoon in some time zones.
- **Forum practice** ([Unity](https://discussions.unity.com/t/how-to-discourage-offline-cheating/761906)):
  - one claim per calendar day, however long the gap;
  - a stored high-water mark of the latest date seen, so winding the clock
    forward only borrows gifts from the future;
  - a clock moved back claims nothing until the real date passes the mark;
  - nothing is ever taken away.

## Evidence that it works

Weak. GameRefinery and Game Developer describe daily gifts as universal and
"sticky" but give no numbers. Vendor blogs (Mistplay) claim D7 gains with no
data. No public A/B test was found. Don't plan on a retention number. E13's
time-to-first-win and the M4 analytics are where a real one would come from.
