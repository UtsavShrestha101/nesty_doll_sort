/* Nesty music engine (GAME_SPEC §11.3, tokens.json → sound.music / sound.jingles).
 * A cozy wooden-toy folk band, all synthesized: balalaika (with tremolo), nylon guitar and pluck bass (Karplus-Strong),
 * marimba, music box, bayan reeds, spoons, shaker, tambourine and frame drum.
 * One score drives live playback and offline export, so the preview matches the shipped files.
 *   NestyMusic.play('music_home') · .stop() · .setStem('drums', false) · .position()
 *   await NestyMusic.render('music_game') -> AudioBuffer (loops: exactly one seamless cycle, tails wrapped) · .wav(buffer) -> Blob
 *   NestyMusic.measure(buffer) -> { rms, peak, truePeak, seconds } in dBFS / dBTP (the levels AUDIO.md quotes)
 */
(function () {
  const NT = { C: 0, D: 2, E: 4, F: 5, G: 7, A: 9, B: 11 };
  const pcOf = s => (NT[s[0]] + (s[1] === '#' ? 1 : s[1] === 'b' ? -1 : 0) + 12) % 12;
  const midi = s => { const m = /^([A-G][#b]?)(\d)$/.exec(s); return 12 * (+m[2] + 1) + pcOf(m[1]); };
  const hz = m => 440 * Math.pow(2, (m - 69) / 12);
  const rng = seed => { let s = (seed >>> 0) || 1; return () => (s = (Math.imul(s, 1664525) + 1013904223) >>> 0) / 4294967296; };
  const Q = { '': [0, 4, 7], m: [0, 3, 7], 7: [0, 4, 7, 10], maj7: [0, 4, 7, 11], m7: [0, 3, 7, 10], add9: [0, 4, 7, 14] };
  const chord = sym => { const m = /^([A-G][#b]?)(.*)$/.exec(sym); return { root: pcOf(m[1]), iv: Q[m[2]] }; };
  const fit = (pc, lo) => lo + ((((pc - lo) % 12) + 12) % 12);
  const voice = (c, lo, n) => c.iv.slice(0, n || 9).map(i => fit((c.root + i) % 12, lo)).sort((a, b) => a - b);
  function mel(str) { // "G5:1.5 A5:.5 G5 | C5~:2 -:1" → beats; ~ = balalaika tremolo, - = rest, default 1 beat
    const ev = []; let b = 0;
    str.trim().split(/\s+/).forEach(tok => {
      if (tok === '|') return;
      const [n, d] = tok.split(':'), dur = d ? parseFloat(d) : 1;
      if (n !== '-') { const tr = n.endsWith('~'); ev.push({ b, m: midi(tr ? n.slice(0, -1) : n), d: dur, tr }); }
      b += dur;
    });
    return ev;
  }

  /* ---------- scores ---------- */
  function home(E) { // Toy Shop Waltz · C major · 3/4 · 108 BPM · A A′ B B′ A″
    const bars = 'C C G7 C F Dm G7 C C C Am Am F C G7 E7 Am Am Dm Am Dm Am E7 Am Am Am Dm Am F C G7 G7 C C G7 C F Dm G7 G7'.split(' ').map(chord);
    [
      ['bala', 'G5:1.5 A5:.5 G5 | E5:2 C5 | D5 E5 F5 | G5~:3 | A5:1.5 G5:.5 F5 | F5:2 E5 | D5 E5:.5 D5:.5 B4 | C5~:2 G4'],
      ['bala mbox', 'G5:1.5 A5:.5 G5 | E5:2 G5 | C6:1.5 B5:.5 A5 | A5~:2 G5 | F5 A5 C6 | C6~:2 G5 | F5 D5 B4 | D5:1.5 C5:.5 B4'],
      ['reed', 'A4 C5 E5 | A5:2 G5 | F5:1.5 E5:.5 D5 | E5:2 C5 | D5 F5 A5 | C6:1.5 B5:.5 A5 | E5:1.5 D5:.5 B4 | A4:3'],
      ['reed bala', 'A4 C5 E5 | A5:2 G5 | F5:1.5 E5:.5 D5 | E5:2 C5 | C6:1.5 A5:.5 F5 | G5:1.5 E5:.5 C5 | B4 D5 F5 | G5~:2 F5'],
      ['marimba mbox', 'G5:1.5 A5:.5 G5 | E5:2 C5 | D5 E5 F5 | G5:3 | A5:1.5 G5:.5 F5 | F5:2 E5 | D5 E5:.5 D5:.5 B4 | B4 D5 F5'],
    ].forEach(([how, s], sec) => mel(s).forEach(n => {
      const b = sec * 24 + n.b;
      if (how === 'bala') E('bala', 'melody', b, n.m, n.d, 0.8, { tr: n.tr });
      if (how === 'bala mbox') { E('bala', 'melody', b, n.m, n.d, 0.78, { tr: n.tr }); E('mbox', 'melody', b, n.m + 12, n.d, 0.3); }
      if (how === 'reed') E('reed', 'melody', b, n.m, n.d * 0.94, 0.72, { vib: 1 });
      if (how === 'reed bala') { E('reed', 'melody', b, n.m, n.d * 0.94, 0.64, { vib: 1 }); E('bala', 'melody', b, n.m, n.d, 0.46, { tr: n.d >= 1.5 }); }
      if (how === 'marimba mbox') { E('marimba', 'melody', b, n.m, n.d, 0.74); E('mbox', 'melody', b, n.m, n.d, 0.24); }
    }));
    bars.forEach((c, i) => {
      const b = i * 3, sec = Math.floor(i / 8), prev = bars[(i + 39) % 40], same = prev.root === c.root && prev.iv === c.iv;
      E('bass', 'bass', b, fit(same ? (c.root + 7) % 12 : c.root, 40), 2.6, 0.85);
      const tri = voice(c, 55, 3), stab = (inst, v, d) => [1, 2].forEach(k => tri.forEach((m, j) => E(inst, 'harmony', b + k, m, d, v * (k === 1 ? 1 : 0.85), { strum: j })));
      if (sec < 2) stab('guitar', sec ? 0.32 : 0.36, 0.45);
      if (sec === 1) voice(c, 57, 4).forEach(m => E('pad', 'harmony', b, m, 3, 0.14));
      if (sec === 2 || sec === 3) stab('reed', 0.22, 0.5);
      if (sec === 4) stab('bala', 0.3, 0.4);
      if (sec < 2 || sec === 4) { E('spoon', 'drums', b + 1, 0, 0.1, 0.3); E('spoon', 'drums', b + 2, 0, 0.1, 0.24); if (i % 4 === 3) E('spoon', 'drums', b + 2.5, 0, 0.1, 0.18); }
      if (sec >= 2) E('kick', 'drums', b, 0, 0.5, sec === 4 ? 0.32 : 0.45);
      if (sec === 3) { E('tamb', 'drums', b + 1, 0, 0.2, 0.2); E('tamb', 'drums', b + 2, 0, 0.2, 0.16); if (i % 4 === 0) E('tamb', 'drums', b, 0, 0.2, 0.34); for (let k = 0; k < 6; k++) E('shaker', 'drums', b + k / 2, 0, 0.1, k % 2 ? 0.08 : 0.12); }
    });
  }
  function game(E) { // Quiet Shelves · F major · 4/4 · 84 BPM · A B C
    const bars = 'Fmaj7 Am7 Bbmaj7 C Fmaj7 Dm7 Gm7 C Dm7 Am7 Bbmaj7 F Gm7 Am7 Bbmaj7 C Bbmaj7 Am7 Gm7 F Bbmaj7 Am7 Gm7 C'.split(' ').map(chord);
    mel('F5 A5 C6:2 | G5 A5 E5:2 | D5 F5 A5:2 | C6:1.5 A5:.5 F5:2 | Bb5:1.5 A5:.5 G5 F5 | E5:2 C5 E5 | F5 G5 A5 D6 | C6:4').forEach(n => E('mbox', 'melody', 32 + n.b, n.m, n.d, 0.42));
    mel('D5:1.5 C5:.5 Bb4 A4 | C5:2 E5 A4 | Bb4:1.5 A4:.5 G4 D5 | A4:3 -:1 | F5:1.5 D5:.5 Bb4 D5 | E5:2 C5 A4 | G4 Bb4 D5 F5 | E5:3 -:1').forEach(n => E('guitar', 'melody', 64 + n.b, n.m, n.d, 0.62));
    const PAT = [0, 2, 3, 2, 1, 2, 3, 2], VEL = [0.6, 0.38, 0.48, 0.36, 0.5, 0.36, 0.46, 0.34];
    bars.forEach((c, i) => {
      const b = i * 4, sec = Math.floor(i / 8), v4 = voice(c, 53, 4); if (v4.length < 4) v4.push(v4[0] + 12);
      if (sec < 2) PAT.forEach((p, k) => E('marimba', 'harmony', b + k / 2, v4[p], 0.5, VEL[k] * (sec ? 0.88 : 1)));
      else if (i < 23) [0, 2, 1, 3].forEach((p, k) => E('marimba', 'harmony', b + k, v4[p], 1, 0.42 - k * 0.03));
      else { E('marimba', 'harmony', b, v4[0], 1, 0.42); E('marimba', 'harmony', b + 1, v4[2], 1, 0.38); ['C5', 'E5', 'G5', 'Bb5'].forEach((n, k) => E('marimba', 'harmony', b + 2 + k / 2, midi(n), 0.5, 0.3 + k * 0.05)); }
      voice(c, 55, 4).forEach(m => E('pad', 'harmony', b, m, 4, [0.13, 0.1, 0.16][sec]));
      const root = fit(c.root, 36), fifth = fit((c.root + 7) % 12, 36);
      if (sec < 2) { E('bass', 'bass', b, root, 1.5, 0.8); E('bass', 'bass', b + 2, fifth, 1.4, 0.6); E('bass', 'bass', b + 3.5, root, 0.5, 0.36); }
      else E('bass', 'bass', b, root, 3.5, 0.72);
      const sh = [[0.16, 0.09], [0.2, 0.11], [0.12, 0.07]][sec];
      for (let k = 0; k < 8; k++) E('shaker', 'drums', b + k / 2, 0, 0.1, sh[k % 2]);
      if (sec === 1) { E('kick', 'drums', b, 0, 0.5, 0.4); E('kick', 'drums', b + 2, 0, 0.5, 0.28); E('tick', 'drums', b + 3.5, 0, 0.1, 0.2); }
      if (sec === 2) E('kick', 'drums', b, 0, 0.5, 0.25);
      if (sec === 0 && i % 4 === 3) E('tick', 'drums', b + 3.5, 0, 0.1, 0.15);
    });
  }
  function chapter(E) {
    ['C5', 'D5', 'E5', 'G5', 'A5', 'C6'].forEach((n, i) => E('marimba', 'melody', i * 0.25, midi(n), 0.5, 0.42 + i * 0.05));
    E('bala', 'melody', 1.5, midi('G5'), 0.5, 0.72);
    E('bala', 'melody', 2, midi('C6'), 2.5, 0.78, { tr: 1 }); E('bala', 'melody', 2, midi('E5'), 2.5, 0.42, { tr: 1 });
    E('bass', 'bass', 2, midi('C3'), 3, 0.9);
    voice(chord('C'), 55, 3).forEach((m, j) => E('guitar', 'harmony', 2, m, 3, 0.5, { strum: j }));
    voice(chord('Cadd9'), 55, 4).forEach(m => E('pad', 'harmony', 2, m, 3.5, 0.2));
    ['C6', 'E6', 'G6', 'C7'].forEach((n, i) => E('mbox', 'melody', 2.5 + i * 0.25, midi(n), 1, 0.3)); E('mbox', 'melody', 3.5, midi('E7'), 2, 0.26);
    E('kick', 'drums', 2, 0, 0.5, 0.6); [[2, 0.5], [3, 0.26], [4, 0.32]].forEach(([b, v]) => E('tamb', 'drums', b, 0, 0.3, v));
  }
  function reward(E) {
    ['C6', 'G6', 'D7', 'E7'].forEach((n, i) => E('mbox', 'melody', i * 0.2, midi(n), 1.5, 0.36));
    ['E6', 'G6', 'C7'].forEach(n => E('mbox', 'melody', 1, midi(n), 2, 0.24));
    E('marimba', 'melody', 1, midi('C5'), 1, 0.4); E('marimba', 'melody', 1, midi('G5'), 1, 0.3);
    voice(chord('Cadd9'), 55, 4).forEach(m => E('pad', 'harmony', 0, m, 3.4, 0.18, { att: 0.5 }));
    E('bass', 'bass', 1, midi('C3'), 3, 0.5);
    for (let k = 0; k < 8; k++) E('shaker', 'drums', 1 + k * 0.25, 0, 0.1, 0.2 * (1 - k / 9));
  }
  function versusWin(E) { // m7: race won, C major
    ['G5', 'A5', 'B5', 'C6', 'D6', 'E6'].forEach((n, i) => E('marimba', 'melody', i * 0.25, midi(n), 0.5, 0.4 + i * 0.05));
    E('bala', 'melody', 1.5, midi('D6'), 0.5, 0.7); E('bala', 'melody', 2, midi('G6'), 2.5, 0.74, { tr: 1 }); E('bala', 'melody', 2, midi('C6'), 2.5, 0.4, { tr: 1 });
    E('bass', 'bass', 1, midi('G2'), 1, 0.6); E('bass', 'bass', 2, midi('C3'), 2.5, 0.85);
    voice(chord('C'), 55, 3).forEach((m, j) => E('guitar', 'harmony', 2, m, 2.5, 0.46, { strum: j }));
    ['E6', 'G6', 'C7', 'E7'].forEach((n, i) => E('mbox', 'melody', 2.25 + i * 0.2, midi(n), 1, 0.26));
    E('kick', 'drums', 2, 0, 0.5, 0.55); [[1, 0.2], [1.5, 0.24], [2, 0.46], [2.5, 0.22], [3, 0.3]].forEach(([b, v]) => E('tamb', 'drums', b, 0, 0.3, v));
  }
  function versusLose(E) { // m7: the computer finished first. Warm, lifts at the end, F major
    ['A5', 'G5', 'F5'].forEach((n, i) => E('marimba', 'melody', i * 0.5, midi(n), 0.75, 0.5 - i * 0.04));
    E('marimba', 'melody', 1.5, midi('C6'), 1.5, 0.52);
    ['F3', 'A3', 'C4', 'F4'].forEach((n, i) => E('guitar', 'harmony', 1.5 + i * 0.18, midi(n), 3, 0.38));
    E('bass', 'bass', 1.5, midi('F2'), 2.5, 0.6);
    ['F6', 'A6', 'C7'].forEach((n, i) => E('mbox', 'melody', 2.25 + i * 0.25, midi(n), 1.2, 0.2));
    for (let k = 0; k < 6; k++) E('shaker', 'drums', 1.5 + k * 0.25, 0, 0.1, 0.16 * (1 - k / 7));
  }
  function oom(E) {
    ['E5', 'D5', 'C5', 'A4'].forEach((n, i) => E('marimba', 'melody', i * 0.5, midi(n), 1, 0.62 - i * 0.07));
    ['F3', 'A3', 'C4', 'E4'].forEach((n, i) => E('guitar', 'harmony', 2 + i * 0.22, midi(n), 3, 0.42));
    E('bass', 'bass', 2, midi('F2'), 3, 0.62);
    voice(chord('Fmaj7'), 55, 4).forEach(m => E('pad', 'harmony', 2, m, 2.6, 0.16));
    E('mbox', 'melody', 3, midi('C6'), 2, 0.2);
  }
  const SONGS = {
    music_home: { title: 'Toy Shop Waltz', bpm: 108, beats: 3, bars: 40, loop: true, key: 'C major', sections: [['A', 8], ['A′', 8], ['B', 8], ['B′', 8], ['A″', 8]], build: home },
    music_game: { title: 'Quiet Shelves', bpm: 84, beats: 4, bars: 24, loop: true, key: 'F major', sections: [['A', 8], ['B', 8], ['C', 8]], build: game },
    jingle_chapter: { title: 'Chapter complete', bpm: 120, beats: 4, bars: 1.5, tail: 2.6, key: 'C major', build: chapter },
    jingle_reward: { title: 'Reward', bpm: 120, beats: 4, bars: 1, tail: 2.4, key: 'C major', build: reward },
    jingle_oom: { title: 'Out of moves', bpm: 120, beats: 4, bars: 1.25, tail: 2, key: 'F major', build: oom },
    jingle_versus_win: { title: 'Race won', bpm: 120, beats: 4, bars: 1.25, tail: 2.4, key: 'C major', build: versusWin },
    jingle_versus_lose: { title: 'So close', bpm: 120, beats: 4, bars: 1.25, tail: 2.2, key: 'F major', build: versusLose },
  };
  const scores = {};
  function score(name) {
    if (scores[name]) return scores[name];
    const ev = [];
    SONGS[name].build((inst, stem, b, m, d, v, o = {}) => ev.push({ inst, stem, b, m, d, v, tr: !!o.tr, strum: o.strum || 0, vib: !!o.vib, att: o.att, seed: ev.length * 7919 + 17 }));
    ev.sort((x, y) => x.b - y.b);
    return (scores[name] = ev);
  }

  /* ---------- instruments ---------- */
  const KS = { bala: [0.9, 0.3, 1.0, 0.13, 1.3], guitar: [0.42, 0.5, 2.2, 0.24, 2.4], bass: [0.28, 0.5, 1.5, 0.2, 1.8] }; // excitation brightness, loop filter, T60 s, pluck position, buffer s
  function ksBuf(S, inst, m) {
    const key = inst + m; if (S.ks[key]) return S.ks[key];
    const [br, s, t60, pos, len] = KS[inst], sr = S.ctx.sampleRate, f = hz(m), N = Math.max(4, Math.floor(sr / f + s)), n = Math.floor(sr * len);
    const buf = S.ctx.createBuffer(1, n, sr), d = buf.getChannelData(0), r = rng(m * 131 + inst.charCodeAt(0)), line = new Float32Array(N);
    let lp = 0, mean = 0, peak = 0;
    for (let i = 0; i < N; i++) { lp += br * (r() * 2 - 1 - lp); line[i] = lp; }
    const P = Math.max(1, Math.round(N * pos)); for (let i = N - 1; i >= P; i--) line[i] -= line[i - P];
    for (let i = 0; i < N; i++) mean += line[i] / N; for (let i = 0; i < N; i++) line[i] -= mean;
    const rho = Math.pow(0.001, N / (sr * t60));
    for (let i = 0, j = 0; i < n; i++) { const a = line[j], j2 = j + 1 === N ? 0 : j + 1; d[i] = a; line[j] = rho * ((1 - s) * a + s * line[j2]); j = j2; }
    for (let i = 0; i < n; i++) if (Math.abs(d[i]) > peak) peak = Math.abs(d[i]);
    const g = peak ? 0.9 / peak : 1, fo = Math.floor(sr * 0.04);
    for (let i = 0; i < n; i++) d[i] *= g * (i > n - fo ? (n - i) / fo : 1);
    return (S.ks[key] = { b: buf, rate: f * (N - s) / sr });
  }
  function pluck(S, out, t, m, d, v, e, r, inst) {
    const { b, rate } = ksBuf(S, inst, m), c = S.ctx, hits = e.tr ? Math.max(2, Math.round(d / 0.074)) : 1, step = d / hits;
    for (let h = 0; h < hits; h++) {
      const th = t + h * step + (h ? r() * 0.006 : 0), last = h === hits - 1;
      const end = Math.min(e.tr && !last ? t + (h + 1) * step + 0.02 : t + d + (inst === 'bass' ? 0.1 : 0.4), th + b.duration / rate);
      const vv = v * (e.tr ? (h === 0 ? 1 : h % 2 ? 0.58 : 0.74) : 1), s = c.createBufferSource(), g = c.createGain();
      s.buffer = b; s.playbackRate.value = rate;
      g.gain.setValueAtTime(vv, th); g.gain.setValueAtTime(vv, Math.max(th, end - 0.03)); g.gain.linearRampToValueAtTime(0, end);
      s.connect(g); g.connect(out); s.start(th); s.stop(end + 0.01);
    }
  }
  function osc(S, out, t, f, v, tc, att = 0.002) {
    const o = S.ctx.createOscillator(), g = S.ctx.createGain(); o.frequency.value = f;
    g.gain.setValueAtTime(0, t); g.gain.linearRampToValueAtTime(v, t + att); g.gain.setTargetAtTime(0, t + att, tc);
    o.connect(g); g.connect(out); o.start(t); o.stop(t + att + tc * 8);
  }
  function nz(S, out, t, type, f, q, v, d, att, r) {
    const c = S.ctx, s = c.createBufferSource(), fl = c.createBiquadFilter(), g = c.createGain(); s.buffer = S.noise;
    fl.type = type; fl.frequency.value = f; fl.Q.value = q;
    g.gain.setValueAtTime(0, t); g.gain.linearRampToValueAtTime(v, t + att); g.gain.setTargetAtTime(0, t + att, d / 3);
    s.connect(fl); fl.connect(g); g.connect(out); s.start(t, r() * 0.8); s.stop(t + att + d * 2.5);
  }
  function reed(S, out, t, m, d, v, att, rel, vib, lpf) {
    const c = S.ctx, f = hz(m), lp = c.createBiquadFilter(), g = c.createGain(), end = t + Math.max(d, att + 0.02), stop = end + rel * 3;
    lp.type = 'lowpass'; lp.frequency.value = lpf || Math.min(3000, 700 + f * 4); lp.Q.value = 0.5;
    [[1, 'sawtooth', -6, 0.5], [1, 'sawtooth', 6, 0.5], [0.5, 'square', 0, 0.2]].forEach(([k, type, cents, a]) => {
      const x = c.createOscillator(), xg = c.createGain(); x.type = type; x.frequency.value = f * k; x.detune.value = cents; xg.gain.value = a;
      x.connect(xg); xg.connect(lp); x.start(t); x.stop(stop);
    });
    g.gain.setValueAtTime(0, t); g.gain.linearRampToValueAtTime(v, t + att); g.gain.setValueAtTime(v, end); g.gain.setTargetAtTime(0, end, rel / 3);
    lp.connect(g);
    if (vib) { // bellows shake, applied after the envelope so the release stays clean
      const tr = c.createGain(), l = c.createOscillator(), lg = c.createGain(); tr.gain.value = 1; l.frequency.value = 5.2; lg.gain.value = 0.1;
      l.connect(lg); lg.connect(tr.gain); l.start(t); l.stop(stop); g.connect(tr); tr.connect(out);
    } else g.connect(out);
  }
  const VOICE = {
    bala: (S, o, t, m, d, v, e, r) => pluck(S, o, t, m, d, v, e, r, 'bala'),
    guitar: (S, o, t, m, d, v, e, r) => pluck(S, o, t, m, d, v, e, r, 'guitar'),
    bass: (S, o, t, m, d, v, e, r) => { pluck(S, o, t, m, d, v, e, r, 'bass'); osc(S, o, t, hz(m), v * 0.32, 0.22, 0.005); },
    marimba: (S, o, t, m, d, v, e, r) => {
      const f = hz(m), tc = Math.min(0.42, Math.max(0.08, 0.2 * Math.sqrt(440 / f)));
      osc(S, o, t, f, v, tc); if (f * 3.99 < 16000) osc(S, o, t, f * 3.99, v * 0.26, tc * 0.25, 0.001); if (f * 9.9 < 16000) osc(S, o, t, f * 9.9, v * 0.06, tc * 0.1, 0.001);
      nz(S, o, t, 'bandpass', 2400, 1.2, v * 0.1, 0.012, 0.001, r);
    },
    mbox: (S, o, t, m, d, v, e, r) => {
      const f = hz(m); [[1, 1, 0.42], [2, 0.14, 0.2], [3, 0.05, 0.11], [6.27, 0.18, 0.035]].forEach(([k, a, tc]) => { if (f * k < 18000) osc(S, o, t, f * k, v * a, tc, 0.001); });
      nz(S, o, t, 'bandpass', 5200, 1.5, v * 0.07, 0.01, 0.001, r);
    },
    reed: (S, o, t, m, d, v, e) => reed(S, o, t, m, d, v, e.att ?? 0.045, 0.12, e.vib),
    pad: (S, o, t, m, d, v, e) => reed(S, o, t, m, d, v, e.att ?? 0.35, 0.5, false, 1300),
    kick: (S, o, t, m, d, v, e, r) => {
      const c = S.ctx, x = c.createOscillator(), g = c.createGain(); x.frequency.setValueAtTime(105, t); x.frequency.exponentialRampToValueAtTime(46, t + 0.13);
      g.gain.setValueAtTime(0, t); g.gain.linearRampToValueAtTime(v, t + 0.004); g.gain.setTargetAtTime(0, t + 0.004, 0.08);
      x.connect(g); g.connect(o); x.start(t); x.stop(t + 0.7); nz(S, o, t, 'lowpass', 380, 0.7, v * 0.3, 0.05, 0.002, r);
    },
    shaker: (S, o, t, m, d, v, e, r) => nz(S, o, t, 'bandpass', 7000, 0.9, v, 0.055, 0.008, r),
    spoon: (S, o, t, m, d, v, e, r) => [0, 0.017].forEach((dt, i) => { const w = v * (i ? 0.55 : 1); osc(S, o, t + dt, 1850 + i * 380, w * 0.5, 0.012, 0.001); osc(S, o, t + dt, 3150 + i * 250, w * 0.22, 0.007, 0.001); nz(S, o, t + dt, 'bandpass', 2700, 1.6, w * 0.6, 0.014, 0.001, r); }),
    tamb: (S, o, t, m, d, v, e, r) => { nz(S, o, t, 'highpass', 6500, 0.7, v * 0.7, 0.14, 0.004, r); [5400, 7300, 8900].forEach((f, i) => osc(S, o, t + i * 0.003, f, v * 0.06, 0.05, 0.001)); },
    tick: (S, o, t, m, d, v, e, r) => { osc(S, o, t, 1180, v * 0.6, 0.028, 0.001); osc(S, o, t, 2950, v * 0.14, 0.01, 0.001); nz(S, o, t, 'bandpass', 2000, 2, v * 0.4, 0.012, 0.001, r); },
  };
  const CH = { // channel strip: level, pan, reverb send, filters
    bala: { g: 0.85, pan: 0.12, send: 0.2, hp: 160, pk: [2600, 1, 3] }, guitar: { g: 0.8, pan: -0.28, send: 0.2, lp: 4200 }, bass: { g: 0.62, pan: 0, send: 0.04, lp: 1000 },
    marimba: { g: 0.85, pan: -0.12, send: 0.26 }, mbox: { g: 0.5, pan: 0.3, send: 0.42 }, reed: { g: 0.26, pan: 0.06, send: 0.28 }, pad: { g: 0.2, pan: -0.04, send: 0.34 },
    kick: { g: 0.85, pan: 0, send: 0.05 }, shaker: { g: 0.5, pan: 0.3, send: 0.1 }, spoon: { g: 0.6, pan: 0.34, send: 0.14 }, tamb: { g: 0.5, pan: -0.32, send: 0.14 }, tick: { g: 0.6, pan: -0.22, send: 0.16 },
  };
  function chan(S, stem, inst) {
    const k = stem + ':' + inst; if (S.ch[k]) return S.ch[k];
    const p = CH[inst], c = S.ctx, inp = c.createGain(); inp.gain.value = p.g; let n = inp;
    const add = (type, f, q, gain) => { const b = c.createBiquadFilter(); b.type = type; b.frequency.value = f; b.Q.value = q; if (gain) b.gain.value = gain; n.connect(b); n = b; };
    if (p.hp) add('highpass', p.hp, 0.7); if (p.lp) add('lowpass', p.lp, 0.7); if (p.pk) add('peaking', ...p.pk);
    const mute = c.createGain(), pan = c.createStereoPanner(), send = c.createGain();
    mute.gain.value = S.muted[stem] ? 0 : 1; pan.pan.value = p.pan; send.gain.value = p.send;
    n.connect(mute); mute.connect(pan); pan.connect(S.master); pan.connect(send); send.connect(S.verb);
    (S.stems[stem] = S.stems[stem] || []).push(mute);
    return (S.ch[k] = inp);
  }
  function ir(ctx, sec = 2.4) { // warm room: pre-delay, early reflections, darkening tail
    const sr = ctx.sampleRate, n = Math.floor(sr * sec), b = ctx.createBuffer(2, n, sr), pre = Math.floor(sr * 0.014);
    for (let ch = 0; ch < 2; ch++) {
      const d = b.getChannelData(ch), r = rng(99 + ch * 31); let lp = 0;
      for (let i = pre; i < n; i++) { const x = i / n; lp += (0.62 - 0.5 * x) * (r() * 2 - 1 - lp); d[i] = lp * Math.pow(1 - x, 2.6); }
      [0.011, 0.019, 0.027, 0.041, 0.053].forEach((s, j) => { const at = Math.floor(sr * (s + ch * 0.003)); d[at] += (0.5 - j * 0.07) * (j % 2 ? -1 : 1); });
    }
    return b;
  }
  function session(ctx, dest, muted) {
    const S = { ctx, ks: {}, ch: {}, stems: {}, muted }, sr = ctx.sampleRate, nb = ctx.createBuffer(1, Math.floor(sr * 1.2), sr), nd = nb.getChannelData(0), r = rng(4242);
    for (let i = 0; i < nd.length; i++) nd[i] = r() * 2 - 1; S.noise = nb;
    S.master = ctx.createGain(); S.master.gain.value = 0.62;
    const comp = ctx.createDynamicsCompressor(); comp.threshold.value = -16; comp.knee.value = 10; comp.ratio.value = 2.5; comp.attack.value = 0.008; comp.release.value = 0.25;
    S.master.connect(comp); comp.connect(dest);
    S.verb = ctx.createConvolver(); S.verb.buffer = ir(ctx); const wet = ctx.createGain(); wet.gain.value = 0.8; S.verb.connect(wet); wet.connect(S.master);
    return S;
  }
  function fire(S, e, t, spb) { // humanize is per event and never early, so both loop cycles are identical
    const r = rng(e.seed), tt = t + e.strum * 0.013 + r() * (e.stem === 'drums' ? 0.004 : 0.007), v = e.v * (0.92 + r() * 0.12);
    VOICE[e.inst](S, chan(S, e.stem, e.inst), tt, e.m, e.d * spb, v, e, r);
  }

  /* ---------- live playback ---------- */
  const L = { ctx: null, run: null, muted: {}, vol: 0.5 };
  function ac() { if (!L.ctx) L.ctx = new (window.AudioContext || window.webkitAudioContext)(); if (L.ctx.state === 'suspended') L.ctx.resume(); return L.ctx; }
  function play(name) {
    stop(0.12);
    const c = ac(), song = SONGS[name], ev = score(name), spb = 60 / song.bpm, out = c.createGain();
    out.gain.value = L.vol; out.connect(c.destination);
    const S = session(c, out, L.muted); ev.forEach(e => { if (KS[e.inst]) ksBuf(S, e.inst, e.m); });
    const R = { name, song, ev, S, out, spb, len: song.bars * song.beats * spb, loop: !!song.loop, t0: c.currentTime + 0.1, idx: 0, cycle: 0 };
    R.timer = setInterval(() => pump(R), 40); L.run = R; pump(R);
  }
  function pump(R) {
    const now = L.ctx.currentTime;
    if (!R.loop && now > R.t0 + R.len + R.song.tail) { if (L.run === R) stop(0.05); return; }
    for (;;) {
      if (R.idx >= R.ev.length) { if (!R.loop) return; R.idx = 0; R.cycle++; }
      const e = R.ev[R.idx], t = R.t0 + R.cycle * R.len + e.b * R.spb;
      if (t > now + 0.3) return;
      if (t > now - 0.02) fire(R.S, e, t, R.spb);
      R.idx++;
    }
  }
  function stop(fade = 0.25) {
    const R = L.run; if (!R) return; L.run = null; clearInterval(R.timer);
    const now = L.ctx.currentTime, g = R.out.gain; g.cancelScheduledValues(now); g.setValueAtTime(g.value, now); g.linearRampToValueAtTime(0, now + fade);
    setTimeout(() => { try { R.out.disconnect(); } catch (e) {} }, fade * 1000 + 400);
  }
  function setStem(stem, on) { L.muted[stem] = !on; const R = L.run; if (R && R.S.stems[stem]) R.S.stems[stem].forEach(g => g.gain.setTargetAtTime(on ? 1 : 0, L.ctx.currentTime, 0.02)); }
  function position() {
    const R = L.run; if (!R) return null;
    const el = Math.max(0, L.ctx.currentTime - R.t0), tl = R.loop ? el % R.len : Math.min(el, R.len), bar = Math.floor(tl / R.spb / R.song.beats);
    let section = '', acc = 0; (R.song.sections || []).some(([n, k]) => { acc += k; if (bar < acc) { section = n; return true; } return false; });
    return { name: R.name, bar: Math.min(bar + 1, Math.ceil(R.song.bars)), bars: Math.ceil(R.song.bars), section, p: tl / R.len };
  }

  /* ---------- offline export ---------- */
  async function render(name, sr = 44100, opts = {}) {
    const song = SONGS[name], ev = score(name), spb = 60 / song.bpm, N = Math.round(song.bars * song.beats * spb * sr);
    const pre = song.loop ? Math.round(6 * sr) : 0, total = song.loop ? pre + N : N + Math.round(song.tail * sr);
    const oc = new OfflineAudioContext(2, total, sr), S = session(oc, oc.destination, {}), list = [];
    // loops: the last 6 s of the previous cycle ring into this one, so the kept cycle wraps seamlessly
    ev.forEach(e => { const t = 0.001 + e.b * spb; if (song.loop) { if (t + (pre - N) / sr >= 0) list.push([t + (pre - N) / sr, e]); list.push([t + pre / sr, e]); } else list.push([t, e]); });
    list.sort((x, y) => x[0] - y[0]);
    let k = 0; const sched = u => { while (k < list.length && list[k][0] < u) { fire(S, list[k][1], list[k][0], spb); k++; } };
    sched(1.5); for (let t = 1; t < total / sr - 0.1; t += 1) oc.suspend(t).then(() => { sched(t + 1.5); oc.resume(); }); // few live nodes = fast render
    const buf = await oc.startRendering(), L0 = buf.getChannelData(0), R0 = buf.getChannelData(1);
    let a = 0, b = total;
    if (song.loop) { a = pre; b = pre + N; }
    else while (b > N / 2 && Math.abs(L0[b - 1]) < 2e-4 && Math.abs(R0[b - 1]) < 2e-4) b--;
    const n = b - a, res = new AudioBuffer({ length: n, numberOfChannels: 2, sampleRate: sr }), fo = song.loop ? 0 : Math.floor(sr * 0.03);
    const out = [res.getChannelData(0), res.getChannelData(1)];
    [L0, R0].forEach((d, ch) => { for (let i = 0; i < n; i++) out[ch][i] = d[a + i] * (fo && i > n - fo ? (n - i) / fo : 1); });
    if (song.loop) { const { peak, rms } = levels(out, n), g = Math.min(0.89 / peak, 0.095 / rms); out.forEach(o => { for (let i = 0; i < n; i++) o[i] *= g; }); } // loops: peak −1 dBFS, RMS −20.5 dBFS
    else master(out, n, sr, opts.ceilDb); // jingles: RMS −17 dBFS, true peak ≤ −1.8 dBTP here, so the OGG stays ≤ −1 dBTP
    return res;
  }

  /* ---------- levels and jingle mastering ---------- */
  // RMS over the whole file and both channels (full-scale square = 0 dBFS). True peak: 4× oversampling with a
  // 48-tap Blackman-windowed sinc, as in ITU-R BS.1770 annex 2.
  const OS = [1, 2, 3].map(p => { const h = []; let s = 0; for (let k = -23; k <= 24; k++) { const x = k - p / 4, w = 0.42 + 0.5 * Math.cos(Math.PI * x / 24) + 0.08 * Math.cos(Math.PI * x / 12), v = (x ? Math.sin(Math.PI * x) / (Math.PI * x) : 1) * w; h.push(v); s += v; } return h.map(v => v / s); });
  function levels(chs, n) { let peak = 0, sum = 0; chs.forEach(d => { for (let i = 0; i < n; i++) { const x = d[i]; if (Math.abs(x) > peak) peak = Math.abs(x); sum += x * x; } }); return { peak, rms: Math.sqrt(sum / (chs.length * n)) }; }
  function tpEnv(chs, n, gate) { // per-sample true-peak magnitude over all channels; samples far below `gate` skip the filter
    const env = new Float32Array(n);
    chs.forEach(d => {
      for (let i = 0; i < n; i++) {
        let m = 0; for (let j = Math.max(0, i - 3); j <= Math.min(n - 1, i + 3); j++) { const v = Math.abs(d[j]); if (v > m) m = v; }
        if (m * 1.5 >= gate) { m = Math.abs(d[i]); for (const h of OS) { let acc = 0; for (let k = 0; k < 48; k++) { const j = i + k - 23; if (j >= 0 && j < n) acc += d[j] * h[k]; } const v = Math.abs(acc); if (v > m) m = v; } }
        if (m > env[i]) env[i] = m;
      }
    });
    return env;
  }
  function truePeak(chs, n) { let m = 0; const e = tpEnv(chs, n, 0); for (let i = 0; i < n; i++) if (e[i] > m) m = e[i]; return m; }
  function limit(chs, n, sr, ceil) { // look-ahead true-peak limiter: 4 ms ramp, 120 ms release
    const env = tpEnv(chs, n, ceil), W = Math.round(sr * 0.004), rel = 1 - Math.exp(-1 / (sr * 0.12)), req = new Float32Array(n);
    let any = false; for (let i = 0; i < n; i++) { req[i] = env[i] > ceil ? ceil / env[i] : 1; if (req[i] < 1) any = true; }
    if (!any) return false;
    const r = new Float32Array(n); let g = 1;
    for (let i = 0; i < n; i++) { let m = 1; for (let k = 0; k < W && i + k < n; k++) if (req[i + k] < m) m = req[i + k]; g = Math.min(m, g + (1 - g) * rel); r[i] = g; }
    let acc = 0; for (let i = 0; i < n; i++) { acc += r[i]; if (i >= W) acc -= r[i - W]; const gi = acc / Math.min(i + 1, W); chs.forEach(d => { d[i] *= gi; }); }
    return true;
  }
  const JINGLE = { rms: Math.pow(10, -17 / 20), ceilDb: -1.8 }; // the Vorbis q4 encode adds up to ~0.6 dB of true peak
  function master(chs, n, sr, ceilDb = JINGLE.ceilDb) {
    const src = chs.map(d => Float32Array.from(d)), ceil = Math.pow(10, ceilDb / 20);
    let g = JINGLE.rms / levels(src, n).rms;
    for (let it = 0; it < 8; it++) {
      chs.forEach((d, c) => { const s = src[c]; for (let i = 0; i < n; i++) d[i] = s[i] * g; });
      for (let p = 0; p < 3 && limit(chs, n, sr, ceil); p++);
      const err = JINGLE.rms / levels(chs, n).rms;
      if (Math.abs(20 * Math.log10(err)) < 0.01) break;
      g *= err;
    }
  }
  function measure(buf) {
    const chs = [...Array(buf.numberOfChannels)].map((_, c) => buf.getChannelData(c)), n = buf.length, db = v => Math.round(2000 * Math.log10(v)) / 100, { peak, rms } = levels(chs, n);
    return { rms: db(rms), peak: db(peak), truePeak: db(truePeak(chs, n)), seconds: Math.round(n / buf.sampleRate * 1000) / 1000 };
  }
  function wav(buf) {
    const ch = buf.numberOfChannels, n = buf.length, dv = new DataView(new ArrayBuffer(44 + n * ch * 2)), w = (o, s) => [...s].forEach((c, i) => dv.setUint8(o + i, c.charCodeAt(0)));
    w(0, 'RIFF'); dv.setUint32(4, 36 + n * ch * 2, true); w(8, 'WAVE'); w(12, 'fmt '); dv.setUint32(16, 16, true); dv.setUint16(20, 1, true); dv.setUint16(22, ch, true);
    dv.setUint32(24, buf.sampleRate, true); dv.setUint32(28, buf.sampleRate * ch * 2, true); dv.setUint16(32, ch * 2, true); dv.setUint16(34, 16, true); w(36, 'data'); dv.setUint32(40, n * ch * 2, true);
    const data = [...Array(ch)].map((_, c) => buf.getChannelData(c));
    for (let i = 0, o = 44; i < n; i++) for (let c = 0; c < ch; c++, o += 2) dv.setInt16(o, Math.max(-1, Math.min(1, data[c][i])) * 0x7fff, true);
    return new Blob([dv.buffer], { type: 'audio/wav' });
  }
  window.NestyMusic = {
    SONGS, STEMS: ['melody', 'harmony', 'bass', 'drums'], play, stop, setStem, position, render, wav, score, measure,
    isStemOn: s => !L.muted[s], playing: () => (L.run ? L.run.name : null), setVolume: v => { L.vol = v; if (L.run) L.run.out.gain.value = v; },
  };
})();
