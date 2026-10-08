package com.futrix.nesty.widget

/**
 * A small, strict JSON reader for the widget's snapshot (local habits stage 4,
 * contract §3).
 *
 * Why not `org.json`: it is part of the Android platform, so on the JVM test
 * classpath it is only a stub, and the Maven artifact that would replace it is
 * a different implementation from Android's fork. A reader of our own keeps
 * [WidgetTimeline] pure Kotlin and runs the very same code in the JVM tests and
 * on the phone, with no extra dependency (CLAUDE.md rule 9).
 *
 * It yields `Map<String, Any?>`, `List<Any?>`, `String`, `Long` (integers that
 * fit), `Double`, `Boolean` and `null`. Anything that isn't RFC 8259 JSON
 * throws [WidgetJsonException].
 */
internal object WidgetJson {
    /** Deeper than the snapshot ever nests; guards the recursion. */
    private const val MAX_DEPTH = 32

    fun parse(text: String): Any? {
        val reader = Reader(text)
        reader.skipWhitespace()
        val value = reader.value(0)
        reader.skipWhitespace()
        if (!reader.atEnd()) reader.fail("trailing characters")
        return value
    }

    private class Reader(private val s: String) {
        private var i = 0

        fun atEnd() = i >= s.length

        fun fail(message: String): Nothing = throw WidgetJsonException("$message at $i")

        fun skipWhitespace() {
            while (i < s.length) {
                when (s[i]) {
                    ' ', '\t', '\n', '\r' -> i++
                    else -> return
                }
            }
        }

        fun value(depth: Int): Any? {
            if (depth > MAX_DEPTH) fail("nested too deep")
            if (atEnd()) fail("unexpected end")
            return when (val c = s[i]) {
                '{' -> obj(depth)
                '[' -> array(depth)
                '"' -> string()
                't' -> literal("true", true)
                'f' -> literal("false", false)
                'n' -> literal("null", null)
                else -> if (c == '-' || c in '0'..'9') number() else fail("unexpected '$c'")
            }
        }

        private fun literal(word: String, result: Any?): Any? {
            if (!s.startsWith(word, i)) fail("bad literal")
            i += word.length
            return result
        }

        private fun obj(depth: Int): Map<String, Any?> {
            i++ // {
            val out = LinkedHashMap<String, Any?>()
            skipWhitespace()
            if (!atEnd() && s[i] == '}') {
                i++
                return out
            }
            while (true) {
                skipWhitespace()
                if (atEnd() || s[i] != '"') fail("expected a key")
                val key = string()
                skipWhitespace()
                if (atEnd() || s[i] != ':') fail("expected ':'")
                i++
                skipWhitespace()
                out[key] = value(depth + 1)
                skipWhitespace()
                if (atEnd()) fail("unterminated object")
                when (s[i]) {
                    ',' -> i++
                    '}' -> {
                        i++
                        return out
                    }
                    else -> fail("expected ',' or '}'")
                }
            }
        }

        private fun array(depth: Int): List<Any?> {
            i++ // [
            val out = ArrayList<Any?>()
            skipWhitespace()
            if (!atEnd() && s[i] == ']') {
                i++
                return out
            }
            while (true) {
                skipWhitespace()
                out.add(value(depth + 1))
                skipWhitespace()
                if (atEnd()) fail("unterminated array")
                when (s[i]) {
                    ',' -> i++
                    ']' -> {
                        i++
                        return out
                    }
                    else -> fail("expected ',' or ']'")
                }
            }
        }

        private fun string(): String {
            i++ // opening quote
            val out = StringBuilder()
            while (true) {
                if (atEnd()) fail("unterminated string")
                val c = s[i++]
                when {
                    c == '"' -> return out.toString()
                    c == '\\' -> {
                        if (atEnd()) fail("unterminated escape")
                        when (val e = s[i++]) {
                            '"' -> out.append('"')
                            '\\' -> out.append('\\')
                            '/' -> out.append('/')
                            'b' -> out.append('\b')
                            'f' -> out.append('\u000C')
                            'n' -> out.append('\n')
                            'r' -> out.append('\r')
                            't' -> out.append('\t')
                            'u' -> {
                                if (i + 4 > s.length) fail("short \\u escape")
                                val hex = s.substring(i, i + 4)
                                // toIntOrNull alone would take a sign ("-001").
                                if (!hex.all { it in '0'..'9' || it in 'a'..'f' || it in 'A'..'F' }) {
                                    fail("bad \\u escape")
                                }
                                val code = hex.toInt(16)
                                // Surrogate pairs arrive as two escapes; appending
                                // both halves rebuilds the UTF-16 pair.
                                out.append(code.toChar())
                                i += 4
                            }
                            else -> fail("bad escape '\\$e'")
                        }
                    }
                    c < ' ' -> fail("control character in a string")
                    else -> out.append(c)
                }
            }
        }

        private fun number(): Any {
            val start = i
            if (s[i] == '-') i++
            if (atEnd()) fail("bad number")
            if (s[i] == '0') {
                i++
            } else if (s[i] in '1'..'9') {
                while (!atEnd() && s[i] in '0'..'9') i++
            } else {
                fail("bad number")
            }
            var integral = true
            if (!atEnd() && s[i] == '.') {
                integral = false
                i++
                if (atEnd() || s[i] !in '0'..'9') fail("bad fraction")
                while (!atEnd() && s[i] in '0'..'9') i++
            }
            if (!atEnd() && (s[i] == 'e' || s[i] == 'E')) {
                integral = false
                i++
                if (!atEnd() && (s[i] == '+' || s[i] == '-')) i++
                if (atEnd() || s[i] !in '0'..'9') fail("bad exponent")
                while (!atEnd() && s[i] in '0'..'9') i++
            }
            val text = s.substring(start, i)
            return if (integral) text.toLongOrNull() ?: text.toDouble() else text.toDouble()
        }
    }
}

internal class WidgetJsonException(message: String) : Exception(message)
