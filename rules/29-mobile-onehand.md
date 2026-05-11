# Mobile : One-Hand Reach & Thumb Zone

モバイル UI で「片手で楽に届く範囲 (thumb zone)」を考慮した配置になっているか。

Steven Hoober (2013) の調査で、スマホ片手操作 75% / 両手操作 25%。片手の親指で快適に届く範囲 = **画面下半分の中央寄り**。重要操作はそこに置くのが定石。

## 軸スコアへの反映

既存 `accessibility` 軸のサブメトリクスとして扱う (新規軸じゃない):
- iOS / Android 評価時のみ active
- web (responsive view) では mobile viewport 評価時にチェック

## ダサさシグナル (Mobile 特有)

### S1. 主要 CTA が画面上半分にある
- 「保存」「次へ」「購入」等の primary CTA が画面上 1/3 以内に固定されている
- 親指が届かない、操作ごとに持ち替え必要
- → priority `high` (= 致命的)

### S2. 主要操作の連打が画面四隅
- 「戻る (左上)」+「次へ (右下)」を 1 画面で何度も往復
- 親指の対角線移動が頻発
- → priority `medium`

### S3. tab bar が下にあるのに primary action が上
- bottom nav はモダンだが、その上の content 内で主操作が上にあると thumb zone から外れる
- iOS HIG / Material Design は bottom action 推奨
- → priority `medium`

### S4. Safe area / Notch / Dynamic Island を考慮していない
- 上部の status bar / notch / dynamic island の下に重要要素を配置 (隠れる)
- 下部の home indicator にかかる位置に tap target
- → priority `high`

### S5. tap target が thumb zone から外れている
- 画面端 (左右上下 8px 以内) に小さな target
- 片手だと角は届きにくい
- → priority `medium`

### S6. landscape で thumb zone が崩れる
- 縦持ち前提の bottom nav が横持ちで横幅 100% になり、片手で届かない
- → priority `low` (横持ちは使用率低い)

## 判定方法

Vision で screenshot を見て:
1. 画面を縦に 3 分割 (上 1/3 / 中 1/3 / 下 1/3)
2. 主要 CTA (button / link / primary action) の位置を識別
3. 上 1/3 にある = ❌ / 中 1/3 = △ / 下 1/3 = ✅
4. safe area 領域 (iOS notch / home indicator) との干渉確認

### Vision prompt 例
```
このアプリ画面で:
1. 主要 CTA (最も重要な action button) はどこにあるか? (上 / 中 / 下)
2. その位置は片手 (右利き想定) の親指で楽に届くか?
3. safe area (iOS notch / home indicator) と重なる要素があるか?
0-3 で thumb zone 適合度を採点。
```

## 良い点ハイライト

- 主要 CTA が画面下 1/3 中央にある (= 片手で楽)
- bottom nav が大きく明確、tap target ≥ 44x44 pt
- destructive action は上 (慎重に到達するべき場所)
- safe area 配慮、home indicator 上に余白 16pt+

## 関連
- iOS HIG: https://developer.apple.com/design/human-interface-guidelines/layout
- Material Design Layout: https://m3.material.io/foundations/layout
- Steven Hoober (2013) thumb zone 研究
- `rules/11-ios-extras.md` — iOS 固有
- `rules/21-dasai-spacing.md` S2 — モバイル端張り付き
