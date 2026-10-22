const {expect}=require('@playwright/test');
const state=page=>page.locator('html').getAttribute('data-matrix-state').then(s=>s?JSON.parse(s):{});
// Only actual keyboard/canvas touch inputs; diagnostics are strictly read-only.
module.exports=async function busboyPath(page,testInfo,mobile){
  async function tap(command){
    const p=(await state(page)).touch_regions[command];
    await page.touchscreen.tap(p[0],p[1]);
  }
  async function use(){ if(mobile) await tap('Use'); else await page.keyboard.press('e'); }
  async function release(point){
    await page.evaluate(([x,y])=>{
      const canvas=document.querySelector('canvas');
      const p={identifier:7,target:canvas,clientX:x,clientY:y,pageX:x,pageY:y};
      const e=new Event('touchend',{bubbles:true,cancelable:true});
      Object.assign(e,{touches:[],targetTouches:[],changedTouches:[p]});canvas.dispatchEvent(e);
    },point);
  }
  async function walk(axis,target,stopAtNpc=false){
    for(let i=0;i<90;i++){
      const current=await state(page),b=current.busboy,distance=target-b[axis];
      if((stopAtNpc&&b.near_npc)||Math.abs(distance)<=10) return;
      const command=axis==='x'?(distance<0?'Left':'Right'):(distance<0?'Up':'Down');
      if(!mobile){
        await page.keyboard.press('Arrow'+command,{delay:Math.min(50,Math.max(10,Math.abs(distance)/160*1000))});
        continue;
      }
      const point=current.touch_regions[command];
      await page.evaluate(([x,y])=>{
        const canvas=document.querySelector('canvas');
        const p={identifier:7,target:canvas,clientX:x,clientY:y,pageX:x,pageY:y};
        const e=new Event('touchstart',{bubbles:true,cancelable:true});
        Object.assign(e,{touches:[p],targetTouches:[p],changedTouches:[p]});canvas.dispatchEvent(e);
      },point);
      try{
        await page.waitForFunction(({axis,target,before,point,stopAtNpc})=>{
          const b=JSON.parse(document.documentElement.getAttribute('data-matrix-state')).busboy;
          if(!(stopAtNpc&&b.near_npc)&&Math.abs(b[axis]-before)<Math.min(24,Math.abs(target-before))&&Math.abs(b[axis]-target)>10)return false;
          const canvas=document.querySelector('canvas');
          const p={identifier:7,target:canvas,clientX:point[0],clientY:point[1],pageX:point[0],pageY:point[1]};
          const e=new Event('touchend',{bubbles:true,cancelable:true});
          Object.assign(e,{touches:[],targetTouches:[],changedTouches:[p]});canvas.dispatchEvent(e);return true;
        },{axis,target,before:b[axis],point,stopAtNpc},{timeout:5000,polling:16});
      }catch(e){await release(point);throw e;}
    }
    throw Error('Busboy path obstructed: '+JSON.stringify(await state(page)));
  }
  if(!mobile)await page.keyboard.press('Enter'); // Mobile route already tapped Begin.
  await expect.poll(async()=>(await state(page)).busboy?.opening).toBe(false);
  await walk('x',480);await walk('y',296);await use();
  await expect.poll(async()=>(await state(page)).busboy?.room).toBe('forest');
  await walk('x',224);await walk('y',400);await walk('x',352,true);await use();
  await expect.poll(async()=>(await state(page)).busboy?.dialogue).toBe(true);
  if(mobile)await page.screenshot({path:testInfo.outputPath('BUSBOY-npc-touch.png')});
  await use();
  await expect.poll(async()=>(await state(page)).busboy?.dialogue).toBe(false);
  await walk('y',432);await walk('x',400);await walk('y',240);await walk('x',704);await use();
  await expect.poll(async()=>(await state(page)).busboy?.battle?.player_turn).toBe(true);
  async function action(name,key){
    if(mobile){const p=(await state(page)).busboy.buttons[name];await page.touchscreen.tap(p[0],p[1]);}
    else await page.keyboard.press(key);
  }
  await action('cleanse','3');
  await expect.poll(async()=>(await state(page)).busboy.battle.mana).toBe(2);
  await expect.poll(async()=>(await state(page)).busboy.battle.player_turn).toBe(true);
  expect((await state(page)).busboy.battle.stain).toBe(1);
  await page.screenshot({path:testInfo.outputPath(mobile?'BUSBOY-combat-touch.png':'BUSBOY-combat.png')});
  await action('guard','2');
  await expect.poll(async()=>(await state(page)).busboy.battle.turn).toBe(2);
  expect((await state(page)).busboy.battle).toMatchObject({health:21,mana:3,stain:0});
  await action('cleanse','3');
  await expect.poll(async()=>(await state(page)).busboy.battle.turn).toBe(3);
  await action('cleanse','3'); // One mana: reject without spending a turn.
  expect((await state(page)).busboy.battle).toMatchObject({turn:3,mana:1,stain:1});
  if(mobile){const p=(await state(page)).busboy.buttons.leave;await page.touchscreen.tap(p[0],p[1]);}
  else await page.keyboard.press('Escape');
  await expect.poll(async()=>(await state(page)).busboy.battle).toBeUndefined();
};
