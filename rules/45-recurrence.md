# 45 — 再発防止チェックリスト (過去指摘由来・成長するファイル)

> **全 platform で必ず通す** (Phase 3「チェックリスト検査」)。ここの fail = 「過去に実際に受けた指摘の二度目」なので priority は原則 high。
> fail は issue 化 (`ref_doc: rules/45-recurrence.md#RC-XX`)。level 不問で省略しない。`platform` タグが対象と合わない項目はスキップ。
> `rules/40-42` や既存軸と重なる項目 (RC-09 / RC-11 / RC-22 等) は **issue を 1 本にまとめ、ref_doc に両 ID を併記**する (二重報告しない)。本ファイル内の項目同士が同一事象に該当する場合も同様 (例: 過去 issue の再発は `ref_doc: "rules/45-recurrence.md#RC-19,RC-28"` のように併記)。
> grep 前提の項目 (RC-10 / RC-14 / RC-20 / RC-21 / RC-23) はソースにアクセスできる場合のみ実施、スクショのみなら Vision で分かる範囲 + n-a。
>
> **追記ルール (SKILL.md Phase 6)**: レビュー後にユーザーから新指摘を受けたら、末尾に次のフォーマットで 1 項目追記する:
> `- [ ] **RC-XX** <チェック内容> — pass基準: <観察可能な条件> | platform: <web/ios/android/image/all> | 出典: <パス or memory 名> | 追加日: <YYYY-MM-DD>`
> 同義の既存項目があれば追記せず、その項目の出典欄に事例を追加する。初版 28 項目 (2026-07-17、過去 issues.json 23 件 + design 系 memory + kotesage 決裁 doc から集約、頻度順)。

## 頻出パターン (出現 3 回以上)

- [ ] **RC-01** アクセントカラーが 1〜2 色に統一され、3 色以上が同一画面で同時主張していないか — pass基準: 画面内のアクセント色数が 2 以下、意味色 (warning/success 等) は彩度低めで最大 2 | platform: all | 出現: 8 回 | 出典: apps/eitango-image + apps/shirowalk の issues.json ほか | 追加日: 2026-07-17
- [ ] **RC-06** ブランド世界観 (トーン・テーマ) が画面をまたいで一貫しているか (一部画面だけ別アプリのように分裂していないか) — pass基準: 全画面で同一の色相・モチーフ・ロゴ位置が継承 | platform: ios | 出現: 5 回 | 出典: apps/biyoclip, apps/shirowalk の issues.json | 追加日: 2026-07-17
- [ ] **RC-02** feature / 機能カードに icon 等の視覚要素があり、テキストのみで単調になっていないか — pass基準: カード群の各要素に line icon 等の視覚アンカーが 1 つ以上 | platform: web | 出現: 4 回 | **再発あり** (修正後も再指摘) | 出典: app/.scratch/design-review-sublog-after-*, design-review-aprico-* | 追加日: 2026-07-17
- [ ] **RC-03** font-family を明示指定し、system フォント chain 任せの冗長な fallback になっていないか — pass基準: font-family 実質 2-3 種、CSS 変数 (--font-sans 等) で一元管理 | platform: web | 出現: 4 回 | 出典: design-review-aprico-*, apps/claudecode-textbook | 追加日: 2026-07-17
- [ ] **RC-04** レイアウトが 2010 年代 / iOS6 時代型 (全幅罫線リスト・過剰ネオングロー・単調テンプレ LP) になっていないか — pass基準: insetGrouped カード化や subtle elevation 等、2026 基準のモダン意匠が入っている | platform: all | 出現: 4 回 | 出典: apps/shirowalk, apps/biyoclip | 追加日: 2026-07-17
- [ ] **RC-05** 補足文・ラベルのコントラストが十分か (薄いグレーで背景に沈んでいないか) — pass基準: 小さい文字でも WCAG AA (4.5:1) を満たす | platform: all | 出現: 4 回 | 出典: apps/kotesage, apps/kenmin-aruaru | 追加日: 2026-07-17
- [ ] **RC-07** spacing / margin が 4-8pt グリッドの design token に揃っているか — pass基準: spacing 種類 5-6 以内、標準偏差が極端に大きくない | platform: web | 出現: 3 回 | 出典: design-review-sublog-after-*, apps/kotesage | 追加日: 2026-07-17
- [ ] **RC-08** true black (#000) / true white (#fff) を使わず gray-900 / gray-50 系で置き換えているか — pass基準: rgb(0,0,0) / rgb(255,255,255) が body / 背景に不使用 | platform: web | 出現: 3 回 | 出典: design-review-sublog-*, apps/claudecode-textbook | 追加日: 2026-07-17
- [ ] **RC-09** tap target が 44pt 以上確保されているか — pass基準: ボタン / チップの実測 44pt 以上 (= rules/11 Tap Target と統合判定) | platform: ios | 出現: 3 回 | 出典: apps/biyoclip, apps/kireilens | 追加日: 2026-07-17
- [ ] **RC-10** バージョン番号・件数・料金等の表示値が実装 / DB の実態と一致しているか (hardcode で古い値のまま放置されていないか) — pass基準: 動的取得または最新値との grep 差分ゼロ | platform: all | 出現: 3 回 | 出典: apps/kireilens, apps/kenmin-aruaru | 追加日: 2026-07-17
- [ ] **RC-11** ダークモード (prefers-color-scheme) に対応しているか — pass基準: dark 用配色が実装され破綻なし (= WEB-14 と統合判定) | platform: web | 出現: 3 回 | **再発あり** (sublog で 3 レビュー連続未解決) | 出典: design-review-sublog-after-* 3 件 | 追加日: 2026-07-17

## 中頻度パターン (出現 2 回)

- [ ] **RC-12** 同じ目的の CTA / ボタンは画面をまたいで同じ色で統一されているか (フロー途中で色が変わらない) — pass基準: 同一フロー内の CTA 色が 1 色で一貫 | platform: ios | 出現: 2 回 | 出典: apps/eitango-image (consistency_001/002) | 追加日: 2026-07-17
- [ ] **RC-13** border-radius が 2 段階以内に統一されているか — pass基準: radius 種類 2 以内 | platform: web | 出現: 2 回 | 出典: apps/claudecode-textbook, apps/kotesage | 追加日: 2026-07-17
- [ ] **RC-14** 過去に廃止 / 禁止と決裁した用語・商標・装飾が別素材 (バナー等) で再導入されていないか — pass基準: 該当キーワードの grep ゼロ (project の決裁 doc / .claude/design-checklist.md を参照) | platform: all | 出現: 2 回 | **再発あり・ユーザー決裁** | 出典: apps/kireilens (brand_001 ウォシュレット商標), apps/shuchu-capsule (cons_001「ひと呼吸」再導入) | 追加日: 2026-07-17
- [ ] **RC-15** hero 数字 / タイトルが base の 2〜2.5 倍以上のサイズでメリハリがついているか (副次アクセントと競合して主役が埋もれない) — pass基準: hero:body の font-size 比 2 倍以上、副次強調は色のみでサイズ据え置き | platform: image | 出現: 2 回 | 出典: branding/sns-bocchi article-2026-05-17, design-review-sublog-final | 追加日: 2026-07-17
- [ ] **RC-16** 複数カード / バリエーション展開時に共通の枠・ロゴ位置・余白システムでブランド一貫性を保っているか — pass基準: 全バリエーションで枠・ロゴ定位置・トーンが共通 | platform: ios | 出現: 2 回 | **再発あり** (shirowalk 2 回連続同傾向) | 出典: apps/shirowalk 20260606-0853 / -1846 | 追加日: 2026-07-17
- [ ] **RC-17** 矢印・区切り線等の低彩度装飾要素が背景に沈んで判読不能になっていないか — pass基準: 装飾要素のコントラスト比 3:1 以上 | platform: all | 出現: 2 回 | 出典: branding/sns-bocchi article-2026-05-17, apps/shirowalk | 追加日: 2026-07-17

## ユーザー決裁由来 (常時適用)

- [ ] **RC-18** 濃色グラデ全幅ヘッダー帯 + 白抜き文字・ベタ塗り chip 等の AI 生成 LP 定番クリシェを使っていないか — pass基準: memory `feedback-ai-design-cliche-checklist` 7 項目の自己検査を通過 | platform: web | **ユーザー決裁** | 出典: apps/claudecode-textbook, memory feedback-ai-design-cliche-checklist.md | 追加日: 2026-07-17
- [ ] **RC-20** AI クリシェ全般 (紫グラデ・emoji 見出し・グロー効果・No.1 バッジ・キラキラ装飾・ストック人物写真) を使っていないか — pass基準: 該当装飾ゼロ | platform: all | **ユーザー決裁** | 出典: apps/kotesage/docs/decisions/2026-07-13-design-direction.md (禁止事項節) | 追加日: 2026-07-17
- [ ] **RC-21** 煽り系マイクロコピー (「今すぐ」「損してる」「最安」等の言い切り・最上級表現) を使っていないか — pass基準: 該当表現ゼロ | platform: all | **ユーザー決裁** | 出典: apps/kotesage/docs/decisions/2026-07-13-design-direction.md (核ルール「言い切り禁止」) | 追加日: 2026-07-17

## 単発だが影響大 (reject 歴・事故由来)

- [ ] **RC-19** モバイル幅 (390px 等) で footer / nav 等の要素が欠落・余白ゼロになっていないか (デスクトップ幅だけで検証しない) — pass基準: 390 / 1280 / 2000px の 3 幅で同一要素の余白が保持 | platform: web | **再発あり** (kotesage v7 白帯バグと同型の再発と明記) | 出典: apps/kotesage/.scratch/design-review-20260716-0000 (cons_001/a11y_001); career/caio/提出用/_design-review (2026-09-09、390pxでheader navと固定DRAFTバッジが重なり文字が読めなくなる新パターン) | 追加日: 2026-07-17
- [ ] **RC-22** 固定 pt でなく相対フォントサイズ (Dynamic Type) に対応しているか — pass基準: `.font(.custom(..., relativeTo:))` または `@ScaledMetric` 使用 (= rules/11 Dynamic Type と統合判定) | platform: ios | 出典: apps/mystery-adv (acc_001) | 追加日: 2026-07-17
- [ ] **RC-23** 価格表記が localizedPriceString 等で動的取得されているか (USD/JPY 等の hardcode でないか) — pass基準: CTA ラベルにハードコード価格文字列がない | platform: ios | **ASC 2.3.7 reject 歴と直結** | 出典: apps/kireilens (color_001) | 追加日: 2026-07-17
- [ ] **RC-24** 生成画像 / バナーで要素が画面外にはみ出て見切れていないか (グリッド下段切れ・tag overflow 等) — pass基準: Vision 目視で overflow 検知ゼロ | platform: image | 出典: memory feedback-image-design-review-gate.md | 追加日: 2026-07-17
- [ ] **RC-25** 空状態 (empty state) が指示文だけでなく価値訴求 (ベネフィット) を伴っているか — pass基準: icon + 一言ベネフィット + ビジュアルの 3 要素 | platform: ios | 出典: apps/biyoclip (brand_001) | 追加日: 2026-07-17
- [ ] **RC-26** 同種リスト内で一部行だけ補助情報の有無が不規則になっていないか — pass基準: 全行で同一ルールの補助情報表示 (全表示 or 全非表示) | platform: ios | 出典: apps/kanji-cam (ui_004) | 追加日: 2026-07-17
- [ ] **RC-27** アイコンの描画系統 (SF Symbol 単色 vs 絵文字カラー) が統一されているか — pass基準: 同列アイコンの色数・線幅・質感が揃っている | platform: ios | 出典: apps/biyoclip (consist_001) | 追加日: 2026-07-17

## メタパターン (レビュー運用そのもの)

- [ ] **RC-28** 同一対象の過去 design-review で WARN / issue になった項目 (icon 不在・dark mode 等) が未解消のまま放置されていないか — pass基準: 対象の過去 `design-review-*/issues.json` があれば Read し、同一 issue が解消済みまたは「low で保留」の合意記録あり。**未解消の再発は priority high で再掲する** | platform: all | **再発あり** (sublog 4 回 / shirowalk 3 回 / kotesage 2 回で横断確認) | 出典: 各 .scratch/design-review-*/issues.json | 追加日: 2026-07-17

## 2026-07-23 ai-jirei.com 本番ユーザー指摘由来

- [ ] **RC-29** 主要セクション（ヘッダー/信頼帯/ナビ/h1/フィルタ/カード/フッター）の視覚左端が一直線か — pass基準: 1440 / 1800 / 2560px の 3 幅で視覚左端の最大差 2px 以内（「素のテキスト列」と「枠カード列」の 2 本線化を検出。1440 だけでは角丸に紛れて見逃す） | platform: web | **本番ユーザー指摘** | 出典: ai-jirei.com (コンテナ+24px と +0px の混在、レビューは 1440 のみで見逃し) | 追加日: 2026-07-23
- [ ] **RC-30** 状態依存 UI（「すべて解除」「N件選択中」等）が空状態でも常時表示されていないか — pass基準: フィルタ未適用・未選択の初期状態スクショで該当リンク/ボタンが非表示 | platform: web | **本番ユーザー指摘** | 出典: ai-jirei.com (「すべて解除」が未適用時も浮遊表示) | 追加日: 2026-07-23
- [ ] **RC-31** 検索窓とフィルタ/タグが視覚的に一体のブロックか + 長いページでスクロール後も検索に到達できるか (sticky 化等) — pass基準: 検索とフィルタが同一ブロック内 / スクロール中も検索手段が viewport 内に存在 | platform: web | **本番ユーザー指摘** | 出典: ai-jirei.com (検索とタグ絞り込みの泣き別れ + スクロール後に検索へ戻れない) | 追加日: 2026-07-23
- [ ] **RC-32** ファセット (タグ等) の表示が実データの種類数に対して不当に切り詰められていないか — pass基準: 実データのファセット種類数を機械集計し、表示数との乖離に合理的説明 (件数閾値+「もっと見る」等) がある | platform: web | **本番ユーザー指摘** | 出典: ai-jirei.com (データ115種のうち上位12個のみ表示、Gemini 等が埋没) | 追加日: 2026-07-23
