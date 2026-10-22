const { defineConfig } = require('@playwright/test');
const chromiumArgs = process.env.CI ? ['--use-angle=swiftshader', '--enable-unsafe-swiftshader'] : [];
module.exports = defineConfig({
  testDir: '.', testMatch: /(?:smoke|mobile)\.spec\.cjs/, timeout: 240000, workers: 1,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: { headless: false, viewport: { width: 1280, height: 720 }, screenshot: 'only-on-failure', trace: 'retain-on-failure' },
  projects: [
    { name: 'Chrome', testMatch: 'smoke.spec.cjs', use: { browserName: 'chromium', channel: 'chrome', launchOptions: { args: chromiumArgs } } },
    { name: 'Firefox', testMatch: 'smoke.spec.cjs', use: { browserName: 'firefox' } },
    { name: 'Edge', testMatch: 'smoke.spec.cjs', use: { browserName: 'chromium', channel: 'msedge', launchOptions: { args: chromiumArgs } } }
    ,{ name: 'Mobile Chrome', testMatch: 'mobile.spec.cjs', use: { browserName: 'chromium', channel: 'chrome', viewport: {width:844,height:390}, deviceScaleFactor:3, isMobile:true, hasTouch:true, launchOptions: {args:chromiumArgs} } },
    { name: 'Mobile WebKit', testMatch: 'mobile.spec.cjs', use: { browserName: 'webkit', viewport: {width:844,height:390}, deviceScaleFactor:3, isMobile:true, hasTouch:true } }
  ],
  webServer: { command: 'python3 -m http.server 8060 --bind 127.0.0.1 --directory ../../exports/web', url: 'http://127.0.0.1:8060', reuseExistingServer: !process.env.CI }
});
