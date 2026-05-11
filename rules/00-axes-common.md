# 共通 10 軸スコア定義

各軸 0-100 でスコアリング。サブメトリクスは「機械判定可能」(CSS) と「Vision 判定」を区別。

**ユーザー報告ルール**: スコア表 / 進捗報告 / コミットメッセージでは必ず**日本語軸名**を使用。英語 ID (`readability` / `hierarchy` 等) は `issues.json` の内部 field でのみ使う。

## 軸 1: 可読性 (`readability`)

**サブメトリクス**:
- contrast_ratio: WCAG AA 基準 (本文 4.5:1 / 大見出し 3:1) を満たすテキスト割合
- line_length: 本文の行長 (英 45-75ch / 和 30-45 字が目安、外れたら減点)
- line_height: body の line-height が 1.5-1.8 か
- font_size_min: 12px 未満の本文がないか

**Vision**: 「ぱっと見で読みづらいか」「文字が小さすぎないか」

**減点トリガー**: WCAG fail / 小さすぎる本文 / 行長 100ch 超 / line-height 1.0

## 軸 2: 情報階層 (`hierarchy`)

**サブメトリクス**:
- jump_rate: h1/body, h2/body の font-size 比 (理想は 2.5-3.5x / 1.6-2.0x)
- weight_jump: heading の weight が body より 200 以上重い
- color_hierarchy: 重要要素に accent color、弱要素に muted color
- spatial_separation: section 間の余白で群がブロック化

**Vision**: 「視線が最初に行く場所が明快か」

**減点トリガー**: jump rate < 1.4 / heading が body と同じ weight / 全要素フラット

## 軸 3: 余白・リズム (`whitespace`)

**サブメトリクス**:
- spacing_stddev: spacing 値の標準偏差。8px grid なら大半が [8, 16, 24, 32, 40, 48] に収まるはず
- spacing_unique_count: ユニーク値が多すぎる (>10 種) と grid 未使用
- odd_pixel_ratio: 奇数 px (3,5,7,9,...) の使用率。10% 超で減点
- mobile_horizontal_padding: モバイルで左右余白 0 または max-width 未設定

**Vision**: 「呼吸感があるか」「詰め込み広告感がないか」

**詳細**: `21-dasai-spacing.md`

## 軸 4: タイポグラフィ (`typography`)

**サブメトリクス**:
- font_family_count: ページ内 unique font-family 数 (4 以上は減点)
- weight_diversity: 使用 weight の unique 数 (≤2 は単調で減点)
- ng_font_used: Comic Sans / Papyrus / Impact / 創英角ポップ体 / MS Pゴシック が混じる
- letter_spacing_set: heading で letter-spacing を意識的に設定しているか

**Vision**: 「フォントが古臭くないか」「テイスト混在で素人っぽくないか」

**詳細**: `20-dasai-typography.md`

## 軸 5: 配色 (`color`)

**サブメトリクス**:
- true_black_white_used: `#000` / `#fff` 完全使用 (gray-900 / gray-50 推奨)
- saturation_overload: HSL S > 90% の色を 3 色以上同画面で使用
- accent_count: アクセント色が 1-2 色か (3 色超で雑多)
- gradient_color_count: gradient の color stop が 4 以上 (虹色化)

**Vision**: 「配色が目に痛くないか」「ブランドカラーが立っているか」

**詳細**: `23-dasai-color-shadow.md`

## 軸 6: 画像密度 (`image_density`)

**サブメトリクス**:
- text_image_ratio: ファーストビュー内の text vs image の面積比 (推奨 60:40 / hero は 30:70 OK)
- image_count_above_fold: ファーストビューに 5 枚以上 = チラシ感 / 0 枚 = テキスト過多
- aspect_ratio_unique: 同一 grid 内の aspect ratio unique 数 (>2 はトリミング失敗印象)
- style_mix_count: 写真 / 3D illust / line drawing / cartoon が同居している数

**Vision**: 「stock 感のある写真が多くないか」「写真とイラストの混在テイストがバラついてないか」

**詳細**: `22-dasai-imagery.md`

## 軸 7: モダン度 (2026 基準) (`modernity`)

**サブメトリクス**:
- gradient_modern: 1-2 色 subtle / blue→teal 等 OK、紫→ピンク鋭角 NG
- shadow_modern: rgba blur > 15 で opacity > 0.3 = 古い、薄い 0.08-0.12 = 現代的
- radius_consistency: 同画面で unique radius 数 (>3 で減点)
- animation_easing: linear / 過剰 bounce 検出

**Vision**: 「2010 年代感 / Bootstrap 直貼り感がないか」

**詳細**: `24-modern-2026.md`

## 軸 8: 統一感 (`consistency`)

**サブメトリクス**:
- design_token_implied: spacing/color/radius/shadow が token 化されているように見える整列度
- repeated_motif: 同じパターン (角丸サイズ / line / icon style) が繰り返されているか
- voice_alignment: テキストトーンと visual トーンが一致 (例: ポップなコピーに minimalist UI = ズレ)

**Vision**: 「ブランドとして 1 つにまとまって見えるか」

## 軸 9: アクセシビリティ (`accessibility`)

**サブメトリクス**:
- wcag_aa_text: コントラスト基準を満たすテキスト割合
- focus_visible: focus state が CSS で削除されていない (`outline: none` 直書きは NG)
- tap_target_size: ボタン/リンクが 44×44 (iOS) / 48×48dp (Android) / 24×24px (Web 基準)
- alt_text: img タグに alt 属性がある割合
- aria_landmark: nav/main/footer の semantic 構造

**Vision**: 「ボタンが小さすぎないか」「色だけで意味を伝えていないか」

## 軸 10: ブランド約束 (`brand_promise`)

**サブメトリクス**:
- 主要 5 画面 (Onboarding / Home / Detail / Paywall / Settings) でアプリ名/コピーが謳う core feature の visual representation を 0-3 採点 → 合計 / 15 を 0-100 にスケール
- アプリ icon と画面 theme の色一貫性
- アプリ名 verb と CTA 導線の一致

**Vision**: 「アプリ名で謳ってることが画面で実体化されているか」

**詳細**: `25-brand-promise.md` (indie アプリの最大盲点)

## 総合スコア (overall) の算出

```
overall = round(
  readability * 0.13 +
  hierarchy * 0.09 +
  whitespace * 0.10 +
  typography * 0.11 +
  color * 0.09 +
  image_density * 0.08 +
  modernity * 0.10 +
  consistency * 0.09 +
  accessibility * 0.09 +
  brand_promise * 0.12
)
```

ブランド約束は indie アプリで最も「ダサさ」に直結するため weight 0.12 を与えている。

ただし any axis < 40 なら overall は 60 を上限にキャップ (致命傷の上にきれいなパッチが乗っているのを隠さない)。

## レベル別の出し分け

- **strict**: 全軸で減点要素を全部 issue 化、low priority も列挙
- **normal**: high + medium のみ、low は集計だけ
- **friendly**: high のみ列挙 + 良い点を 5 個以上ハイライト、low は省略
