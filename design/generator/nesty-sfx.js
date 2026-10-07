/* Nesty SFX engine v2 (GAME_SPEC §11.3). Procedural wooden-toy sounds built with Web Audio, voiced to sit with nesty-music.js:
 * wood partials for lids, picks and buttons, marimba + music box for the combo chimes and the win, metal and glass partials
 * for coins, glass and ice, and a small wooden room on everything.
 * Every sound is a pure function (ctx, out, time, params) so it runs live (AudioContext) or offline (OfflineAudioContext)
 * to export WAV files with the spec's file names. clack_1…3 are baked at size 3.5 (0 semitones); pitch per size at runtime.
 * window.NestySfx.play('clack', { size: 4 }) · .schedule([[0,'whoosh'],[460,'clack',{size:4}]]) · .renderWav('complete', { step: 3 }) -> Promise<Blob>
 * v1 (plain sine/noise placeholders) is kept in scratch/audio-v1/.
 */
(function () {
  const st = { ctx: null, out: null, muted: false, volume: 0.8 };
  const res = new WeakMap(), buses = new WeakMap();
  const semis = n => Math.pow(2, n / 12);
  const rng = seed => { let s = (seed >>> 0) || 1; return () => (s = (Math.imul(s, 1664525) + 1013904223) >>> 0) / 4294967296; };
  function R(ctx) {
    let r = res.get(ctx); if (r) return r;
    const sr = ctx.sampleRate, nb = ctx.createBuffer(1, Math.floor(sr * 1.2), sr), nd = nb.getChannelData(0), a = rng(22222);
    for (let i = 0; i < nd.length; i++) nd[i] = a() * 2 - 1;
    const ir = ctx.createBuffer(1, Math.floor(sr * 0.4), sr), id = ir.getChannelData(0), b = rng(777); let lp = 0;
    for (let i = Math.floor(sr * 0.006); i < id.length; i++) { lp += 0.45 * (b() * 2 - 1 - lp); id[i] = lp * Math.pow(1 - i / id.length, 3); }
    r = { noise: nb, ir }; res.set(ctx, r); return r;
  }
  function bus(ctx, out) { // dry + a small wooden room
    let b = buses.get(out); if (b) return b;
    b = ctx.createGain(); const cv = ctx.createConvolver(), w = ctx.createGain(); cv.buffer = R(ctx).ir; w.gain.value = 0.14;
    b.connect(out); b.connect(cv); cv.connect(w); w.connect(out); buses.set(out, b); return b;
  }
  function partials(c, o, t, f, list, v, att = 0.001, glide) {
    list.forEach(([k, a, tc]) => {
      const fr = f * k; if (fr > 18000) return;
      const x = c.createOscillator(), g = c.createGain(); x.frequency.setValueAtTime(fr, t);
      if (glide) x.frequency.exponentialRampToValueAtTime(fr * glide, t + att + tc * 4);
      g.gain.setValueAtTime(0, t); g.gain.linearRampToValueAtTime(v * a, t + att); g.gain.setTargetAtTime(0, t + att, tc);
      x.connect(g); g.connect(o); x.start(t); x.stop(t + att + tc * 8);
    });
  }
  function noise(c, o, t, { type = 'bandpass', f = 2000, f2, q = 1, a = 0.002, d = 0.05, v = 0.5, off = 0 }) {
    const s = c.createBufferSource(), fl = c.createBiquadFilter(), g = c.createGain(); s.buffer = R(c).noise;
    fl.type = type; fl.frequency.setValueAtTime(f, t); if (f2) fl.frequency.exponentialRampToValueAtTime(f2, t + a + d); fl.Q.value = q;
    g.gain.setValueAtTime(0.0001, t); g.gain.exponentialRampToValueAtTime(Math.max(0.0002, v), t + a); g.gain.exponentialRampToValueAtTime(0.0001, t + a + d);
    s.connect(fl); fl.connect(g); g.connect(o); s.start(t, off); s.stop(t + a + d + 0.05);
  }
  const WOOD = [[1, 1, 0.032], [2.76, 0.5, 0.018], [5.4, 0.25, 0.01], [8.93, 0.1, 0.006]]; // free wooden bar modes
  const wood = (c, o, t, f, v, k = 1) => partials(c, o, t, f, WOOD.map(([m, a, tc]) => [m, a, tc * k]), v);
  const MARIMBA = f => [[1, 1, Math.min(0.4, 0.2 * Math.sqrt(440 / f))], [3.99, 0.26, 0.05], [9.9, 0.06, 0.02]];
  const BOX = [[1, 1, 0.22], [2, 0.14, 0.12], [3, 0.05, 0.07], [6.27, 0.18, 0.03]]; // music-box tine
  const METAL = [[1, 1, 0.07], [2.32, 0.45, 0.04], [3.86, 0.2, 0.02]];

  const CHIME = [1047, 1175, 1319, 1568, 1760]; // C6 D6 E6 G6 A6, one step per combo level (§11.1)
  const SFX = {
    pick: (c, o, t) => { wood(c, o, t, 1500, 0.34, 0.8); noise(c, o, t + 0.008, { f: 1400, f2: 3800, q: 1.4, a: 0.02, d: 0.07, v: 0.14 }); partials(c, o, t + 0.01, 820, [[1, 1, 0.025]], 0.12, 0.004, 1.5); },
    clack: (c, o, t, p = {}) => { // lid touches, then seats: two wooden hits + the hollow body
      const k = semis(((p.size ?? 3.5) - 3.5) * -2), vi = ((p.variant || 1) - 1) % 3, f = [455, 490, 430][vi] * k, t2 = t + 0.014 + vi * 0.003;
      wood(c, o, t, f * 1.34, 0.2, 0.6); noise(c, o, t, { f: 3200 * k, q: 1.6, d: 0.01, v: 0.22, off: 0.05 + vi * 0.1 });
      wood(c, o, t2, f, 0.62, 1 + vi * 0.1); partials(c, o, t2, f * 0.52, [[1, 1, 0.035]], 0.3);
      noise(c, o, t2, { f: 2100 * k, q: 1.1, d: 0.02, v: 0.45, off: 0.3 + vi * 0.1 }); noise(c, o, t2 + 0.004, { type: 'lowpass', f: 700 * k, d: 0.04, v: 0.2, off: 0.6 });
    },
    whoosh: (c, o, t) => { noise(c, o, t, { f: 420, f2: 2200, q: 0.9, a: 0.1, d: 0.18, v: 0.26, off: 0.2 }); noise(c, o, t + 0.02, { type: 'lowpass', f: 600, f2: 1400, a: 0.08, d: 0.16, v: 0.12, off: 0.5 }); },
    bonk: (c, o, t) => { partials(c, o, t, 196, [[1, 1, 0.07], [2.76, 0.35, 0.03]], 0.55, 0.003, 0.8); noise(c, o, t, { type: 'lowpass', f: 500, d: 0.05, v: 0.3 }); partials(c, o, t + 0.085, 175, [[1, 1, 0.06], [2.76, 0.3, 0.025]], 0.32, 0.003, 0.8); },
    complete: (c, o, t, p = {}) => { const f = CHIME[Math.max(1, Math.min(5, p.step || 1)) - 1]; partials(c, o, t, f / 2, MARIMBA(f / 2), 0.4, 0.002); partials(c, o, t, f, BOX, 0.3); partials(c, o, t + 0.07, f * 1.5, BOX, 0.16); noise(c, o, t + 0.05, { type: 'highpass', f: 7000, a: 0.04, d: 0.3, v: 0.035 }); },
    win: (c, o, t) => {
      [523.25, 659.25, 783.99, 1046.5].forEach((f, i) => partials(c, o, t + i * 0.09, f, MARIMBA(f), 0.36, 0.002));
      partials(c, o, t + 0.4, 261.63, MARIMBA(261.63), 0.3, 0.002); [1046.5, 1318.5, 1568].forEach(f => partials(c, o, t + 0.4, f, BOX, 0.16));
      partials(c, o, t + 0.56, 2093, BOX, 0.12); noise(c, o, t + 0.45, { type: 'highpass', f: 6500, a: 0.08, d: 0.7, v: 0.05 });
    },
    coins: (c, o, t) => { const r = rng(5); for (let i = 0; i < 7; i++) partials(c, o, t + i * 0.06 + r() * 0.01, (i % 2 ? 2637 : 1976) * semis((r() - 0.5) * 0.4), METAL, 0.1 + i * 0.012); },
    unlock_glass: (c, o, t) => { partials(c, o, t, 2150, [[1, 1, 0.06], [2.71, 0.4, 0.03]], 0.22); noise(c, o, t + 0.04, { type: 'highpass', f: 2800, d: 0.11, v: 0.34 }); const r = rng(9); for (let i = 0; i < 9; i++) partials(c, o, t + 0.05 + r() * 0.36, 3000 + r() * 4200, [[1, 1, 0.03 + r() * 0.03], [2.4, 0.3, 0.015]], 0.1 * (1 - i / 11)); },
    ice_crack: (c, o, t) => { [0, 0.035, 0.08, 0.13].forEach((dt, i) => noise(c, o, t + dt, { f: [2600, 3800, 2000, 3200][i], q: 5, d: 0.022, v: 0.42 - i * 0.06, off: i * 0.21 })); partials(c, o, t, 760, [[1, 1, 0.03]], 0.1, 0.002, 0.55); },
    ice_shatter: (c, o, t) => { noise(c, o, t, { type: 'highpass', f: 1300, a: 0.003, d: 0.26, v: 0.4 }); partials(c, o, t, 150, [[1, 1, 0.05]], 0.28, 0.003, 0.6); const r = rng(13); for (let i = 0; i < 11; i++) partials(c, o, t + 0.03 + r() * 0.45, 2500 + r() * 3800, [[1, 1, 0.025 + r() * 0.03], [2.6, 0.3, 0.012]], 0.09 * (1 - i / 13)); },
    button: (c, o, t) => { wood(c, o, t, 1180, 0.3, 0.7); partials(c, o, t, 700, [[1, 1, 0.02]], 0.12, 0.003, 1.45); },
    // m7: star reveal (rising E6, G6, C7), chest lid, chest wiggle creaks, rival family done
    star: (c, o, t, p = {}) => { const s = Math.max(1, Math.min(3, p.step || 1)), f = [1318.5, 1568, 2093][s - 1];
      partials(c, o, t, f / 2, MARIMBA(f / 2), 0.26, 0.002); partials(c, o, t, f, BOX, 0.24 + s * 0.02); partials(c, o, t + 0.045, f * 2, BOX, 0.07);
      noise(c, o, t + 0.02, { type: 'highpass', f: 7500, a: 0.02, d: 0.22 + s * 0.06, v: 0.03 + s * 0.008 });
      if (s === 3) [2637, 3136].forEach((g, i) => partials(c, o, t + 0.12 + i * 0.07, g, BOX, 0.08)); },
    chest_open: (c, o, t) => {
      wood(c, o, t, 330, 0.5, 1.4); noise(c, o, t, { type: 'lowpass', f: 700, d: 0.05, v: 0.3 });
      noise(c, o, t + 0.05, { f: 520, f2: 1500, q: 7, a: 0.04, d: 0.16, v: 0.16, off: 0.3 });
      partials(c, o, t + 0.2, 131, [[1, 1, 0.08], [2.76, 0.3, 0.03]], 0.36, 0.004);
      ['C6', 1047, 'E6', 1318.5, 'G6', 1568, 'C7', 2093].filter((x, i) => i % 2).forEach((f, i) => partials(c, o, t + 0.22 + i * 0.05, f, BOX, 0.2 - i * 0.02));
      noise(c, o, t + 0.24, { type: 'highpass', f: 6500, a: 0.05, d: 0.55, v: 0.05 }); },
    chest_wiggle: (c, o, t) => { [0, 0.16, 0.32].forEach((dt, i) => {
      const k = semis(i * 3); noise(c, o, t + dt, { f: 380 * k, f2: 620 * k, q: 6, a: 0.03, d: 0.09, v: 0.42, off: 0.1 + i * 0.2 });
      wood(c, o, t + dt + 0.07, 520 * k, 0.34, 0.9); }); },
    // m7-5: the daily gift is claimed (13.5): a ribbon pull, then two music-box notes G6 → C7 over a soft marimba C6
    gift_claim: (c, o, t) => {
      noise(c, o, t, { f: 2600, f2: 5200, q: 0.9, a: 0.025, d: 0.11, v: 0.13, off: 0.15 });
      noise(c, o, t + 0.045, { f: 1700, f2: 3900, q: 1.3, a: 0.02, d: 0.08, v: 0.09, off: 0.45 });
      partials(c, o, t + 0.07, 1568, BOX, 0.18);
      partials(c, o, t + 0.17, 2093, BOX, 0.21); partials(c, o, t + 0.17, 1046.5, MARIMBA(1046.5), 0.16, 0.002);
      noise(c, o, t + 0.18, { type: 'highpass', f: 7000, a: 0.03, d: 0.32, v: 0.03 }); },
    rival_complete: (c, o, t) => { wood(c, o, t, 784, 0.24, 1.1); wood(c, o, t + 0.09, 1047, 0.26, 1.1); partials(c, o, t + 0.09, 2093, BOX, 0.07); },
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
    ['star_1', 'star', { step: 1 }, 0.7, 'Win card: 1st star pops in (m7)', 'light'],
    ['star_2', 'star', { step: 2 }, 0.75, 'Win card: 2nd star', 'light'],
    ['star_3', 'star', { step: 3 }, 0.9, 'Win card: 3rd star', 'light'],
    ['chest_open', 'chest_open', {}, 1.1, 'Chest lid opens (m7)', 'medium'],
    ['chest_wiggle', 'chest_wiggle', {}, 0.6, 'Chest wiggles before it opens: three rising creaks (m7)', 'light'],
    ['rival_complete', 'rival_complete', {}, 0.45, 'The computer rival completes a family (m7)', null],
    ['gift_claim', 'gift_claim', {}, 0.8, 'The daily gift is claimed: Claim tapped (m7-5)', 'light'],
  ].map(([file, fn, params, len, event, haptic]) => ({ file, fn, params, len, event, haptic }));

  function ensure() {
    if (!st.ctx) { const C = window.AudioContext || window.webkitAudioContext; st.ctx = new C(); st.out = st.ctx.createGain(); st.out.gain.value = st.volume; st.out.connect(st.ctx.destination); }
    if (st.ctx.state === 'suspended') st.ctx.resume();
    return st.ctx;
  }
  const fnOf = name => SFX[name] || (FILES.find(f => f.file === name) && ((c, o, t, p) => { const f = FILES.find(x => x.file === name); SFX[f.fn](c, o, t, { ...f.params, ...p }); }));
  function play(name, params = {}, delayMs = 0) { if (st.muted) return; const ctx = ensure(), fn = fnOf(name); if (fn) fn(ctx, bus(ctx, st.out), ctx.currentTime + 0.01 + delayMs / 1000, params); }
  function schedule(cues) { cues.forEach(([ms, name, p]) => play(name, p || {}, ms)); }
  function wav(buf) {
    const ch = buf.getChannelData(0), n = ch.length, dv = new DataView(new ArrayBuffer(44 + n * 2)), w = (o, s) => [...s].forEach((c, i) => dv.setUint8(o + i, c.charCodeAt(0)));
    w(0, 'RIFF'); dv.setUint32(4, 36 + n * 2, true); w(8, 'WAVE'); w(12, 'fmt '); dv.setUint32(16, 16, true); dv.setUint16(20, 1, true); dv.setUint16(22, 1, true);
    dv.setUint32(24, buf.sampleRate, true); dv.setUint32(28, buf.sampleRate * 2, true); dv.setUint16(32, 2, true); dv.setUint16(34, 16, true); w(36, 'data'); dv.setUint32(40, n * 2, true);
    let peak = 0; for (let i = 0; i < n; i++) peak = Math.max(peak, Math.abs(ch[i]));
    const k = peak > 0.95 ? 0.95 / peak : 1, fo = Math.floor(buf.sampleRate * 0.03);
    for (let i = 0; i < n; i++) dv.setInt16(44 + i * 2, Math.max(-1, Math.min(1, ch[i] * k * (i > n - fo ? (n - i) / fo : 1))) * 0x7fff, true);
    return new Blob([dv.buffer], { type: 'audio/wav' });
  }
  async function renderWav(name, params = {}, seconds) {
    const f = FILES.find(x => x.file === name), fn = fnOf(name), len = seconds || (f ? f.len : 1), sr = 44100;
    const oc = new OfflineAudioContext(1, Math.ceil(sr * len), sr), out = oc.createGain(); out.gain.value = 0.9; out.connect(oc.destination);
    fn(oc, bus(oc, out), 0.003, params);
    return wav(await oc.startRendering());
  }
  window.NestySfx = { play, schedule, renderWav, FILES, CHIME, clackRate: size => semis((size - 3.5) * -2), setMuted: m => { st.muted = !!m; }, isMuted: () => st.muted, setVolume: v => { st.volume = v; if (st.out) st.out.gain.value = v; } };
})();
