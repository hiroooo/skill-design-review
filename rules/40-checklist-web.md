# 40 — Web 実行時チェックリスト

> Phase 3「チェックリスト検査」で **Web ターゲット時に全項目を pass / fail / n-a 判定**する。
> fail は issue 化 (`ref_doc: rules/40-checklist-web.md#WEB-XX`)。level 不問で省略しない。
> DOM / CSS 依存の項目 (WEB-05, 08, 09, 10 等) は `mcp__playwright__browser_evaluate` で機械判定できる。スクショのみ (PNG 直渡し) で判定不能なら n-a。
> 出典: WCAG 2.1/2.2 / Baymard Institute / web.dev (2026-07 調査)。既存 rules/00-30 と重複する観点は載せていない。

## アクセシビリティ (WCAG)

- [ ] **WEB-01** インタラクティブなターゲット同士の間隔が十分か — pass基準: 24×24px 未満のターゲットは、中心に 24px の円を置いたとき隣接ターゲットの円と重ならない (WCAG 2.5.8。既存ルールはターゲット単体サイズのみでターゲット間隔は未カバー) （出典: https://www.w3.org/WAI/WCAG22/Understanding/target-size-minimum.html）
- [ ] **WEB-06** アニメーション / モーションが `prefers-reduced-motion` を尊重しているか — pass基準: CSS に `@media (prefers-reduced-motion: reduce)` が存在し、スクロール連動・自動再生・視差効果などの非本質的モーションが無効化 / 簡略化される （出典: https://www.w3.org/WAI/WCAG22/Techniques/css/C39）
- [ ] **WEB-07** 見出しレベル (h1-h6) がスキップされずに階層構造を保っているか — pass基準: h1 の次に h3 が来るような階層飛ばしがない (視覚サイズ比ではなく semantic level の整合) （出典: https://www.a11yproject.com/posts/how-to-accessible-heading-structure/）
- [ ] **WEB-09** viewport meta tag が正しく設定され、ズームを禁止していないか — pass基準: `width=device-width, initial-scale=1` があり、`user-scalable=no` / `maximum-scale=1` でズームを封じていない （出典: https://developer.mozilla.org/en-US/docs/Web/HTML/Viewport_meta_tag）
- [ ] **WEB-10** `<html>` 要素に `lang` 属性が設定されているか — pass基準: `<html lang="ja">` のように BCP47 準拠コードが指定 (空文字不可)。WCAG 3.1.1 Level A （出典: https://www.w3.org/WAI/WCAG22/Techniques/html/H57）
- [ ] **WEB-11** キーボードのみでメインコンテンツへ直接移動する手段 (skip link) があるか — pass基準: ページ先頭の最初のフォーカス可能要素として「本文へスキップ」リンクが存在し main へジャンプ (フォーカス時のみ表示でも可)。WCAG 2.4.1 Level A （出典: https://www.w3.org/WAI/WCAG21/Understanding/bypass-blocks.html）
- [ ] **WEB-12** 320 CSS px 幅まで縮小しても横スクロールなしで全コンテンツが読めるか (reflow) — pass基準: viewport 幅 320px で縦スクロールのみで完結、2 次元スクロールが発生しない (画像 / 地図 / データ表の例外を除く)。WCAG 1.4.10 Level AA （出典: https://www.w3.org/WAI/WCAG21/Understanding/reflow.html）
- [ ] **WEB-13** フォーカスインジケーターが十分なコントラストとサイズを持つか — pass基準: フォーカス時 / 非フォーカス時でコントラスト比 3:1 以上の変化 + インジケーター面積が「対象の 1px 周囲相当」以上または最短辺 4px 以上 (`outline: none` の有無だけでは pass にしない)。WCAG 2.4.13 （出典: https://www.w3.org/WAI/WCAG22/Understanding/focus-appearance.html）

## フォーム UX (Baymard)

- [ ] **WEB-02** フォーム項目の label が input 内部に消える形式 (placeholder 兼用 / floating label のみ) になっていないか — pass基準: label が input の上または左に常時表示され、入力中も消えない （出典: https://baymard.com/blog/mobile-forms-avoid-inline-labels）
- [ ] **WEB-03** フォームのエラーメッセージが「何が問題で、どう直せばよいか」を具体的に示しているか — pass基準: "Invalid input" のような汎用文言でなく要件を明示 (例: 「8 文字以上必要」)。非難調ワーディングは減点 （出典: https://baymard.com/learn/form-design）
- [ ] **WEB-04** 必須項目にアスタリスク (*) のみを使い説明がない状態になっていないか — pass基準: アスタリスク使用時はフォーム冒頭に「* は必須項目」等の注記がある （出典: https://baymard.com/learn/form-design）
- [ ] **WEB-08** ユーザー情報を収集する input に適切な `autocomplete` 属性があるか — pass基準: 氏名 / メール / 住所 / 電話等に WHATWG 準拠トークン (例: `autocomplete="email"`)。WCAG 1.3.5 Level AA （出典: https://www.w3.org/WAI/WCAG21/Techniques/html/H98）
- [ ] **WEB-15** フォーム入力欄の横幅が期待される入力内容の長さと一致しているか — pass基準: 郵便番号 / CVV のような短い入力に全幅 input を使っていない等、幅が入力長を視覚的に示唆 （出典: https://baymard.com/learn/form-design）

## レスポンシブ / モダン標準

- [ ] **WEB-05** レスポンシブ画像が srcset / sizes (または `<picture>`) で実装されているか — pass基準: hero / カード等の主要画像に srcset (w 記述子) + sizes があり、sizes が固定 px でなく viewport 相対値 （出典: https://web.dev/learn/design/responsive-images）
- [ ] **WEB-14** ダークモード (`prefers-color-scheme`) に対応しているか — pass基準: CSS に `@media (prefers-color-scheme: dark)` が存在し、OS ダークモード時に配色が破綻なく切り替わる （出典: https://web.dev/articles/responsive-web-design-basics）
