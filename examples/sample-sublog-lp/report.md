# Design Review — Sublog LP — hiroooo.github.io/sublog/

- **生成**: 2026-05-11T00:00:00Z
- **プラットフォーム**: web
- **モード**: general / レベル: normal
- **総合スコア**: **77 / 100**

## 軸別スコア

| 軸 | スコア |
|---|---:|
| 可読性 | 85 |
| 情報階層 | 75 |
| 余白・リズム | 72 |
| タイポグラフィ | 72 |
| 配色 | 70 |
| 画像密度 | 70 |
| モダン度 (2026 基準) | 70 |
| 統一感 | 78 |
| アクセシビリティ | 80 |
| ブランド約束 | 88 |

## 軸別評価コメント

- **可読性 (85)** — <span class="term" data-tooltip="Google Fonts の和文 sans、柔らかい印象">Zen Kaku Gothic</span> + 行間 1.7 で本文が読みやすい。行長も適切でストレスなし、コントラストも合格。
- **情報階層 (75)** — h1 <span class="term" data-tooltip="page 最上部の主訴求ブロック (visual + headline + CTA)">hero</span> が強く視線が固定される。h2 と body の weight 差がやや浅く、中間の階層が弱い場面あり。
- **余白・リズム (72)** — 縦余白は十分でミニマル路線の呼吸感あり。ただし spacing 17 種 (<span class="term" data-tooltip="標準偏差、値のバラつき度合い (大きいほど不均一)">stdev</span> 11.4px) で <span class="term" data-tooltip="全 spacing を 8 の倍数 (4/8/16/24/32/48/64) に揃える設計、リズム感の基盤">8pt grid</span> 揺れあり。
- **タイポグラフィ (72)** — <span class="term" data-tooltip="Google Fonts の和文 sans、柔らかい印象">Zen Kaku Gothic</span> + <span class="term" data-tooltip="Apple 標準 sans (system-ui 指定で fallback 含めて呼べる)">SF Pro</span> の組合せが清潔。ただし font-family fallback 7 種で chain が冗長、weight 3 種で階層差控えめ。
- **配色 (70)** — 黒×白×グレー基調が一貫しミニマル台帳と整合。ただし <span class="term" data-tooltip="完全黒 (#000000)、OLED で滲み + 目に痛い、2026 は gray-900 推奨">true black</span> (#000) / <span class="term" data-tooltip="完全白 (#ffffff)、長文で目が疲れる、2026 は gray-50 推奨">true white</span> (#fff) で 2026 標準とは微差あり。
- **画像密度 (70)** — <span class="term" data-tooltip="page 最上部の主訴求ブロック (visual + headline + CTA)">hero</span> に大型 visual はないが iPhone モック 4 枚で <span class="term" data-tooltip="アプリ名/コピー で謳う core feature が画面で視覚化されているか">Brand Promise</span> を視覚化。「できること」6 機能の icon 不在は惜しい。
- **モダン度 (70)** — radius 統一 + 過剰 shadow なしでモダン基準合格。ただし <span class="term" data-tooltip="1-2 色の控えめなグラデ、2026 SaaS で標準">subtle gradient</span> / <span class="term" data-tooltip="ブランドの主訴求色 (1-2 色)、CTA やリンクに使う">accent</span> / <span class="term" data-tooltip="OS の dark 設定に合わせて UI 色を反転する仕組み、2026 標準対応">dark mode</span> 不在で 2026 トレンド味は薄い。
- **統一感 (78)** — ミニマル路線がコピー / visual / footer まで貫徹。<span class="term" data-tooltip="色 / spacing / radius 等の値を CSS 変数で集約する設計手法">design token</span> の片鱗 (radius 1 種) もあり、ブランド統一感は良好。
- **アクセシビリティ (80)** — コントラスト◎、ナビ 4 項目で迷いなし。<span class="term" data-tooltip="タップ可能要素の最小サイズ (iOS 44pt / Android 48dp)">tap target</span> サイズは要実測 (44×44 px が推奨ライン)。
- **ブランド約束 (88)** — 「スクショ 1 枚で台帳になる」コピー + iPhone モック 4 枚 (「ぜんぶで¥X,XXX」「撮ると一覧」「ホームで台帳」「広告 vs 台帳」) で OCR→台帳の流れが完全視覚化、core feature が立ってる。

---

## 🚩 重大な指摘 (priority: high)

### font-family fallback 7 種で chain が冗長

- **axis**: `typography`
- **why**: 実際 render される font は 2-3 種だが、fallback chain が長いと FOIT/FOUT のリスク + 何が表示されるか予測困難。design token 不在の兆候。
- **fix**: 和文 Zen Kaku Gothic New + 英文 SF Pro/-apple-system + monospace の 3 階層に集約。CSS 変数 (--font-sans / --font-serif / --font-mono) 化
- **css**: `unique families: Hiragino Kaku Gothic ProN, -apple-system, system-ui, Helvetica Neue, Zen Kaku Gothic New, Noto Sans JP, sans-serif`
- **screenshot**: `captures/desktop-light.png`
- **参考**: https://linear.app / https://vercel.com

### spacing が 17 種、デザイントークン不在

- **axis**: `whitespace`
- **why**: 18, 28, 36px のような 8pt grid 外の値が混じり、余白がランダムに感じられる。ミニマル路線では特に余白の整列度がブランド印象を決める。
- **fix**: 4pt / 8pt grid の token (4, 8, 16, 24, 32, 48, 64) に集約。CSS 変数 (--space-1 ~ --space-16) で統一
- **css**: `unique values: 0, 40, 18, 24, 8, 12, 48, 36, 10, 28px ... (stdev 11.4 / 8pt grid 外 多数)`
- **screenshot**: `captures/desktop-light.png`
- **参考**: https://stripe.com / https://linear.app

## ⚠️ 改善余地 (priority: medium)

### true black (#000) を本文に使用

- **axis**: `color`
- **why**: OLED で滲み / コントラスト過大で長文読了で目が疲れる。2026 は gray-900 (#111-1a) が標準、ミニマル路線でも黒は微トーン落としが現代的。
- **fix**: 本文色を #111111 / #1a1a1a に置換。h1 だけ #000 残すのは可
- **css**: `rgb(0, 0, 0) detected`
- **screenshot**: `captures/desktop-light.png` crop=[10, 11, 70, 5]
- **参考**: https://apple.com/jp/ / https://stripe.com/jp

### Hero に大型 visual がなく、文字中心で 2026 SaaS LP のインパクト弱め

- **axis**: `image_density`
- **why**: Linear / Vercel / Stripe など 2026 SaaS は hero に必ず大型 visual を置く。Sublog は文字 + 小さな App Store ボタンのみで、iPhone モックが scroll 後に出現。Editorial 狙いなら OK だが SaaS としてはコンバージョン弱め。
- **fix**: 案 A: iPhone モック 4 枚を hero 内に移動 (above-the-fold で Brand Promise を即体感) / 案 B: hero に animated GIF / Lottie で OCR→台帳の流れを 3 秒ループ
- **screenshot**: `captures/desktop-light.png` crop=[0, 5, 100, 24]
- **参考**: https://linear.app / https://stripe.com

### 「できること」6 機能カードに icon 不在で視覚リズム弱め

- **axis**: `image_density`
- **why**: 6 つの feature カードが全部テキストのみで、視線が止まる視覚要素がない。スクロール中に「文字の壁」に見える瞬間が生じる。
- **fix**: Lucide / Heroicons (outline) で 6 つ 24px line icon を統一スタイルで配置。色は accent 1 色 (例: #1a73e8 / #5b6cff 等) でリズム作る
- **screenshot**: `captures/desktop-light.png` crop=[3, 51, 94, 19]
- **参考**: https://lucide.dev / https://heroicons.com

### spacing 標準偏差 11.4px (8pt grid 逸脱)

- **axis**: `whitespace`
- **why**: section ごとに 18 / 28 / 36px のような半端値が混じり、縦のリズム感が揺らぐ。spacing token を一度敷くと一気に整う。
- **fix**: CSS 変数 :root に --space-2/4/6/8/12/16 を定義、全 padding/margin を変数経由に書き換え
- **css**: `stdev=11.4 mean=4.6`
- **screenshot**: `captures/desktop-light.png` crop=[3, 16, 94, 20]

## 💡 細かい指摘 (priority: low)

### true white (#fff) を background に使用

- **axis**: `color`
- **why**: long-form では目の疲労、2026 は gray-50 (#fafafa) / off-white が標準。
- **fix**: body background を #fafafa / #f7f7f7 に。card のみ #ffffff で対比を作る
- **css**: `rgb(255, 255, 255) detected`

### Dark mode 未対応 (prefers-color-scheme 切替なし)

- **axis**: `modernity`
- **why**: 2026 標準は最低限 prefers-color-scheme: dark で OS 設定追従。Pro 訴求の「広告なし」と並んで dark-mode 対応はミニマル LP では効きが良い。
- **fix**: @media (prefers-color-scheme: dark) で body bg #0b0b0d, fg #e8e8ee に切替 (CSS 変数化済なら 1 ブロックで完結)
- **css**: `html.dark でも body background が rgb(255,255,255) のまま`
- **screenshot**: `captures/desktop-dark.png` crop=[0, 0, 100, 14]

---

## ✨ 良い点

- 「スクショ 1 枚で、サブスクが台帳になる。」 Hero copy が短く強い (15 字以内 + 比喩で具体)
- iPhone モック 4 枚で OCR→台帳の流れを完全視覚化 — Brand Promise が hero下で即 visualize
- 黒×余白ミニマル路線がコピー / visual / footer まで貫徹、ブランド統一感が高い
- border-radius が 1 種で統一 (design token の片鱗あり)
- プライバシー 3 項目で trust signal を配置 (OCR 端末完結 / カード番号取らない / Apple ID via AdMob)
- mobile responsive 完成度が高い (横スクロールなし、左右余白も適切)
- ナビゲーション 4 項目で integrity 確保 (プライバシー / 利用規約 / 特商法 / サポート)
- footer に法人名 + 全権利留保表記、indie でも legal trust 出ている

---

## 🎯 改修後イメージ・参考サイト

2026 のモダンな基準としてベンチマーク:

- [https://linear.app](https://linear.app) — SaaS hero benchmark — 大型 visual + 強 Hook copy + accent CTA
- [https://stripe.com/jp](https://stripe.com/jp) — info hierarchy + spacing token の手本、和文 LP として参考
- [https://apple.com/jp/](https://apple.com/jp/) — App Store ボタンの inline embed + 黒系 minimal の現代手本
- [https://vercel.com](https://vercel.com) — Inter + Geist フォントスタック + subtle gradient hero の参考

---

## 📦 アクションアイテム (修正用 JSON)

`issues.json` を読み込んで、優先度順に修正に着手してください。次のように Claude に頼むと改修対話に入れます:

> 「`issues.json` を読んで、priority high の指摘から順に修正して」

```json
{
  "counts": {
    "high": 2,
    "medium": 4,
    "low": 2
  },
  "top_3": [
    {
      "id": "typo_001",
      "axis": "typography",
      "title": "font-family fallback 7 種で chain が冗長",
      "fix_suggestion": "和文 Zen Kaku Gothic New + 英文 SF Pro/-apple-system + monospace の 3 階層に集約。CSS 変数 (--font-sans / --font-serif / --font-mono) 化"
    },
    {
      "id": "space_001",
      "axis": "whitespace",
      "title": "spacing が 17 種、デザイントークン不在",
      "fix_suggestion": "4pt / 8pt grid の token (4, 8, 16, 24, 32, 48, 64) に集約。CSS 変数 (--space-1 ~ --space-16) で統一"
    }
  ]
}
```

---

_Generated by `~/.claude/skills/design-review` — based on 2026 design standards_
