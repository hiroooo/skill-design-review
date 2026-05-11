# Web 用 追加軸

LP / SaaS / 個人サイト共通。共通 9 軸の上に乗せる。

## Web 軸 1: Hero 視覚インパクト

**サブメトリクス**:
- hero_has_visual: above-the-fold (≈900px 以内) に img / svg / canvas / video が 1 枚以上ある
- hero_text_clarity: メインキャッチが 1 秒で読める長さ (15 字以内推奨)
- hero_cta_visible: 主 CTA が above-the-fold 内に存在しタップ可能

**減点**: 文字だけの hero (2026 SaaS では稀) / 抽象的すぎるキャッチ / CTA が二画面目以降

**ベンチマーク**: Linear / Vercel / Stripe / Notion / Apple

## Web 軸 2: CTA 明瞭度

**サブメトリクス**:
- cta_count_above_fold: 1-2 個推奨 (3 以上で散漫)
- cta_color_contrast: 主 CTA がページ内で唯一の高彩度色を使っている
- cta_label_action: 「クリック」「送信」より動詞 + Outcome (`Start free trial`, `はじめる` 等)
- cta_size_min: 高さ 44px 以上

**減点**: グラデボタン / ベベル / 同じ色の secondary CTA が並ぶ

## Web 軸 3: above-the-fold 情報量

**サブメトリクス**:
- text_density_first_screen: 文字数 / px² で密度を測る、1500 字超 = 詰め込み
- nav_item_count: グローバルナビが 7 項目超 = 整理不足
- has_signal_to_noise: 主 CTA 周辺に説明 + 信頼指標 (★/User数/ロゴ) が 1 つ以上

**減点**: 楽天 LP 風の詰め込み / ナビが 10 項目以上

## Web 軸 4: Responsive 完成度

**サブメトリクス**:
- mobile_overflow: 横スクロールが発生している
- mobile_text_size: モバイルで 14px 未満の本文
- mobile_tap_target: ボタンが 44×44 未満
- breakpoint_jump: tablet (768px) で突然崩れる

**減点**: 横スクロール / モバイルで CTA が小さい / タブレットで break

## Web 軸 5: パフォーマンス示唆 (静的観察のみ)

**サブメトリクス**:
- image_format: jpg/png ばかりで webp/avif 未使用
- image_dimension_appropriate: 1440 表示に対して 4000px 画像など過大
- font_loading_flash: web font の FOIT/FOUT (動的検査は別軸)

**減点**: 重そうな heroバナー / web font 大量読み込み (Vision で動的観察)

## Web 軸 6: SEO 視覚 (オプション)

- title / h1 / meta description の 3 階層整合
- og:image の縦横比 (1.91:1 OK)
- 単一 h1 / heading の semantic 構造

(重要だが design-review の主軸ではないので strict 時のみ評価)
