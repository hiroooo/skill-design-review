# 配色 / shadow / radius / animation の「ダサい」シグナル

## 配色

### S1. true black (#000) / true white (#fff)
- `#000000` 完全黒 / `#ffffff` 完全白の使用 → `medium`
- 推奨: gray-900 (`#111111` / `#1a1a1a`) / gray-50 (`#fafafa` / `#f5f5f5`)
- 理由: true black は OLED で滲む / OLEDでない panel ではコントラスト過大で目が疲れる

### S2. 鮮やか原色 3 色超
- HSL S > 90% かつ L が 40-60 の色を 3 色以上同時使用 → `high`
- e.g. red(255,0,0) + green(0,255,0) + blue(0,0,255) → 1990 年代

### S3. 補色不在 / 単調
- 全部同色相 (e.g. 全部青) で対比なし → `low`
- アクセント (主訴求) 1-2 色で締めるのが理想

### S4. 4 色以上の gradient
- linear-gradient(red, yellow, green, blue, purple) のような虹色 → `high`
- 推奨: 1-2 色の subtle (blue → teal / gray → white)

### S5. 紫→ピンク鋭角グラデ
- 「2010 年代 Dribbble 風」、もう古い → `medium`

## Shadow

### S6. 重い black shadow
- box-shadow に opacity > 0.3 と blur > 15 → `medium`
- 推奨: rgba(0,0,0,0.05-0.12), blur 8-24

### S7. blur=0 の hard shadow
- box-shadow: 4px 4px 0 #000 のような flat shadow → スキューモーフィック過去感 → `low`
- 例外: neo-brutalist デザイン狙いの場合は OK

### S8. 四方均等 shadow (方向性なし)
- box-shadow: 0 0 20px rgba(0,0,0,0.3) → 浮遊感不自然 → `low`
- 推奨: 下方向 (Y +4-12) で重力感

### S9. text-shadow ベベル/エンボス
- text-shadow: 1px 1px 0 #ccc, 2px 2px 0 #aaa のような 2000 年代 emboss → `high`

## Border-radius

### S10. radius unique 値 4 種以上
- 同一 viewport で border-radius unique 値 ≥ 4 → `medium`
- 推奨: 2-3 種 (small 4-8px / medium 12-16px / large 24px+)

### S11. 全部同じ radius (デザイントークンなしで偶然)
- 全要素 8px radius → 整っているが単調 → `low` (悪くない)

### S12. ボタンが完全 pill (border-radius: 9999px) で巨大
- 推奨: 中サイズ button は 8-12px radius、CTA だけ pill

### S13. 角丸の不規則 (左上だけ rounded 等)
- border-radius: 16px 0 0 16px のような半端 → 意図不明 → `low`

## Animation

### S14. linear easing の多用
- transition-timing-function: linear が CSS 内で 30% 超 → `medium`
- 推奨: ease-out / cubic-bezier(0.4, 0, 0.2, 1) (Material Standard)

### S15. animation-duration > 800ms (長すぎ)
- 待ち時間として体感、「重い UI」 → `medium`
- 推奨: 150-300ms

### S16. hover transform で過大拡大
- transform: scale(1.2) hover → `medium`、不安定感
- 推奨: scale(1.02-1.05) + translateY(-2px) のような subtle

### S17. bounce / jelly 効果
- spring が overshoot しまくる → `low` (一部ブランドは OK)
- 2026 は subtle spring が主流

## Filled icon の罠 (アプリ向け重要)

### S16. `Icons.check_circle` (filled) が flat color で薄く見える

Material/iOS の filled icon は内部に明色シェイプが含まれることがあり、
Theme primary 色を渡しても視覚的に弱くなる罠:

- `Icons.check_circle` (filled) — 中の checkmark が明色シェイプとして抜かれる
- `Icons.cancel` (filled) — 同様
- `Icons.add_circle` (filled) — 同様

判定:
- スクショで Vision が「icon が予期した色に見えない」「弱く見える」と感じたら flag
- Flutter コードレベルでは Theme.primary を使っているのに視覚的に薄い場合

修正候補:
- `_rounded` variant に置き換え (`Icons.check_circle_rounded` 等)
- `_outlined` で描いて中を別 Icon で重ねる
- size を 18 → 20 にあげる
- 明示色で Color(0xFF...) hardcode (Theme primary が想定外に薄いとき)

例 (eitango-image 第 2 round audit):
- Paywall benefit list で `Icons.check_circle` size 18 + Theme.primary 使用
- 実機では gray-out 気味、ユーザーが「✓ がある」と認知しづらい
- 修正: `Icons.check_circle_rounded` size 20 + 明示 #FF6B35 で解決

## CTA ボタン

### S18. グラデーションボタン
- background: linear-gradient(to bottom, #fff, #ccc) → 2000 年代 Web → `high`
- 推奨: solid color + 微 hover lighten

### S19. 多重 box-shadow ベベル
- inset shadow + outer shadow + border の 3 重防御 → `high`
- 推奨: 1 layer の subtle shadow

### S20. ボタン内部に gradient text
- 「派手にしよう」のセンスで text に gradient
- 例外: ブランドが派手系なら OK、普通の SaaS では `medium`

## 機械判定例

```js
// True black/white
if (styles.colors.includes('rgb(0, 0, 0)')) issue('color_true_black', 'medium', '#000 完全黒使用');
if (styles.colors.includes('rgb(255, 255, 255)')) issue('color_true_white', 'medium', '#fff 完全白');

// Radius unique
const radii = new Set(styles.radii.filter(r => r !== '0px'));
if (radii.size >= 4) issue('radius_count', 'medium', `radius unique ${radii.size}`);

// Shadow opacity
styles.shadows.forEach(s => {
  const m = s.match(/rgba?\([^)]*,\s*([\d.]+)\)/);
  if (m && parseFloat(m[1]) > 0.3) issue('shadow_heavy', 'low', `shadow opacity ${m[1]}`);
});

// Linear easing
const linearCount = styles.animations.filter(a => a === 'linear').length;
if (linearCount / styles.animations.length > 0.3) issue('anim_linear', 'medium', 'linear easing 多用');
```

## 良い点ハイライト

- gray-900 / gray-50 (純黒/純白でない)
- subtle 1-2 色 gradient
- shadow opacity 0.05-0.12
- radius が 2-3 種類で統一
- ease-out / spring easing
- 主 CTA だけ高彩度、他は muted
