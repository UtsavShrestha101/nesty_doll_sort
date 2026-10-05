# Themes, characters and story mode (proposals, after M7; D270)

Status: **proposals, not rules.** The owner picks which to build (Q184). Anything that adds or changes a game rule needs spec-prop text that the owner approves before code (CLAUDE.md). Everything here is local and works offline (D269). Order: after the daily gift (D268) and the local habits (D237), beside the engagement research's wave 2 (D259), and before M4.

The owner's ask (2026-10-05): "other cool themes, animations like Marvel, Power Rangers, Barbie, characters that will make the user hooked; story mode; analyze in detail; research."

**Second pass (2026-10-05).** The owner sent the ask again, so this pass goes deeper and fixes the first:
- **Corrected against the code:**
  - the catalog is Dart constants, not JSON;
  - each FX slot has exactly one Lottie;
  - the colour-symbol disc covers the apron;
  - there are exactly ten chapters;
  - the figurine pairing belongs to design;
  - the copy rules;
  - the story's triggers;
  - the milestone chest's level.

  See §2, §4.5 and §9.
- **Added:**
  - a trend radar with each locale's kid favourites (§1b);
  - the story mode in detail (§4);
  - an animation catalogue (§5);
  - a seasonal calendar (§6);
  - four proposals (TC11–TC14) and two enablers (TC-FX, TC-DATA);
  - the line between a character and a skin (§2).

## 0. The line we can't cross: other companies' characters

- Marvel (Disney), Power Rangers (Hasbro) and Barbie (Mattel) are trademarked and copyrighted. Without a licence, Nesty can't use their names, characters, logos, catchphrases, or suits and designs that look like theirs.
  - Copyright protects a character that is consistently drawn and "especially distinctive", and a name can be a trademark ([DC Comics v. Towle](https://en.wikipedia.org/wiki/DC_Comics_v._Mark_Towle), [US Copyright Office](https://www.copyright.gov/circs/circ33.pdf)).
  - Rights holders do sue games over look-alikes. Marvel sued City of Heroes' makers over player-made heroes ([Slashdot, 2004](https://yro.slashdot.org/story/04/11/12/1515240/marvel-sues-city-of-heroes-makers)), and the case settled in 2005 ([Game Developer](https://www.gamedeveloper.com/game-platforms/ncsoft-marvel-settle-i-city-of-heroes-i-suit)).
  - Costume elements can be protected where a generic cape or goggles are not ([IP Trademark Attorney](https://iptrademarkattorney.com/copyright-halloween-costume-copyrightable-trademark-power-rangers-lawsuit-dilution-ip)).
  - The stores act on it:
    - Apple's guideline 5.2.1 bars unlicensed marks and copyrighted works ([Apple](https://developer.apple.com/app-store/review/guidelines/)).
    - Google Play asks for written permission, counts look-alike fan art as a violation, and suspends apps ([Google](https://support.google.com/googleplay/android-developer/answer/9888072)).
- **What is free:** the *genres*. Superhero teams, colour-coded squads, a transformation moment, fashion and dress-up dolls, magical "reveal" moments.
  - A US appeals court held that Mattel can't monopolize "fashion dolls with a bratty look or attitude, or dolls sporting trendy clothing" ([Loeb & Loeb on Mattel v. MGA](https://www.loeb.com/en/insights/publications/2010/07/mattel-inc-v-mga-entertainment-inc-et-al)).
  - Marvel and DC's US "Super Hero" marks were cancelled by default in September 2024 ([Project DisCo](https://project-disco.org/intellectual-property/a-new-age-of-super-heroes-marvel-and-dc-lose-a-trademark/)). Nesty still uses its own words.
  - Free means: Nesty's own names, faces, outfits and emblems, built on the skin format we already have.
  - Avoid words that echo a mark: "Ranger(s)", "Morphin'", "Avengers", "Marvel", "Barbie", "Dreamhouse", and pink script logos.
  - Before any hero-squad art ships, the owner gets a lawyer's clearance (owner input, M8 at the latest).
- **Generated art needs the same care.**
  - Disney and Universal sued Midjourney in June 2025 over generated look-alikes ([CNN](https://www.cnn.com/2025/06/11/tech/disney-universal-midjourney-ai-copyright-lawsuit)).
  - Nesty's art comes from Claude Design, so every request says "original only", down to silhouettes, helmet shapes and colour blocking.
  - The legal check covers the delivered art too.
- **A real licence (TC-L, Later):**
  - **Who gets one.** Licences go to studios with a track record.
    - Hasbro reportedly earned $83M in royalties from Monopoly GO in H1 2025 ([WN Hub](https://wnhub.io/news/investment/item-48355)).
    - Mattel licensed Barbie to Rollic/Zynga and its brands to Uken ([Shacknews](https://shacknews.com/article/138920/mattel-zynga-rollic-barbie-mobile-game-2024), [Variety](https://variety.com/2025/gaming/news/mattel-uken-mattel-match-toybox-unlocked-mobile-game-1236404832/)), while saying it wants "developers of all sizes" ([PocketGamer.biz](https://www.pocketgamer.biz/mattels-global-head-of-digital-gaming-mike-delaet-talks-about-the-big-push-into-games-and-why-the-focus-will-be-on-mobile/)).
    - Power Rangers: Mighty Force went to East Side Games and Mighty Kingdom ([Hasbro](https://newsroom.hasbro.com/news-releases/news-release-details/east-side-games-group-and-mighty-kingdom-unleash-power-rangers)).
    - Power Rangers is still Hasbro's. Disney+ cancelled its new series in August 2026 ([Deadline](https://deadline.com/2026/08/power-rangers-live-action-series-dead-disney-plus-1237033544/)).
  - **Terms.**
    - Royalties on licensed games are typically 15–20% of sales ([Reuters via Investing.com](https://www.investing.com/news/stock-market-news/tencents-next-level-up-fewer-big-foreign-franchise-games-more-inhouse-3347239)), on top of a minimum guarantee.
    - Lawyers advise approval windows of 15–30 business days ([Harris Beach Murtha](https://www.harrisbeachmurtha.com/insights/choose-your-fighter-negotiating-video-game-ip-licenses/)).
    - The real terms are private.
  - **What a collab does.** A fresh IP that fits the audience lifts the event:
    - Puzzle & Dragons × One Piece Film Red took 8× downloads and 11.5× revenue ([GameRefinery via GameDev Reports](https://gamedevreports.substack.com/p/gamerefinery-ip-collaborations-effect)).
    - Phase 10 × Snoopy gained 23% revenue and 59% downloads.
    - Capybara Go × TMNT lifted revenue per download 48% but brought few new players ([GameRefinery](https://www.gamerefinery.com/mobile-game-market-review-june-2025/)).
    - Naavik says Monopoly GO's crossovers "stall decline without reversing it" ([Naavik](https://naavik.co/digest/dissecting-scopelys-mobile-empire/)).
    - Monopoly GO runs KPop Demon Hunters from 23 September to 25 November 2026 ([mobilegamer.biz](https://mobilegamer.biz/monopoly-go-reveals-new-kpop-demon-hunters-and-ghostbusters-crossovers/)).
  - **For Nesty.** Not realistic before M8; revisit with a publisher after release. Meanwhile, a kid-appeal licence:
    - weighs toward the FTC's "child-directed" test ([FTC](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions));
    - brings approval cycles;
    - conflicts with the kid path's ad rules.

## 1. What the research says

- **One lovable face beats a big cast.**
  - Royal Match frames everything around King Robert ([Mobidictum](https://mobidictum.com/game-industry/kings-co-founder-comments-on-dream-games-success/)). Its high year-two retention is press-reported, so unverified.
  - Playrix's story-plus-renovation (Austin) became the match-3 meta. A Playrix title without the narrative meta reportedly retained far fewer players on day 1 (38% against 68%; not like for like, unverified) ([Game World Observer](https://gameworldobserver.com/2019/08/19/new-playrix-game), [PocketGamer.biz](https://www.pocketgamer.biz/how-gardenscapes-changed-match-three/)).
  - Royal Match's makers tested no meta, an episode meta and a rewarded-episode meta against their area tasks. The area tasks won on revenue per download, with no figures published ([Naavik](https://naavik.co/digest/royal-match-finding-success-through-iteration/)).
  - A cast supports a good core but can't replace it:
    - Toon Blast's cast supports retention but does not replace good levels ([Mobile Free to Play](https://mobilefreetoplay.com/peak-games-toon-blast-death-of-saga/)).
    - Project Makeover shows the other side: its D7 sat about 10 points under Royal Match's, and its downloads fell 55% in a year ([Naavik](https://naavik.co/deep-dives/project-makeover-fall-from-grace/)).
- **The genre's bar.**
  - Sort puzzles earned about $280M in 2025 (+176%). US day-30 retention was 17% for Screwdom and 8% for Magic Sort ([Naavik](https://naavik.co/digest/how-niche-subgenres-are-reshaping-the-mobile-puzzle-market/)).
  - Voodoo aims for a D1 of 45% or more, a D7 of 20% for puzzle and a D30 of 10% ([Game World Observer](https://gameworldobserver.com/2023/07/25/voodoo-hybrid-games-d7-retention-games-and-names-podcast)).
  - No public figure compares a story meta with none (unverified).
- **Kid-safe character love** (Toca Boca, Sago Mini): the character is a toy, never a salesperson.
- **Story in short sessions.** One light beat at a milestone works; a long text story doesn't. Wordless stories travel across languages and reach pre-readers:
  - Unpacking won a BAFTA for narrative with no dialogue ([Wikipedia](https://en.wikipedia.org/wiki/Unpacking_(video_game))).
  - Om Nom Stories passed 15B YouTube views ([PocketGamer.biz](https://www.pocketgamer.biz/zeptolabs-om-nom-stories-lands-25-seasons-deal-with-disney/)).
- **Collections.** Monopoly GO's albums show how strong collecting is, but its cards are random ([mobilegamer.biz](https://mobilegamer.biz/monopoly-go-reveals-new-kpop-demon-hunters-and-ghostbusters-crossovers/)). Random packs for minors are now regulated:
  - Brazil bans loot boxes in games minors can reach from 17 March 2026 ([ASC Jogos](https://www.ascjogos.org.br/en/post/brazil-loot-box-ban-eca-digital-kids-games)).
  - The FTC fined HoYoverse $20M ([FTC](https://www.ftc.gov/news-events/news/press-releases/2025/01/genshin-impact-game-developer-will-be-banned-selling-lootboxes-teens-under-16-without-parental)).
  - PEGI rates paid randomness 16 (BACKLOG M8).

  Nesty's version must be deterministic: each piece is earned at a named point and shown before it's earned (rule 2).
- **Juice** ("Juice it or lose it", [GDC Vault](https://www.gdcvault.com/play/1016487/juice-it-or-lose), [Game Developer](https://www.gamedeveloper.com/design/squeezing-more-juice-out-of-your-game-design-)): reactions to every action matter more than spectacle. Nesty already plays a MoveEvent timeline and 37 Lotties.
- **Flashing.**
  - At most three flashes a second (WCAG 2.3.1, [W3C](https://w3c.github.io/wcag21/understanding/three-flashes-or-below-threshold.html)).
  - A flashing TV episode sent hundreds of viewers in Japan to hospital in 1997 ([Wikipedia](https://en.wikipedia.org/wiki/Denn%C5%8D_Senshi_Porygon)).
  - Bursts, transformations and fireworks stay soft.
- **Rive vs Lottie.**
  - Rive files are reported as much smaller and have state machines for reactive characters (vendor-leaning, [Callstack](https://callstack.com/blog/lottie-vs-rive-optimizing-mobile-app-animation)).
  - Rive would be a new package (rule 9): `flame_rive` 1.11.2 needs `rive` ^0.14.6 and its native runtime ([pub.dev](https://pub.dev/packages/flame_rive)).
  - One Lottie with named segments already makes a reactive character: `ui_rival_react` has idle, family, win and lose.
- **Kids' rules:**
  - The COPPA amendments are in force (compliance by 2026-04-22) ([Federal Register](https://www.federalregister.gov/documents/2025/04/22/2025-05904/childrens-online-privacy-protection-rule)).
  - Apple's Kids Category bars third-party analytics and ads in kids' apps.
  - Google Families allows only self-certified ad SDKs and no manipulative flows ([Google](https://support.google.com/googleplay/android-developer/answer/9893335)).
  - The UK ICO says no nudges and natural breaks ([ICO](https://ico.org.uk/about-the-ico/media-centre/news-and-blogs/2023/02/new-guidance-to-industry-issued-for-game-developers-on-protecting-children)).
  - The FTC counts animated characters and child-oriented incentives when it judges whether a service is child-directed ([FTC](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions)). More characters mean D260's mixed-audience posture (a neutral age question, then the kid path) has to hold.
  - The EU's proposed KIDS Act (17 September 2026) covers online games with no small-company exemption. It is about two years from law ([Freshfields](https://www.freshfields.com/en/our-thinking/blogs/technology-quotient/the-eu-kids-act-europe-moves-online-child-safety-beyond-social-media-bans-102o1ld)).
  - Our rule is stricter: no character ever appears in a purchase, an ad or a loss prompt.
- **Cultural care:**
  - Matryoshka is a contested national symbol today, and reports from 2025 and 2026 show backlash around its use (unverified headlines).
  - Prefer a warm, pan-folk "toy shop" framing (spec §12.1): no flags, no "Russia" labels, no Soviet imagery.
  - The facts behind the toy: the first set was made around 1890 in Moscow, designed by Sergey Malyutin and turned by Vasily Zvyozdochkin, with eight pieces, and won a bronze medal in Paris in 1900. The story of a Japanese model doll is contested, so tell it as legend if at all ([Wikipedia](https://en.wikipedia.org/wiki/Matryoshka_doll)).
  - For world-doll chapters, run a sensitivity review and credit the inspirations.

## 1b. Trend radar: what hooks players now, and Nesty's own take

Inspiration only. Each row borrows the *appeal*, never the character, name, look or premise.

### Global, 2025–26

| Trend (signal) | Why it hooks | Nesty's own take | Where |
|---|---|---|---|
| KPop Demon Hunters: Netflix's most-watched film, two 2026 Oscars ([THR](https://www.hollywoodreporter.com/movies/movie-news/kpop-demon-hunters-wins-oscar-best-animated-film-1236533319/)) | Music, a team to belong to, myth | A doll band where each completed family sings its note. No trio, no demons | TC11 |
| Power Rangers: Hasbro's; its Disney+ series was cancelled in Aug 2026 | A colour-coded team, a transformation | The Nest Squad: a hero in each family colour, "suit up" on the reveal | TC2 |
| Spider-Man: Brand New Day: a record $360M US opening ([Variety](https://variety.com/2026/film/box-office/spider-man-brand-new-day-box-office-opening-record-avengers-endgame-1236826336/)). Avengers: Doomsday on 18 Dec 2026 | A secret identity, the hero pose | The suit-up and a hero-pose celebration | TC2 |
| Barbie ($1.447B in 2023); Roblox's Dress to Impress, with its themed outfit rounds ([Wikipedia](https://en.wikipedia.org/wiki/Dress_to_Impress_(video_game))) | Fashion, self-expression | Atelier skins and a runway celebration. No scores, votes or comparison | TC3 |
| Labubu and Pop Mart blind boxes, now past their peak: the line fell 7.5% in H1 2026 ([China Biz Insider](https://chinabizinsider.com/pop-mart-revenue-rises-24-as-overseas-growth-reverses-and-inventory-piles-up/)). Sonny Angel, Smiski | The reveal, ugly-cute charm | Little Ones: tiny friends in the smallest doll, each shown by name before it's earned. Never blind | TC13 |
| Sanrio: Pompompurin, Cinnamoroll, Pochacco, Kuromi and Hello Kitty top a 70.6M-vote poll ([Sanrio](https://corporate.sanrio.co.jp/en/news/20260628_03.html)) | Round kawaii shapes; Kuromi's sweet-but-sassy | The mascot's soft, round styling; Moonlight Dolls' spooky-cute | TC1, TC12 |
| Wednesday: season 2 drew 123.9M views ([Deadline](https://deadline.com/2026/01/netflix-viewership-second-half-2025-kpop-record-wednesday-1236690643/)) | Deadpan, spooky-cute | Moonlight Dolls | TC12 |
| Pokémon at 30. TCG Pocket has made $1.49B ([mobilegamer.biz](https://mobilegamer.biz/data-digest-q1s-top-performers-milestones-for-pokemon-tcg-pocket-heartopia-efootball-and-plenty-more/)) | Collecting, growth stages | Little Ones' drawer. A "Nest Hatchlings" skin idea: an egg family that grows by size | TC13, skin idea |
| Stitch: over $4B of merchandise in FY2025 ([WDWNT](https://wdwnt.com/2025/12/stitch-makes-disney-over-4-billion-in-merchandise-sales-replaces-mickey-on-national-tour/)) | Chaotic-cute mischief, found family | Little Ones' cheeky personalities | TC13 |
| Zootopia 2: $1.7B, the top Hollywood animation ever ([Variety](https://variety.com/2026/film/box-office/zootopia-2-highest-grossing-animated-film-box-office-history-1236634289/)). Jellycat: £450M sales in 2025 ([inkl](https://www.inkl.com/news/soaring-demand-for-viral-toys-drives-jellycat-to-ps240m-profit-zwz6zmzp)) | Animal casts, huggable comfort | Animal skin lines beside the fox and the bear | Skin ideas |
| Toy Story 5: a $160M opening ([AV Club](https://www.avclub.com/weekend-box-office-toy-story-5-june-21)) | Toys with secret lives | Dolls that blink, sway and yawn when you're not looking | TC7 |
| The Super Mario Galaxy Movie: $1.013B ([Wikipedia](https://en.wikipedia.org/wiki/The_Super_Mario_Galaxy_Movie)) | Space wonder | A rocket celebration for the space skin; the Astronaut family's story | TC-FX, §4 |
| Grow a Garden: 22.3M concurrent players ([Tribune](https://tribune.com.pk/story/2563322/roblox-breaks-concurrent-user-record-after-grow-a-garden-and-steal-a-brainrot-player-surge)). The cozy trend: "cozy" Steam tags up 675% from 2022 to 2025 ([Respawn](https://respawn.outlookindia.com/gaming/gaming-news/steam-vibe-shift-why-cozy-is-the-most-dominant-keyword-of-2026)) | Calm growing and decorating | The Nest House's rooms | TC14 |
| Tasty Travels: $127M in H1 2026 ([PocketGamer.biz](https://www.pocketgamer.biz/puzzle-accounts-for-44-of-casual-mobile-earnings-in-h1-2026/)) | A journey you can see | The town map | TC4b |
| Ne Zha 2: $2.25B ([Variety](https://au.variety.com/2026/film/box-office/zootopia-2-highest-grossing-animated-film-box-office-history-32053)) | Myth and folklore | Folk-tale and world-doll chapters | TC5, TC6 |
| Italian brainrot ([Wikipedia](https://en.wikipedia.org/wiki/Italian_brainrot)), Sprunki, Skibidi | Absurd humour, but short-lived and AI-made, and Sprunki's horror variants worry parents ([Piipple](https://piipple.com/en/sprunki-a-horror-music-game-for-parents-to-know/), secondary) | Skip | §7 |

### By locale: what kids and families love in Nesty's markets

These signals come mostly from Wikipedia pages, because the research pass hit its web-search cap. They can lag, and anything without a source is marked unverified.

| Locale | Favourite (signal) | Why it hooks | Nesty's own take |
|---|---|---|---|
| ja | Chiikawa: a top-10 best-selling IP in China in 2024, and its game took 3M downloads in its first week (March 2025) ([Nippon.com](https://www.nippon.com/en/in-depth/d01122/)) | Tiny, timid, kind creatures finding small joys | Little Ones' gentle personalities (TC13); the mascot's warmth (TC1) |
| ja | Sumikko Gurashi: shy creatures who feel most relaxed in corners ([Wikipedia](https://en.wikipedia.org/wiki/Sumikko_Gurashi)). Fifth in a December 2025 survey of women aged 15–35 in Japan, China and Korea, with Chiikawa first ([CBR](https://www.cbr.com/japan-cutest-character-survey-2025/)) | Shy and cozy, and loved by adults too | Families tucked into cozy hiding spots in the story (TC4) |
| ja | Anpanman: Japan's top-grossing character as of 2019, for ages 0–12 ([Wikipedia](https://en.wikipedia.org/wiki/Anpanman)). A 2024–26 kids' figure is unverified | Kindness as heroism | A kind helper, not a fighter (TC1); heroes who help (TC2) |
| fr | Miraculous: Parisian teens who become heroes through magic jewels. Season 6 began in March 2025; ratings unverified ([Wikipedia](https://en.wikipedia.org/wiki/Miraculous:_Tales_of_Ladybug_%26_Cat_Noir)) | A transformation moment, kid-safe heroes | TC2's suit-up |
| hi | Chhota Bheem: a village hero powered by laddoos, with a live-action film in May 2024; viewing figures unverified ([Wikipedia](https://en.wikipedia.org/wiki/Chhota_Bheem_and_the_Curse_of_Damyaan_(2024_film))) | Strength used to help friends; a sweet as a power-up | Sweet-treat humour in the Baker family's beats (TC4) |
| hi | Motu Patlu: a strong friend and a clever one, with ten films from 2023 to 2026; ratings unverified ([Wikipedia](https://en.wikipedia.org/wiki/Motu_Patlu)) | Buddy comedy | Pairs within a family in the story's panels (TC4) |
| id | Upin & Ipin: five-year-old twins in a village. One July 2024 episode drew 3.1M YouTube views; "top-rated in 2024" is unverified ([Wikipedia](https://en.wikipedia.org/wiki/Upin_%26_Ipin)) | Family, everyday village life, shared values | Everyday family moments in the story; the Children's Day toy parade (§6) |
| pt-BR | Turma da Mônica: a São Paulo neighbourhood gang since 1959, with 20M YouTube subscribers in June 2024 ([EP Grupo](https://epgrupo.com.br/turma-da-monica-alcanca-20-milhoes-de-inscritos-no-youtube-2/)) | A gang of clear, lovable personalities | The town as a neighbourhood of families (TC4b) |
| tr | Rafadan Tayfa: six Istanbul kids on neighbourhood adventures. Its 2023 film drew 2.85M admissions; 2024–26 is unverified ([Box Office Türkiye](https://boxofficeturkiye.com/film/rafadan-tayfa-galaktik-tayfa--2015119)) | Neighbourhood friends; nostalgia for parents | The town of families; Little Ones as a gang (TC13) |
| de | Die Sendung mit der Maus: explainer shorts with calm mascots, watched across generations ([Wikipedia](https://en.wikipedia.org/wiki/Die_Sendung_mit_der_Maus)). German children aged 6–13 favour Netflix (21%), KiKA (14%) and YouTube (11%) ([KIM-Studie 2024](https://mpfs.de/studie/kim-studie-2024/)) | Curiosity, a calm and trusted mascot | The Nest Keeper's calm, wordless warmth (TC1) |
| All | Paw Patrol: pups with jobs, uniforms and vehicles; *The Dino Movie* took $151.5M in August 2026 ([Wikipedia](https://en.wikipedia.org/wiki/Paw_Patrol)) | A team where everyone has a job and a colour | TC2's crew |
| All | PJ Masks: children who become colour-coded heroes at night (blue, red, green); the Disney Junior run ended in April 2024 ([Wikipedia](https://en.wikipedia.org/wiki/PJ_Masks)) | Colour as identity | TC2: the colour *is* the hero |
| All | Care Bears: each bear's belly badge shows who it is; a Warner Bros. film was announced in June 2025 ([Wikipedia](https://en.wikipedia.org/wiki/Care_Bears)) | A symbol as identity | TC2's badge ring around the colour symbol |
| All | Bluey: imaginative family play, with 55.6B streaming minutes and a Peabody in 2024 ([Wikipedia](https://en.wikipedia.org/wiki/Bluey_(TV_series))) | Family play that parents enjoy too | The families' everyday warmth in the story (TC4) |

## 2. How every proposal must fit

| Constraint | What it means here |
|---|---|
| Rules come only from the spec | Characters, themes and story are **cosmetic and narrative**. No proposal changes moves, nesting, scoring, boosters or rewards. If one ever needs to, it waits for owner-approved spec-prop text |
| Respect rules (D92, spec-prop §1.1) | No random characters (no gacha or pulls), no limited-time characters, no character pressure, no shame on a loss, and the rival is always "Computer". Everything earnable is earned by play, and is shown before it's earned |
| Character or skin | A **character** has a persona: a name, reactions, a story role. Characters are earned by play and never sold. A **skin** is a look with no persona, and may be sold for coins (§7.3). Coins are sold for money (§9), so no character appears in the Shop, an ad, a loss offer or beside the rewarded "×3 coins" button |
| Stars are cosmetic (spec-prop §7.10) | Stars "never pay, unlock or gate anything". Nothing here costs or needs stars: it's earned by level or chapter progress |
| Kid path (D260) | Wordless story beats, no chat, no characters in purchases or ads. A grown-up gates any share. More characters raise child appeal in the FTC's eyes, so the mixed-audience posture must hold |
| Copy rules (`apps/game/test/l10n/`) | The respect lists deny words such as lost, missing, gone, sad, only, left, now, before and soon in every key under `checkedPrefixes` (`support/arb_checks.dart`). New prefixes (`story`, `littleOne`, `mascot`, `season`, `nestHouse`) join that list when they're built |
| Local first, data-driven (D269) | Characters, story beats, Little Ones, FX variants and the calendar are read through `CatalogRepository`. Its bundled defaults are Dart constants in `BundledCatalogRepository` today, and there is no catalog JSON. Firestore serves them in M4 and the admin edits them in M5 (TC-DATA). Nothing is hard-coded in widgets |
| Art pipeline | Doll looks stay inside the layered skin format (spec §12.2: 512×768, the same geometry, tinted masks). So a "hero" or "fashion" doll is a **skin** (apron and top details, face, shine), and the board never changes. One artwork is tinted for every colour. Sets come from Claude Design (design/ is the owner's) |
| Colour symbols (§12.3, D91) | Large symbols are the default: a cream disc of r 92 with a centred 8 px ring (out to r 96) at (256,590), over the apron. A player who chose Subtle has no disc. Emblems frame the symbol outside r 96 and read in both modes. Symbol shapes never change |
| Ten chapters, 200 levels (§7.1) | `ChapterTheme` is an enum of ten, `ThemeInfo.chapterNumber` is required, and the Museum sync expects ten figurines. New lands need levels 201 and up plus a data-driven theme list (M4), or a Shop-only theme (a data change) |
| One Lottie per FX slot | `FxLibrary[FxId]` returns one composition. Image slots and tint fills are the only variation. Per-theme motion needs TC-FX |
| Motion and performance (rule 8, WCAG 2.3.1) | Rasterize once, Lottie on set pieces, no per-frame allocation, 60 fps on a 2 GB Android. At most three flashes a second. Idles pause off screen and under reduce motion, which shows stills |
| Ads (§9.1, from M6) | No interstitial inside the story flow, from a homecoming to the next arrival (a spec-prop §9.1 line) |

## 3. The proposals

### TC1. A mascot: the Nest Keeper (wave 1)
- **What.** One warm character who "keeps the nest" and greets you on Home:
  - she guides the tutorial (replacing the plain tip card's voice);
  - she cheers wins, and comforts after an out of moves ("Let's try that one again", never "you failed");
  - she sleeps when you've played a while (ICO's natural break).
  - The working name is "Grandma Nesta" (the owner names her, Q184). She is a big painted doll herself, and opening her is the app icon's moment.
- **Never** in the Shop, ads, purchase or loss-offer surfaces. She is a character, so she's never sold (§2).
- **Fit.**
  - One Lottie with named segments (idle, cheer, comfort, sleep, wave), the way `ui_rival_react` works, plus a small tap reaction.
  - A wordless babble voice instead of spoken lines (§5).
  - Data: one catalog entry with the lines' copy ids.
- **Size.** M (art), S (code). **Needs:** Claude Design (the look, one segmented Lottie, the voice), copy, a tutorial copy pass in 9 locales.

### TC2. The Nest Squad: original colour-coded heroes (wave 2)
- **What.** A colour-coded hero team, the genre of hero teams but Nesty's own. Each member *is a doll family colour*, so the squad and the sort are the same idea.
  - **One look, every colour.** A skin is one artwork tinted per colour (§12.2), so the Squad look dresses every family as a hero in its own colour. Five colours get names and story roles: Crimson Comet (red), Tidal Blue, Meadow Green, Sunny Spark (yellow) and Plum Nova (purple). The rest are the crew. The names are placeholders and get a legal check.
  - **The look:**
    - a cape-scarf on `top_detail`;
    - a determined face;
    - a badge ring that frames the family's colour symbol, so the symbol *is* the emblem. The ring sits outside the Large disc (r 96 plus a margin) and still reads in Subtle mode.
    - Never a lightning bolt or star logo that echoes a team.
- **The transformation** is the nesting reveal. When a family completes, the outer doll opens and the inner dolls "suit up" in a 1.2 s hero pose with a soft burst (at most three flashes a second).
  - It is skippable, and a static pose under reduce motion.
  - It is a variant of the family-complete moment, so it needs TC-FX.
- **How you get it.** Earned at a named chapter's end (the owner picks which, Q184). Never random, and never sold: it carries personas (§2).
- **Size.** L (the look, a suit-up variant, story beats). **Needs:** Claude Design, a legal check, TC-FX, TC-DATA.

### TC3. The Atelier: fashion and dress-up dolls (wave 2, with ER6)
- **What.** A fashion line of doll **skins** (runway, ballet, folk festival, garden party), plus a **runway celebration** after a chapter win, where your equipped doll walks (a TC-FX variant).
- **Fits ER6 Doll Workshop:** you mix the face, apron and shine from owned skins, and new Atelier stamps (lace, sequins, embroidery) join the matryoshka school stamps.
- **Self-expression only:** no outfit scores, ratings or comparison with others (unlike Dress to Impress's runway votes). That keeps the kid path safe.
- **Original only:** no pink script logo, no "Barbie" or "Dreamhouse" words, no look-alike faces.
- **Size.** M–L. **Needs:** Claude Design skins and stamps, ER6, TC-FX.

### TC4. Story mode: "The Long Way Home" (wave 2, absorbs ER9)
- The full analysis is §4. In short:
  - **TC4a:** wordless story panels at one-time moments (Level 2's first win, each chapter's homecoming and the next chapter's arrival), and a Storybook in the Museum.
  - **TC4b:** an optional town map, the campaign seen as a story.
- It is a hide-and-seek story: the families choose to hide around town with a playful Breeze, and the player brings each one home. No villain, no new rule, and no save step by default.
- **Size.** M code, L art (about 32 panels). **Needs:** Claude Design, a little copy in 9 locales, spec-prop lines (§4.10).

### TC5. Folk-tale chapters (wave 2)
- **What.** Chapter themes plus a matching skin and story beats from shared Slavic and folk-tale motifs:
  - **Firebird Grove:** a glowing bird crosses the board at the chapter's end; feathers are the chapter's confetti.
  - **Kind Grandmother of the Woods:** the tales' ambiguous Baba Yaga as a helper. Her hut-on-legs hops in to carry a family home. Friendly, never scary, for under-13s.
  - **Snow Maiden's Winter** (pairs with the winter skin).
- **Cultural care.** Pan-folk framing, no national symbols, and a sensitivity review before art ships.
- **Route.** There are exactly ten chapters today (§2). New lands come either with levels 201 and up in M4, or as Shop-only themes (a data change). The owner picks (Q184); the default is with M4.
- **Size.** M per chapter (a theme, a skin, 3 beats).

### TC6. World Dolls chapters (wave 3)
- **What.** "Nesting cousins" from other doll traditions. Each is a chapter theme, a skin and 3 beats, matched to Nesty's locales where possible:
  - **India (hi):** Channapatna's lacquered, lathe-turned wooden toys, close cousins of a matryoshka's finish ([Wikipedia](https://en.wikipedia.org/wiki/Channapatna_toys)).
  - **Japan (ja):**
    - kokeshi: lathe-turned, limbless and not nesting ([Japan Travel](https://www.japan.travel/en/ph/special-features/kokeshi-dolls/));
    - daruma: you paint one eye when you make a wish ([Tokyo Weekender](https://www.tokyoweekender.com/art_and_culture/history/dark-history-daruma-doll/)). Daruma has Buddhist roots, so it needs a reviewer.
  - **Mexico (es):** Otomí Lele dolls ([Muertolandia](https://muertolandia.com/blogs/news/lele-dolls-a-folk-art-tradition-from-queretaro-mexico)). An Indigenous craft: credit it, and ideally work with an Otomí artist.
  - **Germany (de):** Erzgebirge turned-wood toys (unverified; no source gathered yet).
  - **Brazil (pt-BR):** rag dolls and Carnival colour (unverified).
  - **Turkey (tr) and Indonesia (id):** Karagöz shadow puppets (UNESCO, 2009) ([Wikipedia](https://en.wikipedia.org/wiki/Karag%C3%B6z)) and wayang golek ([What's New Indonesia](https://whatsnewindonesia.com/jakarta/ultimate-guide/things-do/5-betawi-traditional-performance-arts-you-should-know)). These are puppets, so they suit ch07 Puppet Theater's story beats better than a skin.
  - From the first pass: wycinanki papercut patterns, Dala-horse-inspired, alebrije-inspired colour.
- **Care.** Each needs:
  - a sensitivity reviewer;
  - a credit line in the Museum;
  - "inspired by" framing, never "authentic";
  - ideally, a collaborating artist from the culture (owner input).
- **Route.** As TC5.
- **Size.** M per chapter.

### TC7. A character animation layer (wave 1, small)
- **Idle life:**
  - dolls on stands blink and sway a little every few seconds;
  - after a long idle, one yawns;
  - the Home mascot breathes.
- **Tap reactions:** the touched doll squishes and giggles (a sound), and the target that receives a nest bounces "home".
- **Celebrations:** per-theme family-complete variants (squad pose, runway twirl, Firebird feather) need TC-FX. Ship the idle and tap layer first; it needs no new Lottie.
- **Fit.**
  - Flame tweens on existing components: transforms only, no game truth (rule 10), and no per-frame allocation (pre-built curves).
  - Lottie for set pieces.
  - Reduce motion turns idles off.
  - Battery: idles stop when nothing has changed for 30 s and after backgrounding.
  - A 60 fps check on low-end Android (rule 8).
- Every moment, today's FX and what's new are in §5.
- **Size.** S–M. **Needs:** a small Claude Design motion spec (timings, sounds).

### TC8. The Computer with a personality (wave 1, small)
- **What.** The race's Computer gets friendly reactions:
  - it waves at the start;
  - it says "Nice one!" when you complete a family first;
  - when it wins, it gives a polite bow, **not** a celebration over your loss.

  It is always labelled "Computer", never human, never chatty.
- **Resolves the ethics lens's P1 (Q183):** today's loss card plays the rival's `win` hop with confetti over the player's loss. This proposes a "good game" bow instead, if the owner agrees.
- **Fit.** Two new segments, wave and bow, beside `ui_rival_react`'s idle, family, win and lose.
- **Size.** S code, S art.

### TC9. Themed boosters (look only, wave 2)
- **What.** When a squad or theme is equipped, the booster *animations* wear it:
  - Undo as a rewind swirl in the squad colour;
  - Hint as a Firebird spark;
  - +1 Slot as a little Atelier pedestal.
- **No rule change:** the boosters' cost, count and effect stay exactly as the spec says.
- **Needs TC-FX:** each FX slot has one Lottie today.
- **Size.** S per theme.

### TC10. Costume days that come back (wave 3, with ER8)
- **What.** The squad and the mascot dress for the season (winter scarves, spring flowers, harvest), every year, on a fixed calendar. Nothing to buy, nothing that expires. It extends ER8's seasons with characters.
- The dates, places and care notes are in §6. The looks are free. TC12's skin is a separate Shop item on sale all year.
- **Never:** a limited-time character, a countdown or a seasonal-only reward (rule 3).

### TC11. Pop Stage: a doll band (wave 2)
- **What.** A **skin** that dresses every family as a section of a doll band. A skin dresses all dolls, so the band is every colour, never a trio.
- **The harmony celebration:** each completed family sings a short wordless note, and a finished board plays a chord.
- **Option:** a fixed pitch per `DollColor`, as a second, non-visual cue for colour-blind players. It must sit with the existing combo chime and needs spec-prop text (§11.3, §16).
- **Ties in** with ch08 Autumn Bandstand and the Musician family.
- **Never:** lyrics (nothing to translate), votes, fans, rankings, or anything from KPop Demon Hunters (no idol trio, no demon hunting).
- **Size.** M (a skin, a TC-FX variant, 11 short notes). **Needs:** Claude Design (the skin, the motion, and the notes from its music generator), TC-FX.

### TC12. Moonlight Dolls: spooky-cute (wave 2–3)
- **What.** A **skin** with no persona: ghost-sheet capes, lantern lids, and sleepy, friendly faces. Its family-complete variant is a soft "boo-poof" (TC-FX).
- **Never scary:** no skulls, no jump scares, no strobing.
- **Sold for coins all year,** like any skin (§7.3). Only TC10's free costume looks come back each Halloween, with no seasonal Shop badge, countdown or "back soon" (rule 3).
- **Size.** S–M. **Needs:** Claude Design, TC-FX.

### TC13. Little Ones: tiny friends who live in the smallest dolls (wave 2)
- **What.** On the first win of each chapter's levels 3, 7, 13 and 17 (40 in all), the smallest doll lifts its lid and a Little One bobs out.
  - It takes 1.2 s or less and never blocks Continue.
  - These four levels stay clear of the other moments: the milestone chest at level 10, the chapter's end at level 20 (`milestone_chest.dart`), and ch01's rate prompt at level 15.
- **Shown before it's earned:** each Little One appears ahead of time with its **name and silhouette** ("Level 13 · Pip"), in the style of the Museum's locked figurine (frame 6.3).
- **A drawer in the Museum,** and nowhere else:
  - no "N of 40" counter, no collect-all badge, no notification;
  - no randomness, duplicates, trading or stars;
  - never framed as a "surprise" or a "blind box". The toys that inspired it are blind boxes, and rule 2 forbids mystery rewards.
- **No save step:** a Little One is collected when its level is won. Players already past a level find theirs in the drawer, as the stars' backfill works.
- **Art:**
  - 40 tiny original characters;
  - one reveal Lottie with a new `FxImageSlot`, filled the way `RivalPortraitImageSource` and `_FigurineSource` fill slots today (a second slot if it waves);
  - LOTTIE.md and `gen_fx_spec` entries.
- **Replaces** Later's "sticker album". It adds a collectible, so it needs spec-prop text (§7.2 or §7.8).
- **Size.** M code, M art. **Needs:** Claude Design, TC-DATA.

### TC14. Nest House: the Museum as a dollhouse (wave 3)
- **What.** The Museum's cabinet becomes a dollhouse. Each family that comes home lives in a room in its land's style.
  - Furniture arrives at fixed chapter points and is shown before it's earned.
  - The player places it freely, which gives agency without a currency.
  - The Storybook (TC4) lives here.
- **Why, and the doubt.**
  - For: decorating carries Homescapes and Royal Match, and cozy decorating is in fashion.
  - Against: their evidence is for *spending* a currency on decorating. Nesty's stars can't be spent (§7.10). Coins could be, as skins are, but that turns the house into a coin sink.
  - With furniture that comes with progress, the lift is unproven.
- **Save.** Free placement needs a save step (the positions).
- **Replaces** Later's "Museum diorama". Build after TC4, and only if post-release data supports it.
- **Size.** M code, L art (ten rooms and their furniture).

### TC-FX. FX variants (enabler)
- Each `FxId` maps to exactly one Lottie today. A variant key (a theme or skin id) would pick that file's variant, falling back to the base file.
- Variants load lazily, for the equipped theme or skin only (memory, rule 8).
- **Contract:**
  - `gen_fx_spec`, LOTTIE.md and `sync_design_assets` learn variants;
  - a host test proves every variant names a base `FxId`, loads, and keeps its segment names.
- **Size.** S–M code. It comes with the first of TC2, TC3, TC9, TC11 or TC12 to be built.

### TC-DATA. The catalog's new data (enabler)
- The accessors in §9, with bundled defaults. It comes with the first picked item that needs it.

### TC-L. A licensed collaboration (Later, owner)
- Only after M8, with a publisher. It needs the rights holder's approvals, a kid-path check (ads in kids' apps) and a separate rule review. It is not planned work. The facts are in §0.

## 4. Story mode in detail

### 4.1 Why a story, and what the evidence says
- Story and decoration carry the puzzle genre's long tail:
  - Homescapes passed $1B by 2019 ([Sensor Tower](https://sensortower.com/blog/homescapes-revenue-1-billion)).
  - Story is Lily's Garden's main draw ([GameRefinery](https://www.gamerefinery.com/deconstructing-lilys-garden/)).
  - Gossip Harbor builds its ads on its narrative ([Deconstructor of Fun](https://www.deconstructoroffun.com/blog/2024/8/19/finding-genre-success-the-case-of-gossip-harbor)).
- The best test is Royal Match's: its area tasks beat both episode metas on revenue per download (§1). A story frames progress; it doesn't replace good levels (Toon Blast, Project Makeover).
- What a story gives Nesty:
  - a reason to see the next chapter;
  - a face for each figurine family;
  - something to re-read.

  There's no public figure for story against no story, so the lift is a bet; §4.11 measures it.

### 4.2 Formats compared

| Format | Who uses it | Evidence | Fit with Nesty | Cost | Verdict |
|---|---|---|---|---|---|
| Wordless panels at chapter moments | Candy Crush, Toon Blast, Om Nom | Frames progress; travels without words | No rule; offline; almost no copy; fine for pre-readers | M code, L art | **Pick: TC4a** |
| Stars buy decorating tasks | Homescapes, Gardenscapes, Royal Match | The strongest (Royal Match's test) | Breaks §7.10: stars never pay, unlock or gate | XL art, ongoing | No. TC14 is the rule-free cousin |
| Dialogue-led story | Lily's Garden, Gossip Harbor, June's Journey | Drives those games and their ads | Thousands of lines in 9 locales; the respect lists; shuts out pre-readers | L copy, L art | No |
| A journey map | Tasty Travels, saga maps | Travel metas sell (§1b) | A view of chapter progress; no rule | S–M code, M art | **TC4b** |
| A separate story mode with its own puzzles | n.a. | n.a. | New puzzle rules, so spec text; it splits the campaign | XL | No |
| A collection album | Monopoly GO, Royal Match | Strong, but random packs draw criticism and law | Only a deterministic version | M | TC13 |

### 4.3 The pick
- **TC4a:** about 32 wordless panels at one-time moments, plus a Storybook in the Museum. It absorbs ER9.
- **TC4b:** a town map that shows the campaign as the story's journey, from an optional Story entry (a §10.2 line). It comes after TC4a.
- **Not stars for decorating:** that needs a §7.10 change, and TC14 covers the decorating wish without one.

### 4.4 The arc: "The Long Way Home", a game of hide-and-seek
- **Premise.**
  - The Breeze is a playful friend from the first panel. One morning it invites the ten doll families to play hide-and-seek, and they **choose** to hide all over town.
  - The player seeks each family, chapter by chapter, and brings it home to the Museum, whose copy already says "Every family is home."
  - Nobody is lost, scared or sad, and there's no villain.
- **The pairing is the plot.** `tokens.json` gives each chapter its family, and some places are funny for their family: astronauts in the snow, a snow family in a spring shed. Hide-and-seek explains that: everyone picked a surprising place to hide.
- **The sorting *is* the story:** every family you complete is one more family found.
- **One panel per beat:** a prologue, then an arrival, a midpoint and a homecoming for each chapter, then an epilogue: 32 panels. This is a draft for the owner and Claude Design.

| Chapter (family) | Arrival | Midpoint (Storybook only) | Homecoming |
|---|---|---|---|
| Prologue | The Nest Keeper's shop at dawn: the Breeze taps on the window, and the families dash off to hide | | |
| ch01 Sunny Toy Shop (Classic) | The Classics hide among the shop's own toys | Peeking out of a toy box | Back on the cabinet shelf, as the Nest Keeper unrolls a town map |
| ch02 Rainy Café Corner (Sailor) | Sailing a teacup across a puddle | Dry under the café awning | Rowing home in a paper boat |
| ch03 Seaside Market (Baker) | Hiding among the bread baskets | Sharing buns with the gulls | Riding home on a fish cart |
| ch04 Snowy Cabin (Astronaut) | Landing in the snow, sure it's the moon | Building a snow rocket | Sledding home under the stars |
| ch05 Night Carnival (Gardener) | A beanstalk up the Ferris wheel | Planting seeds by lantern light | Riding the carousel home |
| ch06 Spring Garden Shed (Snow) | Hiding under flowerpot sun hats | The Breeze cools them with a gentle gust | Floating home on a cool breeze |
| ch07 Puppet Theater (Circus) | Slipping backstage | Putting on a show for the puppets | A bow, and the puppets clap |
| ch08 Autumn Bandstand (Musician) | Hiding among the instruments | The Breeze hums along to their tune | Marching home to their own song |
| ch09 Castle Library (Royal) | Hiding between the storybooks | Reading by a tall window | Home with a royal wave |
| ch10 Sunrise Lookout (Explorer) | Climbing to the lookout at dawn | Spotting every hiding place with a spyglass | The Breeze takes a turn to hide, the whole town finds it, and all ten families parade home together |
| Epilogue | The Breeze lives in the shop's wind chime. On Home it rings softly now and then | | |

- **Wordless means no text in the art either:** no shop signs, no readable book spines, no labels. Faces, gestures and colour carry it.

### 4.5 When beats play
Beats play only at one-time events, so nothing new is saved. All the changes are in the view (`gameplay_view.dart`), keyed on what the bloc already knows:

| Beat | When | Hook |
|---|---|---|
| The prologue and ch01's arrival | After Level 2's first win, before Level 3 | A per-level "first win" flag computed in the bloc's `_win` (`order >= highestLevel`, read before `recordLevelWin`). Not `tutorialDone`, which flips during Level 2's first move. Level 1 stays instant, and its first win is where the kid path's age question will sit (Q174) |
| A chapter's homecoming | Inside the chapter-complete flow, before the figurine's spotlight | `_openChapterComplete`, which covers both callers, keyed on `GameplayState.completedChapterId`. That is set only on the first completion (`!museum.contains`). Not `PlayEntry.completesChapter`, which is true on any campaign play of a last level |
| The next chapter's arrival | After the chapter-complete Continue, before the next level starts | In `_continueFromChapterComplete`. That once, it can stand in for the next level's `ChapterRibbon` (Claude Design decides) |
| A chapter's midpoint | Never in the flow: its page unlocks silently at the level-10 win | The milestone chest owns that win (`MilestoneChest.chapterPosition`) |
| ch10's homecoming and the epilogue | After the last chapter's figurine | As a homecoming |

- A new `GameplayOverlay` value carries a beat. `_onBack` and the chapter jingle learn about it.
- **Never** in a race, the daily, Bonus Endless or a replay.
- **One tap skips**, and there's no auto-advance. Reduce motion shows still panels.
- **Players already past a beat**, or who closed the app during it, find it in the Storybook.
  - If the owner wants passed beats replayed in the flow, a `storySeen` save field is a schema step via `/plan` (the daily gift takes schema 3).

### 4.6 The Storybook and the map
- **Storybook (TC4a).**
  - The figurine dialog (frame 6.2, `figurine_modal.dart`) budgets its height so it never overflows. So it gets one "Storybook" button under the Collected chip, not thumbnails.
  - The button opens a full-screen reader of that family's pages. The prologue opens the Classic family's book, and the epilogue closes the Explorer family's.
  - A locked page shows a silhouette and "Finish chapter N", in the style of frame 6.3.
- **The town map (TC4b).**
  - The ten places on one illustrated town map, with the families you've found standing in theirs.
  - An optional Story entry (a §10.2 line).
  - It reads chapter progress and never gates anything.

### 4.7 Words, languages and accessibility
- **Wordless by default.**
  - At most one optional caption per beat, 50 characters or fewer, under the `story` prefix so the respect lists check it.
  - Captions are warm and in the present tense: "The Sailors set sail!"
- **Screen readers.** Every panel gets a description: about 32 × 9 strings, with an Opus review (D240) and the same respect lists.
- **Text.** Captions follow text scaling up to 1.3× (§16) and pass the overflow suite in nine locales. Dolls in the art keep their colour symbols readable.

### 4.8 Art, size and memory
- 32 phone-size rasters would add roughly 5–12 MB to the download (an estimate, unverified), which costs installs in a hybrid-casual game.
- **Prefer vector panels** drawn to §12.2's limits (paths, gradients, no filters):
  - rasterized when shown, disposed when closed;
  - one panel in memory at a time (rule 8).
- **Fallback, if vectors don't suit the art:** bundle the prologue and chapters 1–3, and fetch the rest in M4. Play stays complete offline without the later panels (hard rule 3).

### 4.9 Where it plugs in
- **Bloc:** a per-level first-win flag in `_win`, next to `completedChapterId`.
- **View:** `gameplay_view.dart`'s chapter-complete methods and a new `GameplayOverlay` value.
- **Rules:** a pure `StoryRules`, like `services/chest/`, maps an event to its beat, or to none.
- **Data:** TC-DATA's `storyBeats`.
- **Museum:** the Storybook button in `features/museum/widgets/figurine_modal.dart`.
- **New feature folder:** `features/story/`, for the reader and the panels. Building it adds a CLAUDE.md Code-map line and a TEST_COVERAGE row (`tools/test/claude_md_test.dart` and `test_coverage_test.dart` check both).
- **Audio:** a page-turn sound and a short story sting with §11.3 names. `MusicService` ducks under them.

### 4.10 Tests and spec text
- **Tests (D169):**
  - `StoryRules` unit tests: each trigger, and no beat in races, the daily, Bonus Endless or replays;
  - widget tests for the reader: skip, screen-reader labels, reduce motion;
  - the overflow suite in nine locales;
  - a playthrough step with a screenshot: the prologue after Level 2, skipped;
  - a TEST_COVERAGE row.
- **Spec-prop lines to approve first:**
  - §7.2: the Storybook beside the Museum;
  - §9.1: no interstitial in the story flow;
  - §10.1: where beats sit in the flow;
  - §10.2: the Story entry (TC4b);
  - §11.3: the new sounds;
  - §15: an admin Story section in M5;
  - §16: the panels' accessibility.

### 4.11 Ethics, and what to measure
- **Never:** timers, "tomorrow" cliffhangers, anything behind coins or ads, characters on purchase surfaces, anything scary, a villain, or a comment on a loss.
- **Measure:** a Remote Config key, `story_beats_enabled`, lets M4 compare (default true, hard-coded per rule 6). After M4, and only once the kid path's legal check allows analytics, measure:
  - the skip rate;
  - Storybook opens;
  - chapter-to-chapter continuation.

## 5. Animation catalogue

| Moment | Today | Proposal | Needs |
|---|---|---|---|
| Pick, move, nest | `doll_pick`, `doll_move`, `doll_nest`, `doll_swallow` | A little squash and stretch on the nest | Flame tweens (TC7) |
| Invalid move | `doll_invalid` | A gentle shake, never a red flash | As today |
| Family complete | `doll_complete`, `fx_sparkle`, `ui_family_counter` | Per-theme variants: squad suit-up (TC2), runway twirl (TC3), harmony (TC11), boo-poof (TC12), a rocket for the space skin | TC-FX, Claude Design |
| Win | `ui_win_ribbon`, `doll_win_dance`, `doll_win_hop`, `fx_confetti` | The mascot's cheer (TC1). A Little One bobs out at levels 3, 7, 13 and 17 (TC13) | A new image slot |
| Out of moves | The sheet | The mascot's comfort, never "you failed" (TC1) | A segment |
| Chapter complete | `ui_chapter_ribbon`, the figurine's spotlight | The homecoming panel and a short family parade (TC4a) | Panels |
| Board idle | `doll_idle` | Blink, sway and a rare yawn. They stop after 30 s idle and in the background | TC7 |
| Home | The plank's idle dolls | The mascot breathes. After the finale, the Breeze's wind chime | TC1, TC4a |
| Museum | `ui_museum_idle` (a bob loop) | A tapped figurine waves | New art |
| Race | `ui_rival_react` (idle, family, win, lose) | A wave at the start, a polite bow when it wins (Q183) | Two segments (TC8) |
| Boosters | `ui_booster_glow`, `ui_extra_slot`, `ui_hint_arrow` | Themed looks, effects unchanged (TC9) | TC-FX |
| Seasons | None | Costume looks (TC10) | Art per season |
| Story | None | A page turn and a slow pan; stills under reduce motion | TC4a |
| Voices | Sound effects only | A wordless babble voice for the mascot and the characters, so nothing to translate | Claude Design's SFX generator, §11.3 names |

- **Limits:**
  - at most three flashes a second;
  - reduce motion gives still frames;
  - 60 fps on a 2 GB Android, with no per-frame allocation;
  - FX variants load only for the equipped theme or skin.
- **Babble voices travel.**
  - Animal Crossing's Animalese is built from each language's text, so it localizes itself ([Nookipedia](https://nookipedia.com/wiki/Animalese)).
  - The Sims' Simlish was made so players connect with feelings, not words ([Wikipedia](https://en.wikipedia.org/wiki/Simlish)).
  - The Minions mix words from many languages, Hindi and Indonesian among them ([BuzzFeed News](https://www.buzzfeednews.com/article/danielspielberger/how-the-minions-took-over-the-world), [Wikipedia](https://en.wikipedia.org/wiki/Minions_(Despicable_Me))).
  - Nesty's babble stays pure sound with no real words, so all nine locales share one set of files.
- **Lottie or Rive.**
  - Characters use one Lottie with named segments, as `ui_rival_react` does.
  - Rive only if a character needs live state (looking at your finger, reacting mid-animation). Even then, only after a rule-9 package reason and a 60 fps spike on a low-end Android.

## 6. Seasons and cultural calendar (October 2026 to November 2027)

- **Looks only,** every year (ER8, TC10): no rewards, offers or countdowns (rule 3; PEGI rates time-limited offers 12, BACKLOG M8).
- **Where:**
  - keyed on the device's region (nothing leaves the phone), with the locale as the fallback;
  - region-neutral by default, as ER8 says: Brazil's winter is June to August, and Indonesia has no four seasons.
- **A Settings toggle,** "Seasonal looks", on by default.
- **Dates are data** (TC-DATA): lunar and lunisolar dates move every year, so the table is kept per year.
- **One art set serves many rows:** the Children's Days share one toy-parade look.
- **The game isn't released yet,** so the calendar starts on the release date (M8).

| Date | Occasion | Where | The look (free) | Care |
|---|---|---|---|---|
| 31 Oct 2026 | Halloween | Most regions | Costume looks: pumpkin lids, moon lanterns (TC10, in TC12's style) | Cute, never scary; no strobing |
| 1–2 Nov | Día de Muertos ([UNESCO](https://ich.unesco.org/en/RL/indigenous-festivity-dedicated-to-the-dead-00054)) | Mexico only | Default: none until a reviewer signs off. Then marigolds and papel picado | A remembrance day: never beside Halloween or TC12, no skulls on kids' surfaces |
| 8 Nov | Diwali ([Awareness Days](https://www.awarenessdays.com/awareness-days-calendar/diwali/)) | India | Diyas and rangoli under the shelf | No firework strobe |
| 14 Nov | Children's Day ([Wikipedia](https://en.wikipedia.org/wiki/Children's_Day)) | India | The toy parade on Home | |
| 15 Nov | Shichi-Go-San, for girls of 3 and 7 and boys of 5 ([Wikipedia](https://en.wikipedia.org/wiki/Shichi-Go-San)) | Japan | Festive kimono patterns and chitose-ame candy sticks | A shrine custom: festive colours only, no shrine imagery |
| 20 Nov | Children's Day | France | The toy parade | |
| 25 Dec | Christmas | Most regions | Snow, garlands, ribbons | Secular and festive |
| 1–3 Jan 2027 | Shōgatsu, the Japanese New Year ([Wikipedia](https://en.wikipedia.org/wiki/Japanese_New_Year)) | Japan | Kadomatsu pine, kites and a kagami-mochi stack on the shelf | Leave out otoshidama money envelopes: no money imagery for children |
| 6 Jan | Reyes Magos ([idealista](https://www.idealista.com/en/news/lifestyle-in-spain/2025/12/01/874619-day-of-the-three-kings-in-spain-dates-parades-and-traditions)) | Spain, Latin America | Gift ribbons, a parade | No religious figures |
| 5–10 Feb | Carnival ([Beach.com](https://www.beach.com/beaches/carnival-brazil-guide/)) | Brazil | Confetti, masks, feathers | |
| 6 Feb | Imlek, Lunar New Year: the Year of the Goat ([Awareness Days](https://www.awarenessdays.com/awareness-days-calendar/chinese-new-year/)) | Indonesia | Red lanterns, a goat costume | A national holiday in Indonesia since 2003 ([Wikipedia](https://en.wikipedia.org/wiki/Chinese_Indonesians)), the only one of Nesty's locales that marks it |
| From about 8 Feb | Ramadan ([The National](https://www.thenationalnews.com/news/uae/2026/09/09/ramadan-2027-dates-eid-al-fitr-holiday/)) | Indonesia, Turkey | Lanterns only | No food during the fast |
| 3 Mar | **Hinamatsuri, the Doll Festival** ([Nippon.com](https://www.nippon.com/en/features/jg00031/)) | Japan | The Museum becomes a tiered hina-dan display | Put it away the next day, as the custom says ([Wikipedia](https://en.wikipedia.org/wiki/Hinamatsuri)). Leave out the custom's gendered superstition |
| About 9–10 Mar | Eid al-Fitr: Lebaran and Şeker Bayramı ([Daily Sabah](https://www.dailysabah.com/life/religion/ramadan-bayram-the-sweetest-of-holidays-at-least-for-muslim-turks), [Jakarta Post](https://www.thejakartapost.com/news/2019/06/05/anies-marks-idul-fitri-with-angpao-takbiran-traditions.html)) | Indonesia, Turkey | Sweets and lanterns | Children get sweets or gifts in both traditions |
| 22 Mar | **Holi, the festival of colours** ([Divine Hindu](https://www.divinehindu.in/blogs/news/holi-holika-dahan-2027-date-muhurat-significance)) | India | Colour puffs when a family completes | Soft colour, no flashing |
| 23 Apr | Children's Day | Turkey | The toy parade | |
| 30 Apr | Día del Niño | Mexico | The toy parade | |
| 5 May | Kodomo no Hi ([Wikipedia](https://en.wikipedia.org/wiki/Tango_no_sekku)) | Japan | Carp streamers over the shelf | |
| 23 Jul | Children's Day | Indonesia | The toy parade | |
| 20 Sep | Weltkindertag | Germany | The toy parade | |
| Sep–Oct | Navratri Golu ([Wikipedia](https://en.wikipedia.org/wiki/Golu_(festival))) | South India | Optional: a tiered doll display like the hina-dan | A South Indian custom, so a weak fit for Hindi players |
| 12 Oct | Dia das Crianças ([Correio Braziliense](https://www.correiobraziliense.com.br/cidades-df/2026/09/7507019-comercio-aposta-no-crescimento-das-vendas-para-o-dia-das-criancas.html)) | Brazil | The toy parade | Brazil's third-biggest retail date, so no offers of any kind |
| Sport | For example, the 2027 Women's World Cup in Brazil, 24 Jun–25 Jul ([Wikipedia](https://en.wikipedia.org/wiki/2027_FIFA_Women%27s_World_Cup)) | By region | Generic sporty looks | No FIFA marks, no flags |

## 7. Don't copy

| Pattern | Why not | Instead |
|---|---|---|
| Character gacha, random pulls, duplicate shards | Loot-box-like (rule 2); PEGI 16; Brazil's 2026 ban | Earned characters (TC2, TC4) |
| Blind-box or "surprise" framing | Rule 2 bans mystery rewards | A name and silhouette shown first (TC13) |
| Limited-time characters or "last chance" skins | Scarcity (rule 3) | TC10's yearly return |
| Characters that ask you to buy, or appear in ads, loss offers or the Shop | Manipulation; Apple and Google kids' rules; ICO; coins are sold for money | TC1's "never" list; characters earned, skins sold (§2) |
| Spending stars on decorating or story | Stars never pay, unlock or gate (§7.10) | Progress-earned pieces (TC13, TC14) |
| "Next chapter tomorrow" cliffhangers or story timers | Rule 3 | Beats at one-time chapter moments (§4.5) |
| A rival that gloats, or a villain that mocks a loss | Shame; the respect lists ban taunts | TC8; a story with no villain |
| Outfit scores or comparison | Social comparison; the kid path | Self-expression only (TC3) |
| Energy or lives tied to a character | Gates play; not in the spec | n.a. |
| Look-alike heroes, logos, names or catchphrases, in drawn or generated art | Legal risk (§0) | Original designs plus a legal check |
| National flags, "Russia" labels, Soviet imagery, FIFA marks | Cultural, political and legal risk | Pan-folk toy-shop framing; generic sporty looks |
| Brainrot, horror and meme trends | Short-lived and AI-made, and they worry parents | Warm original characters |

## 8. Order and size

| Id | Proposal | Wave | Code | Art | Depends on |
|---|---|---|---|---|---|
| TC7 | Character animation layer | 1 | S–M | S | Claude Design motion spec; TC-FX only for theme variants |
| TC8 | Computer personality | 1 | S | S | Q183 |
| TC1 | Mascot, the Nest Keeper | 1 | S | M | Claude Design; tutorial copy in 9 locales |
| TC4a | Story panels and the Storybook | 2 | M | L | ER9 merged in; spec-prop lines (§4.10); TC-DATA |
| TC13 | Little Ones | 2 | M | M | Spec-prop §7.2 or §7.8; TC-DATA |
| TC2 | The Nest Squad | 2 | M | L | Legal check; TC-FX; TC-DATA |
| TC3 | The Atelier | 2 | M | M–L | ER6; TC-FX |
| TC11 | Pop Stage | 2 | S–M | M | TC-FX; §11.3 and §16 text for the pitch option |
| TC5 | Folk-tale chapters | 2 | S each | M each | Sensitivity review; the new-lands route |
| TC9 | Themed boosters (look) | 2 | S | S each | TC-FX; TC2, TC3 or TC5 |
| TC4b | The town map | 2–3 | S–M | M | TC4a; a §10.2 line |
| TC12 | Moonlight Dolls | 2–3 | S | S–M | TC-FX |
| TC6 | World Dolls chapters | 3 | S each | M each | Reviewers, credits; the new-lands route |
| TC10 | Costume days | 3 | S | M | ER8; §6 |
| TC14 | Nest House | 3 | M | L | TC4a; post-release data; a save step |
| TC-FX | FX variants | With its first user | S–M | n.a. | The LOTTIE.md contract |
| TC-DATA | The catalog's new data | With its first user | S–M | n.a. | D269 |
| TC-L | Licensed collab | Later | n.a. | n.a. | After M8, a publisher |

The default if the owner picks nothing else (Q184): wave 1 (TC7, TC8, TC1), then TC4a (absorbing ER9), then TC13.

## 9. Data shape (TC-DATA; D269: admin-ready)

`CatalogRepository` is the one place features read all of this from.
- **Today:** `BundledCatalogRepository` holds Dart constants for the skins, themes and figurine ids, and M4 overlays Firestore.
- **The fake** gets the same fields (hard rule 4).
- **New accessors,** each with bundled defaults:
  - `characters`: id, kind (mascot, squad, rival), look (a skin or Lottie id), segment names, copy ids, and the unlock point (a chapter or level id).
  - `storyBeats`: id, chapter id, moment (prologue, arrival, midpoint, homecoming, epilogue), image asset id, screen-reader copy id, and an optional caption copy id.
  - `littleOnes`: id, name copy id, level id, image asset id.
  - `fxVariants`: an `FxId` plus a variant key (a theme or skin id), mapped to an asset file (TC-FX).
  - `calendar`: occasion id, regions, dates per year, look id.
- **Rules:** a pure `StoryRules` decides which beat an event shows. It is host-tested and never touches game truth (rule 10).
- **Remote Config:** `story_beats_enabled`, default true, hard-coded in `RemoteConfigService` (rule 6).
- **Save:** nothing new by default. Beats and Little Ones derive from progress (one-time events and won levels). Each of these would be a schema step with a migration:
  - a `storySeen` field (passed beats replayed in the flow);
  - TC14's furniture positions.

## 10. Claude Design request (paste-ready, after the owner picks)

> Nesty: characters and story (follow-up to nesty-design-m7-4). Keep the cozy folk-toy-shop direction (spec §12.1, tokens v4). Original designs only, including anything generated. Nothing may resemble Marvel, Power Rangers, Barbie, KPop Demon Hunters, Sanrio or any existing character: not its logo, suit, helmet, silhouette, colour blocking or catchphrase. Motion never flashes more than three times a second.
> 0. **A character bible.** For each character:
>    - a proposed name, for a legal check;
>    - a personality in three words;
>    - how it moves;
>    - its wordless babble voice;
>    - do and don't: it never sells, never mocks, is never scary.
> 1. **The Nest Keeper mascot:**
>    - a large painted matryoshka grandmother;
>    - a Home pose;
>    - one Lottie with named segments (idle breathe, cheer, comfort after out of moves, sleep after long play, wave), like `ui_rival_react`, at the size and position the Home and win frames give;
>    - reduce-motion stills;
>    - a babble voice.
> 2. **The Nest Squad:** one hero look in the 512×768 layered skin format (shadow, bottom_mask, bottom_detail, top_mask, face, top_detail, shine), tinted per family colour:
>    - a cape-scarf on `top_detail`;
>    - a determined face;
>    - a badge ring that frames the colour symbol outside r 96 (the Large disc) and still reads in Subtle mode;
>    - a 1.2 s "suit up" variant of the family-complete moment;
>    - names for the five lead colours, for a legal check.
> 3. **Story "The Long Way Home"** (hide-and-seek; the beat sheet is themes-characters-story §4.4):
>    - 32 single wordless panels, with no text inside the art (no signs, no readable book spines);
>    - the Breeze as a playful friend from the first panel;
>    - the Storybook reader, and its locked page (a silhouette plus "Finish chapter N");
>    - vector-friendly within §12.2's limits where possible;
>    - reduce-motion stills.
> 4. **Computer reactions:** "wave" and "bow" segments beside `ui_rival_react`'s idle, family, win and lose. The bow replaces the win hop over the player's loss on 9.5.
> 5. **Idle and tap motion spec:**
>    - blink, sway and yawn timings;
>    - the tap squish and the "home" bounce;
>    - a tap-wave for Museum figurines;
>    - sounds named per spec §11.3.
> 6. **If picked:**
>    - **Little Ones:** 40 tiny original characters with names, and one reveal Lottie with an image slot.
>    - **Pop Stage:** a skin, the harmony moment, and 11 short notes that sit with the combo chime.
>    - **Moonlight Dolls:** a skin and a soft boo-poof, never scary.
>
> Deliver into `design/` as before, with LOTTIE.md and copy.md entries and the tokens.

## 11. Questions for the owner

- **Q183.** The 9.5 race-loss card plays the Computer's `win` hop with confetti over the player's loss.
  - The ethics lens rates it P1: close to the line, not a rule break.
  - The shipped default is the design as delivered.
  - TC8 proposes a polite bow instead.
- **Q184.** Which of TC1–TC14 to build, and in what order. TC-FX and TC-DATA come with the items that need them. The default order is wave 1 (TC7, TC8, TC1), then TC4a, then TC13. Within that, the owner also decides:
  - the mascot's name, and the squad's names and chapter, after a legal check;
  - the route for new lands in TC5 and TC6 (default: with M4's weekly levels);
  - whether the story keeps the tokens' figurine pairing (default: yes, as its plot);
  - whether beats a player has already passed replay in the flow (default: no, the Storybook only).
