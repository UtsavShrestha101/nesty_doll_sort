/* Nesty SFX engine (GAME_SPEC §11.3). Procedural placeholder sounds built with Web Audio.
 * Every sound is a pure function (ctx, out, time, params) so it runs live (AudioContext)
 * or offline (OfflineAudioContext) to export WAV files with the spec's file names.
 * window.NestySfx.play('clack', { size: 4 }) · .schedule([[0,'whoosh'],[460,'clack',{size:4}]])
 * .renderWav('complete', { step: 3 }) -> Promise<Blob>
 */
(function () {
  const st = { ctx: null, out: null, muted: false, volume: 0.8 };
  const noiseBufs = new WeakMap();
  const semis = n => Math.pow(2, n / 12);
  function noiseBuf(ctx) {
    let b = noiseBufs.get(ctx);
    if (!b) { b = ctx.createBuffer(1, Math.floor(ctx.sampleRate * 1.2), ctx.sampleRate); const d = b.getChannelData(0); let s = 22222; for (let i = 0; i < d.length; i++) { s = (s * 1103515245 + 12345) & 0x7fffffff; d[i] = s / 0x3fffffff - 1; } noiseBufs.set(ctx, b); }
    return b;
  }
  function env(g, t, a, peak, d) { g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(Math.max(0.0002, peak), t + a); g.gain.exponentialRampToValueAtTime(0.0001, t + a + d); }
  function tone(ctx, out, t, { f, f2, type = 'sine', a = 0.004, d = 0.2, v = 0.5 }) {
    const o = ctx.createOscillator(), g = ctx.createGain(); o.type = type; o.frequency.setValueAtTime(f, t);
    if (f2) o.frequency.exponentialRampToValueAtTime(f2, t + a + d);
    env(g, t, a, v, d); o.connect(g); g.connect(out); o.start(t); o.stop(t + a + d + 0.05);
  }
  function noise(ctx, out, t, { type = 'bandpass', f = 2000, f2, q = 1, a = 0.002, d = 0.05, v = 0.5, off = 0 }) {
    const s = ctx.createBufferSource(), fl = ctx.createBiquadFilter(), g = ctx.createGain(); s.buffer = noiseBuf(ctx);
    fl.type = type; fl.frequency.setValueAtTime(f, t); if (f2) fl.frequency.exponentialRampToValueAtTime(f2, t + a + d); fl.Q.value = q;
    env(g, t, a, v, d); s.connect(fl); fl.connect(g); g.connect(out); s.start(t, off); s.stop(t + a + d + 0.05);
  }
  function bell(ctx, out, t, f, v = 0.3, d = 0.9) { [[1, 1], [2, 0.32], [3.01, 0.16], [4.2, 0.07]].forEach(([m, w]) => tone(ctx, out, t, { f: f * m, a: 0.003, d: d / (0.6 + m * 0.4), v: v * w })); }

  const CHIME = [1047, 1175, 1319, 1568, 1760]; // C6 D6 E6 G6 A6, one step per combo level (§11.1)
  const SFX = {
    pick: (c, o, t) => { noise(c, o, t, { f: 2600, q: 2.5, d: 0.035, v: 0.55 }); tone(c, o, t, { f: 1500, f2: 1100, a: 0.001, d: 0.05, v: 0.22 }); },
    clack: (c, o, t, p = {}) => {
      const k = semis(((p.size || 3) - 3.5) * -2), base = [520, 565, 488][((p.variant || 1) - 1) % 3] * k;
      tone(c, o, t, { f: base * 1.9, f2: base * 1.25, type: 'triangle', a: 0.001, d: 0.07, v: 0.42 });
      tone(c, o, t, { f: base, f2: base * 0.82, a: 0.001, d: 0.12, v: 0.4 });
      noise(c, o, t, { f: 1800 * k, q: 1.2, d: 0.028, v: 0.5, off: 0.1 * (p.variant || 1) });
      noise(c, o, t + 0.018, { f: 950 * k, q: 3, d: 0.05, v: 0.22, off: 0.4 });
    },
    whoosh: (c, o, t) => noise(c, o, t, { f: 450, f2: 2600, q: 0.8, a: 0.09, d: 0.17, v: 0.3, off: 0.2 }),
    bonk: (c, o, t) => { tone(c, o, t, { f: 210, f2: 118, a: 0.004, d: 0.16, v: 0.5 }); noise(c, o, t, { type: 'lowpass', f: 650, d: 0.05, v: 0.25 }); },
    complete: (c, o, t, p = {}) => { const f = CHIME[Math.max(1, Math.min(5, p.step || 1)) - 1]; bell(c, o, t, f, 0.3, 0.9); bell(c, o, t + 0.07, f * 1.5, 0.17, 0.7); },
    win: (c, o, t) => { [523, 659, 784, 1047].forEach((f, i) => bell(c, o, t + i * 0.11, f, 0.26, 1)); bell(c, o, t + 0.52, 1568, 0.2, 1.3); noise(c, o, t + 0.52, { type: 'highpass', f: 6000, a: 0.05, d: 0.6, v: 0.05 }); },
    coins: (c, o, t) => { for (let i = 0; i < 7; i++) bell(c, o, t + i * 0.06, i % 2 ? 2637 : 1976, 0.11, 0.25); },
    unlock_glass: (c, o, t) => { noise(c, o, t, { type: 'highpass', f: 3000, d: 0.12, v: 0.35 }); [3900, 5200, 4600, 6100, 4300].forEach((f, i) => tone(c, o, t + 0.02 + i * 0.045, { f, a: 0.001, d: 0.25, v: 0.11 })); },
    ice_crack: (c, o, t) => { [0, 0.05, 0.11].forEach((dt, i) => noise(c, o, t + dt, { f: [2400, 3400, 1800][i], q: 4, d: 0.03, v: 0.42, off: i * 0.2 })); tone(c, o, t, { f: 900, f2: 500, a: 0.001, d: 0.05, v: 0.12 }); },
    ice_shatter: (c, o, t) => { noise(c, o, t, { type: 'highpass', f: 1500, a: 0.003, d: 0.3, v: 0.42 }); [2800, 3600, 4400, 3100, 5000, 3900].forEach((f, i) => tone(c, o, t + 0.03 + i * 0.05, { f, a: 0.001, d: 0.2, v: 0.08 })); },
    button: (c, o, t) => { tone(c, o, t, { f: 620, f2: 900, a: 0.002, d: 0.06, v: 0.3 }); noise(c, o, t, { f: 3000, q: 2, d: 0.012, v: 0.15 }); },
  };
  /* Spec file list → generator + params + export length (s) */
  const FILES = [
    ['pick', 'pick', {}, 0.15, 'Nest picked up', 'light'],
    ['clack_1', 'clack', { variant: 1 }, 0.25, 'Lid snaps shut (pitched by size)', 'medium'],
    ['clack_2', 'clack', { variant: 2 }, 0.25, 'Lid snaps shut (pitched by size)', 'medium'],
    ['clack_3', 'clack', { variant: 3 }, 0.25, 'Lid snaps shut (pitched by size)', 'medium'],
    ['whoosh', 'whoosh', {}, 0.35, 'Nest moves between slots', null],
    ['bonk', 'bonk', {}, 0.3, 'Invalid drop', 'error'],
    ['complete_1', 'complete', { step: 1 }, 1.1, 'Family completes (combo step 1)', 'success'],
    ['complete_2', 'complete', { step: 2 }, 1.1, 'Combo step 2 (within 4 s)', 'success'],
    ['complete_3', 'complete', { step: 3 }, 1.1, 'Combo step 3', 'success'],
    ['complete_4', 'complete', { step: 4 }, 1.1, 'Combo step 4', 'success'],
    ['complete_5', 'complete', { step: 5 }, 1.1, 'Combo step 5 (max)', 'success'],
    ['win', 'win', {}, 2.0, 'Level complete', 'success'],
    ['coins', 'coins', {}, 0.8, 'Coins count up', null],
    ['unlock_glass', 'unlock_glass', {}, 0.6, 'Glass case shatters', 'medium'],
    ['ice_crack', 'ice_crack', {}, 0.35, 'Ice counter drops', 'light'],
    ['ice_shatter', 'ice_shatter', {}, 0.7, 'Ice reaches 0', 'medium'],
    ['button', 'button', {}, 0.15, 'Any UI button', 'selection'],
  ].map(([file, fn, params, len, event, haptic]) => ({ file, fn, params, len, event, haptic }));

  function ensure() {
    if (!st.ctx) { const C = window.AudioContext || window.webkitAudioContext; st.ctx = new C(); st.out = st.ctx.createGain(); st.out.gain.value = st.volume; st.out.connect(st.ctx.destination); }
    if (st.ctx.state === 'suspended') st.ctx.resume();
    return st.ctx;
  }
  const fnOf = name => SFX[name] || (FILES.find(f => f.file === name) && ((c, o, t, p) => { const f = FILES.find(x => x.file === name); SFX[f.fn](c, o, t, { ...f.params, ...p }); }));
  function play(name, params = {}, delayMs = 0) { if (st.muted) return; const ctx = ensure(), fn = fnOf(name); if (fn) fn(ctx, st.out, ctx.currentTime + 0.01 + delayMs / 1000, params); }
  function schedule(cues) { cues.forEach(([ms, name, p]) => play(name, p || {}, ms)); }
  function wav(buf) {
    const ch = buf.getChannelData(0), n = ch.length, dv = new DataView(new ArrayBuffer(44 + n * 2)), w = (o, s) => [...s].forEach((c, i) => dv.setUint8(o + i, c.charCodeAt(0)));
    w(0, 'RIFF'); dv.setUint32(4, 36 + n * 2, true); w(8, 'WAVE'); w(12, 'fmt '); dv.setUint32(16, 16, true); dv.setUint16(20, 1, true); dv.setUint16(22, 1, true);
    dv.setUint32(24, buf.sampleRate, true); dv.setUint32(28, buf.sampleRate * 2, true); dv.setUint16(32, 2, true); dv.setUint16(34, 16, true); w(36, 'data'); dv.setUint32(40, n * 2, true);
    let peak = 0; for (let i = 0; i < n; i++) peak = Math.max(peak, Math.abs(ch[i]));
    const k = peak > 0.95 ? 0.95 / peak : 1;
    for (let i = 0; i < n; i++) dv.setInt16(44 + i * 2, Math.max(-1, Math.min(1, ch[i] * k)) * 0x7fff, true);
    return new Blob([dv.buffer], { type: 'audio/wav' });
  }
  async function renderWav(name, params = {}, seconds) {
    const f = FILES.find(x => x.file === name), fn = fnOf(name), len = seconds || (f ? f.len : 1), sr = 44100;
    const oc = new OfflineAudioContext(1, Math.ceil(sr * len), sr), out = oc.createGain(); out.gain.value = 0.9; out.connect(oc.destination);
    fn(oc, out, 0.003, params);
    return wav(await oc.startRendering());
  }
  window.NestySfx = { play, schedule, renderWav, FILES, CHIME, clackRate: size => semis((size - 3.5) * -2), setMuted: m => { st.muted = !!m; }, isMuted: () => st.muted, setVolume: v => { st.volume = v; if (st.out) st.out.gain.value = v; } };
})();
