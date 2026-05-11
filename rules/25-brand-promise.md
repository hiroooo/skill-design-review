# Brand Promise Alignment (アプリ盲点の核心)

アプリ名・コピー・app icon で謳った core feature が、実際の画面で「視覚的に」「明示的に」実装されているかを検査する独立軸。

indie アプリで盲点になりがちな致命傷:
- 「絵で覚える英熟語」アプリで絵が無い
- 「集中カプセル」で集中ガジェットが薄い
- 「Sublog」で sub UI 中心が分かりづらい
- 「画像を簡単に編集」アプリで編集導線が深い

## 判定方法

### Step 1: アプリ約束の抽出

以下 3 ソースから "core feature noun" を抽出:

1. **App 名** — タイトルに含まれる動詞 / 名詞 (「絵で覚える」「集中」「タイマー」等)
2. **App Store subtitle / tagline** — 提供価値の短文
3. **Onboarding hero copy** — 第一印象の中核

例:
- 「絵で覚える英熟語300」 → 約束: **絵で覚える** / **英熟語**
- 「mikan 単語アプリ」 → 約束: **単語**
- 「集中カプセル」 → 約束: **集中** / **カプセル**

### Step 2: 各画面で約束の visual representation を確認

主要 5 画面 (Onboarding / Home / Detail / Paywall / Settings) で:

- **Onboarding**: 約束した core feature の visual サンプルが見えるか
- **Home / List**: 約束を表す主要 visual element が一覧で見えるか
- **Detail**: 約束した core experience が centerstage か
- **Paywall**: 課金で得られる約束の "after picture" が見えるか
- **Settings**: 約束に関わる設定 / トグルがあるか (核機能なら)

### Step 3: スコアリング

各画面で 0-3 で採点:
- 0: 約束に関わる visual / element 完全不在
- 1: 文字でのみ約束に触れ、絵がない
- 2: 関連 visual あるが弱い (placeholder / 借り物 icon / 小さい)
- 3: 約束を体現する visual が明確 + 大きく + 中心配置

合計 / 15 で軸スコア。10 未満で `high` (brand promise breakdown)。

## ダサさシグナル

### S1. 「絵で覚える」「写真で」「動画で」アプリで visual が placeholder
- スクショに「画像 生成予定」「coming soon」「☐」アイコン
- → `high` (シビア)、ローンチ前なら必須項目

### S2. アプリ icon と画面色の不一致
- App icon は warm orange / illustration、画面 theme は wine red など
- → `medium`

### S3. アプリ名の verb と画面導線の不一致
- 名前: 「集中する」、画面: 設定画面ばかり、肝心の「集中モード」CTA が深い
- → `high`

### S4. core feature の onboarding 不在
- onboarding でアプリ名の意味 / 使い方が説明されない (起動 → いきなり Home)
- 約束を verbal で知るだけで visual 体験させてない
- → `medium`

### S5. Paywall で約束の after-state が見えない
- 「全機能アンロック」と書くだけで、unlock 後の画面 mock が無い
- → `medium` (page-cro の Cialdini 原則とも被る)

### S6. List view で 1 件も visual が無い
- 「絵で覚える」「写真で記録」アプリのメインリストで thumbnail / preview が無い
- → `high`

## 良い点ハイライト

- アプリ名を直訳した visual が onboarding hero に出ている
- List view 各 row に core visual の thumbnail
- Detail で核機能が screen の 50% 以上占有
- Paywall に unlock 後の screen mock が嵌っている
- App icon と画面 theme color が一貫

## 具体例 (eitango-image)

| 画面 | 約束「絵で覚える」を視覚化しているか | 評点 |
|---|---|---|
| Onboarding | book icon + 文字「AI 挿絵で覚える」のみ、sample 絵は無い | 1 |
| Home List | rank badge + 文字、絵 thumbnail 無し | 1 |
| Detail | 4:3 image area が大きい、placeholder の段階だが構造 OK | 2 |
| Paywall | 「300 シーンの AI 挿絵」と書くが visual sample 無し | 1 |
| Settings | アプリ説明のテキストのみ | n/a |

合計 5/15 → `high` brand promise breakdown 状態。

修正:
- 300 挿絵バッチ生成 (Detail を 2→3 に上げる)
- Onboarding に sample 挿絵 1 枚 hero (1→3)
- Home List 各 row に thumbnail (1→3)
- Paywall hero に sample 挿絵 grid 6 枚 (1→3)

→ 合計 11-12/15 (整合性 OK レベル)

## 機械判定 vs Vision

100% Vision で判定。

Vision prompt 例:
```
このスクショで「{app_name}」というアプリ名から期待される
core feature ({core_noun}) が画面に visualize されているか?
0-3 で採点 (0=不在, 1=文字のみ, 2=弱い視覚化, 3=明確な視覚化)
```

## 関連 rule

- `22-dasai-imagery.md` — visual 不足 / stock 感
- `00-axes-common.md §軸 6 Image Density` — 全体の文字 vs 画像比率
- `paywall-upgrade-cro` skill — Paywall 設計
