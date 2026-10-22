const { test, expect } = require('@playwright/test');
const state = page => page.locator('html').getAttribute('data-matrix-state').then(s => s ? JSON.parse(s) : {});
test('landscape touch movement, terminal, seven routes, return and rotation', async ({ page }, testInfo) => {
  const errors = [];
  page.on('pageerror', e => errors.push(e.message));
  page.on('console', m => { if (/SCRIPT ERROR:|^ERROR:/.test(m.text())) errors.push(m.text()); });
  await page.goto('http://127.0.0.1:8060/?matrix_smoke=1');
  await expect.poll(async () => (await state(page)).touch, {timeout: 60000}).toBe(true);
  await expect.poll(async () => (await state(page)).width).toBe(844);
  async function tap(command) {
    await expect.poll(async () => !!(await state(page)).touch_regions?.[command]).toBe(true);
    const p = (await state(page)).touch_regions[command];
    await page.touchscreen.tap(p[0], p[1]);
  }
  // Browser touch events exercise the actual canvas input path; no gameplay setters.
  async function touch(command, pressed) {
    const p = (await state(page)).touch_regions[command];
    await page.evaluate(([x,y,pressed]) => {
      const canvas = document.querySelector('canvas');
      const touch = {identifier:7,target:canvas,clientX:x,clientY:y,pageX:x,pageY:y};
      const event = new Event(pressed?'touchstart':'touchend',{bubbles:true,cancelable:true});
      Object.assign(event,{touches:pressed?[touch]:[],targetTouches:pressed?[touch]:[],changedTouches:[touch]});
      canvas.dispatchEvent(event);
    }, [...p,pressed]);
    return p;
  }
  await tap('Begin');
  await expect.poll(async () => (await state(page)).opening).toBe(false);
  async function move(axis,target,negative,positive) {
    for(let i=0;i<30;i++) {
      const before=(await state(page))[axis];
      const distance=target-before;
      // Interaction is the acceptance condition; waypoint precision is only for routing.
      if(Math.abs(distance)<=18) return;
      const command=distance<0?negative:positive;
      const point=await touch(command,true);
      try {
        // Wait for rendered physics progress, rather than assuming an 80ms press
        // spans a frame on a software-rendered CI runner. Collision still fails.
        await page.waitForFunction(({axis,before,target,point})=>{
          const raw=document.documentElement.getAttribute('data-matrix-state');
          if(!raw)return false;
          const value=JSON.parse(raw)[axis];
          if(Math.abs(value-before)<Math.min(26,Math.abs(target-before)) && Math.abs(value-target)>18) return false;
          // Release in this browser callback, avoiding another protocol round trip
          // while the character is still moving on a slow renderer.
          const canvas=document.querySelector('canvas');
          const pointer={identifier:7,target:canvas,clientX:point[0],clientY:point[1],pageX:point[0],pageY:point[1]};
          const event=new Event('touchend',{bubbles:true,cancelable:true});
          Object.assign(event,{touches:[],targetTouches:[],changedTouches:[pointer]});
          canvas.dispatchEvent(event);
          return true;
        },{axis,before,target,point},{timeout:5000,polling:16});
      } catch(error) { await touch(command,false); throw error; }
      await expect.poll(async () => (await state(page)).touch_held.includes(command)).toBe(false);
    }
    throw Error('Touch navigation stalled: '+JSON.stringify(await state(page)));
  }
  await move('y',172,'Up','Down');
  await move('x',464,'Left','Right');
  await expect.poll(async () => (await state(page)).near_terminal).toBe(true);
  for(const code of ['BOUNCE','BALLS','BUG','BUBBY','BUSBOY','MACHINE','YOU']) {
    await tap('Use');
    await expect.poll(async () => (await state(page)).terminal).toBe(true);
    await tap(code);
    await expect.poll(async () => (await state(page)).code).toBe(code);
    if(code==='BUSBOY') { await tap('Begin'); }
    if(code==='YOU') expect((await state(page)).camera_status).toContain('unavailable in this browser');
    if(code==='BUG') await page.touchscreen.tap(422,195);
    await page.screenshot({path:testInfo.outputPath(`${code}-touch.png`)});
    await tap('Matrix');
    await expect.poll(async () => (await state(page)).code).toBe('');
  }
  await page.setViewportSize({width:390,height:844});
  await expect.poll(async () => (await state(page)).touch_context).toBe('portrait');
  await page.screenshot({path:testInfo.outputPath('portrait.png')});
  await page.setViewportSize({width:844,height:390});
  await expect.poll(async () => (await state(page)).touch_context).toBe('hub');
  expect(errors).toEqual([]);
});
