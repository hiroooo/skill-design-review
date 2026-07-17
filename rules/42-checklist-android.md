# 42 — Android 実行時チェックリスト

> Phase 3「チェックリスト検査」で **Android ターゲット時に全項目を pass / fail / n-a 判定**する。
> fail は issue 化 (`ref_doc: rules/42-checklist-android.md#AND-XX`)。level 不問で省略しない。
> 出典: Material 3 / Android Developers (2026-07 調査)。既存 `rules/12-android-extras.md` (Material3 準拠 / Tap Target / Dynamic Color / Edge to Edge) と重複する観点は載せていない。
> 静止スクショで判定できない項目 (AND-03 プレディクティブバック等) は動画 / 実機確認がなければ n-a。

## レイアウト適応

- [ ] **AND-01** 画面幅に応じたレイアウト適応 (window size class) ができている — pass基準: 幅 840dp 以上で単一カラムのまま伸びておらず、デュアルペイン等ワイド対応レイアウトに切り替わる （出典: https://m3.material.io/foundations/layout/applying-layout/window-size-classes）
- [ ] **AND-08** 大画面 (タブレット / 折りたたみ) でナビゲーションが適応している — pass基準: 幅 600dp 以上でボトムナビゲーションバーではなく navigation rail 等を使用 （出典: https://m3.material.io/components/navigation-rail/guidelines）

## コンポーネント / スタイル

- [ ] **AND-02** elevation の表現が Material 3 の tonal 方式に沿っている — pass基準: level 0 (filled button / outlined card 等フラット要素) に自前の drop shadow を追加していない （出典: https://m3.material.io/styles/elevation/tokens）
- [ ] **AND-04** ボトムナビゲーションの選択状態表現が Material 3 準拠 — pass基準: 選択中タブは塗りつぶしアイコン + pill 型インジケータ、非選択タブはアウトラインアイコン （出典: https://m3.material.io/components/navigation-bar/overview）
- [ ] **AND-05** タイポグラフィが type scale のロールに揃っている — pass基準: 画面内の文字サイズが Display / Headline / Title / Body / Label × Large / Medium / Small の代表値に揃い、アドホックな px 指定が乱立していない （出典: https://m3.material.io/styles/typography/type-scale-tokens）
- [ ] **AND-06** 一時的な状態通知に Snackbar を使い、処理をブロックしていない — pass基準: 短い通知は画面下部の Snackbar (自動消滅または 1 アクション)、ブロッキング AlertDialog を使っていない （出典: https://m3.material.io/components/snackbar/guidelines）
- [ ] **AND-07** 色付きコンテナ上のテキストが対応する on- ロールカラーで視認性を確保 — pass基準: colored container 上のテキストが同系統の on-role カラーで、小文字 4.5:1 / 大文字・UI 要素 3:1 を満たす （出典: https://m3.material.io/foundations/designing/color-contrast）

## インタラクション

- [ ] **AND-03** システムバック操作でプレディクティブバックに対応している — pass基準: スワイプバック中に遷移先画面のプレビューが表示され、突然のカット切り替えにならない （出典: https://developer.android.com/design/ui/mobile/guides/patterns/predictive-back）
