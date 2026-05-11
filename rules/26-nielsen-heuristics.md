# Nielsen 10 Usability Heuristics (interaction 評価軸)

既存 10 軸 (visual 寄り) を補完する **interaction 観点** の評価軸。strict モード or プロダクト app (LP ではなく) を対象にする時に有効化する。

Nielsen の 10 原則は 1994 年以来の業界デファクト。視覚デザインだけでは漏れる「使いやすさ」「エラー回復」「help」の観点をカバーする。

## 軸対応表 (既存軸とのオーバーラップ)

| Nielsen # | 原則名 | design-review 既存軸 | 新規 (strict 時のみ評価) |
|---|---|---|---|
| 1 | Visibility of system status | — | ✅ `system_status` |
| 2 | Match real world | — | ✅ `real_world_match` |
| 3 | User control & freedom | — | ✅ `user_control` |
| 4 | Consistency & standards | `consistency` 軸と統合 | (既存統合) |
| 5 | Error prevention | — | ✅ `error_prevention` |
| 6 | Recognition over recall | — | ✅ `recognition` |
| 7 | Flexibility & efficiency | — | ✅ `flexibility` |
| 8 | Aesthetic & minimalist | `modernity` / `whitespace` と統合 | (既存統合) |
| 9 | Error recovery | — | ✅ `error_recovery` |
| 10 | Help & documentation | — | ✅ `help_doc` |

→ **新規 8 軸** + 既存 10 軸 = 計 18 軸 (strict 時)。`normal` / `friendly` 時は既存 10 軸のみ。

## 評価ガイド (各 Nielsen 軸の判定 prompt)

### system_status (システム状態の可視性)
- ローディング表示 / 進捗 bar / 状態フィードバック (button hover / press / disabled) が明示されているか
- toast / inline notification で操作結果が見えるか
- **減点**: loading なし / 「処理中」の表示なし / button click 後の反応なし

### real_world_match (システムと現実世界の一致)
- ユーザーが知っている用語 / アイコン / メタファーを使っているか
- 技術用語 (API / endpoint / state) を UI に露出していないか
- **減点**: 「Submit」ばかりで具体 verb なし / icon が抽象的すぎて意味不明

### user_control (ユーザーコントロールと自由)
- Undo / Cancel / 戻る が常に可能か
- modal を ESC や outside click で閉じられるか
- 取り消し可能な操作が明示されているか
- **減点**: 「削除しました」(復元不可) / Cancel が無い modal / 操作中の中断不可

### error_prevention (エラー予防)
- 危険な操作の前に確認 dialog がある
- form の inline validation (送信前)
- 削除 / 不可逆操作で明示的な「本当に？」確認
- **減点**: 削除 button 1 押しで消える / 確認なしの大きな破壊

### recognition (認識 vs 想起)
- 必要な情報がその場で見えている (memory 依存しない)
- placeholder ではなく label / 例 / 説明
- 過去入力の autocomplete
- **減点**: placeholder で項目消える / 「思い出してね」要求

### flexibility (柔軟性 + 効率性)
- ショートカット (キーボード / accelerator) がある
- 上級者の bulk action / template / preset
- power user の高速化導線
- **減点**: 必須クリック多い / shortcut なし / 同じ操作の繰り返し強要

### error_recovery (エラー回復)
- エラーメッセージが「何が起きたか」「どうすれば良いか」を提示
- error code じゃなく自然言語
- 入力した内容が消えないリトライ動線
- **減点**: 「Error 500」「Something went wrong」だけで何も分からない

### help_doc (ヘルプとドキュメント)
- inline help (?) tooltip / contextual hint
- 「使い方」/ onboarding tour / empty state guidance
- 検索可能 docs
- **減点**: 操作方法が画面から推測不能 / 外部ドキュメント探さないと分からない

## モード別評価ポリシー

| level | 既存 10 軸 | Nielsen 8 軸 | 合計 |
|---|---|---|---|
| `friendly` | 評価 | 評価しない | 10 |
| `normal` | 評価 | 評価しない | 10 |
| `strict` | 評価 | 評価する | 18 |

`general` モードで LP audit → Nielsen は通常 evaluate しない (LP は閲覧中心、interaction 軽い)。
**プロダクト app の audit / strict 時のみ Nielsen 評価**。

## issues.json への追加

strict 時に Nielsen 軸の issue を追加する際の axis enum:
- `system_status` / `real_world_match` / `user_control` / `error_prevention`
- `recognition` / `flexibility` / `error_recovery` / `help_doc`

(現状の schema は `axis` enum でこれら未対応 → strict 実装時に schema 拡張)

## 参考
- Nielsen Norman Group: https://www.nngroup.com/articles/ten-usability-heuristics/
- 5 reviewers で independently 評価 → severity を合議で集約 (NN/g 推奨)
