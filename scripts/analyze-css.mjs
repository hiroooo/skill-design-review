#!/usr/bin/env node
/**
 * design-review : CSS computed style 統計から「ダサさ」シグナルを抽出する
 *
 * Usage:
 *   node analyze-css.mjs <styles.json>
 *
 * Input: Playwright で取得した {fonts, weights, spacings, colors, shadows, radii, animations}
 * Output: stdout に JSON で findings (issue 候補リスト)
 */

import { readFileSync } from 'node:fs';

const NG_FONTS = [
  'Comic Sans', 'Papyrus', 'Impact', 'Trajan',
  '創英角ポップ', 'HG行書', 'HG明朝', 'DFP', 'DF平成',
  'MS Pゴシック', 'MS P明朝', 'Curlz', 'Brush Script',
];

const MODERN_FONTS = [
  'Inter', 'Geist', 'Söhne', 'Sohne', 'Neue Haas', 'IBM Plex',
  'Pretendard', 'Noto Sans JP', 'Hiragino Sans', 'Source Han Sans',
  'Zen Maru Gothic', 'Zen Kaku Gothic',
  'SF Pro', 'system-ui', '-apple-system',
  'Roboto Flex',
];

function pct(n, d) { return d === 0 ? 0 : Math.round((n / d) * 100); }

function parseSpacings(arr) {
  return arr
    .flatMap(s => String(s).split(/\s+/))
    .map(v => parseFloat(v))
    .filter(v => !Number.isNaN(v) && v >= 0 && v < 1000);
}

function uniqueFamilies(fonts) {
  const set = new Set();
  fonts.forEach(f => {
    String(f).split(',').forEach(x => {
      const name = x.trim().replace(/['"]/g, '');
      if (name && name.length < 60) set.add(name);
    });
  });
  return [...set];
}

function uniqueColors(colors) {
  const set = new Set();
  colors.forEach(c => {
    if (!c || c === 'rgba(0, 0, 0, 0)' || c === 'transparent') return;
    set.add(String(c).trim());
  });
  return [...set];
}

function findings(styles) {
  const out = [];
  let cnt = { typography: 0, spacing: 0, color: 0, shadow: 0, radius: 0, anim: 0 };
  const nextId = (key) => `${key}_${String(++cnt[key]).padStart(3, '0')}`;

  // === Typography ===
  const families = uniqueFamilies(styles.fonts || []);
  const ng = families.filter(f => NG_FONTS.some(ng => f.toLowerCase().includes(ng.toLowerCase())));
  if (ng.length) {
    out.push({
      id: nextId('typography'),
      axis: 'typography',
      priority: 'high',
      title: `古臭フォント: ${ng.join(', ')}`,
      evidence: { css_finding: `font-family contains: ${ng.join(', ')}` },
      why_dasai: '2026 で「素人」記号として使われる定番 NG フォント',
      fix_suggestion: 'Inter / Noto Sans JP / Pretendard 等のモダンファミリへ',
      ref_doc: 'rules/20-dasai-typography.md NG フォント節',
    });
  }
  if (families.length >= 4) {
    out.push({
      id: nextId('typography'),
      axis: 'typography',
      priority: families.length >= 6 ? 'high' : 'medium',
      title: `font-family ${families.length} 種混在`,
      evidence: { css_finding: `unique families: ${families.slice(0, 8).join(', ')}${families.length > 8 ? '...' : ''}` },
      why_dasai: 'テイスト不統一、雑多に見える',
      fix_suggestion: '英 1 + 和 1 (+ monospace) の 2-3 種に集約',
      ref_doc: 'rules/20-dasai-typography.md S1',
    });
  }
  const weights = [...new Set((styles.weights || []).map(w => parseInt(w)).filter(w => !Number.isNaN(w)))];
  if (weights.length > 0 && weights.length <= 2) {
    out.push({
      id: nextId('typography'),
      axis: 'typography',
      priority: weights.length === 1 ? 'high' : 'medium',
      title: `font-weight ${weights.length} 種のみ、階層感が弱い`,
      evidence: { css_finding: `weights: ${weights.join(', ')}` },
      why_dasai: '太細の段階がなく、見出しと本文が同じ「重さ」に見える',
      fix_suggestion: 'h1 700 / h2 600 / body 400 / caption 300 の 4 段階を最低限',
      ref_doc: 'rules/20-dasai-typography.md S2',
    });
  }

  // === Spacing ===
  const spacings = parseSpacings(styles.spacings || []);
  if (spacings.length > 20) {
    const unique = [...new Set(spacings)];
    const mean = spacings.reduce((a, b) => a + b, 0) / spacings.length;
    const stdev = Math.sqrt(spacings.reduce((a, b) => a + (b - mean) ** 2, 0) / spacings.length);
    const oddRate = pct(spacings.filter(v => v > 0 && v % 4 !== 0).length, spacings.length);

    if (unique.length > 12) {
      out.push({
        id: nextId('spacing'),
        axis: 'whitespace',
        priority: 'high',
        title: `spacing 値が ${unique.length} 種類、デザイントークン不在`,
        evidence: { css_finding: `unique values: ${unique.slice(0, 10).join(', ')}px ...` },
        why_dasai: '余白がランダムに見える、目分量で打った印象',
        fix_suggestion: '4pt / 8pt grid の token (4, 8, 16, 24, 32, 48, 64) に集約',
        ref_doc: 'rules/21-dasai-spacing.md S1',
      });
    }
    if (stdev > 8) {
      out.push({
        id: nextId('spacing'),
        axis: 'whitespace',
        priority: 'medium',
        title: `spacing 標準偏差 ${stdev.toFixed(1)}px (8pt grid 逸脱)`,
        evidence: { css_finding: `stdev=${stdev.toFixed(1)} mean=${mean.toFixed(1)}` },
        why_dasai: '余白のリズムが揃わない',
        fix_suggestion: 'CSS 変数 (--space-*) にして統一',
        ref_doc: 'rules/21-dasai-spacing.md S1',
      });
    }
    if (oddRate > 25) {
      out.push({
        id: nextId('spacing'),
        axis: 'whitespace',
        priority: 'medium',
        title: `4pt grid 外の spacing が ${oddRate}%`,
        evidence: { css_finding: `奇数 px / grid 外: ${oddRate}%` },
        why_dasai: '13px / 17px / 22px のような半端な値は素人感',
        fix_suggestion: '4 の倍数に丸める、または 4pt token を導入',
        ref_doc: 'rules/21-dasai-spacing.md S2',
      });
    }
  }

  // === Color ===
  const colors = uniqueColors(styles.colors || []);
  if (colors.includes('rgb(0, 0, 0)')) {
    out.push({
      id: nextId('color'),
      axis: 'color',
      priority: 'medium',
      title: 'true black (#000) 使用',
      evidence: { css_finding: 'rgb(0, 0, 0) detected' },
      why_dasai: 'OLED で滲み / コントラスト過大、2026 は gray-900 (#111-1a) が標準',
      fix_suggestion: '#111111 / #1a1a1a に置換',
      ref_doc: 'rules/23-dasai-color-shadow.md S1',
    });
  }
  if (colors.includes('rgb(255, 255, 255)')) {
    out.push({
      id: nextId('color'),
      axis: 'color',
      priority: 'low',
      title: 'true white (#fff) 使用',
      evidence: { css_finding: 'rgb(255, 255, 255) detected' },
      why_dasai: '目の疲労、2026 は gray-50 (#fafafa) が標準',
      fix_suggestion: '#fafafa / #f5f5f5 に置換',
      ref_doc: 'rules/23-dasai-color-shadow.md S1',
    });
  }

  // === Shadow ===
  const shadows = (styles.shadows || []).filter(s => s && s !== 'none');
  shadows.forEach(s => {
    const m = String(s).match(/rgba?\([^)]*,\s*([\d.]+)\)/);
    if (m && parseFloat(m[1]) > 0.4) {
      out.push({
        id: nextId('shadow'),
        axis: 'modernity',
        priority: 'low',
        title: `box-shadow opacity ${m[1]} (重い)`,
        evidence: { css_finding: s },
        why_dasai: '2026 は rgba(0,0,0,0.05-0.12) の極薄が標準',
        fix_suggestion: 'opacity を 0.08-0.12 に、blur を 12-24px に',
        ref_doc: 'rules/23-dasai-color-shadow.md S6',
      });
    }
  });

  // === Border-radius ===
  const radii = [...new Set((styles.radii || []).filter(r => r && r !== '0px'))];
  if (radii.length >= 4) {
    out.push({
      id: nextId('radius'),
      axis: 'consistency',
      priority: 'medium',
      title: `border-radius ${radii.length} 種混在`,
      evidence: { css_finding: `radii: ${radii.slice(0, 6).join(', ')}` },
      why_dasai: 'design token 不在、要素ごとに角丸がバラバラ',
      fix_suggestion: 'small (4-8px) / medium (12-16px) / large (24px+) の 3 種に整理',
      ref_doc: 'rules/23-dasai-color-shadow.md S10',
    });
  }

  // === Animation ===
  const anims = styles.animations || [];
  const linearCount = anims.filter(a => a === 'linear').length;
  if (anims.length > 5 && pct(linearCount, anims.length) > 30) {
    out.push({
      id: nextId('anim'),
      axis: 'modernity',
      priority: 'medium',
      title: `linear easing が ${pct(linearCount, anims.length)}% で多用`,
      evidence: { css_finding: `linear / total: ${linearCount} / ${anims.length}` },
      why_dasai: '物理的に不自然、機械的な印象',
      fix_suggestion: 'cubic-bezier(0.4, 0, 0.2, 1) (ease-out) / spring に',
      ref_doc: 'rules/23-dasai-color-shadow.md S14',
    });
  }

  // === Modern サイン (highlights 用) ===
  const highlights = [];
  const modernFound = families.find(f => MODERN_FONTS.some(m => f.toLowerCase().includes(m.toLowerCase())));
  if (modernFound) highlights.push(`モダンフォント採用: ${modernFound}`);
  if (radii.length > 0 && radii.length <= 3) highlights.push(`border-radius が ${radii.length} 種で統一`);
  if (weights.length >= 4) highlights.push(`font-weight が ${weights.length} 段階で階層的`);

  return { findings: out, highlights, stats: { families: families.length, weights: weights.length, spacings_unique: [...new Set(spacings)].length, colors_unique: colors.length, radii_unique: radii.length } };
}

// === main ===
if (process.argv.length < 3) {
  console.error('Usage: analyze-css.mjs <styles.json>');
  process.exit(1);
}

const stylesPath = process.argv[2];
const styles = JSON.parse(readFileSync(stylesPath, 'utf-8'));
const result = findings(styles);
console.log(JSON.stringify(result, null, 2));
