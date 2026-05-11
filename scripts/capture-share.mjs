#!/usr/bin/env node
/**
 * design-review : report.html の #hero 要素を 1200×675 PNG として切り出す
 *
 * Usage:
 *   node capture-share.mjs <report.html path> <share-x.png path>
 *
 * 依存: playwright (`npm i -D playwright` or `npx playwright@latest install chromium`)
 *
 * 注意:
 *   main Claude Code session から /design-review を走らせる場合は、Playwright MCP の
 *   browser_take_screenshot (element 指定) で代替可能。subprocess (CI / 単体実行) 時は
 *   このスクリプトを使う。
 */

import { chromium } from 'playwright';
import path from 'node:path';
import { existsSync } from 'node:fs';

const [, , htmlPath, outPath] = process.argv;
if (!htmlPath || !outPath) {
  console.error('Usage: capture-share.mjs <report.html> <share-x.png>');
  process.exit(1);
}
if (!existsSync(htmlPath)) {
  console.error(`ERROR: ${htmlPath} not found`);
  process.exit(1);
}

const absHtml = path.resolve(htmlPath);
const absPng = path.resolve(outPath);

const browser = await chromium.launch();
try {
  const ctx = await browser.newContext({
    viewport: { width: 1280, height: 720 },
    deviceScaleFactor: 2,
  });
  const page = await ctx.newPage();
  await page.goto(`file://${absHtml}`, { waitUntil: 'networkidle' });
  const hero = await page.$('#hero');
  if (!hero) {
    console.error('ERROR: #hero element not found in report.html');
    process.exit(1);
  }
  await hero.screenshot({ path: absPng, omitBackground: false });
  console.log(`✓ wrote ${absPng}`);
} finally {
  await browser.close();
}
