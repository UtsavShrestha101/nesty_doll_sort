/* Nesty doll generator (GAME_SPEC §12.2, §12.3).
 * Builds a tinted, filter-free SVG doll from any layered skin: any color, any symbol SVG.
 * Same math the game uses at runtime: grayscale mask layers are multiplied by the doll color
 * (BlendMode.modulate), the symbol is drawn at symbolAnchor in the ink shade, and the lid
 * (top_* groups + face) is offset on Y for the nest animations.
 * Browser only (DOMParser). Exposes window.NestyDoll and the <nesty-doll> custom element.
 *
 * <nesty-doll color="red|#3E8EDE" symbol="heart|url.svg" svg="<svg…>" mode="subtle|large|none"
 *             skin="classic" lid="0..1" open silhouette shadow="false" half="top|bottom" height="120">
 */
(function () {
  const PRESETS = {
    red: { name: 'Cherry', base: '#E5484D', ink: '#A43434', light: '#F19A9D', symbol: 'heart' },
    orange: { name: 'Tangerine', base: '#F2893B', ink: '#AD6028', light: '#F8BE93', symbol: 'flower' },
    yellow: { name: 'Sunflower', base: '#F5C518', ink: '#92710D', light: '#FADF80', symbol: 'sun' },
    green: { name: 'Leaf', base: '#46A758', ink: '#38753C', light: '#99CFA3', symbol: 'leaf' },
    teal: { name: 'Lagoon', base: '#12A594', ink: '#157365', light: '#7DCEC4', symbol: 'wave' },
    blue: { name: 'Sky', base: '#3E8EDE', ink: '#326497', light: '#95C1ED', symbol: 'drop' },
    purple: { name: 'Grape', base: '#8E4EC6', ink: '#693887', light: '#C19EE0', symbol: 'star' },
    pink: { name: 'Bubblegum', base: '#E93D82', ink: '#A72D58', light: '#F394BA', symbol: 'bow' },
    navy: { name: 'Midnight', base: '#2F3E8F', ink: '#282C5D', light: '#979FC7', symbol: 'moon' },
    brown: { name: 'Cocoa', base: '#A0673C', ink: '#754929', light: '#CBAB94', symbol: 'acorn' },
    gold: { name: 'Gold', base: '#D4A22C', ink: '#8C5E12', light: '#FFF1B0', symbol: 'crown', gold: true },
  };
  const ALIAS = { cherry: 'red', tangerine: 'orange', sunflower: 'yellow', leaf: 'green', lagoon: 'teal', sky: 'blue', grape: 'purple', bubblegum: 'pink', midnight: 'navy', cocoa: 'brown' };
  const SKIN = { artboard: [512, 768], splitY: 400, lidLiftPx: 120, symbolAnchor: [256, 590], symbolSize: 110, symbolSizeLarge: 150, badgeRadius: 92 };
  const GROUPS = ['shadow', 'bottom_mask', 'bottom_detail', 'top_mask', 'face', 'top_detail', 'shine_top', 'shine_bottom'];
  const MASKS = ['bottom_mask', 'top_mask'];
  const TOP = ['top_mask', 'face', 'top_detail', 'shine_top'];
  const BOTTOM = ['shadow', 'bottom_mask', 'bottom_detail', 'shine_bottom', 'symbol', 'interior'];
  const WOOD = '#E6C08C';
  const GOLD_RAMP = [[0, '#4A3008'], [0.3, '#7A5210'], [0.55, '#B07E1C'], [0.75, '#D9A634'], [0.9, '#F0C452'], [1, '#FFE89A']];
  const cfg = { skinsBase: 'skins/', symbolsBase: 'icons/' };
  const NS = 'http://www.w3.org/2000/svg';

  const hex2rgb = h => { h = String(h).replace('#', ''); if (h.length === 3) h = h.split('').map(c => c + c).join(''); const n = parseInt(h, 16); return [n >> 16 & 255, n >> 8 & 255, n & 255]; };
  const rgb2hex = c => '#' + c.map(v => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, '0')).join('').toUpperCase();
  const isHex = v => /^#([0-9a-f]{3}|[0-9a-f]{6})$/i.test(v || '');
  const isGray = v => { if (!isHex(v)) return false; const [r, g, b] = hex2rgb(v); return r === g && g === b; };
  const mul = (base, gray) => { const a = hex2rgb(base), g = hex2rgb(gray); return rgb2hex(a.map((v, i) => v * g[i] / 255)); };
  const ramp = (stops, t) => { for (let i = 1; i < stops.length; i++) if (t <= stops[i][0]) { const [t0, c0] = stops[i - 1], [t1, c1] = stops[i], k = (t - t0) / (t1 - t0 || 1), a = hex2rgb(c0), b = hex2rgb(c1); return rgb2hex(a.map((v, j) => v + (b[j] - v) * k)); } return stops[stops.length - 1][1]; };

  // OKLCH, so derived ink/light shades keep the same perceived hue for any input color.
  const lin = c => { c /= 255; return c <= 0.04045 ? c / 12.92 : Math.pow((c + 0.055) / 1.055, 2.4); };
  const gam = c => (c <= 0.0031308 ? 12.92 * c : 1.055 * Math.pow(c, 1 / 2.4) - 0.055) * 255;
  function toOklch(hex) {
    const [r, g, b] = hex2rgb(hex).map(lin);
    const l = Math.cbrt(0.4122214708 * r + 0.5363325363 * g + 0.0514459929 * b), m = Math.cbrt(0.2119034982 * r + 0.6806995451 * g + 0.1073969566 * b), s = Math.cbrt(0.0883024619 * r + 0.2817188376 * g + 0.6299787005 * b);
    const L = 0.2104542553 * l + 0.793617785 * m - 0.0040720468 * s, A = 1.9779984951 * l - 2.428592205 * m + 0.4505937099 * s, B = 0.0259040371 * l + 0.7827717662 * m - 0.808675766 * s;
    return [L, Math.hypot(A, B), Math.atan2(B, A)];
  }
  function fromOklch(L, C, H) {
    const A = C * Math.cos(H), B = C * Math.sin(H);
    const l = (L + 0.3963377774 * A + 0.2158037573 * B) ** 3, m = (L - 0.1055613458 * A - 0.0638541728 * B) ** 3, s = (L - 0.0894841775 * A - 1.291485548 * B) ** 3;
    return [4.0767416621 * l - 3.3077115913 * m + 0.2309699292 * s, -1.2684380046 * l + 2.6097574011 * m - 0.3413193965 * s, -0.0041960863 * l - 0.7034186147 * m + 1.707614701 * s];
  }
  function oklchHex(L, C, H) {
    for (let i = 0; i < 40; i++) { const c = fromOklch(L, C, H); if (c.every(v => v >= -0.0005 && v <= 1.0005)) return rgb2hex(c.map(v => gam(Math.max(0, Math.min(1, v))))); C *= 0.92; }
    return rgb2hex(fromOklch(L, 0, H).map(v => gam(Math.max(0, Math.min(1, v)))));
  }
  function shades(base) {
    const [L, C, H] = toOklch(base);
    return { base: rgb2hex(hex2rgb(base)), ink: oklchHex(Math.max(0.24, L - 0.17), C * 0.85, H), light: oklchHex(Math.min(0.94, L + 0.17), C * 0.6, H) };
  }
  function resolve(input) {
    const key = ALIAS[input] || input;
    if (PRESETS[key]) return { id: key, ...PRESETS[key] };
    if (isHex(input) || isHex('#' + input)) { const hex = input[0] === '#' ? input : '#' + input; return { id: null, name: hex.toUpperCase(), symbol: null, ...shades(hex) }; }
    return { id: 'red', ...PRESETS.red };
  }
  const clean = t => { let s = String(t).replace(/<metadata>[\s\S]*?<\/metadata>/g, '').replace(/<\?xml[^>]*>/, '').trim(); if (/^<svg\b/i.test(s) && !/^<svg[^>]*\sxmlns=/i.test(s)) s = s.replace(/^<svg\b/i, `<svg xmlns="${NS}"`); return s; };

  function symbolGroup(doc, svgText, ink, mode) {
    const s = new DOMParser().parseFromString(clean(svgText), 'image/svg+xml').documentElement;
    if (!s || s.nodeName !== 'svg') return null;
    const vb = (s.getAttribute('viewBox') || `0 0 ${parseFloat(s.getAttribute('width')) || 128} ${parseFloat(s.getAttribute('height')) || 128}`).split(/[\s,]+/).map(Number);
    const large = mode === 'large', S = large ? SKIN.symbolSizeLarge * 0.78 : SKIN.symbolSize, [ax, ay] = SKIN.symbolAnchor, k = S / Math.max(vb[2], vb[3]);
    const g = doc.createElementNS(NS, 'g'); g.setAttribute('id', 'symbol');
    if (large) { const c = doc.createElementNS(NS, 'circle'); [['cx', ax], ['cy', ay], ['r', SKIN.badgeRadius], ['fill', '#FFF8EC'], ['stroke', ink], ['stroke-width', 8]].forEach(([a, v]) => c.setAttribute(a, v)); g.appendChild(c); }
    const inner = doc.createElementNS(NS, 'g');
    inner.setAttribute('transform', `translate(${(ax - (vb[0] + vb[2] / 2) * k).toFixed(2)} ${(ay - (vb[1] + vb[3] / 2) * k).toFixed(2)}) scale(${k.toFixed(4)})`);
    inner.setAttribute('fill', ink); inner.setAttribute('color', ink);
    if (!large) inner.setAttribute('opacity', '0.94');
    [...s.childNodes].forEach(n => {
      if (n.nodeType !== 1 || /^(metadata|title|desc|script|style)$/i.test(n.nodeName)) return;
      const c = doc.importNode(n, true);
      [c, ...c.querySelectorAll('*')].forEach(e => ['fill', 'stroke'].forEach(a => { const v = e.getAttribute(a); if (v && v !== 'none' && !v.startsWith('url(')) e.setAttribute(a, ink); }));
      inner.appendChild(c);
    });
    g.appendChild(inner);
    return g;
  }

  function uniquify(svg, pre, keepGroups) {
    const map = {};
    svg.querySelectorAll('[id]').forEach(e => { const id = e.getAttribute('id'); if (keepGroups && GROUPS.includes(id)) return; map[id] = `${pre}-${id}`; e.setAttribute('id', map[id]); });
    svg.querySelectorAll('*').forEach(e => [...e.attributes].forEach(at => {
      if (at.value.includes('url(#')) e.setAttribute(at.name, at.value.replace(/url\(#([^)]+)\)/g, (m, id) => map[id] ? `url(#${map[id]})` : m));
      if (/href$/.test(at.name) && at.value[0] === '#' && map[at.value.slice(1)]) e.setAttribute(at.name, '#' + map[at.value.slice(1)]);
    }));
  }

  let uid = 0;
  /** Synchronous build from skin SVG text. Options: color, ink, light, symbolSvg, mode, lid, open, silhouette, shadow, half, headroom, uniqueIds */
  function build(skinText, o = {}) {
    const col = resolve(o.color || 'red'), ink = o.ink || col.ink, gold = !!(o.gold ?? col.gold);
    const doc = new DOMParser().parseFromString(clean(skinText), 'image/svg+xml'), svg = doc.documentElement;
    const byId = id => svg.querySelector(`[id="${id}"]`);
    const tint = o.silhouette ? g => mul(WOOD, g) : gold ? g => ramp(GOLD_RAMP, Math.pow(hex2rgb(g)[0] / 255, 2)) : g => mul(col.base, g);
    const clones = {};
    MASKS.forEach(id => {
      const grp = byId(id); if (!grp) return;
      [grp, ...grp.querySelectorAll('*')].forEach(e => ['fill', 'stroke'].forEach(a => {
        const v = e.getAttribute(a); if (!v || v === 'none') return;
        const m = v.match(/^url\(#(.+)\)$/);
        if (m) {
          if (!clones[m[1]]) { const src = byId(m[1]); if (!src) return; const cl = src.cloneNode(true); clones[m[1]] = m[1] + '__tint'; cl.setAttribute('id', clones[m[1]]); cl.querySelectorAll('stop').forEach(s => { const sc = s.getAttribute('stop-color'); if (isGray(sc)) s.setAttribute('stop-color', tint(sc)); }); src.parentNode.appendChild(cl); }
          e.setAttribute(a, `url(#${clones[m[1]]})`);
        } else if (isGray(v)) e.setAttribute(a, tint(v));
      }));
    });
    if (o.silhouette) { ['bottom_detail', 'face', 'top_detail'].forEach(id => byId(id)?.remove()); ['shine_top', 'shine_bottom'].forEach(id => byId(id)?.setAttribute('opacity', '0.45')); }
    const mode = o.silhouette ? 'none' : (o.mode || 'subtle');
    const anchorAfter = byId('bottom_detail') || byId('bottom_mask');
    if (mode !== 'none' && o.symbolSvg && anchorAfter) { const g = symbolGroup(doc, o.symbolSvg, ink, mode); if (g) anchorAfter.after(g); }
    const lid = Math.max(0, Math.min(1.5, +o.lid || 0));
    if ((lid > 0 || o.open) && byId('top_mask')) {
      const rim = doc.createElementNS(NS, 'g'); rim.setAttribute('id', 'interior');
      rim.innerHTML = `<ellipse cx="256" cy="398" rx="148" ry="21" fill="${o.silhouette ? mul(WOOD, '#CFCFCF') : gold ? '#E9BE4E' : mul(col.base, '#D6D6D6')}"/><ellipse cx="256" cy="401" rx="134" ry="15" fill="#2A1608" opacity=".88"/>`;
      byId('top_mask').before(rim);
    }
    if (lid > 0) TOP.forEach(id => byId(id)?.setAttribute('transform', `translate(0 ${(-SKIN.lidLiftPx * lid).toFixed(1)})`));
    if (o.half === 'top') BOTTOM.forEach(id => byId(id)?.remove());
    if (o.half === 'bottom') TOP.forEach(id => byId(id)?.remove());
    if (o.shadow === false) byId('shadow')?.remove();
    if (lid > 0 || o.headroom) svg.setAttribute('viewBox', '0 -140 512 908');
    svg.removeAttribute('width'); svg.removeAttribute('height');
    if (o.uniqueIds) uniquify(svg, o.idPrefix || 'nd' + (++uid), true);
    return new XMLSerializer().serializeToString(svg);
  }

  const texts = new Map();
  const fetchText = url => { if (!texts.has(url)) texts.set(url, fetch(url).then(r => { if (!r.ok) throw new Error('Could not load ' + url); return r.text(); })); return texts.get(url); };
  const skinUrl = id => `${cfg.skinsBase}${id}/doll.svg`;
  const symbolUrl = name => /[/.]/.test(name) ? name : `${cfg.symbolsBase}${name}.svg`;
  /** Async: loads the skin and symbol, then builds. Same options as build, plus skin, symbol. */
  async function render(o = {}) {
    const col = resolve(o.color || 'red');
    const skin = o.skinSvg || await fetchText(skinUrl(o.skin || 'classic'));
    let sym = o.symbolSvg;
    const name = o.symbol || col.symbol;
    if (!sym && (o.mode || 'subtle') !== 'none' && name) sym = await fetchText(symbolUrl(name)).catch(() => null);
    return build(skin, { ...o, symbolSvg: sym });
  }

  const urls = new Map();
  class NestyDollElement extends HTMLElement {
    static get observedAttributes() { return ['color', 'ink', 'symbol', 'svg', 'mode', 'skin', 'lid', 'open', 'silhouette', 'shadow', 'half', 'height']; }
    connectedCallback() { if (!this.style.display) this.style.display = 'inline-block'; this.style.lineHeight = '0'; this.sync(); }
    attributeChangedCallback() { if (this.isConnected) this.sync(); }
    opts() {
      const a = n => this.getAttribute(n), b = n => { const v = a(n); return v !== null && v !== 'false' && v !== '0'; };
      return { color: a('color') || 'red', ink: a('ink') || undefined, symbol: a('symbol') || undefined, symbolSvg: a('svg') || undefined, mode: a('mode') || 'subtle', skin: a('skin') || 'classic', lid: parseFloat(a('lid')) || 0, open: b('open'), silhouette: b('silhouette'), shadow: a('shadow') === null ? true : b('shadow'), half: a('half') || undefined };
    }
    async sync() {
      const o = this.opts(), h = parseFloat(this.getAttribute('height'));
      if (h) { this.style.height = h + 'px'; this.style.width = Math.round(h * (o.lid > 0 ? 512 / 908 : 2 / 3)) + 'px'; }
      const key = JSON.stringify(o); if (key === this._key) return; this._key = key;
      const tok = (this._tok = (this._tok || 0) + 1);
      let url = urls.get(key);
      if (!url) { try { url = 'data:image/svg+xml;charset=utf-8,' + encodeURIComponent(await render(o)); urls.set(key, url); } catch (e) { console.warn('[nesty-doll]', e.message); return; } }
      if (tok !== this._tok) return;
      let img = this.firstElementChild;
      if (!img || img.tagName !== 'IMG') { this.textContent = ''; img = document.createElement('img'); img.alt = ''; img.draggable = false; img.style.cssText = 'display:block;width:100%;height:100%;object-fit:contain;object-position:50% 100%;pointer-events:none'; this.appendChild(img); }
      img.src = url;
    }
  }
  if (!customElements.get('nesty-doll')) customElements.define('nesty-doll', NestyDollElement);
  window.NestyDoll = { PRESETS, ALIAS, SKIN, GROUPS, config: c => Object.assign(cfg, c), resolve, shades, toOklch, oklchHex, mul, build, render, fetchText };
})();
