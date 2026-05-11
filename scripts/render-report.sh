#!/usr/bin/env bash
# design-review : テンプレ → 最終 report.md / report.html を生成
#
# 前提: <out-dir>/issues.json が既に書かれている (Claude が作る)
# 動作:
#   1. ~/.claude/skills/design-review/templates/{report.md,report.html} をコピー
#   2. issues.json を Python で読み込んで HTML を組み立て、{{...}} プレースホルダを置換
#   3. share-x.png は subprocess Playwright が入っていれば自動生成 (なくても主成果物の report.html は出る)
#
# Usage:
#   render-report.sh <out-dir>

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <out-dir>" >&2
  exit 1
fi

OUT_DIR="$1"
ISSUES_JSON="$OUT_DIR/issues.json"
TEMPLATE_DIR="$HOME/.claude/skills/design-review/templates"

if [ ! -f "$ISSUES_JSON" ]; then
  echo "ERROR: $ISSUES_JSON not found. Generate it first." >&2
  exit 1
fi

cp "$TEMPLATE_DIR/report.md" "$OUT_DIR/report.md"
cp "$TEMPLATE_DIR/report.html" "$OUT_DIR/report.html"

export ISSUES_JSON OUT_DIR

# === Python で issues.json を読み込み → HTML 生成 → テンプレ置換 ===
python3 - "$OUT_DIR/report.md" "$OUT_DIR/report.html" <<'PYEOF'
import sys, os, json, html, pathlib, math, struct

ISSUES_JSON = os.environ["ISSUES_JSON"]
OUT_DIR_ABS = os.environ.get("OUT_DIR", os.path.dirname(ISSUES_JSON))
with open(ISSUES_JSON, "r", encoding="utf-8") as f:
    data = json.load(f)

def _png_dim(path):
    """PNG dimension を struct で取得 (width, height)"""
    try:
        with open(path, "rb") as f:
            head = f.read(24)
            if head.startswith(b"\x89PNG"):
                w, h = struct.unpack(">II", head[16:24])
                return w, h
    except Exception:
        pass
    return None, None

def _img_dim(rel_path):
    """evidence.screenshot (相対 path) → image dimension"""
    abs_path = os.path.join(OUT_DIR_ABS, rel_path)
    return _png_dim(abs_path)

# ============================================================
# Term tooltip dictionary
#   キーは text に出現する term、value は hover 時に出す説明 (40-80 字)
# ============================================================
TERM_DICT = {
    # design token / spacing
    "デザイントークン": "色 / spacing / radius 等の値を CSS 変数で集約する設計手法。例: --space-4: 16px",
    "design token": "色 / spacing / radius 等の値を CSS 変数で集約する設計手法",
    "8pt grid": "全 spacing を 8 の倍数 (4/8/16/24/32/48/64) に揃える設計、リズム感の基盤",
    "4pt grid": "8pt grid の派生で、4 の倍数を基本値に。より細かい調整が可能",
    "baseline grid": "文字 baseline を縦に揃えるグリッド、editorial 感が出る",
    "spacing scale": "余白の段階表 (4/8/16/24/32...)、scale が崩れるとリズム感が消える",
    "spacing token": "spacing を CSS 変数で集約したもの (--space-2 等)",
    "spacing stdev": "spacing 値の標準偏差。大きいほど余白がバラついている",
    # typography
    "letter-spacing": "文字間隔 (CSS)、見出しは tight、CAPS は wide が定石",
    "tracking": "letter-spacing の組版用語、字間調整のこと",
    "line-height": "行の高さ (倍率 or px、本文 1.5-1.8 推奨)",
    "kerning": "個別の文字ペアの間隔を fine-tune、見出しで効く",
    "tabular-nums": "数字の幅を全部統一する font feature、財務 / dashboard 必須",
    "fallback chain": "font-family 指定で先頭 → 後続 に fallback する仕組み",
    "FOIT": "Flash of Invisible Text — web font 読込中は文字が見えない罠",
    "FOUT": "Flash of Unstyled Text — web font 読込前は fallback で表示",
    "font-display": "web font 読込中の挙動を制御 (swap / optional 推奨)",
    "variable font": "1 ファイルで太さ / 幅を可変できる現代フォント技術",
    "Inter": "2026 SaaS 標準の英文 sans フォント (Vercel 製、variable)",
    "Geist": "Vercel が出した Inter 後継の現代 sans フォント",
    "Noto Sans JP": "Google の和文 sans フォント、Web 安全策の定番",
    "Hiragino Sans": "Apple 標準の和文 sans フォント (macOS / iOS)",
    "Zen Kaku Gothic": "Google Fonts の和文 sans、柔らかい印象",
    "SF Pro": "Apple 標準 sans (system-ui 指定で fallback 含めて呼べる)",
    # color
    "true black": "完全黒 (#000000)、OLED で滲み + 目に痛い、2026 は gray-900 推奨",
    "true white": "完全白 (#ffffff)、長文で目が疲れる、2026 は gray-50 推奨",
    "gray-900": "完全黒の代わりに使う最濃 gray (#111-1a)、目に優しい",
    "gray-50": "完全白の代わりに使う最薄 gray (#fafafa)、目に優しい",
    "accent color": "ブランドの主訴求色 (1-2 色)、CTA やリンクに使う",
    "accent": "ブランドの主訴求色 (1-2 色)、CTA やリンクに使う",
    "OLED": "有機 EL ディスプレイ、true black の滲みが出やすい",
    "subtle gradient": "1-2 色の控えめなグラデ、2026 SaaS で標準",
    # layout / image
    "ファーストビュー": "page 上端から最初の 1 画面分、above-the-fold とも",
    "above-the-fold": "page 上端から最初の 1 画面分、ファーストビュー",
    "hero": "page 最上部の主訴求ブロック (visual + headline + CTA)",
    "Hero": "page 最上部の主訴求ブロック (visual + headline + CTA)",
    "stock photo": "Unsplash 等の汎用素材写真、ブランド感が出にくい",
    "aspect ratio": "横:縦 比率 (16:9 / 4:3 / 1:1 等)",
    "aspect-ratio": "横:縦 比率の CSS property、modern 基準",
    "object-fit": "img の縦横比維持表示 (cover / contain 等)",
    # icon set
    "icon set": "Lucide / Heroicons 等の統一された SVG icon 集合",
    "Lucide": "オープンソース SVG icon set、Feather の後継 (1100+ icons)",
    "Heroicons": "Tailwind 公式の SVG icon set (outline / solid 2 style)",
    "Material Symbols": "Google の icon set、Material Design 系で標準",
    # animation
    "ease-out": "cubic-bezier(0.4, 0, 0.2, 1)、Material Standard の easing",
    "cubic-bezier": "CSS の easing 指定方式、4 値で curve を定義",
    "linear easing": "easing なし、機械的で不自然、2026 では非推奨",
    # responsive / a11y
    "WCAG AA": "Web アクセシビリティ基準 AA (本文 contrast 4.5:1 以上)",
    "tap target": "タップ可能要素の最小サイズ (iOS 44pt / Android 48dp)",
    "max-width": "container の最大幅 (mobile で端張り付き防止に必須)",
    "prefers-color-scheme": "OS の dark/light 設定を CSS で取得、dark mode 切替の基本",
    "Dark mode": "OS の dark 設定に合わせて UI 色を反転する仕組み、2026 標準対応",
    "dark mode": "OS の dark 設定に合わせて UI 色を反転する仕組み、2026 標準対応",
    "responsive": "画面幅に応じて layout が自動調整される設計",
    "viewport": "ブラウザの表示領域、mobile / tablet / desktop で違うサイズで test 推奨",
    "Lighthouse": "Google の web 品質測定ツール (performance / a11y / SEO スコア)",
    "Core Web Vitals": "Google が定める web 品質の 3 指標 (LCP / INP / CLS)",
    "stdev": "標準偏差、値のバラつき度合い (大きいほど不均一)",
    # apple / iOS
    "HIG": "Apple Human Interface Guidelines、iOS デザイン公式基準",
    "Dynamic Type": "iOS の文字サイズ可変機能、アクセシビリティ必須対応",
    "Family Controls": "iOS の Screen Time / Shield 系 API",
    "VisionKit": "Apple の OCR / Document scan API (iOS 13+)",
    # web modern
    "subtle micro-interaction": "0.15-0.3s の細やかなアニメ、modern UI 必須",
    "view-transition": "ページ遷移を滑らかにする CSS / JS API",
    "container queries": "container 自身のサイズに応じた CSS (modern responsive)",
    "OKLCH": "Wide gamut の color space (modern CSS color-mix)",
    # brand
    "Brand Promise": "アプリ名/コピー で謳う core feature が画面で視覚化されているか",
    "Editorial": "雑誌 / 新聞風のレイアウト (typography 主役、visual subdued)",
    "Saas LP": "SaaS の Landing Page、hero に大型 visual + 強 CTA が定石",
    "SaaS LP": "SaaS の Landing Page、hero に大型 visual + 強 CTA が定石",
}

# 用語表記ゆれを吸収 (longest match first で wrap)
_TERMS_SORTED = sorted(TERM_DICT.keys(), key=lambda k: -len(k))

def wrap_terms(escaped_text):
    """既に html.escape 済の text に対して term を <span> wrap (各 term 最初の 1 回のみ)"""
    if not escaped_text:
        return ""
    out = escaped_text
    wrapped_positions = []  # 既 wrap 済 span を二重 wrap しないようマーク
    for term in _TERMS_SORTED:
        if term not in out:
            continue
        # 既存 <span class="term"...> 内に term が含まれていれば skip
        idx = out.find(term)
        while idx != -1:
            # その idx が既存 .term span 内かを軽く check (data-tooltip 内 / span 内)
            # 単純化: 1 occurrence だけ wrap、それ以降は同 term は無視
            before = out[:idx]
            after = out[idx + len(term):]
            # span 内側にいないか? 直近の <span / </span> から判断
            last_open = before.rfind('<span class="term"')
            last_close = before.rfind('</span>')
            if last_open > last_close:
                # span 内 (data-tooltip attr or span text) なので skip して次の occurrence
                idx = out.find(term, idx + len(term))
                continue
            desc = TERM_DICT[term]
            out = before + f'<span class="term" data-tooltip="{html.escape(desc)}">{term}</span>' + after
            break  # この term は 1 回だけ wrap
    return out

def safe_text(text):
    """html escape + term wrap (None safe)"""
    if not text:
        return ""
    return wrap_terms(html.escape(text))

# ---------- スカラ値 ----------
scores = data.get("scores", {})
ac = data.get("axis_comments", {})

def s(key, default=0):
    return scores.get(key, default)

def acg(key):
    return safe_text(ac.get(key, ""))

def score_class(v):
    try:
        v = int(v)
    except Exception:
        return ""
    if v < 60: return "low"
    if v < 80: return "mid"
    return ""

# 軸 top/bottom 識別 (overall を除く 10 軸で max / min)
_AXIS_KEYS = ["readability","hierarchy","whitespace","typography","color",
              "image_density","modernity","consistency","accessibility","brand_promise"]
_axis_values = [(k, int(s(k, 0))) for k in _AXIS_KEYS]
_max_score = max(v for _, v in _axis_values) if _axis_values else 0
_min_score = min(v for _, v in _axis_values) if _axis_values else 0
_top_axes = {k for k, v in _axis_values if v == _max_score}
_bottom_axes = {k for k, v in _axis_values if v == _min_score and v < _max_score}

def axis_emphasis(key):
    """軸名 → axis-card に付与する class (axis-top / axis-bottom / 空)"""
    if key in _top_axes:
        return "axis-top"
    if key in _bottom_axes:
        return "axis-bottom"
    return ""

S_OVR = int(s("overall", 0))
if S_OVR >= 90: verdict = "完成度高め"
elif S_OVR >= 80: verdict = "おおむね良好"
elif S_OVR >= 70: verdict = "改善余地あり"
elif S_OVR >= 60: verdict = "要ブラッシュアップ"
else: verdict = "全面見直し推奨"

target = data.get("target", {})
target_label = target.get("label") or target.get("url") or target.get("bundle_id") or target.get("captures_dir") or "unknown"
hero_shot = target.get("hero_screenshot") or ""
hero_html = (
    f'<img src="{html.escape(hero_shot)}" alt="target screenshot">'
    if hero_shot
    else '<div class="no-image">スクリーンショット未指定</div>'
)

# ring dash
RING_TOTAL = 628
HERO_RING_TOTAL = 364
ring_dash = f"{int(S_OVR / 100 * RING_TOTAL)} {RING_TOTAL}"
hero_ring_dash = f"{int(S_OVR / 100 * HERO_RING_TOTAL)} {HERO_RING_TOTAL}"

# counts
issues = data.get("issues", [])
high_n   = sum(1 for i in issues if i.get("priority") == "high")
medium_n = sum(1 for i in issues if i.get("priority") == "medium")
low_n    = sum(1 for i in issues if i.get("priority") == "low")
highlights = data.get("highlights", [])
hl_n = len(highlights)

# ---------- issue HTML renderer ----------
def render_evidence(ev):
    """evidence dict → HTML (focus crop + highlight overlay)"""
    if not ev:
        return ""
    shot = ev.get("screenshot")
    if not shot:
        return ""
    crop = ev.get("crop")          # [x%, y%, w%, h%] 0-100
    hl   = ev.get("highlight")     # [x%, y%, w%, h%] (全体に対する %)
    callout = ev.get("callout", "")
    zoom_icon = '<span class="icon"><svg><use href="#i-zoom"/></svg></span>'

    out = ['<div class="evidence">']

    if crop and isinstance(crop, list) and len(crop) == 4:
        x, y, w, h = [float(v) for v in crop]
        if w <= 0: w = 100
        if h <= 0: h = 50
        # image dimension を取得して px 単位で正確に計算 (image aspect 考慮)
        img_w_px, img_h_px = _img_dim(shot)
        FRAME_W = 480  # max frame width
        if img_w_px and img_h_px:
            crop_w_px = w / 100 * img_w_px
            crop_h_px = h / 100 * img_h_px
            scale = FRAME_W / crop_w_px if crop_w_px > 0 else 1.0
            bg_w_px = img_w_px * scale
            bg_h_px = img_h_px * scale
            bg_pos_x = -(x / 100) * img_w_px * scale
            bg_pos_y = -(y / 100) * img_h_px * scale
            frame_h_px = crop_h_px * scale
            style = (
                f"width: {FRAME_W:.0f}px; "
                f"max-width: 100%; "
                f"height: {frame_h_px:.0f}px; "
                f"background-size: {bg_w_px:.0f}px {bg_h_px:.0f}px; "
                f"background-position: {bg_pos_x:.0f}px {bg_pos_y:.0f}px; "
                f"background-image: url('{html.escape(shot)}');"
            )
        else:
            # PNG dim 取得失敗時の fallback (旧式の % ベース、image aspect 無視)
            bg_w = 100 / w * 100
            bg_x = -x * (100 / w)
            bg_y = -y * (100 / h)
            ar = f"{w:g} / {h:g}"
            style = (
                f"--bg-size: {bg_w:.2f}% auto; "
                f"--bg-pos: {bg_x:.2f}% {bg_y:.2f}%; "
                f"--ar: {ar}; "
                f"background-image: url('{html.escape(shot)}');"
            )
        out.append(f'<div class="evidence-frame crop" style="{style}">')
        if hl and isinstance(hl, list) and len(hl) == 4:
            hx0, hy0, hw, hh = hl
            hx = (hx0 - x) / w * 100
            hy = (hy0 - y) / h * 100
            pass  # highlight box は撤廃、callout は別途下で frame の child として render
        if callout:
            out.append(f'<div class="callout">{html.escape(callout)}</div>')
        out.append('</div>')
    else:
        out.append('<div class="evidence-frame" style="position: relative; max-width: 360px;">')
        out.append(f'<img class="evidence-img-full" src="{html.escape(shot)}" alt="">')
        if callout:
            out.append(f'<div class="callout">{html.escape(callout)}</div>')
        out.append('</div>')

    if crop and not callout:
        # callout が無い場合のみ「該当箇所」ラベル
        out.append(f'<div class="ev-caption">{zoom_icon}該当箇所</div>')

    out.append('</div>')
    return "\n".join(out)


_priority_icon = {
    "high":   '<span class="icon"><svg><use href="#i-alert-triangle"/></svg></span>',
    "medium": '<span class="icon"><svg><use href="#i-alert-circle"/></svg></span>',
    "low":    '<span class="icon"><svg><use href="#i-info"/></svg></span>',
}

def render_issue(issue, idx):
    p = issue.get("priority", "low")
    axis = issue.get("axis", "")
    title = issue.get("title", "")
    why = issue.get("why_dasai", "")
    fix = issue.get("fix_suggestion", "")
    ev = issue.get("evidence") or {}
    css = ev.get("css_finding", "")
    refs = issue.get("reference_examples") or []
    effort = issue.get("effort", "")  # quick / moderate / major
    p_icon = _priority_icon.get(p, _priority_icon["low"])

    _EFFORT_LABEL = {"quick": "Quick (15 分)", "moderate": "中 (1-2h)", "major": "Major (半日+)"}

    # Copy prompt for Claude (改修対話に直接 paste できる format)
    issue_id = issue.get("id", f"issue_{idx:03d}")
    fix_prompt = (
        f"issues.json の {issue_id} を修正してください。\n\n"
        f"[Issue] {title}\n"
        f"[Why] {why}\n"
        f"[Fix] {fix}\n"
        f"[axis] {axis} / priority {p}\n\n"
        f"該当ファイル/コンポーネントを grep + Edit で直接修正してください。"
    )
    parts = [
        f'<div class="issue {p}" data-prompt="{html.escape(fix_prompt, quote=True)}">'
    ]
    parts.append(
        '<button type="button" class="issue-copy" title="クリックで修正 prompt をコピー、Claude に paste して即対話">'
        '<span class="icon"><svg><use href="#i-clipboard"/></svg></span>'
        '<span class="copy-text">Claude へ送る</span>'
        '</button>'
    )
    parts.append(f'<div class="issue-num">{idx:02d}</div>')
    parts.append('<div class="issue-body-wrap">')
    parts.append('<div class="issue-head">')
    parts.append(f'<span class="badge">{p_icon}{html.escape(p.upper())}</span>')
    if axis:
        parts.append(f'<span class="axis-tag">{html.escape(axis)}</span>')
    if effort in _EFFORT_LABEL:
        parts.append(f'<span class="effort-chip {effort}">{html.escape(_EFFORT_LABEL[effort])}</span>')
    parts.append(f'<span class="title">{safe_text(title)}</span>')
    parts.append('</div>')
    parts.append('<div class="issue-body">')
    if why:
        parts.append(f'<p class="why">{safe_text(why)}</p>')
    if fix:
        parts.append(f'<p class="fix">{safe_text(fix)}</p>')
    if css:
        parts.append(f'<div class="css-finding">{html.escape(css)}</div>')
    parts.append(render_evidence(ev))
    if refs:
        link_icon = '<span class="icon"><svg><use href="#i-external-link"/></svg></span>'
        ref_links = ' '.join(
            f'<a href="{html.escape(r)}" target="_blank">{html.escape(r)}</a>' for r in refs
        )
        parts.append(f'<p class="ref">{link_icon}参考: {ref_links}</p>')
    parts.append('</div></div></div>')
    return "\n".join(parts)


def render_priority(prio):
    items = []
    for idx, i in enumerate([x for x in issues if x.get("priority") == prio], start=1):
        items.append(render_issue(i, idx))
    if not items:
        return '<div class="empty">— 該当なし</div>'
    return "\n".join(items)


def render_priority_md(prio):
    items = [i for i in issues if i.get("priority") == prio]
    if not items:
        return "_(該当なし)_"
    out = []
    for i in items:
        ev = i.get("evidence") or {}
        block = [f'### {i.get("title", "")}', ""]
        block.append(f'- **axis**: `{i.get("axis", "")}`')
        if i.get("why_dasai"):
            block.append(f'- **why**: {i["why_dasai"]}')
        block.append(f'- **fix**: {i.get("fix_suggestion", "")}')
        if ev.get("css_finding"):
            block.append(f'- **css**: `{ev["css_finding"]}`')
        if ev.get("screenshot"):
            line = f'- **screenshot**: `{ev["screenshot"]}`'
            if ev.get("crop"):
                line += f' crop={ev["crop"]}'
            block.append(line)
        if i.get("reference_examples"):
            block.append(f'- **参考**: {" / ".join(i["reference_examples"])}')
        out.append("\n".join(block))
    return "\n\n".join(out)


HIGH_HTML = render_priority("high")
MEDIUM_HTML = render_priority("medium")
LOW_HTML = render_priority("low")
HIGH_MD = render_priority_md("high")
MEDIUM_MD = render_priority_md("medium")
LOW_MD = render_priority_md("low")

# ---------- highlights ----------
if not highlights:
    HIGHLIGHTS_HTML = '<div class="empty">— 該当なし</div>'
    PULL_QUOTE_TEXT = "—"
    HIGHLIGHTS_MD = "_(なし)_"
else:
    PULL_QUOTE_TEXT = safe_text(highlights[0])
    rest = highlights[1:] if len(highlights) > 1 else []
    chip_icon = '<span class="icon-wrap"><span class="icon"><svg><use href="#i-check"/></svg></span></span>'
    HIGHLIGHTS_HTML = "".join(
        f'<div class="chip">{chip_icon}<span>{safe_text(h)}</span></div>'
        for h in rest
    ) or '<div class="empty">—</div>'
    HIGHLIGHTS_MD = "\n".join(f'- {h}' for h in highlights)

# ---------- references ----------
refs = data.get("modern_references") or []
if not refs:
    MODERN_REFS_HTML = '<div style="color:var(--muted)">参考リンクなし</div>'
    MODERN_REFS_MD = "_(なし)_"
else:
    def stripped(u):
        return u.replace("https://", "").replace("http://", "")
    ref_icon = '<span class="icon-wrap"><span class="icon"><svg><use href="#i-external-link"/></svg></span></span>'
    MODERN_REFS_HTML = "".join(
        f'<a href="{html.escape(r["url"])}" target="_blank">{ref_icon}<span class="ref-text"><strong>{html.escape(stripped(r["url"]))}</strong><span>{html.escape(r.get("why", ""))}</span></span></a>'
        for r in refs
    )
    MODERN_REFS_MD = "\n".join(f'- [{r["url"]}]({r["url"]}) — {r.get("why", "")}' for r in refs)

# ---------- summary json ----------
top3 = [
    {"id": i.get("id"), "axis": i.get("axis"), "title": i.get("title"), "fix_suggestion": i.get("fix_suggestion")}
    for i in issues if i.get("priority") == "high"
][:3]
ISSUES_SUMMARY_JSON = json.dumps(
    {"counts": {"high": high_n, "medium": medium_n, "low": low_n}, "top_3": top3},
    ensure_ascii=False,
    indent=2
)

# ---------- repl table ----------
repl = {
    "{{TARGET_LABEL}}": target_label,
    "{{GENERATED_AT}}": data.get("generated_at", ""),
    "{{PLATFORM}}": data.get("platform", ""),
    "{{MODE}}": data.get("mode", ""),
    "{{LEVEL}}": data.get("level", ""),
    "{{SCORE_OVERALL}}": str(S_OVR),
    "{{SCORE_READABILITY}}":   str(int(s("readability"))),
    "{{SCORE_HIERARCHY}}":     str(int(s("hierarchy"))),
    "{{SCORE_WHITESPACE}}":    str(int(s("whitespace"))),
    "{{SCORE_TYPOGRAPHY}}":    str(int(s("typography"))),
    "{{SCORE_COLOR}}":         str(int(s("color"))),
    "{{SCORE_IMAGE_DENSITY}}": str(int(s("image_density"))),
    "{{SCORE_MODERNITY}}":     str(int(s("modernity"))),
    "{{SCORE_CONSISTENCY}}":   str(int(s("consistency"))),
    "{{SCORE_ACCESSIBILITY}}": str(int(s("accessibility"))),
    "{{SCORE_BRAND_PROMISE}}": str(int(s("brand_promise"))),
    "{{AC_READABILITY}}":   acg("readability"),
    "{{AC_HIERARCHY}}":     acg("hierarchy"),
    "{{AC_WHITESPACE}}":    acg("whitespace"),
    "{{AC_TYPOGRAPHY}}":    acg("typography"),
    "{{AC_COLOR}}":         acg("color"),
    "{{AC_IMAGE_DENSITY}}": acg("image_density"),
    "{{AC_MODERNITY}}":     acg("modernity"),
    "{{AC_CONSISTENCY}}":   acg("consistency"),
    "{{AC_ACCESSIBILITY}}": acg("accessibility"),
    "{{AC_BRAND_PROMISE}}": acg("brand_promise"),
    "{{CLASS_READABILITY}}":   score_class(s("readability")),
    "{{CLASS_HIERARCHY}}":     score_class(s("hierarchy")),
    "{{CLASS_WHITESPACE}}":    score_class(s("whitespace")),
    "{{CLASS_TYPOGRAPHY}}":    score_class(s("typography")),
    "{{CLASS_COLOR}}":         score_class(s("color")),
    "{{CLASS_IMAGE_DENSITY}}": score_class(s("image_density")),
    "{{CLASS_MODERNITY}}":     score_class(s("modernity")),
    "{{CLASS_CONSISTENCY}}":   score_class(s("consistency")),
    "{{CLASS_ACCESSIBILITY}}": score_class(s("accessibility")),
    "{{CLASS_BRAND_PROMISE}}": score_class(s("brand_promise")),
    "{{EMPH_READABILITY}}":   axis_emphasis("readability"),
    "{{EMPH_HIERARCHY}}":     axis_emphasis("hierarchy"),
    "{{EMPH_WHITESPACE}}":    axis_emphasis("whitespace"),
    "{{EMPH_TYPOGRAPHY}}":    axis_emphasis("typography"),
    "{{EMPH_COLOR}}":         axis_emphasis("color"),
    "{{EMPH_IMAGE_DENSITY}}": axis_emphasis("image_density"),
    "{{EMPH_MODERNITY}}":     axis_emphasis("modernity"),
    "{{EMPH_CONSISTENCY}}":   axis_emphasis("consistency"),
    "{{EMPH_ACCESSIBILITY}}": axis_emphasis("accessibility"),
    "{{EMPH_BRAND_PROMISE}}": axis_emphasis("brand_promise"),
    "{{RING_DASH}}": ring_dash,
    "{{HERO_RING_DASH}}": hero_ring_dash,
    "{{VERDICT_LABEL}}": verdict,
    "{{HERO_SCREENSHOT_HTML}}": hero_html,
    "{{HIGH_COUNT}}": str(high_n),
    "{{MEDIUM_COUNT}}": str(medium_n),
    "{{LOW_COUNT}}": str(low_n),
    "{{HIGHLIGHTS_COUNT}}": str(hl_n),
    "{{HIGH_ISSUES_HTML}}": HIGH_HTML,
    "{{MEDIUM_ISSUES_HTML}}": MEDIUM_HTML,
    "{{LOW_ISSUES_HTML}}": LOW_HTML,
    "{{HIGH_ISSUES_MD}}": HIGH_MD,
    "{{MEDIUM_ISSUES_MD}}": MEDIUM_MD,
    "{{LOW_ISSUES_MD}}": LOW_MD,
    "{{HIGHLIGHTS_HTML}}": HIGHLIGHTS_HTML,
    "{{HIGHLIGHTS_MD}}": HIGHLIGHTS_MD,
    "{{MODERN_REFS_HTML}}": MODERN_REFS_HTML,
    "{{MODERN_REFERENCES_MD}}": MODERN_REFS_MD,
    "{{ISSUES_JSON_PATH}}": "issues.json",
    "{{ISSUES_SUMMARY_JSON}}": ISSUES_SUMMARY_JSON,
    "{{PULL_QUOTE_TEXT}}": PULL_QUOTE_TEXT,
}

for path in sys.argv[1:]:
    p = pathlib.Path(path)
    text = p.read_text(encoding="utf-8")
    for k, v in repl.items():
        text = text.replace(k, str(v))
    p.write_text(text, encoding="utf-8")
    print(f"✓ wrote {path}")
PYEOF

echo ""
echo "✓ report.md   → $OUT_DIR/report.md"
echo "✓ report.html → $OUT_DIR/report.html"

# === share-x.png (optional) — Playwright npm が入っていれば自動生成 ===
SHARE_PNG="$OUT_DIR/share-x.png"
CAPTURE_SCRIPT="$HOME/.claude/skills/design-review/scripts/capture-share.mjs"
if command -v node >/dev/null 2>&1 && [ -f "$CAPTURE_SCRIPT" ]; then
  if node -e "require('playwright')" 2>/dev/null; then
    node "$CAPTURE_SCRIPT" "$OUT_DIR/report.html" "$SHARE_PNG" 2>/dev/null && \
      echo "✓ share-x.png → $SHARE_PNG"
  fi
fi

echo ""
echo "Open in browser:"
echo "  open \"$OUT_DIR/report.html\""
