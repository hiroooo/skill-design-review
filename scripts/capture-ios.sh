#!/usr/bin/env bash
# iOS Simulator キャプチャ用 (xcodebuild MCP fallback / 単純な xcrun simctl ラッパー)
#
# 通常は SKILL.md フローで `mcp__xcodebuild__screenshot` を main session から呼ぶ。
# これは MCP が無効 / sim を直接操作したい時の fallback。
#
# Usage:
#   capture-ios.sh <out-dir> [screen-name1 screen-name2 ...]
#
#   引数 screen-name は単なる出力ファイル名 (例: home, detail, settings)。
#   実行前に手動で sim を該当画面に遷移させる。

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <out-dir> [screen-names...]" >&2
  exit 1
fi

OUT_DIR="$1"
shift
mkdir -p "$OUT_DIR"

if ! command -v xcrun >/dev/null 2>&1; then
  echo "ERROR: xcrun not found (Xcode CLT 未インストール?)" >&2
  exit 1
fi

# default: 1 ショットだけ "home" として
NAMES=("$@")
if [ ${#NAMES[@]} -eq 0 ]; then
  NAMES=("home")
fi

for name in "${NAMES[@]}"; do
  read -r -p "→ Simulator を「${name}」画面にして Enter (skip: s)..." ans
  if [ "$ans" = "s" ]; then
    echo "  skipped"
    continue
  fi
  xcrun simctl io booted screenshot "$OUT_DIR/ios-${name}-light.png"
  echo "  ✓ $OUT_DIR/ios-${name}-light.png"
done

echo ""
echo "✓ Captured ${#NAMES[@]} screen(s)"
echo ""
echo "  Dark mode は sim の Features > Toggle Appearance で切替後に再実行:"
echo "    capture-ios.sh $OUT_DIR ${NAMES[*]/%/-dark}"
