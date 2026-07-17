# 41 — iOS 実行時チェックリスト

> Phase 3「チェックリスト検査」で **iOS ターゲット時に全項目を pass / fail / n-a 判定**する。
> fail は issue 化 (`ref_doc: rules/41-checklist-ios.md#IOS-XX`)。level 不問で省略しない。
> 出典: Apple Human Interface Guidelines / App Store Connect アクセシビリティ評価基準 (2026-07 調査)。既存 `rules/11-ios-extras.md` (HIG 準拠 / Tap Target / Dynamic Type / Dark Mode) と重複する観点は載せていない。
> スクショに該当 UI が写っていない項目 (アラート / ローディング / オンボーディング等) は n-a。

## アイコン

- [ ] **IOS-01** アプリアイコンに自前で角丸・影・透過を付けていない (システムが自動マスクする前提の正方形フル画像) — pass基準: 1024×1024px PNG、透過なし、四隅を自分で丸めていない （出典: https://developer.apple.com/design/human-interface-guidelines/app-icons）
- [ ] **IOS-02** アプリアイコンの主要モチーフがマスクで切れる位置に配置されていない — pass基準: ロゴ等の主要要素がキャンバス中央 70〜80% 以内に収まっている （出典: https://developer.apple.com/design/human-interface-guidelines/app-icons）

## 色・コントラスト

- [ ] **IOS-03** 通常テキスト・ボタン・コントロールのコントラストがライト / ダーク両モードで基準を満たす — pass基準: 通常テキスト 4.5:1 以上、UI コンポーネント / フォーカスインジケータ 3:1 以上 （出典: https://developer.apple.com/help/app-store-connect/manage-app-accessibility/sufficient-contrast-evaluation-criteria/）
- [ ] **IOS-04** 状態・エラー・成功表示が色のみに依存していない — pass基準: 色分けされた状態表示に必ずアイコンまたはテキストラベルが併記 （出典: https://developer.apple.com/help/app-store-connect/manage-app-accessibility/differentiate-without-color-alone-evaluation-criteria/）

## ナビゲーション / モーダル

- [ ] **IOS-05** モーダル (sheet / full-screen) と push 遷移の使い分けが妥当 — pass基準: 単発タスク・入力系は sheet、カメラ / 写真編集等の没入系は full-screen modal、閲覧の深掘りは push (NavigationStack) （出典: https://developer.apple.com/design/human-interface-guidelines/modality）
- [ ] **IOS-06** モーダル表示中はタブバーが隠れている — pass基準: モーダルを開いた画面でタブバーが非表示 （出典: https://developer.apple.com/design/human-interface-guidelines/modality）
- [ ] **IOS-07** アラートのボタン数が過剰でない — pass基準: アラートのボタンは最大 2 個、3 個以上必要なら action sheet を使用 （出典: https://developer.apple.com/design/human-interface-guidelines/alerts）

## フロー / 状態表示

- [ ] **IOS-08** オンボーディングが簡潔でスキップ可能 — pass基準: オンボーディング画面が 3 枚以内、スキップ導線がある （出典: https://developer.apple.com/design/human-interface-guidelines/onboarding）
- [ ] **IOS-09** ローディング表示に処理特性と合ったインジケータを使用 — pass基準: 所要時間が既知の処理は determinate progress bar、不明な処理は indeterminate スピナー （出典: https://developer.apple.com/design/human-interface-guidelines/loading）

## アイコノグラフィ

- [ ] **IOS-10** SF Symbols のウェイト・レンダリングモードが画面内で統一されている — pass基準: 同一画面内で symbol weight が隣接テキストと一致し、rendering mode (mono / hierarchical / palette / multicolor) が混在していない （出典: https://developer.apple.com/design/human-interface-guidelines/sf-symbols）
