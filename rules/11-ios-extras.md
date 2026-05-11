# iOS 用 追加軸

Apple HIG 2026 + Liquid Glass 前提。共通 9 軸に乗せる。

## iOS 軸 1: HIG 準拠

**サブメトリクス**:
- safe_area_respect: status bar / home indicator / notch を踏んでいない
- nav_bar_pattern: 標準 nav bar / large title / 自前 header の使い分けが妥当
- tab_bar_count: 3-5 項目 (HIG 推奨)、6 以上は overflow に
- sheet_handle: bottom sheet にハンドルがあって dismiss 直感的

**減点**: status bar 直下に文字 / nav bar 自作で標準と乖離 / tab 6 以上

**参考**: SwiftUI で `safeAreaInset` + ScrollView を組合せる時、scroll overflow との競合に注意 (HIG 「Layouts」セクション)。

## iOS 軸 2: Tap Target

**サブメトリクス**:
- min_tap_44pt: 全タップ要素が 44×44 pt 以上
- spacing_between_taps: 隣接タップ要素間 8pt 以上
- thumb_zone: 主要 CTA が画面下半分 (片手親指到達)

**減点**: 36×36 のボタン / 角の close ボタンが小さすぎる / CTA が画面上端

## iOS 軸 3: Dynamic Type 対応

**サブメトリクス**:
- system_text_style: `.title`, `.headline`, `.body` 等の SwiftUI semantic font を使用
- layout_breaks_at_200: Dynamic Type 200% で UI が破綻しない
- truncation_acceptable: 長文の切り詰めで意味が落ちない

**減点**: ハードコード font-size (`.font(.system(size: 16))`) / 拡大時に文字切れ

**確認**: Settings > Accessibility > Display & Text Size > Larger Text ON で再撮影

## iOS 軸 4: Dark Mode

**サブメトリクス**:
- color_scheme_aware: light/dark で色が切り替わる
- contrast_maintained_dark: dark でも WCAG 4.5:1 保たれる
- material_appropriate: `.regularMaterial`, `.thinMaterial` を背景に活用 (Liquid Glass)

**減点**: dark で文字が見えない / 光源 (white panel) がそのまま乗っている

## iOS 軸 5: ジェスチャー / Interaction

**サブメトリクス**:
- swipe_back: navigation で edge swipe back が効く
- haptic_feedback: 主要 CTA に `.sensoryFeedback` / `UIImpactFeedbackGenerator`
- animation_native_feel: spring animation で慣性感、線形 ease は減点

**減点**: 強制 modal で back できない / ボタン押しても無反応 / linear ease

## iOS 軸 6: Liquid Glass / 2026 適合

**サブメトリクス**:
- material_used: `.ultraThinMaterial` 等のガラス感
- depth_layering: foreground/midground/background の 3 階層
- subtle_animation: < 300ms の控えめなトランジション

**減点**: フラットすぎて 2018 年感 / 過剰 blur で文字読めない

## 確認すべき主要画面 (アプリ scaffold 標準構成)

1. Onboarding / Welcome
2. メイン (Home / Feed / List)
3. 詳細 (Detail)
4. Settings
5. Paywall (有料アプリ)
6. Empty State (空のとき)
7. Error State (ネットワークエラー時)

strict モードでは 7 種類すべて、normal は上 5 つ、friendly は 1-3 のみ。
