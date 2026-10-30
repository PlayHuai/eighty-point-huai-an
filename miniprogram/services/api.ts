import { config } from '../config/env';
import { ensureLogin, getAccessToken, silentLogin } from './auth';

export interface RequestOptions {
  method?: 'GET' | 'POST';
  data?: Record<string, unknown>;
}

export async function request<T>(
  path: string,
  options: RequestOptions = {},
  retryUnauthorized = true
): Promise<T> {
  await ensureLogin();
  const token = getAccessToken();
  return new Promise((resolve, reject) => {
    wx.request<WechatMiniprogram.IAnyObject>({
      url: `${config.apiBaseUrl}${path}`,
      method: options.method ?? 'GET',
      data: options.data,
      header: {
        'content-type': 'application/json',
        Authorization: 'Bearer ' + token,
      },
      success: async (response) => {
        if (response.statusCode === 401 && retryUnauthorized) {
          try {
            await silentLogin();
            resolve(await request<T>(path, options, false));
          } catch (error) {
            reject(error);
          }
          return;
        }
        if (response.statusCode < 200 || response.statusCode >= 300) {
          const error = new Error(`服务暂不可用 (${response.statusCode})`);
          wx.showToast({ title: error.message, icon: 'none' });
          reject(error);
          return;
        }
        resolve(response.data as T);
      },
      fail: () => {
        const error = new Error('网络连接失败，请稍后重试');
        wx.showToast({ title: error.message, icon: 'none' });
        reject(error);
      }
    });
  });
}

export function listEntertainmentHalls(): Promise<{ halls: import('../types/api').Hall[] }> {
  return request('/api/lobby/halls');
}

export function listEntertainmentRooms(): Promise<{
  hallId: string;
  rooms: import('../types/api').RoomSummary[];
  nextPageToken: string;
}> {
  return request('/api/lobby/rooms?hallId=entertainment');
}

export function joinRoom(roomId: string, expectedVersion: number): Promise<import('../types/api').RoomEntry> {
  return request('/api/lobby/joinRoom', {
    method: 'POST',
    data: { roomId, expectedVersion }
  });
}

export function createEntertainmentRoom(requestId: string): Promise<import('../types/api').RoomEntry> {
  return request('/api/lobby/createRoom', {
    method: 'POST',
    data: { requestId }
  });
}

export function submitGameAction(
  action: import('../types/api').GameActionRequest
): Promise<{ accepted: boolean; stateVersion: number; errorCode?: string }> {
  return request('/api/game/act', { method: 'POST', data: action as unknown as Record<string, unknown> });
}
