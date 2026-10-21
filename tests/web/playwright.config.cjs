const { defineConfig } = require('@playwright/test');
const chromiumArgs = process.env.CI ? ['--use-angle=swiftshader', '--enable-unsafe-swiftshader'] : [];
module.exports = defineConfig({
  testDir: '.', testMatch: 'smoke.spec.cjs', timeout: 240000, workers: 1,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: { headless: false, viewport: { width: 1280, height: 720 }, screenshot: 'only-on-failure', trace: 'retain-on-failure' },
  projects: [
    { name: 'Chrome', use: { browserName: 'chromium', channel: 'chrome', launchOptions: { args: chromiumArgs } } },
    { name: 'Firefox', use: { browserName: 'firefox' } },
    { name: 'Edge', use: { browserName: 'chromium', channel: 'msedge', launchOptions: { args: chromiumArgs } } }
  ],
  webServer: { command: 'python3 -m http.server 8060 --bind 127.0.0.1 --directory ../../exports/web', url: 'http://127.0.0.1:8060', reuseExistingServer: !process.env.CI }
});
