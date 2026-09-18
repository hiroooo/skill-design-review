# 43 — Web パフォーマンス実行時チェックリスト (Core Web Vitals)

> 2026-08-15 新設。既存 rules は a11y (40) を厚くカバーする一方、**LCP / CLS / INP への言及がゼロ**だった（`rules/10-web-extras.md` の「Web 軸 5」は静的観察のみ = 画像形式・寸法・font flash）。その穴を埋める実行時チェック。
> Phase 3「チェックリスト検査」で **Web ターゲット時に判定**する。fail は issue 化 (`ref_doc: rules/43-checklist-web-perf.md#WEBP-XX`)、`axis` は `modernity` か `image_density` の近い方に寄せる。
> **PNG 直渡しでは判定不能** → その場合は全項目 `n-a`。`mcp__playwright__browser_evaluate` でページを開けているときのみ実施する。
> 出典: web.dev / Core Web Vitals 2026 しきい値。

## しきい値（2026 現在の "Good"）

| 指標 | Good | Needs improvement | Poor |
|---|---|---|---|
| **LCP** (Largest Contentful Paint) | ≤ 2.5s | ≤ 4.0s | > 4.0s |
| **INP** (Interaction to Next Paint) | ≤ 200ms | ≤ 500ms | > 500ms |
| **CLS** (Cumulative Layout Shift) | ≤ 0.1 | ≤ 0.25 | > 0.25 |
| TTFB（参考） | ≤ 800ms | ≤ 1.8s | > 1.8s |

Needs improvement = `medium`、Poor = `high` で issue 化する。

## 計測スニペット（`browser_evaluate` にそのまま渡す）

```js
// ページ読み込み後に実行。LCP / CLS を回収し、LCP 要素の正体まで返す
await new Promise(r => setTimeout(r, 3000));
const nav = performance.getEntriesByType('navigation')[0] || {};
const lcpEntries = performance.getEntriesByType('largest-contentful-paint');
const lcp = lcpEntries.at(-1);
let cls = 0;
new PerformanceObserver(l => l.getEntries().forEach(e => { if (!e.hadRecentInput) cls += e.value; }))
  .observe({ type: 'layout-shift', buffered: true });
await new Promise(r => setTimeout(r, 500));
return {
  ttfb: Math.round(nav.responseStart || 0),
  lcp_ms: lcp ? Math.round(lcp.startTime) : null,
  lcp_element: lcp?.element?.tagName + (lcp?.element?.className ? '.' + String(lcp.element.className).slice(0, 60) : ''),
  lcp_url: lcp?.url || null,
  cls: Number(cls.toFixed(4)),
  transfer_kb: Math.round((nav.transferSize || 0) / 1024),
  dom_nodes: document.getElementsByTagName('*').length,
  img_no_dimensions: [...document.images].filter(i => !i.getAttribute('width') || !i.getAttribute('height')).length,
  img_lazy_above_fold: [...document.images].filter(i => i.loading === 'lazy' && i.getBoundingClientRect().top < window.innerHeight).length,
  fonts_swap_missing: [...document.styleSheets].length, // 目視補助（詳細は WEBP-06 参照）
};
```

INP は実ユーザー操作が要るので、**主 CTA を 1 回クリックして `event` エントリの `duration` を見る**（`PerformanceObserver({type:'event', durationThreshold:40})`）。取得できなければ `n-a`。

## チェック項目

- [ ] **WEBP-01** LCP が 2.5s 以内か — pass基準: 上記スニペットの `lcp_ms` ≤ 2500。ローカル開発サーバ計測時は「本番相当ではない」旨をレポートに注記した上で判定する
- [ ] **WEBP-02** LCP 要素が「意味のあるメインビジュアル / 見出し」か — pass基準: `lcp_element` が hero の画像・h1 であること。ローディングスピナー / プレースホルダ / 空 div が LCP になっていたら fail（体感と指標が乖離している証拠）
- [ ] **WEBP-03** CLS が 0.1 以内か — pass基準: `cls` ≤ 0.1。0.25 超は `high`。原因は大抵「寸法未指定の画像」「後から差し込まれるバナー / Cookie 同意」「web font 差し替え」
- [ ] **WEBP-04** 画像に width / height（または aspect-ratio）が指定されているか — pass基準: `img_no_dimensions` が 0。CLS の最大の発生源で、指定するだけで消える
- [ ] **WEBP-05** above-the-fold の画像に `loading="lazy"` が付いていないか — pass基準: `img_lazy_above_fold` が 0。初期表示画像の lazy 化は LCP を直接悪化させる（`next/image` なら `priority` を付ける）
- [ ] **WEBP-06** web font が `font-display: swap`（または `optional`）でセルフホストされているか — pass基準: `@font-face` に `font-display` があり、外部 CDN への `<link>` 直読みでない。Next.js なら `next/font` を使っているか
- [ ] **WEBP-07** INP が 200ms 以内か — pass基準: 主 CTA / メニュー開閉を 1 回操作したときの `event` duration が ≤ 200ms。500ms 超は `high`。取得不能なら `n-a`
- [ ] **WEBP-08** 初期転送量が過大でないか — pass基準: `transfer_kb` が 1500KB 未満（LP / コーポレート想定）。超過時は最大の寄与リソースを `browser_network_requests` で特定して issue に書く
- [ ] **WEBP-09** DOM ノード数が過大でないか — pass基準: `dom_nodes` < 1500。超過はスタイル再計算とスクロール性能を直撃する
- [ ] **WEBP-10** スクロール連動アニメーションが `transform` / `opacity` 以外を動かしていないか — pass基準: `top` / `left` / `width` / `height` / `box-shadow` をアニメーションさせていない（レイアウト・ペイントが毎フレーム走る）。`prefers-reduced-motion` の有無は WEB-06 側で判定

## レポートへの書き方

- 数値は**必ず実測値を併記**する（「LCP が遅い」ではなく「LCP 4.1s（Poor / LCP 要素 = `IMG.hero-bg`, 2.3MB）」）。
- ローカル / 本番のどちらで測ったかを明記する。**ローカル実測だけで「本番も遅い」と断定しない**。
- 1 回の計測でぶれる指標なので、**Poor 判定は 2 回計測して再現したときだけ** `high` にする。
