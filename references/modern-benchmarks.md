# 2026 モダン UI ベンチマーク (改修後イメージ提示用)

レポート末尾の「改修後イメージ・参考サイト」で使う URL ストック。カテゴリごとに 2-3 件、対象アプリ / LP のジャンルが近いものを Claude が pick する。

## SaaS LP / B2B 製品サイト

- **Linear** (https://linear.app) — 余白 / モノクロ + 紫アクセント / Inter / hero に立体グラフ
- **Vercel** (https://vercel.com) — 黒地 + subtle mesh gradient / Geist / 階層感
- **Stripe** (https://stripe.com) — カード視覚 layered / フォント階層 / pastel gradient
- **Attio** (https://attio.com) — 立体カード / typographic hierarchy / serif accent
- **Cron** (https://cron.com) — minimal monochrome / large hero typography
- **Resend** (https://resend.com) — neutral 余白 / 黒文字 / 1 色アクセント

## デザインツール / クリエイティブ

- **Figma** (https://www.figma.com) — Whitney font / 6 階層 weight / 立体カラフル
- **Framer** (https://www.framer.com) — motion 多用 / aurora gradient
- **Tldraw** (https://www.tldraw.com) — playful + 整理された hierarchy

## 個人開発 / Indie SaaS

- **Notion** (https://www.notion.so) — minimal + emoji + cute illustration
- **Raycast** (https://www.raycast.com) — dark + accent / Inter / mode-aware
- **Linear (Indie 寄り版)** — 自分の領域に近い参考

## メディア / コンテンツ系

- **Stripe Press** (https://press.stripe.com) — Editorial / serif heading / large typography
- **The Browser Company** (https://thebrowser.company) — 若々しい / colorful / cartoon mix

## モバイルアプリ (Apple Featured 級)

- **Things 3** (https://culturedcode.com/things/) — minimalist / spaceful
- **Bear** (https://bear.app) — typography-driven / theme variants
- **Day One** (https://dayoneapp.com) — Editorial 寄り / serif

## 個人ブログ / Jekyll

- **Apoorv Govila** — minimal monochrome
- **Lee Robinson** (https://leerob.io) — code + writing 共存
- **Brian Lovin** (https://brianlovin.com) — typographic / interactive

## 日本語 LP の参考

- **STUDIO** (https://studio.design) — 日本語タイポグラフィ良例
- **Cursor 日本版風サイトの先進例** (要 case-by-case)
- **note.com** — 日本語 Editorial の標準

## 何をどう使うか

`issues.json.modern_references` には:
```json
[
  {"url": "https://linear.app", "why": "SaaS LP として hero の立体感 + 余白の取り方が 2026 標準"},
  {"url": "https://stripe.com", "why": "カード layered と微 gradient が同ジャンルで参考になる"}
]
```
のように、why を必ず添える。理由なしのリンク列挙は無価値。

ユーザーが「アプリは XX ジャンル」と言ったら、それに最も近いベンチマークを 3-5 件 pick して提示する。
