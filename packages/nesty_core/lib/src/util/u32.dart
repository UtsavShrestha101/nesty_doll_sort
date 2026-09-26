/// Web-safe unsigned 32-bit arithmetic for the PRNG, the hashes and the
/// solver's packed state (docs/plans/m1-core-design.md §3, PROGRESS Q9).
///
/// On the VM an `int` is 64 bits, but in dart2js it is a JS number: exact only
/// up to 2^53, with bitwise operators that work on 32 bits. A plain
/// `a * b & 0xFFFFFFFF` therefore gives different answers on the two
/// platforms once `a * b` passes 2^53, which would make the daily puzzle
/// (spec §7.5) differ between the web admin and a phone. Every helper here
/// keeps each intermediate value below 2^53 and masks after every operation
/// that can leave 32 bits, so the VM, dart2js and wasm agree bit for bit.
///
/// Inputs may be any `int` whose low 32 bits are the operand: a value in
/// [0, 2^32), or a signed value read back from an `Int32List`. Outputs are
/// always in [0, 2^32). Never use `~x` (it is negative on the VM and positive
/// on the web): use [not32]. Shift amounts must be in 0..31, because JS masks
/// shift counts to 5 bits.
///
/// Internal to nesty_core (not exported by the barrel).
library;

/// The 32 low bits: `x & u32Mask` is `x` as an unsigned 32-bit value.
const int u32Mask = 0xFFFFFFFF;

/// [x] reduced to its low 32 bits, as a value in [0, 2^32).
int toU32(int x) => x & u32Mask;

/// `(a + b) mod 2^32`. The sum of two 32-bit values is below 2^33, so it is
/// exact on the web before the mask.
int add32(int a, int b) => ((a & u32Mask) + (b & u32Mask)) & u32Mask;

/// `(a - b) mod 2^32`.
int sub32(int a, int b) => ((a & u32Mask) - (b & u32Mask)) & u32Mask;

/// `(a * b) mod 2^32`, the only safe way to multiply two 32-bit values.
///
/// A full 32×32 product needs 64 bits, which a JS number can't hold. Splitting
/// each operand into 16-bit halves keeps every partial product below 2^32:
/// `a·b mod 2^32 = al·bl + ((ah·bl + al·bh) mod 2^16)·2^16`, and the `ah·bh`
/// term only affects bits 32 and up, so it is dropped.
int mul32(int a, int b) {
  final al = a & 0xFFFF;
  final ah = (a >>> 16) & 0xFFFF;
  final bl = b & 0xFFFF;
  final bh = (b >>> 16) & 0xFFFF;
  // Multiply rather than shift left by 16: the product is below 2^32 and
  // exact on both platforms, with no sign-bit surprises from JS `<<`.
  final cross = ((ah * bl + al * bh) & 0xFFFF) * 0x10000;
  return (al * bl + cross) & u32Mask;
}

/// `x << n` truncated to 32 bits. [n] must be in 0..31.
int shl32(int x, int n) {
  assert(n >= 0 && n < 32, 'shift must be 0..31, was $n');
  return (x << n) & u32Mask;
}

/// Rotates the 32-bit value [x] left by [r] bits. [r] may be any value; it is
/// taken mod 32.
int rotl32(int x, int r) {
  final v = x & u32Mask;
  final n = r & 31;
  // `v >>> 32` is 0 on the VM but `v` on the web (JS masks the count to 0),
  // so a zero rotation must not take the general path.
  if (n == 0) return v;
  return ((v << n) & u32Mask) | (v >>> (32 - n));
}

/// Bitwise NOT within 32 bits. Use it instead of `~`, whose result differs
/// between the VM and the web.
int not32(int x) => (x & u32Mask) ^ u32Mask;

/// The MurmurHash3 32-bit finalizer ("fmix32"): a bijective avalanche mix,
/// used to spread seeds and hash halves (docs/plans/m1-core-design.md §1).
int fmix32(int h) {
  var v = h & u32Mask;
  v ^= v >>> 16;
  v = mul32(v, 0x85EBCA6B);
  v ^= v >>> 13;
  v = mul32(v, 0xC2B2AE35);
  v ^= v >>> 16;
  return v;
}
