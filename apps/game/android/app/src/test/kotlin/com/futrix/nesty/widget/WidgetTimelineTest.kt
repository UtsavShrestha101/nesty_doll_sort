package com.futrix.nesty.widget

import java.io.File
import java.time.Duration
import java.time.Instant
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.ZoneId
import java.time.ZonedDateTime
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/**
 * WidgetTimeline against the app's own snapshot goldens (written by the Dart
 * snapshot test, `apps/game/test/fixtures/widget_snapshot_v1*.json`, read by
 * path so both sides share one file), plus malformed snapshots and the
 * midnight across DST nights (plan-local-habits §4 "Tests", Kotlin).
 */
class WidgetTimelineTest {
    private fun golden(name: String): String {
        // Gradle runs unit tests in the module folder (apps/game/android/app);
        // walk up to apps/game, whose test/fixtures holds the goldens.
        val from = System.getProperty("user.dir") ?: "."
        var dir: File? = File(from).absoluteFile
        while (dir != null) {
            val file = File(dir, "test/fixtures/$name")
            if (file.isFile) return file.readText()
            dir = dir.parentFile
        }
        throw AssertionError("golden $name not found above $from")
    }

    private fun snapshot(name: String): WidgetSnapshot =
        WidgetTimeline.decode(golden(name)) ?: throw AssertionError("$name did not decode")

    private val start = LocalDate.of(2026, 10, 8)

    // ---- the goldens --------------------------------------------------------

    @Test
    fun decodesTheReadyGolden() {
        val s = snapshot("widget_snapshot_v1.json")
        assertEquals("nesty-dev", s.scheme)
        assertEquals("en", s.lang)
        assertTrue(s.unlocked)
        assertEquals("Daily puzzle", s.locked.title)
        assertEquals("Opens after Level 2", s.locked.small)
        assertEquals("Your first daily puzzle opens after Level 2.", s.locked.medium)
        assertEquals("Nesty daily puzzle. Opens after Level 2.", s.locked.a11y)
        assertEquals(8, s.days.size)
        assertEquals((0L..7L).map { start.plusDays(it) }, s.days.map { it.date })

        val today = s.days[0]
        assertEquals(DayState.READY, today.state)
        assertEquals(4, today.streak)
        assertEquals("4", today.number)
        assertEquals("day streak", today.label)
        assertNull(today.labelShort)
        assertEquals("Thursday’s puzzle", today.title)
        assertEquals("5 colors · Medium", today.sub)
        assertEquals(listOf(0xFF2F3E8F.toInt(), 0xFFF2893B.toInt()), today.dolls)
        assertEquals("Today’s puzzle is ready", today.line)
        assertEquals("Ready to play", today.lineShort)
        assertEquals("Nesty daily puzzle. 4-day streak. Today’s puzzle is ready.", today.a11y)

        val tomorrow = s.days[1]
        assertEquals(DayState.PAUSED, tomorrow.state)
        assertEquals("day streak · resting", tomorrow.label)
        assertEquals("resting", tomorrow.labelShort)
        assertEquals(3, tomorrow.dolls.size)
        // Only today's and tomorrow's dolls are computed (lead ruling).
        assertTrue(s.days.drop(2).all { it.dolls.isEmpty() })
    }

    @Test
    fun eachDateFindsItsOwnEntry() {
        val s = snapshot("widget_snapshot_v1.json")
        for (offset in 0L..7L) {
            val date = start.plusDays(offset)
            val content = WidgetTimeline.content(s, date) as WidgetContent.Day
            assertEquals(date, content.day.date)
            assertEquals(if (offset == 0L) DayState.READY else DayState.PAUSED, content.day.state)
            assertEquals(s.days[offset.toInt()], content.day)
        }
    }

    @Test
    fun beforeTheFirstEntryTakesTheFirst() {
        val s = snapshot("widget_snapshot_v1.json")
        val content = WidgetTimeline.content(s, start.minusDays(3)) as WidgetContent.Day
        assertEquals(s.days.first(), content.day)
    }

    @Test
    fun pastTheLastEntryIsTheLastAsReadyWithTheGenericTitle() {
        val s = snapshot("widget_snapshot_v1.json")
        val last = s.days.last()
        for (late in listOf(8L, 9L, 40L)) {
            val day = (WidgetTimeline.content(s, start.plusDays(late)) as WidgetContent.Day).day
            assertEquals(DayState.READY, day.state)
            assertEquals(last.date, day.date)
            assertEquals(last.streak, day.streak)
            assertEquals(last.number, day.number)
            assertEquals(last.label, day.label)
            assertEquals(last.labelShort, day.labelShort)
            assertEquals("Daily puzzle", day.title)
            assertNull(day.sub)
            assertTrue(day.dolls.isEmpty())
            assertEquals(last.line, day.line)
            assertEquals(last.lineShort, day.lineShort)
            assertEquals(last.a11y, day.a11y)
        }
    }

    @Test
    fun theSolvedGoldenLightsTodayOnly() {
        val s = snapshot("widget_snapshot_v1_solved.json")
        val today = (WidgetTimeline.content(s, start) as WidgetContent.Day).day
        assertEquals(DayState.SOLVED, today.state)
        assertEquals("5", today.number)
        assertEquals("Solved. See you tomorrow.", today.line)
        assertEquals("Solved!", today.lineShort)
        val tomorrow = (WidgetTimeline.content(s, start.plusDays(1)) as WidgetContent.Day).day
        assertEquals(DayState.READY, tomorrow.state)
        assertEquals("Today’s puzzle is ready", tomorrow.line)
        assertTrue(s.days.drop(1).none { it.state == DayState.SOLVED })
    }

    @Test
    fun aSolvedLastEntryBorrowsTheReadyWording() {
        // The app never writes one (days after today are projected with no
        // solve), but a solved line must never outlive its day.
        val s = snapshot("widget_snapshot_v1_solved.json")
        val solvedOnly = s.copy(days = listOf(s.days[1], s.days[0].copy(date = start.plusDays(2))))
        val day = WidgetTimeline.dayFor(solvedOnly, start.plusDays(5))
        assertEquals(DayState.READY, day.state)
        assertEquals("5", day.number)
        assertEquals(s.days[1].line, day.line)
        assertEquals(s.days[1].lineShort, day.lineShort)
        assertEquals(s.days[1].a11y, day.a11y)

        val alone = s.copy(days = listOf(s.days[0]))
        val kept = WidgetTimeline.dayFor(alone, start.plusDays(1))
        assertEquals(DayState.READY, kept.state)
        assertEquals(s.days[0].line, kept.line)
    }

    @Test
    fun theLockedGoldenDrawsTheLockedStrings() {
        val s = snapshot("widget_snapshot_v1_locked.json")
        assertFalse(s.unlocked)
        val content = WidgetTimeline.content(s, start)
        assertEquals(WidgetContent.Locked(s.locked), content)
        assertTrue(s.days.all { it.state == DayState.ZERO && it.number == null })
        assertEquals("Your first flame", s.days[0].label)
    }

    @Test
    fun nothingStoredIsTheFirstRun() {
        assertEquals(WidgetContent.FirstRun, WidgetTimeline.content(WidgetTimeline.decode(null), start))
        assertEquals(WidgetContent.FirstRun, WidgetTimeline.content(WidgetTimeline.decode(""), start))
    }

    // ---- malformed and newer snapshots → the first run ----------------------

    private fun goldenWith(transform: (String) -> String) = transform(golden("widget_snapshot_v1.json"))

    @Test
    fun aNewerSchemaIsTheFirstRun() {
        assertNull(WidgetTimeline.decode(goldenWith { it.replaceFirst("\"v\": 1", "\"v\": 2") }))
        assertNull(WidgetTimeline.decode(goldenWith { it.replaceFirst("\"v\": 1", "\"v\": \"1\"") }))
        assertNull(WidgetTimeline.decode(goldenWith { it.replaceFirst("\"v\": 1,", "") }))
        // 1.0 is still schema 1.
        assertNotNull(WidgetTimeline.decode(goldenWith { it.replaceFirst("\"v\": 1", "\"v\": 1.0") }))
    }

    @Test
    fun malformedJsonIsTheFirstRun() {
        val bad = listOf(
            "{",
            "[]",
            "null",
            "42",
            "not json",
            goldenWith { it.dropLast(3) },
            goldenWith { "$it trailing" },
            goldenWith { it.replaceFirst("\"unlocked\": true", "\"unlocked\": \"yes\"") },
            goldenWith { it.replaceFirst("\"state\": \"ready\"", "\"state\": \"glowing\"") },
            goldenWith { it.replaceFirst("\"date\": \"2026-10-08\"", "\"date\": \"08/10/2026\"") },
            goldenWith { it.replaceFirst("\"streak\": 4", "\"streak\": -1") },
            goldenWith { it.replaceFirst("\"streak\": 4", "\"streak\": 4.5") },
            goldenWith { it.replaceFirst("\"title\": \"Daily puzzle\",", "") },
            goldenWith { it.replaceFirst("\"line\": \"Today’s puzzle is ready\"", "\"line\": null") },
            goldenWith { it.replaceFirst("\"label\": \"day streak\"", "\"label\": 3") },
            goldenWith { it.replace(Regex("\"days\": \\[.*]\\s*}\\s*$", RegexOption.DOT_MATCHES_ALL), "\"days\": []}") },
            goldenWith { it.replaceFirst("\"dolls\": [", "\"dolls\": {\"x\": [") },
        )
        for (json in bad) {
            assertNull(json.take(60), WidgetTimeline.decode(json))
            assertEquals(WidgetContent.FirstRun, WidgetTimeline.content(WidgetTimeline.decode(json), start))
        }
    }

    @Test
    fun optionalFieldsMayBeNullOrAbsent() {
        val s = WidgetTimeline.decode(
            goldenWith {
                it.replaceFirst("\"scheme\": \"nesty-dev\",", "")
                    .replaceFirst("\"lang\": \"en\"", "\"lang\": null")
                    .replaceFirst("\"sub\": \"5 colors · Medium\",", "")
            },
        )
        assertNotNull(s)
        assertNull(s!!.scheme)
        assertNull(s.lang)
        assertNull(s.days[0].sub)
    }

    @Test
    fun anUnreadableDollColourIsSkippedNotFatal() {
        val s = WidgetTimeline.decode(goldenWith { it.replaceFirst("\"#2F3E8F\"", "\"navy\"") })
        assertNotNull(s)
        assertEquals(listOf(0xFFF2893B.toInt()), s!!.days[0].dolls)
    }

    private fun dayJson(date: String, state: String, line: String = "Today’s puzzle is ready") =
        """{"date":"$date","state":"$state","streak":2,"number":"2","label":"day streak",""" +
            """"labelShort":null,"title":"T $date","sub":"5 colors","dolls":[],""" +
            """"line":"$line","lineShort":"Ready to play","a11y":"A $date"}"""

    private fun snapshotJson(vararg days: String) =
        """{"v":1,"scheme":"nesty","lang":"de","unlocked":true,""" +
            """"locked":{"title":"Daily","small":"S","medium":"M","a11y":"L"},""" +
            """"days":[${days.joinToString(",")}]}"""

    @Test
    fun daysAreReadInDateOrderOncePerDate() {
        val s = WidgetTimeline.decode(
            snapshotJson(
                dayJson("2026-10-10", "paused"),
                dayJson("2026-10-08", "solved", "Solved. See you tomorrow."),
                dayJson("2026-10-09", "ready"),
                dayJson("2026-10-09", "zero"),
            ),
        )!!
        assertEquals(
            listOf(LocalDate.of(2026, 10, 8), LocalDate.of(2026, 10, 9), LocalDate.of(2026, 10, 10)),
            s.days.map { it.date },
        )
        assertEquals(DayState.READY, s.days[1].state) // the first one written wins
        assertEquals(DayState.SOLVED, WidgetTimeline.dayFor(s, LocalDate.of(2026, 10, 8)).state)
        assertEquals("T 2026-10-10", WidgetTimeline.dayFor(s, LocalDate.of(2026, 10, 10)).title)
    }

    @Test
    fun aMissingDateTakesTheLatestEarlierEntry() {
        val s = WidgetTimeline.decode(snapshotJson(dayJson("2026-10-08", "ready"), dayJson("2026-10-11", "paused")))!!
        assertEquals(LocalDate.of(2026, 10, 8), WidgetTimeline.dayFor(s, LocalDate.of(2026, 10, 10)).date)
        assertEquals(LocalDate.of(2026, 10, 11), WidgetTimeline.dayFor(s, LocalDate.of(2026, 10, 11)).date)
    }

    @Test
    fun unicodeEscapesDecodeLikeRawText() {
        val raw = WidgetTimeline.decode(snapshotJson(dayJson("2026-10-08", "ready", "Hoje é o dia 🪆")))!!
        val escaped = WidgetTimeline.decode(
            snapshotJson(dayJson("2026-10-08", "ready", "Hoje \\u00e9 o dia \\ud83e\\ude86")),
        )!!
        assertEquals(raw.days[0].line, escaped.days[0].line)
    }

    @Test
    fun parsesDollColours() {
        assertEquals(0xFF2F3E8F.toInt(), WidgetTimeline.parseColor("#2F3E8F"))
        assertEquals(0xFFA0673C.toInt(), WidgetTimeline.parseColor("#a0673c"))
        assertNull(WidgetTimeline.parseColor("2F3E8F"))
        assertNull(WidgetTimeline.parseColor("#2F3E8"))
        assertNull(WidgetTimeline.parseColor("#2F3E8FFF"))
        assertNull(WidgetTimeline.parseColor("#GGGGGG"))
        assertNull(WidgetTimeline.parseColor("#-12345"))
    }

    // ---- today and the next midnight -----------------------------------------

    private fun at(zone: String, local: String): Instant =
        LocalDateTime.parse(local).atZone(ZoneId.of(zone)).toInstant()

    @Test
    fun todayIsTheLocalDate() {
        val instant = Instant.parse("2026-10-08T23:30:00Z")
        assertEquals(LocalDate.of(2026, 10, 9), WidgetTimeline.today(instant.toEpochMilli(), ZoneId.of("Europe/Amsterdam")))
        assertEquals(LocalDate.of(2026, 10, 8), WidgetTimeline.today(instant.toEpochMilli(), ZoneId.of("America/Sao_Paulo")))
        assertEquals(LocalDate.of(2026, 10, 9), WidgetTimeline.today(instant.toEpochMilli(), ZoneId.of("Asia/Tokyo")))
    }

    @Test
    fun nextMidnightOnAnOrdinaryDay() {
        val zone = ZoneId.of("Europe/Amsterdam")
        val next = WidgetTimeline.nextMidnight(at("Europe/Amsterdam", "2026-10-08T15:20:00"), zone)
        assertEquals(ZonedDateTime.parse("2026-10-09T00:00+02:00[Europe/Amsterdam]").toInstant(), next)
        // Exactly at midnight, the next one is a day later.
        val atMidnight = at("Europe/Amsterdam", "2026-10-09T00:00:00")
        assertEquals(Duration.ofHours(24), Duration.between(atMidnight, WidgetTimeline.nextMidnight(atMidnight, zone)))
    }

    @Test
    fun amsterdamSpringForwardDayIs23Hours() {
        // 2026-03-29: 02:00 CET jumps to 03:00 CEST.
        val zone = ZoneId.of("Europe/Amsterdam")
        val before = WidgetTimeline.nextMidnight(at("Europe/Amsterdam", "2026-03-28T12:00:00"), zone)
        assertEquals(Instant.parse("2026-03-28T23:00:00Z"), before) // 00:00 +01:00
        val after = WidgetTimeline.nextMidnight(before.plusSeconds(5), zone)
        assertEquals(Instant.parse("2026-03-29T22:00:00Z"), after) // 00:00 +02:00
        assertEquals(Duration.ofHours(23), Duration.between(before, after))
    }

    @Test
    fun amsterdamFallBackDayIs25Hours() {
        // 2026-10-25: 03:00 CEST falls back to 02:00 CET.
        val zone = ZoneId.of("Europe/Amsterdam")
        val start = at("Europe/Amsterdam", "2026-10-25T00:00:05")
        val next = WidgetTimeline.nextMidnight(start, zone)
        assertEquals(Instant.parse("2026-10-25T23:00:00Z"), next) // 00:00 +01:00
        assertEquals(Duration.ofHours(25).minusSeconds(5), Duration.between(start, next))
        // Inside the repeated hour the date is still the 25th.
        val repeated = Instant.parse("2026-10-25T01:30:00Z") // 02:30 CET, the second time
        assertEquals(LocalDate.of(2026, 10, 25), WidgetTimeline.today(repeated.toEpochMilli(), zone))
    }

    @Test
    fun saoPauloSpringForwardSkipsMidnight() {
        // 2018-11-04: São Paulo's clocks went from 00:00 straight to 01:00
        // (its last DST start), so the day began at 01:00 -02:00.
        val zone = ZoneId.of("America/Sao_Paulo")
        val next = WidgetTimeline.nextMidnight(at("America/Sao_Paulo", "2018-11-03T18:00:00"), zone)
        assertEquals(ZonedDateTime.parse("2018-11-04T01:00-02:00[America/Sao_Paulo]").toInstant(), next)
        assertEquals(Instant.parse("2018-11-04T03:00:00Z"), next)
        // The alarm 5 s later is on the new date.
        val alarm = WidgetTimeline.alarmAtMillis(at("America/Sao_Paulo", "2018-11-03T18:00:00").toEpochMilli(), zone)
        assertEquals(LocalDate.of(2018, 11, 4), WidgetTimeline.today(alarm, zone))
        assertEquals(next.toEpochMilli() + 5_000L, alarm)
    }

    @Test
    fun saoPauloFallBackRepeatsTheEveningNotMidnight() {
        // 2019-02-17 00:00 -02:00 fell back to 2019-02-16 23:00 -03:00, so the
        // 16th was 25 hours long and the 17th began once, at 00:00 -03:00.
        val zone = ZoneId.of("America/Sao_Paulo")
        val noon = at("America/Sao_Paulo", "2019-02-16T12:00:00")
        val next = WidgetTimeline.nextMidnight(noon, zone)
        assertEquals(Instant.parse("2019-02-17T03:00:00Z"), next)
        val secondEleven = Instant.parse("2019-02-17T02:30:00Z") // 23:30 -03:00
        assertEquals(LocalDate.of(2019, 2, 16), WidgetTimeline.today(secondEleven.toEpochMilli(), zone))
        assertEquals(next, WidgetTimeline.nextMidnight(secondEleven, zone))
    }

    @Test
    fun theAlarmAlwaysLandsOnTheNextDate() {
        for (zoneId in listOf("Europe/Amsterdam", "America/Sao_Paulo", "Asia/Kolkata", "Pacific/Chatham", "UTC")) {
            val zone = ZoneId.of(zoneId)
            var now = Instant.parse("2018-10-01T10:00:00Z")
            repeat(400) {
                val today = WidgetTimeline.today(now.toEpochMilli(), zone)
                val alarm = WidgetTimeline.alarmAtMillis(now.toEpochMilli(), zone)
                assertEquals("$zoneId $now", today.plusDays(1), WidgetTimeline.today(alarm, zone))
                assertTrue(alarm > now.toEpochMilli())
                now = Instant.ofEpochMilli(alarm).plus(Duration.ofHours(7))
            }
        }
    }
}
