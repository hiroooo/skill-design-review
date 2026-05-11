# Android 用 追加軸

Material 3 (Material You) 前提。共通 9 軸に乗せる。

## Android 軸 1: Material 3 準拠

**サブメトリクス**:
- top_app_bar_pattern: TopAppBar standard / center / large の使い分け
- navigation_pattern: BottomNavigationBar / NavigationRail / NavigationDrawer の選択が画面サイズに合う
- fab_usage: FAB は主要 1 アクションのみ、複数は減点
- card_elevation: Material 3 elevation level (0-5) を 2-3 種類で抑える

**減点**: iOS 風の上 nav + 下 tab bar / FAB が複数 / Card に shadow を勝手に追加

## Android 軸 2: Tap Target

**サブメトリクス**:
- min_tap_48dp: タップ要素 48×48 dp 以上
- icon_button_padding: icon button の touch ripple 領域が 48 dp

**減点**: 32 dp の icon button / 行間隔 4dp で密集

## Android 軸 3: Dynamic Color (Material You)

**サブメトリクス**:
- dynamic_color_supported: ColorScheme が壁紙連動を考慮
- on_surface_contrast: surface / onSurface のコントラスト維持

**減点**: 固定原色 (`#FF5722`) ハードコード / wallpaper 切替で破綻

## Android 軸 4: Edge to Edge (Android 15+)

**サブメトリクス**:
- system_bars_translucent: status / navigation bar が translucent or 適切に handle されている
- inset_handling: WindowInsets を respect、コンテンツが system bar に隠れない

**減点**: コンテンツが status bar 下に潜る / nav bar に被って tap 不可

## Android 軸 5: モーション

**サブメトリクス**:
- motion_easing_standard: Material 3 motion (FastOutSlowIn 等) を使用
- transition_duration: 200-400ms 範囲、800ms 超は冗長

**減点**: linear / 過剰 spring / 1s 超アニメ

## 確認すべき主要画面

iOS 同様 7 種:
1. Onboarding
2. Home
3. Detail
4. Settings
5. Paywall (or Play Billing 画面)
6. Empty
7. Error

ただし Android は **Pixel 6 (1080×2400 / 6.4")** をベースに。Foldable は別途依頼があれば追加。
