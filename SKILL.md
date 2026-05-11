---
name: design-review
description: Web / iOS / Android の UI を multi-axis でスコアリングし、フォント/余白/画像密度/モダン度の「ダサさ」シグナルを機械的に拾って md+html レポート化する design audit skill。general (一般フィードバック) と diff (目標デザインとの差分) の 2 モード × strict/normal/friendly の 3 レベル。レビュー結果は issues.json に構造化して残し、後続の Claude 修正対話に渡しやすい形で出力する。Use when the user asks for design review, UI audit, ダサさチェック, デザインレビュー, design feedback, 'デザイン見て', or runs /design-review.
metadata:
  version: 1.0.0
allowed-tools: [Read, Write, Edit, Glob, Grep, Bash, AskUserQuestion, WebFetch, WebSearch]
---

# design-review

Web / モバイルアプリの UI を Claude にレビューさせる skill。明らかなバグ / 見づらさ / フォント・余白・画像密度のダサさ / モダン度低下を **9 + α 軸 × 0-100 スコア** + **ダサさシグナル 5 カテゴリ** で評価し、`report.md` + `report.html` + `issues.json` を吐く。後続の修正対話に乗せやすい構造で残すのがゴール。

## いつ使うか

- v1.0 提出前の最終 design audit
- LP / Jekyll サイトのリニューアル前後
- 「なんかダサい気がするけど何が悪いか言語化できない」を機械的に分解したい時
- デザイナー友人レビュー前の自己チェック
- 既存アプリの旧画面と新画面の比較 (diff モード)

## 既存 skill との棲み分け

| Skill | 領域 | この skill との関係 |
|---|---|---|
| `page-cro` | コンバージョン軸 | 直交補完。design-review → page-cro 順で使う |
| `frontend-design` | 実装コード生成 | review 結果を渡して改修に使う |
| `copywriting` | 文言 | 直交補完 |
| Apple plugin `ios-design-consultant` | "どこに置く" 事前相談 | こちらは事後 audit |
| `iap-promo-image` | IAP 画像 1 枚生成 | template + render パターンを流用 |

## 重要な前提 (起動前に確認)

1. **Playwright MCP は main session でないと permission denied** (memory `feedback-playwright-main-vs-agent.md`)。`/design-review` は **必ずメインの Claude Code セッションで起動**、Agent からの委譲では Web キャプチャが失敗する。Agent に投げる場合は PNG 直渡し前提のフローのみ。
2. **一時ファイルは絶対にプロジェクトルートに置かない** (CLAUDE.md / memory `feedback-scratch-location.md`)。出力先自動判定を必ず通す。
3. iOS 実機画面 / FamilyControls 系画面など Simulator で映らないものは MCP 自動キャプチャ不可。最初からユーザー PNG 直渡しを促す。
4. レビュー結果は **AI が読みやすい JSON** と **人間が読みやすい HTML** の両方を残す。md は GitHub PR 貼り付け用。

---

## ワークフロー

### Phase 1 — ヒアリング

`AskUserQuestion` で以下 3 問を最初に聞く。回答が揃うまで他の処理に入らない。

**Q1 対象プラットフォーム**:
- Web URL (Playwright で自動キャプチャ)
- iOS Simulator (xcodebuild MCP で screenshot)
- iOS 実機 / Android / その他 (PNG パスを後で渡す)
- PNG / 画像直渡し (パス指定)

**Q2 スコープ**:
- 単一 1 画面 (URL / 単一 PNG)
- 主要 3-5 画面 (ナビゲートして自動収集 or 複数 PNG)
- サイト全体 (LP の section 単位 / アプリの主要 tab すべて)

**Q3 モード × レベル**:
- mode: `general` (一般フィードバック) / `diff` (目標デザインとの差分 — Figma URL or 目標 PNG が必要)
- level: `strict` (全軸 + low priority も) / `normal` (high/medium のみ) / `friendly` (良い点多め、low 省略)

**追加で必要なら聞く**:
- 対象 URL / アプリの bundle id / 目標 PNG パス / Figma URL
- 「想定読者」「ブランドカラー」「タイトな締切か否か」(friendly モードでのトーン調整に使う)

### Phase 2 — 出力先決定 + キャプチャ取得

#### 出力先自動判定 (Bash で実行)

```bash
TS=$(date +%Y%m%d-%H%M)
CWD=$(pwd)
APP_ROOT=""

# git top の下に apps/<name> があればそこを採用
GIT_TOP=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
if [ -n "$GIT_TOP" ]; then
  REL=${CWD#"$GIT_TOP/"}
  if [[ "$REL" == apps/* ]]; then
    APP_NAME=$(echo "$REL" | cut -d/ -f2)
    APP_ROOT="$GIT_TOP/apps/$APP_NAME"
  fi
fi

if [ -n "$APP_ROOT" ] && [ -d "$APP_ROOT" ]; then
  OUT_DIR="$APP_ROOT/.scratch/design-review-$TS"
else
  OUT_DIR="$HOME/Downloads/design-review-$TS"
fi

mkdir -p "$OUT_DIR/captures"
echo "OUT_DIR=$OUT_DIR"
```

#### Web キャプチャ (Playwright MCP, main session 必須)

3 viewport × Light/Dark = 6 枚を `captures/` に保存:

| viewport | size | ファイル名 |
|---|---|---|
| mobile | 375 × 812 | `mobile-light.png` / `mobile-dark.png` |
| tablet | 768 × 1024 | `tablet-light.png` / `tablet-dark.png` |
| desktop | 1440 × 900 | `desktop-light.png` / `desktop-dark.png` |

各 viewport で:
1. `mcp__playwright__browser_resize` で size 設定
2. `mcp__playwright__browser_navigate` で対象 URL
3. `mcp__playwright__browser_evaluate` で `document.documentElement.style.colorScheme = 'light'` (or 'dark')
4. `mcp__playwright__browser_take_screenshot` で full page を保存

CSS 系統計用に `mcp__playwright__browser_evaluate` で computed styles を JSON dump し `captures/styles.json` に保存:

```js
() => {
  const out = { fonts: [], spacings: [], colors: [], shadows: [], radii: [], animations: [] };
  document.querySelectorAll('*').forEach(el => {
    const cs = getComputedStyle(el);
    out.fonts.push(cs.fontFamily);
    out.spacings.push(cs.margin, cs.padding);
    out.colors.push(cs.color, cs.backgroundColor);
    out.shadows.push(cs.boxShadow, cs.textShadow);
    out.radii.push(cs.borderRadius);
    out.animations.push(cs.transitionTimingFunction, cs.animationTimingFunction);
  });
  return out;
}
```

#### iOS Simulator キャプチャ (xcodebuild MCP)

1. `mcp__xcodebuild__session_show_defaults` で project/scheme/sim 確認
2. 必要なら `build_run_sim` でアプリを起動
3. 主要画面ごとに `mcp__xcodebuild__screenshot` → `captures/ios-<screen>-light.png`
4. strict モードなら Dark + Dynamic Type 200% も撮る:
   - Dark: シミュレータ設定で appearance dark に切替
   - Dynamic Type: Settings > Accessibility > Display & Text Size

#### PNG 直渡し / Android / 自動キャプチャ失敗時

ユーザーに「`captures/` 配下に PNG をコピーしてください」と頼んで、`mobile-light.png` `desktop-light.png` 等の規約名にリネームしてもらう。

### Phase 3 — 分析

各 capture を順に Read で読んで Vision 評価し、CSS 統計と合わせて issue を構造化する。

#### スコア軸 (`rules/00-axes-common.md` 参照)

共通 9 軸 (内部 ID は英語、**ユーザー報告は必ず日本語軸名で**):

| # | 内部 ID | 日本語軸名 (報告時) | 内容 |
|---|---|---|---|
| 1 | `readability` | **可読性** | コントラスト / 行長 / 行間 |
| 2 | `hierarchy` | **情報階層** | h1/h2/body サイズ比 |
| 3 | `whitespace` | **余白・リズム** | spacing scale 標準偏差 |
| 4 | `typography` | **タイポグラフィ** | font 種類数 / weight 多様性 / NG フォント / letter-spacing → `rules/20-dasai-typography.md` |
| 5 | `color` | **配色** | true black/white / 彩度過多 → `rules/23-dasai-color-shadow.md` |
| 6 | `image_density` | **画像密度** | text:image 比率 / aspect ratio / stock 感 → `rules/22-dasai-imagery.md` |
| 7 | `modernity` | **モダン度 (2026 基準)** | gradient/shadow/radius/animation → `rules/24-modern-2026.md` |
| 8 | `consistency` | **統一感** | design token らしさ |
| 9 | `accessibility` | **アクセシビリティ** | WCAG AA / tap target / focus |
| 10 | `brand_promise` | **ブランド約束** | アプリ名 / コピーで謳った core feature が画面で視覚化されているか → `rules/25-brand-promise.md` (indie アプリの盲点) |

**重要**: スコアをユーザーに見せる場面 (進捗報告 / 比較表 / コミットメッセージ) では英語軸名を直接出さず、必ず**日本語軸名**で表記する。`issues.json` の `axis` フィールドだけは内部 ID (英語) を使う。

プラットフォーム別追加:
- Web → `rules/10-web-extras.md`
- iOS → `rules/11-ios-extras.md`
- Android → `rules/12-android-extras.md`

interaction / mobile / heuristics 追加:
- `strict` モード時 → `rules/26-nielsen-heuristics.md` (Nielsen 10 軸の interaction 評価)
- iOS / Android mobile viewport → `rules/29-mobile-onehand.md` (片手操作 / thumb zone / safe area)
- 色覚 simulation → `report.html` の cover-figure toolbar で Protanopia / Deuteranopia / Tritanopia / 完全色盲 を切替 (CSS filter url(#cv-*))
- 修正コスト → `issues.json` の `effort: "quick" | "moderate" | "major"` で対応コストを示し、issue card に chip 表示

LP / hero 専用追加 (Web 中心):
- `rules/30-hero-visual-patterns.md` — hero に device frame / browser frame / illustration をどう置くか、商品カテゴリ別の正解 pattern 7 種 + iPhone bezel の 7 項目品質基準 (3 層 shadow / glow ring / 固定 screen height 等)。Web LP 評価時に必ず通す。

#### ダサさシグナル検査

6 カテゴリの rules ファイルを読み、各シグナルに対して **検出可否 + 根拠** を判定:
- `rules/20-dasai-typography.md`
- `rules/21-dasai-spacing.md` (S11 chrome 占有率, S12 above-the-fold, **S13 container 幅とコンテンツ密度の不一致**)
- `rules/22-dasai-imagery.md` (S12 Material 既製 icon overuse)
- `rules/23-dasai-color-shadow.md` (S16 filled icon flat color の罠)
- `rules/24-modern-2026.md`
- `rules/25-brand-promise.md`
- `rules/30-hero-visual-patterns.md` (Web LP / hero に device mock を置く時の到達基準、iPhone bezel 7 項目)

Web の CSS が拾える項目は `scripts/analyze-css.mjs captures/styles.json` で機械集計、それ以外と iOS は Vision で判定。

#### 軸ごと 1 行コメント (`axis_comments`)

10 軸それぞれで **40-80 字の 1 行コメント** を生成し `issues.json.axis_comments` に保存する。スコアの数字だけでは読者に伝わらない「なぜそのスコアか」「何が良くて何がダサいか」を端的に書く。`report.html` の軸別評価セクションと markdown report 両方で表示される。

コメントの書き方:
- ❌ ダメ: 「タイポグラフィは適切」(中身ゼロ)
- ✅ 良い: 「Inter + Noto Sans JP の 2 種で清潔、ただし h1 と body の weight 差が浅く階層が弱い」(状態 + ダサさ理由)
- ✅ 良い: 「true black 不使用で目に優しいが、accent 色が 3 色あって視線が散る」(良い点 + 問題点)

#### Issue 構造化

`issues.schema.json` に従って 1 issue ごとに以下を埋める:

```jsonc
{
  "id": "typo_001",
  "axis": "typography",
  "priority": "high",
  "title": "フォント 4 種混在で雑多",
  "evidence": {
    "screenshot": "captures/desktop-light.png",
    "crop": [120, 340, 480, 540],
    "css_finding": "font-family unique=4 on hero"
  },
  "why_dasai": "2026 のモダン LP は 2-3 種で統一が定石",
  "fix_suggestion": "Inter (英) + Noto Sans JP (和) の 2 family 構成に",
  "reference_examples": ["https://linear.app", "https://vercel.com"],
  "ref_doc": "rules/20-dasai-typography.md §1",
  "component_hint": ".hero h1, .hero p"
}
```

priority: `high` (バグ/WCAG fail/HIG 違反/即ダサい) / `medium` (改善余地) / `low` (好み)。

level による絞り込み:
- strict: high + medium + low 全部
- normal: high + medium のみ
- friendly: high のみ + low の中から「好い点ハイライト」を抜粋

### Phase 4 — diff モード (任意)

mode=`diff` のときのみ:

1. 目標 PNG / Figma URL を別途 capture (`captures/target-*.png`)
2. 実装スクショと並べて Claude が以下を観察:
   - 「目的は何か」(目標から推察)
   - 「達成度は」(実装で意図が立っているか)
   - 「差分」を箇条書き (pixel diff ではなく意図 diff)
3. 重大な差分は high priority issue として `issues.json` に追加 (`axis: "diff"`)

### Phase 5 — レポート生成 + 開く

#### `issues.json` を書く

```bash
cat > "$OUT_DIR/issues.json" <<EOF
{
  "schema_version": "1.0",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "platform": "web|ios|android",
  "mode": "general|diff",
  "level": "strict|normal|friendly",
  "target": {
    "url": "https://example.com",
    "captures_dir": "captures",
    "hero_screenshot": "captures/desktop-light.png",
    "label": "Example LP"
  },
  "scores": {
    "overall": 78,
    "readability": 82,
    "hierarchy": 70,
    "whitespace": 85,
    "typography": 60,
    "color": 75,
    "image_density": 65,
    "modernity": 80,
    "consistency": 75,
    "accessibility": 88,
    "brand_promise": 75
  },
  "axis_comments": {
    "readability":   "gray-900 本文で目に優しいが、行長が 80ch 超で読みにくい場面あり",
    "hierarchy":     "h1/body の size 比は OK だが weight 段階が 2 種で階層感が浅い",
    "whitespace":    "spacing が 4pt grid に揃っていてリズム感は良い",
    "typography":    "Inter + Noto Sans JP の 2 種で清潔、letter-spacing 未設定が惜しい",
    "color":         "true black 不使用で目に優しい、accent も 1 色で締まっている",
    "image_density": "hero に visual がなく、文字中心で 2026 SaaS 基準だと薄い",
    "modernity":     "subtle 1-color gradient + ease-out で 2026 基準合格",
    "consistency":   "radius が 3 種で統一、design token らしさあり",
    "accessibility": "コントラスト OK、ただし tap target が 36px の場所あり (44 推奨)",
    "brand_promise": "アプリ名で謳う core feature が hero で視覚化されている"
  },
  "issues": [/* ... */],
  "highlights": ["余白の取り方が一貫している", "..."],
  "modern_references": [
    {"url": "https://linear.app", "why": "似たカテゴリの 2026 ベンチマーク"}
  ]
}
EOF
```

`target.hero_screenshot` には **share-x.png 用に最も見栄えする 1 枚** (通常は `captures/desktop-light.png`) を指定する。これが `report.html` の `#hero` 左半分に埋め込まれ、X 投稿の visual 主役になる。

#### `report.md` と `report.html` を生成

template をコピーして埋める:

```bash
cp ~/.claude/skills/design-review/templates/report.md  "$OUT_DIR/report.md"
cp ~/.claude/skills/design-review/templates/report.html "$OUT_DIR/report.html"
```

`{{...}}` プレースホルダを `issues.json` の値で全置換。`scripts/render-report.sh "$OUT_DIR"` で一括処理。

#### `share-x.png` 生成 (X 投稿用、`report.html` の `#hero` を element screenshot)

`report.html` の `#hero` セクションは **1200×675 固定** で X 投稿カード比 (16:9) になるように設計されている。これを element screenshot するだけで X 投稿用画像 (`share-x.png`) が取れる。2 経路ある:

**経路 A: main session で MCP 経由 (推奨、高速)**

```
mcp__playwright__browser_navigate → file://$OUT_DIR/report.html
mcp__playwright__browser_resize → width: 1280, height: 720
mcp__playwright__browser_take_screenshot → element: "#hero", filename: "$OUT_DIR/share-x.png"
```

`feedback-playwright-main-vs-agent.md` のとおり、MCP は main session 必須。subagent 経由では permission denied で失敗する。

**経路 B: subprocess 経由 (CI / 単体実行)**

```bash
node ~/.claude/skills/design-review/scripts/capture-share.mjs \
  "$OUT_DIR/report.html" "$OUT_DIR/share-x.png"
```

`render-report.sh` の末尾で `playwright` npm がインストール済みなら自動で呼ばれる。なければ「MCP で取って」とユーザーに案内が出る。

#### 開く

ユーザーに以下を提示 (自動実行しない、bash 提案として):

```bash
open "$OUT_DIR/report.html"
```

最後に以下 2 点を添える:
- 「**`report.md` の high 指摘から優先順に直してほしい**と言ってもらえれば、issues.json を読みつつ Edit で改修に入れます」(これが /design-review-fix の代わり)
- 「X 投稿用画像は `$OUT_DIR/share-x.png` (1200×675 16:9)、`report.html` の `#hero` をそのまま切り出したもの」

---

## 出力ファイル一覧

```
$OUT_DIR/
├── captures/
│   ├── desktop-light.png
│   ├── desktop-dark.png
│   ├── tablet-light.png
│   ├── mobile-light.png
│   ├── ...
│   └── styles.json              # Web のみ
├── issues.json                   # 修正用構造化データ (scores / axis_comments / issues / highlights)
├── report.md                     # GitHub / PR 貼り付け用
├── report.html                   # ブラウザ表示用 (open で起動) — 主成果物
└── share-x.png                   # X 投稿用 1200×675 (report.html の #hero を切り出し)
```

## Notes

- **Playwright MCP は main Claude Code session 必須**: subagent 経由では permission denied になる。Web ターゲットの自動キャプチャは main で起動。
- **一時ファイルは `.scratch/` 配下に**: プロジェクトルートを汚さない。`<git_top>/apps/<name>/.scratch/design-review-<TS>/` か `~/Downloads/design-review-<TS>/` に出力。
- **画像 → HTML レポート pipeline**: HTML テンプレ + Python 置換 + Playwright で element screenshot。`scripts/render-report.sh` の構造を参考に。
