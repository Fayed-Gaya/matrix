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
  await page.screenshot({path: testInfo.outputPath('hub-room.png')});
  async function move(axis,target,negative,positive) {
    for(let i=0;i<30;i++) {
      const current=await state(page);
      if(current.near_terminal) return;
      const before=current[axis];
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
          const current=JSON.parse(raw);
          const value=current[axis];
          if(!current.near_terminal && Math.abs(value-before)<Math.min(26,Math.abs(target-before)) && Math.abs(value-target)>18) return false;
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
  await move('y',192,'Up','Down');
  await move('x',448,'Left','Right');
  await expect.poll(async () => (await state(page)).near_terminal).toBe(true);
  await tap('Use');
  const input=page.getByRole('textbox',{name:'Terminal input'});
  await input.tap();
  await expect(input).toBeFocused();
  await page.keyboard.insertText('not-a-code');
  await page.getByRole('button',{name:'ENTER',exact:true}).tap();
  await expect(page.locator('#matrix-terminal')).toContainText('Unknown code');
  await expect(input).toHaveValue('');
  await page.setViewportSize({width:844,height:180});
  await input.tap();
  await expect(input).toBeFocused();
  const box=await input.boundingBox();
  expect(box.y).toBeGreaterThanOrEqual(0);
  expect(box.y+box.height).toBeLessThanOrEqual(180);
  const submitBox=await page.getByRole('button',{name:'ENTER',exact:true}).boundingBox();
  expect(submitBox.y+submitBox.height).toBeLessThanOrEqual(180);
  await page.getByRole('button',{name:'Close terminal'}).tap();
  await expect.poll(async () => (await state(page)).terminal).toBe(false);
  await page.setViewportSize({width:844,height:390});
  await expect.poll(async () => (await state(page)).height).toBe(390);
  for(const code of ['BOUNCE','BALLS','BUG','BUBBY','BUSBOY','MACHINE','YOU']) {
    await tap('Use');
    await expect.poll(async () => (await state(page)).terminal).toBe(true);
    if (code === 'BOUNCE') await page.screenshot({path: testInfo.outputPath('hub-terminal.png')});
    const field=page.getByRole('textbox', {name:'Terminal input'});
    await field.tap();
    await expect(field).toBeFocused();
    await expect(page.locator('#matrix-terminal')).not.toContainText(/BOUNCE|BALLS|BUG|BUBBY|BUSBOY|MACHINE|YOU|WORLD|DESTINATION|SIMULATION/);
    await page.keyboard.insertText(code.toLowerCase());
    await expect(field).toHaveValue(code);
    await page.getByRole('button', {name:'ENTER',exact:true}).tap();
    await expect.poll(async () => (await state(page)).code).toBe(code);
    if(code==='BUSBOY') { await tap('Begin'); }
    if(code==='YOU') expect((await state(page)).camera_status).toContain('unavailable in this browser');
    if(code==='BUG') await page.touchscreen.tap(422,195);
    await page.screenshot({path:testInfo.outputPath(`${code}-touch.png`)});
    if(code==='BUBBY') {
      async function walk(axis,target,negative,positive) {
        for(let i=0;i<30;i++) {
          const b=(await state(page)).bubby;
          if(Math.abs(target-b[axis])<=14) return;
          const point=await touch(target<b[axis]?negative:positive,true);
          try {
            await page.waitForFunction(({axis,before,target,point})=>{
              const b=JSON.parse(document.documentElement.getAttribute('data-matrix-state')).bubby;
              if(Math.abs(b[axis]-before)<Math.min(24,Math.abs(target-before)) && Math.abs(b[axis]-target)>14) return false;
              const canvas=document.querySelector('canvas');
              const p={identifier:7,target:canvas,clientX:point[0],clientY:point[1],pageX:point[0],pageY:point[1]};
              const e=new Event('touchend',{bubbles:true,cancelable:true});
              Object.assign(e,{touches:[],targetTouches:[],changedTouches:[p]});canvas.dispatchEvent(e);
              return true;
            },{axis,before:b[axis],target,point},{timeout:5000,polling:16});
          } catch(e) { await touch(target<b[axis]?negative:positive,false);throw e; }
        }
        throw Error('Bubby touch navigation stalled: '+JSON.stringify(await state(page)));
      }
      await walk('y',282,'Up','Down');
      await walk('x',560,'Left','Right');
      await tap('Use');
      await expect.poll(async()=>(await state(page)).bubby?.room).toBe('outside');
      await tap('Use');
      await expect.poll(async()=>{
        const b=(await state(page)).bubby;
        return b.phase==='rest' && Math.hypot(b.x-b.bird_x,b.y-b.bird_y)<=86;
      },{timeout:15000}).toBe(true);
      // Two simultaneous action/movement fingers, released in-browser on physics progress.
      const before=(await state(page)).bubby;
      await page.evaluate(()=>{
        const s=JSON.parse(document.documentElement.getAttribute('data-matrix-state'));
        const canvas=document.querySelector('canvas');
        const points=['Right','Shoo'].map((name,i)=>{
          const [x,y]=s.touch_regions[name];
          return {identifier:7+i,target:canvas,clientX:x,clientY:y,pageX:x,pageY:y};
        });
        const event=new Event('touchstart',{bubbles:true,cancelable:true});
        Object.assign(event,{touches:points,targetTouches:points,changedTouches:points});canvas.dispatchEvent(event);
        window.bubbyTestTouches=points;
      });
      try {
        await page.waitForFunction(({x,resolve})=>{
          const b=JSON.parse(document.documentElement.getAttribute('data-matrix-state')).bubby;
          if(b.x<x+6 || b.resolve>=resolve) return false;
          const e=new Event('touchend',{bubbles:true,cancelable:true});
          Object.assign(e,{touches:[],targetTouches:[],changedTouches:window.bubbyTestTouches});
          document.querySelector('canvas').dispatchEvent(e);return true;
        },{x:before.x,resolve:before.resolve},{timeout:5000,polling:16});
      } finally {
        await page.evaluate(()=>{
          const e=new Event('touchend',{bubbles:true,cancelable:true});
          Object.assign(e,{touches:[],targetTouches:[],changedTouches:window.bubbyTestTouches});
          document.querySelector('canvas').dispatchEvent(e);delete window.bubbyTestTouches;
        });
      }
      await expect.poll(async()=>(await state(page)).touch_held.length).toBe(0);
      await page.screenshot({path:testInfo.outputPath('BUBBY-balcony-touch.png')});
    }
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
