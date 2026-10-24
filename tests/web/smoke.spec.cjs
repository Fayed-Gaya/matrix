const { test, expect } = require('@playwright/test');
const state = page => page.locator('html').getAttribute('data-matrix-state').then(s => s ? JSON.parse(s) : {});
test('opening, terminal, one level and return', async ({ page }) => {
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/SCRIPT ERROR:|^ERROR:/.test(m.text())) errors.push(m.text()); });
  page.on('response', r => { if (r.status() >= 400 && new URL(r.url()).hostname === '127.0.0.1') errors.push(`${r.status()}: ${r.url()}`); });
  await page.goto('http://127.0.0.1:8060/?matrix_smoke=1');
  await expect.poll(async () => (await state(page)).opening, { timeout: 60000 }).toBe(true);
  await page.locator('canvas').click();
  await page.keyboard.press('Enter');
  await expect.poll(async () => (await state(page)).opening).toBe(false);
  async function moveAxis(axis, target, negative, positive, tolerance = 12) {
    for (let pulse = 0; pulse < 50; pulse++) {
      const current = await state(page);
      if (current.near_terminal) return; // The usable terminal is the destination, including its collision edge.
      const distance = target - current[axis];
      if (Math.abs(distance) <= tolerance) return;
      await page.keyboard.press(distance < 0 ? negative : positive, {delay: 40});
    }
    throw new Error('Could not reach waypoint: ' + JSON.stringify(await state(page)));
  }
  // Short real key pulses avoid holding movement during slow browser assertions.
  // Reach the usable corridor, rather than demanding sub-frame pixel alignment.
  // Native integration covers the other registered routes.
  await moveAxis('y', 192, 'ArrowUp', 'ArrowDown', 18);
  await moveAxis('x', 448, 'ArrowLeft', 'ArrowRight', 4);
  await expect.poll(async () => (await state(page)).near_terminal).toBe(true);
  const codes = ['BOUNCE'];
  for (const code of codes) {
    await page.keyboard.press('e');
    await expect.poll(async () => (await state(page)).terminal).toBe(true);
    const input=page.getByRole('textbox',{name:'Terminal input'});
    await expect(input).toBeFocused();
    await expect(page.locator('#matrix-terminal')).not.toContainText(/BOUNCE|BALLS|BUG|BUBBY|BUSBOY|MACHINE|YOU|WORLD|DESTINATION|SIMULATION/);
    await page.keyboard.type(code);
    await page.keyboard.press('Enter');
    await expect.poll(async () => (await state(page)).code, {timeout: 60000}).toBe(code);
    expect((await state(page)).scene).toMatch(/^res:\/\/levels\/.+\.tscn$/);
    await page.keyboard.press('Escape');
    await expect.poll(async () => (await state(page)).code).toBe('');
  }
  await page.setViewportSize({width: 960, height: 600});
  await expect.poll(async () => (await state(page)).width).toBe(960);
  expect(errors).toEqual([]);
});
