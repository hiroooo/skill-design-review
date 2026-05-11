#!/usr/bin/env bash
# Web キャプチャ (Playwright MCP fallback 用 / Chrome headless 直接呼び)
#
# 通常は SKILL.md フローで `mcp__playwright__browser_*` を main session から呼ぶのが推奨。
# これは Playwright MCP が使えない場面 (CI / agent 委譲 / sandbox) の fallback。
#
# Usage:
#   capture-web.sh <url> <out-dir>
#
# Output:
#   <out-dir>/desktop-light.png
#   <out-dir>/desktop-dark.png
#   <out-dir>/tablet-light.png
#   <out-dir>/mobile-light.png

set -euo pipefail

if [ $# -lt 2 ]; then
  echo "Usage: $0 <url> <out-dir>" >&2
  exit 1
fi

URL="$1"
OUT_DIR="$2"
mkdir -p "$OUT_DIR"

# Find Chrome / Chromium binary
CHROME=""
for candidate in \
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  "/Applications/Chromium.app/Contents/MacOS/Chromium" \
  "$(command -v chromium 2>/dev/null || true)" \
  "$(command -v google-chrome 2>/dev/null || true)"; do
  if [ -n "$candidate" ] && [ -x "$candidate" ]; then
    CHROME="$candidate"
    break
  fi
done

if [ -z "$CHROME" ]; then
  echo "ERROR: Chrome / Chromium not found" >&2
  exit 1
fi

shoot() {
  local name="$1"
  local w="$2"
  local h="$3"
  local extra="${4:-}"
  echo "→ $name (${w}x${h})..."
  "$CHROME" \
    --headless \
    --disable-gpu \
    --no-sandbox \
    --hide-scrollbars \
    --window-size="${w},${h}" \
    --screenshot="$OUT_DIR/${name}.png" \
    $extra \
    "$URL" 2>/dev/null
}

shoot "desktop-light" 1440 900
shoot "desktop-dark"  1440 900 "--force-dark-mode --enable-features=WebContentsForceDark"
shoot "tablet-light"  768  1024
shoot "mobile-light"  375  812
shoot "mobile-dark"   375  812 "--force-dark-mode --enable-features=WebContentsForceDark"

echo "✓ Captured 5 viewport into $OUT_DIR"
echo "  Note: For CSS computed-style stats, use Playwright MCP from main session"
echo "        and dump styles.json (this fallback script does not collect computed styles)."
