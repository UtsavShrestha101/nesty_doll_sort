package com.futrix.nesty.widget

import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

/**
 * The widget's pure logic (local habits stage 4; plan-local-habits §4 "Pure
 * logic"): the snapshot decode, today's entry and the next local midnight.
 *
 * No Android types, so the JVM tests (`src/test/`) run it as the phone does.
 * No streak rule lives here (CLAUDE.md hard rule 2's spirit): the app projects
 * every state into the snapshot (`DailyService.projection`), and this file only
 * looks a date up in it. java.time works on API 24–25 through the core-library
 * desugaring that app/build.gradle.kts already turns on.
 */
object WidgetTimeline {
    /** The snapshot schema this build reads (contract §3). */
    const val SCHEMA_VERSION = 1L

    /**
     * The alarm fires this long after midnight, so a clock that is a little
     * early still lands on the new day (plan §4 "Midnight").
     */
    const val MIDNIGHT_SLACK_MILLIS = 5_000L

    /**
     * Decodes the stored JSON. Null (draw the first-run state, contract §3)
     * when nothing is stored, the JSON is malformed, a field has the wrong
     * type, or `v` is not [SCHEMA_VERSION] (a newer app wrote it).
     */
    fun decode(json: String?): WidgetSnapshot? {
        if (json.isNullOrBlank()) return null
        // Every failure (WidgetJsonException, SnapshotException, a
        // DateTimeParseException, anything unforeseen) is the first-run state:
        // a widget never crashes the app's process (rule 3).
        return try {
            decodeOrThrow(WidgetJson.parse(json))
        } catch (_: Exception) {
            null
        }
    }

    /** What the widget draws for [today] (the device's local date). */
    fun content(snapshot: WidgetSnapshot?, today: LocalDate): WidgetContent = when {
        snapshot == null -> WidgetContent.FirstRun
        !snapshot.unlocked -> WidgetContent.Locked(snapshot.locked)
        else -> WidgetContent.Day(dayFor(snapshot, today))
    }

    /**
     * Today's entry (contract §3): the entry dated [today]; before the first
     * entry, the first; past the last, [pastTheLast]. A date missing between
     * two entries (never written by the app) takes the latest earlier entry.
     */
    fun dayFor(snapshot: WidgetSnapshot, today: LocalDate): WidgetDay {
        val days = snapshot.days
        val first = days.first()
        val last = days.last()
        return when {
            today.isBefore(first.date) -> first
            today.isAfter(last.date) -> pastTheLast(snapshot)
            else -> days.last { !it.date.isAfter(today) }
        }
    }

    /**
     * Past the last entry (the phone left unopened for more than a week;
     * contract §3, design spec gap 18): the last entry with the generic
     * title and no sub or dolls. Its state is kept (a resting streak stays
     * resting, as iOS draws it; lead ruling, D312): only a solved last entry
     * turns ready, since the new day isn't solved, and it takes the ready
     * line and screen reader text of the latest unsolved entry, when there
     * is one (the app never writes one: days after today are projected with
     * no solve).
     */
    fun pastTheLast(snapshot: WidgetSnapshot): WidgetDay {
        val last = snapshot.days.last()
        val wording = if (last.state == DayState.SOLVED) {
            snapshot.days.lastOrNull { it.state != DayState.SOLVED } ?: last
        } else {
            last
        }
        return last.copy(
            state = if (last.state == DayState.SOLVED) DayState.READY else last.state,
            title = snapshot.locked.title,
            sub = null,
            dolls = emptyList(),
            line = wording.line,
            lineShort = wording.lineShort,
            a11y = wording.a11y,
        )
    }

    /** The local date at [nowMillis] in [zone]. */
    fun today(nowMillis: Long, zone: ZoneId): LocalDate =
        Instant.ofEpochMilli(nowMillis).atZone(zone).toLocalDate()

    /**
     * The next local midnight after [now] in [zone]. `atStartOfDay` takes a
     * DST gap at midnight into account (São Paulo's old spring-forward began
     * the day at 01:00), and a 23- or 25-hour day comes out right because the
     * date, not a fixed 24 hours, moves on.
     */
    fun nextMidnight(now: Instant, zone: ZoneId): Instant =
        now.atZone(zone).toLocalDate().plusDays(1).atStartOfDay(zone).toInstant()

    /** When the inexact midnight alarm should fire: the next midnight + 5 s. */
    fun alarmAtMillis(nowMillis: Long, zone: ZoneId): Long =
        nextMidnight(Instant.ofEpochMilli(nowMillis), zone).toEpochMilli() + MIDNIGHT_SLACK_MILLIS

    /** `#RRGGBB` (the app writes `DollColor.base` upper case) as opaque ARGB. */
    fun parseColor(hex: String): Int? {
        if (hex.length != 7 || hex[0] != '#') return null
        val digits = hex.substring(1)
        if (!digits.all { it in '0'..'9' || it in 'a'..'f' || it in 'A'..'F' }) return null
        return (0xFF000000L or digits.toLong(16)).toInt()
    }

    private class SnapshotException(message: String) : Exception(message)

    private fun decodeOrThrow(root: Any?): WidgetSnapshot {
        val top = root.asObject("snapshot")
        val v = top.integer("v")
        if (v != SCHEMA_VERSION) throw SnapshotException("schema v$v")
        val lockedJson = top["locked"].asObject("locked")
        val locked = WidgetLocked(
            title = lockedJson.text("title"),
            small = lockedJson.text("small"),
            medium = lockedJson.text("medium"),
            a11y = lockedJson.text("a11y"),
        )
        val daysJson = top["days"] as? List<*> ?: throw SnapshotException("days")
        val days = daysJson.map { decodeDay(it.asObject("day")) }
            .sortedBy { it.date }
            .distinctBy { it.date }
        if (days.isEmpty()) throw SnapshotException("no days")
        return WidgetSnapshot(
            scheme = top.optionalText("scheme"),
            lang = top.optionalText("lang"),
            unlocked = top["unlocked"] as? Boolean ?: throw SnapshotException("unlocked"),
            locked = locked,
            days = days,
        )
    }

    private fun decodeDay(day: Map<*, *>): WidgetDay {
        val streak = day.integer("streak")
        if (streak < 0 || streak > Int.MAX_VALUE) throw SnapshotException("streak")
        val dolls = day["dolls"] as? List<*> ?: throw SnapshotException("dolls")
        return WidgetDay(
            date = LocalDate.parse(day.text("date")),
            state = DayState.fromJson(day.text("state")) ?: throw SnapshotException("state"),
            streak = streak.toInt(),
            number = day.optionalText("number"),
            label = day.text("label"),
            labelShort = day.optionalText("labelShort"),
            title = day.text("title"),
            sub = day.optionalText("sub"),
            // A colour this build can't read is skipped, not fatal: the dolls
            // are decoration, and the rest of the day still draws.
            dolls = dolls.mapNotNull { (it as? String)?.let(::parseColor) },
            line = day.text("line"),
            lineShort = day.optionalText("lineShort"),
            a11y = day.text("a11y"),
        )
    }

    private fun Any?.asObject(what: String): Map<*, *> =
        this as? Map<*, *> ?: throw SnapshotException("$what is not an object")

    private fun Map<*, *>.text(key: String): String =
        this[key] as? String ?: throw SnapshotException("$key is not a string")

    /** Absent and JSON null both read as null; any other non-string throws. */
    private fun Map<*, *>.optionalText(key: String): String? = when (val value = this[key]) {
        null -> null
        is String -> value
        else -> throw SnapshotException("$key is not a string")
    }

    private fun Map<*, *>.integer(key: String): Long = when (val value = this[key]) {
        is Long -> value
        is Double -> if (value % 1.0 == 0.0 && value >= Long.MIN_VALUE && value <= Long.MAX_VALUE) {
            value.toLong()
        } else {
            throw SnapshotException("$key is not an integer")
        }
        else -> throw SnapshotException("$key is not an integer")
    }
}

/** The snapshot, JSON v1 (contract §3), as this build reads it. */
data class WidgetSnapshot(
    val scheme: String?,
    /** The rendered language; Android draws every language in the system sans. */
    val lang: String?,
    val unlocked: Boolean,
    val locked: WidgetLocked,
    /** Oldest first, one per date, never empty. */
    val days: List<WidgetDay>,
)

/** The locked strings (`{level}` already filled), used while the Daily is locked. */
data class WidgetLocked(
    val title: String,
    val small: String,
    val medium: String,
    val a11y: String,
)

/** One date's entry, every string already localized by the app. */
data class WidgetDay(
    val date: LocalDate,
    val state: DayState,
    val streak: Int,
    /** Null for [DayState.ZERO]: no number is drawn. */
    val number: String?,
    val label: String,
    /** Set for [DayState.PAUSED] only (`widgetStreakRestingShort`). */
    val labelShort: String?,
    val title: String,
    val sub: String?,
    /** Opaque ARGB, puzzle order; empty hides the dolls row. */
    val dolls: List<Int>,
    val line: String,
    val lineShort: String?,
    val a11y: String,
)

/** A day's state, from `DailyService.projection` (never derived here). */
enum class DayState(val json: String) {
    READY("ready"),
    SOLVED("solved"),
    PAUSED("paused"),
    ZERO("zero"),
    ;

    companion object {
        fun fromJson(value: String): DayState? = entries.firstOrNull { it.json == value }
    }
}

/** What one render draws. */
sealed interface WidgetContent {
    /**
     * Nothing stored yet, or a snapshot this build can't read: the locked look
     * with the native strings (design spec §2.6).
     */
    data object FirstRun : WidgetContent

    /** The Daily is still locked (before Level 2). */
    data class Locked(val locked: WidgetLocked) : WidgetContent

    /** Today's (or the fallback) entry. */
    data class Day(val day: WidgetDay) : WidgetContent
}
