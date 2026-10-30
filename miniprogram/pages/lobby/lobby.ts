import { ensureLogin } from '../../services/auth';
import { joinDefaultRoom } from '../../services/api';
import type { RoomEntry, UserProfile } from '../../types/api';

Page({
  data: {
    profile: {} as UserProfile,
    profileInitial: '玩',
    joining: false,
    roomStatus: '默认房间服务尚未接入'
  },

  async onShow() {
    try {
      const profile = await ensureLogin();
      this.setData({
        profile,
        profileInitial: profile.nickname?.slice(0, 1) || '玩'
      });
    } catch {
      this.setData({ roomStatus: '正在等待微信授权服务' });
    }
  },

  async enterDefaultRoom() {
    if (this.data.joining) {
      return;
    }
    this.setData({ joining: true });
    try {
      const room = await joinDefaultRoom();
      this.navigateToRoom(room);
    } catch {
      this.setData({ roomStatus: '暂时无法加入默认房，请稍后重试' });
    } finally {
      this.setData({ joining: false });
    }
  },

  navigateToRoom(room: RoomEntry) {
    wx.navigateTo({
      url: `/pages/gametable/gametable?roomId=${encodeURIComponent(room.roomId)}&seat=${room.seat}`
    });
  },

  openSettings() {
    wx.showToast({ title: '设置与反馈服务尚未接入', icon: 'none' });
  }
});
