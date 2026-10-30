import { config } from '../config/env';
import type { LoginResponse, UserProfile } from '../types/api';

const accessTokenKey = 'accessToken';
let loginInFlight: Promise<UserProfile> | undefined;

export function getAccessToken(): string {
  return wx.getStorageSync(accessTokenKey) || '';
}

export function ensureLogin(): Promise<UserProfile> {
  if (getAccessToken()) {
    return Promise.resolve(wx.getStorageSync('profile') || {});
  }
  if (!loginInFlight) {
    loginInFlight = silentLogin().finally(() => {
      loginInFlight = undefined;
    });
  }
  return loginInFlight;
}

export function silentLogin(): Promise<UserProfile> {
  return new Promise((resolve, reject) => {
    wx.login({
      success: ({ code }) => {
        if (!code) {
          reject(new Error('微信登录未返回临时凭证'));
          return;
        }
        wx.request<LoginResponse>({
          url: `${config.apiBaseUrl}/api/auth/wx-login`,
          method: 'POST',
          data: { code, clientType: 'miniprogram' },
          header: { 'content-type': 'application/json' },
          success: (response) => {
            const result = response.data;
            if (response.statusCode < 200 || response.statusCode >= 300 ||
              !result?.token || !result.userId) {
              reject(new Error('静默登录暂不可用'));
              return;
            }
            wx.setStorageSync(accessTokenKey, result.token);
            const profile = { userId: result.userId };
            wx.setStorageSync('profile', profile);
            resolve(profile);
          },
          fail: () => reject(new Error('无法连接登录服务'))
        });
      },
      fail: () => reject(new Error('微信登录暂不可用'))
    });
  });
}
