# 画像密度・テイストの「ダサい」シグナル

写真 / イラスト / アイコンの使い方で素人っぽさが出やすい。

## ダサさシグナル

### S1. ファーストビューに画像 5 枚以上
- above-the-fold (≈900px) 内の img / picture / video / svg-illustration 数 ≥ 5
- → `medium` (チラシ感、視線散漫)
- 例外: グリッド product showcase は OK

### S2. hero に visual ゼロ
- above-the-fold に画像 / 動画 / 大型グラフィックがない、文字だけ
- 2026 SaaS では珍しい (Linear / Stripe / Vercel / Figma 全部 hero に visual)
- → `medium`、「文字が中心の Editorial」狙いなら friendly に下げる

### S3. stock photo 感
- 笑顔の外国人モデル / 握手 / 巨大ホワイトボードでミーティング / 矢印 + 上昇グラフ
- 「Unsplash でよく見るあれ」
- → `high`、「ブランド固有のビジュアル不在」

→ Vision で判定: prompt 例
> 「この画像は stock photo に見える典型例 (笑顔モデル / 握手 / 抽象ビジネス) を含むか? 0-100 で stock 感をスコア化」

### S4. 写真 + イラスト + cartoon の混在
- 同 1 セクション内で実写 + 3D illust + line drawing + emoji が混ざる
- → `high` (テイスト不統一 = 素人)
- 例外: あえて collage 表現の場合は OK

→ Vision で 1 セクション内の image style 数を判定

### S5. aspect ratio バラバラ
- card grid で画像が 16:9, 1:1, 4:3 混在 → トリミング失敗印象 → `medium`
- → `medium`
- 推奨: card grid は全部 16:9 or 1:1 で統一

### S6. text:image 比率の崩れ
- 推奨: section 全体で 60% text : 40% image
- hero は 30% text : 70% image でも OK
- product feature 紹介で 95% text + 5% icon → `low`、文字過多

### S7. 画像のクオリティ低下サイン
- 拡大すると jpeg ノイズ
- 透過なし PNG が白背景に置かれて margin が見える
- アイコンが PNG (svg にできる場面) → `low`、解像度のばら付き

→ Vision で判定 (低解像度 / blurry / 圧縮ノイズ)

### S8. 商品/UI スクリーンショットがフレームなし裸
- App Store のような商品紹介で UI スクショだけポンと貼られる → `low`
- iPhone モックアップ / browser frame / 影 (subtle) で囲うとモダン

### S9. 装飾 emoji の乱発
- ✨🚀💪🔥 を見出しや CTA に使いまくる → `medium`
- 2026 では line icon set / solid icon set に置き換えが主流
- 例外: コミカルなブランドや Discord/Slack 系 LP は OK

### S10. 背景パターン / pattern overlay の古さ
- subtle dot grid / line grid は OK
- 強い半透明 mesh / 虹色 noise / 派手 confetti は古い → `medium`

### S11. アイコンスタイル混在
- line icon (Heroicons outline) + solid icon (Heroicons solid) + colored icon (Twemoji) が同時に使われる → `medium`

## 良い点ハイライト

- hero に確固たる visual がある (Linear のような立体グラフ)
- 画像のテイストが統一されている (全部 line illustration / 全部実写)
- aspect ratio が grid 内で揃っている
- アイコンが 1 set に統一 (Lucide / Heroicons / Material Symbols)
- emoji を使うとしても CTA や見出しでなく contextual な場面のみ
- product UI スクショに browser/device frame と微小 shadow

## 機械判定 vs Vision

| シグナル | 手段 |
|---|---|
| ファーストビュー画像数 | DOM (img / picture 数) + Vision |
| stock 感 | Vision |
| テイスト混在 | Vision |
| aspect ratio | DOM (img の natural width/height) |
| 解像度 | DOM (src の dimension チェック) |
| アイコン set | Vision (line vs solid 判別) |

iOS / Android のアプリスクショは全部 Vision で判定。

## S12. Material / iOS 既製 icon の象徴的 overuse

特定の generic icon を「ブランドの顔」として使うと「どこかで見た」感が出る:

- `Icons.workspace_premium` (王冠リボン) — Premium / Paywall で常識的すぎ
- `Icons.auto_awesome` (4 点星) — AI 機能の指標として濫用、Apple Intelligence 以来コモディティ
- `Icons.rocket_launch` — startup LP 直貼り
- `Icons.lightbulb` — Tips / お得情報の決まり文句
- `Icons.diamond` — Pro tier 表示の凡庸選択

→ priority `medium`、特に Paywall / Hero の主要 visual で使用していたら `high`

修正候補:
- (a) アプリ独自 illustration スタイルで作る (line drawing / 3D / 写真)
- (b) Material icon でも普段使われない選択肢に置換
- (c) icon を撤廃、typography だけで表現

特に **アプリ icon 設計と一貫した style の custom icon** が ideal。

判定 method:
- スクショから象徴 icon の位置 + サイズを Vision 確認
- それが Material / iOS 既製の有名どころ ID であれば flag

例 (eitango-image 第 2 round audit):
- Paywall hero に `Icons.workspace_premium` 使用 → 修正提案: AI 挿絵スタイルで「鍵 + 王冠」custom icon を生成して差別化
