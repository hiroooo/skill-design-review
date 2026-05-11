# フォントの「ダサい」シグナル

「2026 年現在、これは古い / 素人っぽい」と判定するチェック項目。

## NG フォント (即 high priority)

font-family にこれらが含まれていたら一発 high:

**英語**:
- Comic Sans (MS) — 30 年不変の「素人」記号
- Papyrus
- Impact (見出し直使い、tracking なし)
- Arial Black
- Trajan Pro (映画ポスター流用感)

**日本語**:
- 創英角ポップ体
- HG 行書体
- DF 系装飾体 (DF平成明朝、DFP行書体...)
- MS Pゴシック / MS P明朝 (Web 直使いで body)
- 標準 Arial に和文 fallback で Hiragino/Meiryo 任せ (font-family 指定を真面目にしていない兆候)

**判定**:
```js
const NG = ['Comic Sans', 'Papyrus', 'Impact', 'Trajan', '創英角ポップ', 'HG行書', 'DFP', 'DF平成', 'MS Pゴシック', 'MS P明朝'];
const found = familySet.find(f => NG.some(ng => f.includes(ng)));
if (found) issue('typography_ng_font', 'high', `古臭いフォント: ${found}`);
```

## モダン推奨 font (2026 標準)

**英語 Web**:
- Inter (デファクト)
- Geist (Vercel)
- Söhne / Söhne Mono (Klim)
- Neue Haas Grotesk
- IBM Plex
- Pretendard (韓 / 日対応もあり)

**日本語 Web**:
- Noto Sans JP (Google) — 安全
- Hiragino Sans (system / Mac)
- Source Han Sans (Adobe)
- Zen Maru Gothic / Zen Kaku Gothic — 柔らかさ
- LINE Seed JP (やや個性派)

**iOS**: SF Pro Display / SF Pro Text / SF Mono / Hiragino Sans

**Android**: Roboto / Roboto Flex / system fonts

## ダサさシグナル (signal)

### S1. font-family 4 種以上混在
- 同一 viewport 内の computed font-family unique 数 ≥ 4 → priority `medium`
- ただし monospace (code) は別カウント可
- serif + sans + display + handwriting の混在は `high` に格上げ

### S2. weight 多様性ゼロ
- font-weight unique 数 ≤ 2 → `medium`
- weight 1 種だけ (e.g. 全 400) → `high` (階層感ゼロ)

### S3. letter-spacing デフォルト
- 大型タイトル (font-size ≥ 48px) で letter-spacing が `normal` → `medium`
- 英大文字見出し (text-transform: uppercase) で tracking 未設定 → `medium`
- 推奨: heading は -0.02em 〜 -0.04em で tight、CAPS は +0.05em

### S4. serif と sans の重量ミスマッチ
- serif heading + sans body の組合せで weight が大きく違う (serif 700 + sans 300 等) → 視覚 imbalance → `medium`

### S5. font-display 未指定 (Web のみ)
- `@font-face` で `font-display: swap | optional` 未指定 → FOIT で読みづらい → `low`

### S6. (おまけ) 絵文字を見出しに直置き
- h1 や hero copy に 🚀 ✨ 🔥 を直貼り → `medium`
- 2026 では「視覚的 noise」、icon set の line / solid icon に統一すべき

### S7. (おまけ) 日本語にイタリックを当てる
- font-style: italic を日本語に適用 → 字形が斜変形して醜い → `high`
- 強調は色 / weight / 下線で

### S8. (おまけ) display font を本文に
- Lobster / Pacifico / 装飾系 display font を本文 (p) に使う → `high`
- display は h1 / hero のみ

## 機械判定の優先順位

CSS パース可能 (Web のみ):
1. NG フォント検出 → 1 行で確定、最優先
2. unique family 数
3. unique weight 数
4. letter-spacing 設定有無

Vision 必須 (iOS / Android / 画像):
1. 装飾フォント / 古臭フォントの判別 (見た目)
2. 絵文字直置き
3. 日本語 italic
4. テイスト混在

## 良い点ハイライトのネタ

friendly モードで以下を見つけたら積極的に褒める:

- variable font (Inter / Geist) を使っている
- weight が 4 種くらい段階的に並ぶ (300/400/500/700)
- heading に letter-spacing -0.03em のような微調整がある
- 日本語に Noto Sans JP / Hiragino を使っている
- font-display: swap が指定されている
- 全部 system font で潔い (パフォーマンス◎)
