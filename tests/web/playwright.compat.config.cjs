const { defineConfig } = require('@playwright/test');
const base = require('./playwright.config.cjs');
module.exports = defineConfig({
  ...base,
  projects: [
    { name: 'Firefox', testMatch: 'smoke.spec.cjs', use: { browserName: 'firefox', launchOptions: {args: []} } },
    { name: 'Mobile Chromium', testMatch: 'mobile.spec.cjs', use: { browserName: 'chromium', viewport: {width:844,height:390}, deviceScaleFactor:3, isMobile:true, hasTouch:true } },
    { name: 'Mobile WebKit', testMatch: 'mobile.spec.cjs', use: { browserName: 'webkit', viewport: {width:844,height:390}, deviceScaleFactor:3, isMobile:true, hasTouch:true, launchOptions: {args: []} } }
  ],
  testMatch: /(?:smoke|mobile)\.spec\.cjs/
});
