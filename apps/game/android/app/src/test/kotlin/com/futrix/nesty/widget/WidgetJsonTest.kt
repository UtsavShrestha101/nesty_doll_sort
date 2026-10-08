package com.futrix.nesty.widget

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Assert.fail
import org.junit.Test

/** The widget's own JSON reader: what it accepts, and that it refuses the rest. */
class WidgetJsonTest {
    @Test
    fun readsEveryKindOfValue() {
        val value = WidgetJson.parse(
            """ { "s": "a\"b\\c\/d\n\t\u00e9", "i": -12, "big": 12345678901234567890, "d": 1.5e2,
                "t": true, "f": false, "n": null, "a": [1, [], {}], "o": {"k": "v"} } """,
        )
        val map = value as Map<*, *>
        assertEquals("a\"b\\c/d\n\t\u00E9", map["s"])
        assertEquals(-12L, map["i"])
        assertEquals(1.2345678901234567E19, map["big"])
        assertEquals(150.0, map["d"])
        assertEquals(true, map["t"])
        assertEquals(false, map["f"])
        assertNull(map["n"])
        assertEquals(listOf(1L, emptyList<Any?>(), emptyMap<String, Any?>()), map["a"])
        assertEquals(mapOf("k" to "v"), map["o"])
    }

    @Test
    fun rebuildsSurrogatePairs() {
        assertEquals("\uD83E\uDE86", WidgetJson.parse("\"\\ud83e\\ude86\""))
        assertEquals("\uD83E\uDE86", WidgetJson.parse("\"\uD83E\uDE86\""))
    }

    @Test
    fun refusesWhatIsNotJson() {
        val bad = listOf(
            "", " ", "{", "}", "[1,]", "{\"a\":1,}", "{a:1}", "{'a':1}", "01", "1.", ".5", "-", "1e",
            "tru", "nul", "\"open", "\"bad \\x escape\"", "\"\\u12\"", "\"\\u-123\"", "\"tab\there\"",
            "[1] [2]", "{\"a\" 1}", "[" .repeat(40) + "]".repeat(40),
        )
        for (text in bad) {
            try {
                WidgetJson.parse(text)
                fail("accepted: $text")
            } catch (_: WidgetJsonException) {
                // expected
            }
        }
    }
}
