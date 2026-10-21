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
  async function moveAxis(axis, target, negative, positive) {
    for (let pulse = 0; pulse < 50; pulse++) {
      const current = await state(page);
      const distance = target - current[axis];
      if (Math.abs(distance) <= 2) return;
      await page.keyboard.press(distance < 0 ? negative : positive, {delay: Math.min(50, Math.max(8, Math.abs(distance) / 260 * 1000))});
    }
    throw new Error('Could not reach waypoint: ' + JSON.stringify(await state(page)));
  }
  // Short real key pulses avoid holding movement during slow browser assertions.
  await moveAxis('y', 423, 'ArrowUp', 'ArrowDown');
  await moveAxis('x', 400, 'ArrowLeft', 'ArrowRight');
  for (let pulse = 0; pulse < 15 && !(await state(page)).near_terminal; pulse++)
    await page.keyboard.press('ArrowDown', {delay: 25});
  expect((await state(page)).near_terminal).toBe(true);
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
