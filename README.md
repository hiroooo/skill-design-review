# design-review

> Claude Code skill — Web / iOS / Android の UI を **10 軸スコアリング + 1 行コメント** で採点し、ダッシュボード型 HTML レポートを出力する design audit skill。

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude%20Code-skill-orange)](https://code.claude.com)

---

## 何ができる

- **10 軸 0-100 スコア**: 可読性 / 情報階層 / 余白 / タイポ / 配色 / 画像密度 / モダン度 / 統一感 / アクセシビリティ / ブランド約束
- **1 行コメント**: 各軸でなぜそのスコアか + 何が良くて何がダサいか
- **focus crop + 該当バッジ**: 該当箇所をピンポイントで切り出して赤バッジで指摘
- **用語 tooltip**: 45+ 用語 (デザイントークン / FOIT / gray-900 等) を hover で説明
- **色覚 simulation**: Protanopia / Deuteranopia / Tritanopia / 完全色盲 を 1 クリック切替
- **Display toggle**: 対象スクショを Fit / Full / Mobile プレビュー
- **ダッシュボード型 HTML**: sidebar nav + KPI tile + 軸 grid + issue list + 良かった点 + 参考サイト
- **Dark mode**: OS の prefers-color-scheme に追従
- **PDF 印刷対応**: ⌘P でそのまま PDF 化、page-break 制御込み
- **Severity effort chip**: 修正コスト (quick / moderate / major) で着手順を判断

---

## インストール

### A. Claude Code plugin 経由 (推奨)

```
/plugin marketplace add hiroooo/skill-design-review
/plugin install design-review@hiroooo-skill-design-review
```

### B. 手動 clone

```bash
git clone https://github.com/hiroooo/skill-design-review.git \
  ~/.claude/skills/design-review
```

---

## 依存関係

### 必須
| 依存 | 用途 | インストール |
|---|---|---|
| **Claude Code** | skill 実行環境 | [公式](https://claude.com/claude-code) |
| **Playwright MCP** | Web ターゲットの自動キャプチャ | `~/.claude/mcp.json` に登録 (下記) |
| **Python 3** | テンプレ置換 + PNG dim 取得 | macOS / Linux 標準装備 |
| **Bash** | render-report.sh | macOS / Linux 標準 |

### Playwright MCP の登録

`~/.claude/mcp.json` (なければ新規) に追加:

```jsonc
{
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  }
}
```

初回 `npx` で自動 install されます。

### オプション
| 依存 | 用途 |
|---|---|
| **xcodebuild MCP** | iOS Simulator キャプチャ (iOS ターゲット時のみ) |
| **node + `playwright` npm** | `capture-share.mjs` の subprocess 実行 (MCP 経由でも代替可) |

---

## Quick Start (3 step、個人開発者の改善ループ)

### 1. レビュー実行
```
/design-review
```
対象 URL / プラットフォーム / モードを答えるだけ。3 viewport × Light/Dark でキャプチャ + CSS 解析 + Vision 採点 + 報告書を自動生成。

### 2. レポートを開く
```bash
open <出力先>/report.html
```
- 10 軸スコア + 1 行コメント
- High / Medium / Low / Good の KPI tile (クリックで該当 section にスクロール)
- Issue card ごとに 該当箇所 crop + 赤バッジ
- 色覚 simulation / Display モード切替 / 用語 tooltip / Dark mode / PDF 印刷対応

### 3. 修正対話に投げる
気になる Issue card 右上の **「📋 Claude へ」 button** をクリック → clipboard に修正 prompt がコピーされる:

> issues.json の typo_001 を修正してください。
> [Issue] font-family fallback 7 種で chain が冗長
> [Why] 実 render は 2-3 種だが chain が長いと FOIT/FOUT リスク + design token 不在の兆候
> [Fix] 和文 Zen Kaku Gothic + 英文 SF Pro + monospace の 3 family に集約。CSS 変数 (--font-sans / --font-mono) で集中管理
> [axis] typography / priority high
>
> 該当ファイル/コンポーネントを grep + Edit で直接修正してください。

→ Claude Code に paste するだけで該当ファイル特定 → Edit → 修正完了。

→ 修正後にもう一度 `/design-review` を回せば改善 score を確認できる。

---

## ヒアリング項目 (Q1-Q3)

1. **対象プラットフォーム**: Web URL / iOS Simulator / 画像 PNG
2. **スコープ**: 単一画面 / 主要 3-5 画面 / サイト全体
3. **モード × レベル**: `general` / `diff` × `strict` / `normal` / `friendly`

---

## 出力ファイル

```
$OUT_DIR/                          # apps/<name>/.scratch/design-review-<TS>/
├── captures/                       # 取得スクリーンショット
│   ├── desktop-light.png
│   ├── desktop-dark.png
│   ├── tablet-light.png
│   ├── mobile-light.png
│   └── styles.json                 # Web のみ (computed style 統計)
├── issues.json                     # 修正対話用の構造化データ
├── report.md                       # GitHub / PR 貼り付け用
├── report.html                     # 主成果物 (ダッシュボード)
└── share-x.png                     # X 投稿用 1200×675 (オプション)
```

`report.html` を `open` するだけで全てが見えます。後段で Claude に
「`issues.json` を読んで重大な指摘から修正して」と頼めば改修対話に入れます。

---

## 評価軸 (10 + α)

| # | 軸 | 重み | チェック内容 |
|---|---|---|---|
| 1 | 可読性 | 0.13 | contrast / 行長 / 行間 / 最小フォントサイズ |
| 2 | 情報階層 | 0.09 | h1/body 比 / weight 段階 / 色階層 |
| 3 | 余白・リズム | 0.10 | spacing scale 整列度 / 8pt grid 適合 |
| 4 | タイポグラフィ | 0.11 | font 種類 / weight 多様性 / NG フォント |
| 5 | 配色 | 0.09 | true black/white / 彩度過多 / accent 整理 |
| 6 | 画像密度 | 0.08 | text:image 比 / stock 感 / aspect 統一 |
| 7 | モダン度 (2026) | 0.10 | gradient / shadow / radius / easing |
| 8 | 統一感 | 0.09 | design token らしさ / motif 一貫 |
| 9 | アクセシビリティ | 0.09 | WCAG AA / tap target / alt / focus |
| 10 | ブランド約束 | 0.12 | アプリ名/コピーで謳う core feature の視覚化 |

`strict` モード時のみ Nielsen 10 usability heuristics の 8 軸が追加で評価されます (`rules/26-nielsen-heuristics.md`)。

---

## ダッシュボード スクリーンショット

`examples/` 配下に Sublog LP を採点した sample report.html を同梱しています。

```bash
open ~/.claude/skills/design-review/examples/sample-report/report.html
```

---

## カスタマイズ

各 rule は `rules/*.md` に分割されています。プロジェクトの基準に合わせて編集可能:

| ファイル | 内容 |
|---|---|
| `rules/00-axes-common.md` | 共通 10 軸の定義と重み |
| `rules/10-web-extras.md` | Web 用 追加軸 (Hero / CTA / SEO 等) |
| `rules/11-ios-extras.md` | iOS 用 追加軸 (HIG / Dynamic Type 等) |
| `rules/12-android-extras.md` | Android 用 追加軸 |
| `rules/20-dasai-typography.md` | フォントの「ダサい」シグナル |
| `rules/21-dasai-spacing.md` | 余白の「ダサい」シグナル |
| `rules/22-dasai-imagery.md` | 画像 / icon の「ダサい」シグナル |
| `rules/23-dasai-color-shadow.md` | 配色 / shadow / radius / animation |
| `rules/24-modern-2026.md` | 2026 基準で「古い」装飾 |
| `rules/25-brand-promise.md` | ブランド約束 (indie アプリの盲点) |
| `rules/26-nielsen-heuristics.md` | Nielsen 10 (strict mode) |
| `rules/29-mobile-onehand.md` | Mobile thumb zone / one-hand reach |

---

## トラブルシューティング

### Playwright が動かない
- `~/.claude/mcp.json` で `playwright` server が登録されているか確認
- **Claude Code の main session で起動**しているか確認 (subagent 経由では permission denied)
- 初回は `npx @playwright/mcp@latest` を一度走らせて install を完了させる

### iOS Simulator が映らない
- FamilyControls 系 API や VisionKit 等は Simulator で動かない → 実機 PNG を `captures/` に直接置く
- ファイル名規約: `ios-<screen>-light.png` / `ios-<screen>-dark.png`

### `.scratch/` が `.gitignore` に入っているのに作られる
- 仕様: プロジェクトルートを汚さないために `apps/<name>/.scratch/design-review-<TS>/` に書き出す
- 各アプリ submodule の `.gitignore` に `.scratch/*` を追加推奨

### `share-x.png` が生成されない
- 主成果物 `report.html` は出る、share-x.png はオプション
- 必要なら main session で MCP `browser_take_screenshot` の `element: "#hero"` で生成
- subprocess 経由なら `node ~/.claude/skills/design-review/scripts/capture-share.mjs <report.html> <out.png>` (要 `playwright` npm install)

---

## 思想

このツールは **「指摘の列挙」** ではなく **「読みもの」** を目指しています:

- 各軸にスコアだけでなく 1 行コメントで「なぜそのスコアか」を物語化
- 用語 tooltip で専門用語の壁を排除
- focus crop + バッジで「どこを指している」を一目で示す
- AI ジェネ感を意図的に排除した編集記事 + ダッシュボード融合のレイアウト

そして **後段の修正対話に乗せやすい構造化データ (`issues.json`)** を残すことで、
Claude に「`issues.json` の high から直して」と頼むだけで改修サイクルに入れます。

---

## ライセンス

[MIT](LICENSE)

## 関連プロジェクト

- [iap-promo-image](https://github.com/hiroooo/iap-promo-image) — IAP プロモ画像 1024×1024 を HTML テンプレで生成 (App Store 2.3.2 reject 防止)
- [Claude Code marketplace](https://claudemarketplaces.com/) — Claude Code skill / plugin の発見ポータル

---

🤖 Built with Claude Code
