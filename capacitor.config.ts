// import type { CapacitorConfig } from '@capacitor/cli';

// const config: CapacitorConfig = {
//   appId: 'com.citus.stage',
//   appName: 'AutoBuild_DemoApp',
//   webDir: 'www'
// };

// export default config;

import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.citus.stage',
  appName: 'AutoBuild_DemoApp',
  webDir: 'www',
  bundledWebRuntime: false // Recommended for modern builds
};