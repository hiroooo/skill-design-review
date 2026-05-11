# Hero Visual パターン — 2026 SaaS/indie LP の到達基準

LP の Hero における「visual の置き方」は、Brand Promise (rule 25) と Image Density (rule 22) の交差点。
ここでは **どの visual パターンを採るべきか** と、**選んだパターンを「ダサい」域に落とさないための実装基準** を定義する。

> **重要**: meta-note.net や Linear のような具体例は、それぞれの context での最適解にすぎない。
> モバイルアプリの LP に Linear 風 SaaS dashboard mock を置くのは不適切、というように、
> **「コンテンツ種別 → 適切な hero visual pattern」のマッピング** を判断軸として使う。

## 1. コンテンツ別 hero pattern の対応表

| 商品種別 | 推奨 hero pattern | 代表例 |
|---|---|---|
| **iOS / Android indie アプリ** (Sublog / 集中カプセル等) | **iPhone bezel + screen content** / カルーセル | meta-note.net / Apple.com/iphone |
| **B2B SaaS dashboard 系** | **Browser frame + app screenshot** / 斜め配置 | Linear / Notion / Vercel dashboard |
| **API / Dev tools** | **コードブロック + flowing animation** | Stripe / Vercel API |
| **マーケ / no-code** | **大型 hero illustration + 浮遊 UI element** | Webflow / Framer |
| **ハードウェア / 物理製品** | **製品の高解像 photo + isometric mock** | Tesla / Nothing |
| **教育 / 学習サービス** | **学習画面 mock + 進捗 visual + マスコット** | meta-note / Duolingo |
| **食事 / レシピ系** | **料理 hero photo + iPhone screen 小** | Whisk / Mealime |

判定ロジック:
- アプリ商品なのに browser mock を置いている → 「カテゴリ違反」`high`
- 物理製品なのに iPhone bezel しか置いていない → `medium`

## 2. iPhone / device bezel を使う時の品質基準

Sublog で確立した到達基準。下記 7 項目のうち **5 つ以上満たして「合格」、3 つ以下は `medium` issue 化**。

### 2.1 frame 本体
- `width: 280-360px` (desktop)、`max-width: 92%` mobile fallback
- `padding: 8px` (bezel 厚)、`border-radius: 44px` (round corners)
- `background: linear-gradient(to bottom, #1a1c20 0%, #000 100%)` (top やや明るく、底まで真っ黒)
- **aspect-ratio は指定せず**、screen の固定 height で「下端 cut」を演出する (meta-note 流)
  - aspect 9/19.5 は実機リアルだが「縦長すぎ」になり hero copy area とのバランスが崩れる
  - **screen height 固定 (例 555px)** で frame の総 height は 571px 前後に収まる、見やすい

### 2.2 box-shadow を 3 層 + inset highlight にする
**❌ NG**: `box-shadow: 0 25px 50px -12px rgba(0,0,0,0.25)` (Tailwind `shadow-2xl` 単体、平面感残る)

**✅ OK**: 多層 + inset highlight で立体感を担保
```css
box-shadow:
  rgba(0, 0, 0, 0.12) 0 50px 100px -20px,
  rgba(0, 0, 0, 0.15) 0 30px 60px -30px,
  rgba(255, 255, 255, 0.10) 0 -2px 6px 0 inset;
```

### 2.3 ::after で accent color の glow ring を浮かす
```css
.iphone-frame::after {
  content: '';
  position: absolute;
  inset: -2px;
  border-radius: inherit;
  background: linear-gradient(to right, var(--accent-30), var(--accent-30), var(--accent-30));
  filter: blur(8px);
  opacity: 0.6;
  z-index: -1;
}
```

これで frame が周りに薄く光を放つ。**アプリの accent color と一致** していること必須 (バラついた色は逆効果)。

### 2.4 Dynamic Island / Notch を上部中央に
- `width: 100-120px` / `height: 24-32px` / `border-radius: 999px or rounded-b-2xl`
- 内側に camera dot (radial-gradient + inset highlight) を入れると更にリアル

### 2.5 side button を 3-4 個 配置 (overflow visible 必須)
- 左: ringer (top:80px h:28px) + volume up (top:120px h:48px) + volume down (top:178px h:48px)
- 右: power (top:130px h:64px)
- 各 `width: 3px / background: linear-gradient(to right, #2a2b2e, #1a1c20)`

これがあると一気に「iPhone らしさ」が上がる。**frame の overflow が hidden だと button が消える** ので注意。

### 2.6 screen 内部に固定 height (550-600px) + overflow hidden
- aspect-ratio 指定だと frame 全体が縦長になる
- **screen の height を直接固定** (例 `height: 555px`) して content が下端で切れる演出に
- `border-radius: 36px` (frame radius - padding)、画面下も丸い (status bar / home indicator の自然な見切れ)
- 中身の画像/コンテンツは `object-fit: cover; object-position: center top;` で「上から開始」

### 2.7 perspective rotation は控えめ or 撤去
- `transform: perspective(1400px) rotateY(-5deg)` は「Apple マーケ風」が出るが、
  glow ring との相性が悪い (light 反射が破綻) のと、 modern SaaS LP では「まっすぐ立つ」のが標準
- どうしても傾けたいなら 3deg 以内、screen の object-position も傾きと合わせる

## 3. カルーセル / auto-rotate の品質基準

複数画面を見せたい場合の最低基準:

| 項目 | 基準 |
|---|---|
| 切替速度 | 3.0-4.0s (3.2s 推奨)、2 秒未満は読みづらい |
| 操作可能性 | scroll-snap-type で swipe / drag 可、CSS のみで実装 |
| pause トリガ | `pointerenter` / `focusin` で auto-rotate を止める |
| indicator | ドット (active 22×6px / inactive 6×6px) で現在位置表示 |
| 切替動作 | `behavior: 'smooth'` 必須、step じゃなくスライド |

実装スニペット (Sublog で確立):
```js
const slides = carousel.querySelectorAll('.hero-slide');
let idx = 0;
let paused = false;
setInterval(() => {
  if (paused) return;
  idx = (idx + 1) % slides.length;
  slides[idx].scrollIntoView({ behavior: 'smooth', inline: 'start' });
}, 3200);
['pointerenter', 'focusin'].forEach(e => carousel.addEventListener(e, () => paused = true));
['pointerleave', 'focusout'].forEach(e => carousel.addEventListener(e, () => paused = false));
```

## 4. Hero 全体レイアウトの品質基準

- container max-width **1024-1280px** (rule 21 S13)、indie アプリは 1152 推奨
- hero-grid `1fr 1fr` の 2 カラム (768px 以下で 1 カラム)、gap **48-64px**
- 左カラム: eyebrow (12px 700 wt accent color) → h1 (32-44px 800 wt) → lede (16px 1.75lh) → CTA (App Store badge + meta)
- 右カラム: device mock / illustration

左右の縦の長さがアンバランス (片側が空白多い) なら、左カラムに **trust line 1 行** ("公開済 / 評価 4.7 / N 万 DL" 等) を追加して埋める。

## 5. 「shiny but soulless」を避ける 3 か条

- **glow ring の色がアプリ accent と乖離** → 逆効果、フェイク感 → `high`
- **device frame が本物以上にリアル過ぎる** (camera lens の点滅光 / 反射光) → ノイズ → `medium`
- **screen の中身がデモ用 placeholder で実機と乖離** → ユーザー期待を裏切る → `high`

## 6. Vision サブ判定

`captures/desktop-light.png` の hero 範囲 (上 30%) を Read で観察し:
- device frame の有無、bezel 厚、shadow の層数 (1 / 2-3 / 4+)
- glow ring の存在、color の accent 一致度
- screen 内 content の中身 (実機スクショ / 加工 / placeholder)
- frame の縦サイズと hero copy area の縦バランス

これらから 2.x の項目を機械的にチェックし、不足項目を `issues.json` の issue として:

```jsonc
{
  "id": "hero_visual_001",
  "axis": "modernity",
  "priority": "medium",
  "effort": "moderate",
  "title": "device bezel が 1 層 shadow で立体感不足",
  "evidence": {"screenshot": "captures/desktop-light.png"},
  "why_dasai": "Linear/meta-note 等 2026 標準は 3 層 shadow + glow ring が定石、平面的に見える",
  "fix_suggestion": "box-shadow を 3 層 (50px100px-20px, 30px60px-30px, inset -2px6px) + ::after の accent glow ring blur 8px opacity 0.6 に変更",
  "ref_doc": "rules/30-hero-visual-patterns.md §2.2-2.3",
  "component_hint": ".iphone-frame / .phone-frame / .device-mock"
}
```

## 7. 修正 prompt テンプレート (issue card の data-prompt)

`fix_prompt` に下記テンプレを入れて Claude へ paste しやすくする:

```
issues.json の {issue_id} を修正してください。

[Issue] device frame の box-shadow / glow ring が不足
[Why] 2026 SaaS LP 標準は 3 層 shadow + accent glow ring (rules/30-hero-visual-patterns.md §2.2-2.3)
[Fix]
- box-shadow を 3 層 + inset highlight に変更
- ::after で accent color の glow ring (blur 8px opacity 0.6) を追加
- 参考実装: https://meta-note.net (HeroSection.tsx の phone-frame)
- カテゴリが違うなら Linear / Notion / Stripe の hero を参考に、商品カテゴリに合った visual pattern を選ぶ

該当ファイル (style.scss / globals.css 等) を grep + Edit で直接修正してください。
```
