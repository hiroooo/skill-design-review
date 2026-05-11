# 余白の「ダサい」シグナル

8pt grid (or 4pt grid) を基本に、spacing scale の整列度で判定。

## ダサさシグナル

### S1. spacing 値がランダム (grid 未使用)
- 同一ページ内の margin / padding 値の unique 数 > 12
- 標準偏差 (stdev) > 8
- 4pt grid 適合率 < 75% (4 で割り切れない値が 25% 超)

→ priority `high`、説明「spacing scale が破綻、トークン未使用」

```js
const all = styles.spacings
  .flatMap(s => s.split(/\s+/).map(v => parseFloat(v)).filter(v => !isNaN(v)));
const unique = [...new Set(all)];
const mean = all.reduce((a,b)=>a+b, 0) / all.length;
const stdev = Math.sqrt(all.reduce((a,b)=>a+(b-mean)**2, 0) / all.length);
const oddRate = all.filter(v => v > 0 && v % 4 !== 0).length / all.length;

if (unique.length > 12) issue('space_unique', 'high', `spacing unique 値 ${unique.length}`);
if (stdev > 8) issue('space_stdev', 'medium', `spacing stdev ${stdev.toFixed(1)}px`);
if (oddRate > 0.25) issue('space_grid_off', 'medium', `4pt grid 外 ${(oddRate*100).toFixed(0)}%`);
```

### S2. mobile で左右マージン 0 (端張り付き)
- 375px viewport で text/button が左右端 < 16px → `high`
- container max-width が none / 100vw → `medium`

→ 「チラシっぽい」「楽天 LP 風」とも形容される

### S3. 余白率 < 25% (詰め込み広告型)
- スクショ全体に対して背景色のみのピクセル比率
- 25% 未満で `high`、35-55% が理想、70% 超は `low` (スカスカ)

→ Vision で判定 (ピクセル走査で背景色一致度を概算)

### S4. section 間リズム単調
- 主要 section 5 つ以上で margin-top / padding-top の unique 値 ≤ 1
- 全部同じ 80px → `medium` (リズム感ゼロ)

→ 推奨: hero 96px / feature 80px / footer 64px のように階層的

### S5. 縦方向リズム破壊 (vertical rhythm)
- baseline grid 未使用で行間がバラバラ
- font-size 16px / line-height 1.5 = 24px が baseline、24px の倍数 (24/48/72) で各 spacing が並ぶと美しい
- 多くの古臭いサイトは baseline 無視 → `low`

### S6. padding 四方非対称で意図不明
- card 内 padding-top 12 / right 8 / bottom 16 / left 24 のようなランダム → `medium`
- 推奨: 上下 16px / 左右 24px、または全方向 16px

### S7. 隣接要素間距離が「画面端 < 要素間」
- 画面外周 padding 8px、要素間 gap 24px → 構図散漫 → `medium`
- 階層: 画面端 (16-24px) > 要素 padding (16-24px) > 要素間 gap (8-12px)

### S8. max-width の不統一
- section ごとに max-width が違う (1200, 1100, 980, 1400) → `medium`
- 1 サイトに 2 種類くらいまで (narrow 728px / wide 1200px 等)

### S9. flex/grid gap 未使用で margin で空ける
- gap プロパティ使えるのに margin で空けて、最後の要素にも margin-bottom が残る → `low`

### S10. 縦中央崩壊
- card / hero の content が visually centered ではない (上寄り / 下寄り) → `medium`
- flex column で justify-content / align-items 未指定が原因

## 良い点ハイライト

- spacing 値が [4, 8, 16, 24, 32, 48, 64, 96] みたいに整列
- mobile で左右 16-20px、desktop で max-width 1200px が一貫
- section ごとに余白が階層的に変化
- baseline grid が見える (font-size と spacing が 24px 倍数)

## 補助: デザイントークンの推奨

```css
:root {
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;
  --space-6: 24px;
  --space-8: 32px;
  --space-12: 48px;
  --space-16: 64px;
  --space-24: 96px;
}
```

→ 改修提案で参考に提示

### S11. Chrome 占有率が 30% 超 (アプリ向け重要シグナル)

ナビゲーション要素 (top AppBar / search / filter chips / bottom nav 等) が縦の N% を食うと
ユーザーは毎回 chrome をスクロールしてからコンテンツに到達する。**毎日使うアプリで致命的**。

判定 (アプリ画面 / 主に first viewport):
```
chrome_height = AppBar + (search bar) + (filter chips) + (banner) + (bottom nav)
content_visible_height = viewport_height - chrome_height
chrome_ratio = chrome_height / viewport_height
```

| chrome_ratio | priority | 解釈 |
|---|---|---|
| ≤ 25% | OK | 健全 |
| 25-35% | `medium` | やや重い、機能アプリなら許容 |
| 35-45% | `high` | コンテンツが initial viewport で見えない、毎日使うアプリで離脱誘発 |
| > 45% | `high` | chrome が UI を支配、ナビゲーションを設計し直す |

例 (eitango-image 第 1 round audit):
- SliverAppBar.large 120pt + Today card 130pt + Search 50pt + Filter chips 40pt = 340pt
- iPhone 14 Pro safe area 750pt → ratio = 45% → `high`
- 修正: AppBar.large → AppBar (56pt) + Today card 横並び圧縮 (64pt) で 175pt = 23% → OK

修正候補:
- `SliverAppBar.large` → `SliverAppBar`(floating+snap) で 120pt → 56pt
- 多階層 chrome (search + filter + breadcrumb) を 1 階層に統合
- bottom nav と top nav を併用しない (どちらか 1 つ)

**Vision で判定**: スクショの上から「最初のコンテンツ要素 (List item / image / hero text)」までの距離をピクセル走査で測る。

### S12. Above-the-fold で核機能が見えない (アプリ Detail 画面)

Detail 画面で「核情報 (例文 / 説明 / 商品情報)」が initial viewport に収まらない。
ユーザーは「絵を見てから例文を読む」体験を期待しているのに、絵だけが見えて例文が下にスクロールされている状態。

判定:
- アプリの Detail 画面で、画面トップから「重要 secondary 要素 (例文 / 説明 / レビュー / 関連情報)」までの距離 > viewport の 60%
- → `high` 「Brand promise breakdown」(rule 25 と複合)

例 (eitango-image):
- Image 1:1 = 360pt + Header 60pt + Section 30pt = 450pt まで占有 → 例文は below-the-fold
- 修正: image 1:1 → 4:3 (270pt) で 360pt まで圧縮、例文が上に来る

修正候補:
- 主要 visual の aspect ratio 縮小 (1:1 → 4:3 / 16:9 など)
- visual と secondary content を side-by-side に (iPad のみ)
- visual を hero 化せず inline mini にして title 上に

### S13. container 幅とコンテンツ密度の不一致 (Web LP 向け)

LP / SaaS サイトで `<main>` や section の `max-width` が、載せているコンテンツの種類に合っていない。**横にスカスカ** or **詰まりすぎ** で「シュッとしすぎ」「広告感」のどちらかに転ぶ。

判定 (desktop viewport ≥ 1280px 時):

| content_max_width | コンテンツ種別 | priority | 解釈 |
|---|---|---|---|
| < 720px | LP hero / feature grid 系 | `medium` | 横にスカスカ、左右の余白が hero より広く「未完成感」 |
| 720-1024px | テキスト中心 (blog / docs) | OK | 読みやすさ最優先で正しい |
| **1024-1280px** | LP / SaaS (Linear / Vercel / Stripe / meta-note) | OK | modern 標準帯 |
| 1280-1440px | hero に大型 visual / 多列 grid | OK | spacious、画像強めの LP に合う |
| > 1536px | 美術館 / fashion / luxury | OK if 意図的 | 通常 LP では「埋めきれない」感が出やすい |

**ミスマッチ判定**:
- viewport 1440px で content max-width 760px の hero (左右 340px 余白) → `medium` 「container too narrow」
- viewport 1440px で content max-width none (full bleed) の text 段落 → `high` 「行長 100ch 超で読みにくい」

**Vision サブ判定**: hero 左右の余白 (背景色のみ) を viewport 幅で割って占有率を測る。
- 左右余白合計 > 45% → スカスカ感 (container 狭すぎ or visual 不足)
- 左右余白合計 < 8% → 端張り付き (mobile 流用の desktop 表示など)

**CSS 計測**:
```js
const containers = [...document.querySelectorAll('main, [class*=container], [class*=wrapper], section > div:first-child')];
const widths = containers.map(el => parseFloat(getComputedStyle(el).maxWidth)).filter(v => !isNaN(v));
// widths のうち hero/feature 系の最大値が 1024-1280 帯か判定
```

**改修候補**:
- Sublog 系 indie SaaS LP は **1152-1280px** が無難 (Tailwind の `max-w-6xl` 1152 / `max-w-7xl` 1280)
- 1440px 以上に広げるなら hero に大型 visual + 多列 feature grid (3-4 列) で「埋める」設計が必須
- container を広げる前に「中身を増やす」のが先。Hero に iPhone モック + caption + secondary CTA、feature を 6 個 → 9 個、等
- テキスト段落だけは container と独立に max-width 720px / margin auto で読みやすさを担保
