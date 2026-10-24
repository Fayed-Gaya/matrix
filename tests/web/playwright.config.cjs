const { defineConfig } = require('@playwright/test');
module.exports = defineConfig({
  testDir: '.', testMatch: 'smoke.spec.cjs', timeout: 90000, workers: 1,
  reporter: [['list']],
  use: {
    headless: true, viewport: { width: 1280, height: 720 },
    screenshot: 'only-on-failure',
    trace: { mode: 'retain-on-failure', screenshots: false, snapshots: true, sources: true },
    launchOptions: { args: ['--use-angle=swiftshader', '--enable-unsafe-swiftshader'] }
  },
  projects: [{ name: 'Chromium', use: { browserName: 'chromium' } }],
  webServer: {
    command: 'mkdir -p ../../build/test-logs && python3 -m http.server 8060 --bind 127.0.0.1 --directory ../../exports/web 2>../../build/test-logs/http-server.log',
    url: 'http://127.0.0.1:8060', reuseExistingServer: false
  }
});
