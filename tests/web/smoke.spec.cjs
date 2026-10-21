const { test, expect } = require('@playwright/test');
const state = page => page.locator('html').getAttribute('data-matrix-state').then(s => s ? JSON.parse(s) : {});
test('opening, real keyboard navigation, ten terminal codes, return and resize', async ({ page }, testInfo) => {
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/SCRIPT ERROR:|^ERROR:/.test(m.text())) errors.push(m.text()); });
  page.on('response', r => { if (r.status() >= 400 && new URL(r.url()).hostname === '127.0.0.1') errors.push(`${r.status()}: ${r.url()}`); });
  await page.goto('http://127.0.0.1:8060/?matrix_smoke=1');
  await expect.poll(async () => (await state(page)).opening, { timeout: 60000 }).toBe(true);
  await page.locator('canvas').click();
  await page.keyboard.press('Enter');
  await expect.poll(async () => (await state(page)).opening).toBe(false);
  async function walk(key, predicate) {
    await page.keyboard.down(key);
    try { await expect.poll(async () => predicate(await state(page)), {timeout: 15000, intervals: [10, 20, 30]}).toBe(true); }
    finally { await page.keyboard.up(key); }
  }
  // Walk below the furniture, then across to the terminal; no state-changing hooks.
  await walk('ArrowDown', s => s.y >= 420);
  await walk('ArrowRight', s => s.x >= 395);
  await walk('ArrowDown', s => s.near_terminal);
  const codes = ['BOUNCE','BALLS','BUG','PONG','JUMP','MARIO','ZELDA','MONSTERS','UNTITLED','YOU'];
  for (const code of codes) {
    await page.keyboard.press('e');
    await expect.poll(async () => (await state(page)).terminal).toBe(true);
    await page.keyboard.type(code);
    await page.keyboard.press('Enter');
    await expect.poll(async () => (await state(page)).code, {timeout: 20000}).toBe(code);
    expect((await state(page)).scene).toMatch(/^res:\/\/levels\/.+\.tscn$/);
    if (code === 'YOU') expect((await state(page)).camera_status).toContain('unavailable in this browser');
    await page.screenshot({path: testInfo.outputPath(`${code}.png`)});
    await page.keyboard.press('Escape');
    await expect.poll(async () => (await state(page)).code).toBe('');
  }
  await page.setViewportSize({width: 960, height: 600});
  await expect.poll(async () => (await state(page)).width).toBe(960);
  expect(errors).toEqual([]);
  console.log('Browser tested:', testInfo.project.name, await page.evaluate(() => navigator.userAgent));
});
