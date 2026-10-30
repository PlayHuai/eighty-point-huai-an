import { silentLogin } from './services/auth';
import type { UserProfile } from './types/api';

interface MiniProgramGlobalData {
  profile?: UserProfile;
  loginPromise?: Promise<void>;
}

App({
  globalData: {} as MiniProgramGlobalData,

  onLaunch() {
    void this.loginWithBackoff();
  },

  onShow() {
    if (!wx.getStorageSync('accessToken')) {
      void this.loginWithBackoff();
    }
  },

  async loginWithBackoff() {
    if (this.globalData.loginPromise) {
      return this.globalData.loginPromise;
    }
    this.globalData.loginPromise = (async () => {
      let delay = 1000;
      while (!wx.getStorageSync('accessToken')) {
        try {
          this.globalData.profile = await silentLogin();
        } catch {
          await new Promise((resolve) => setTimeout(resolve, delay));
          delay = Math.min(delay * 2, 30000);
        }
      }
    })().finally(() => {
      this.globalData.loginPromise = undefined;
    });
    return this.globalData.loginPromise;
  }
});

export {};
