import { ensureLogin } from '../../services/auth';
import {
  createEntertainmentRoom,
  joinRoom,
  listEntertainmentHalls,
  listEntertainmentRooms
} from '../../services/api';
import type { RoomEntry, RoomSummary, UserProfile } from '../../types/api';

Page({
  data: {
    profile: {} as UserProfile,
    halls: [] as { hallId: string; name: string }[],
    rooms: [] as RoomSummary[],
    loading: false,
    creating: false,
    roomStatus: '正在加载娱乐厅'
  },

  async onShow() {
    try {
      const profile = await ensureLogin();
      this.setData({ profile });
      await this.refreshEntertainmentHall();
    } catch {
      this.setData({ roomStatus: '微信登录或娱乐厅服务暂不可用' });
    }
  },

  async onPullDownRefresh() {
    try {
      await this.refreshEntertainmentHall();
    } finally {
      wx.stopPullDownRefresh();
    }
  },

  async refreshEntertainmentHall() {
    this.setData({ loading: true });
    try {
      const { halls } = await listEntertainmentHalls();
      const entertainmentOnly = halls.filter((hall) => hall.hallId === 'entertainment');
      const { rooms } = await listEntertainmentRooms();
      this.setData({
        halls: entertainmentOnly,
        rooms,
        roomStatus: entertainmentOnly.length
          ? rooms.length ? `当前 ${rooms.length} 个娱乐房间` : '暂无房间，可以创建娱乐房'
          : '没有可用的娱乐厅'
      });
    } catch {
      this.setData({ roomStatus: '暂时无法加载娱乐厅，请下拉重试' });
    } finally {
      this.setData({ loading: false });
    }
  },

  async enterRoom(event: WechatMiniprogram.TouchEvent) {
    const roomId = String(event.currentTarget.dataset.roomId || '');
    const expectedVersion = Number(event.currentTarget.dataset.version);
    if (!roomId || this.data.loading) {
      return;
    }
    this.setData({ loading: true });
    try {
      const room = await joinRoom(roomId, expectedVersion);
      this.navigateToRoom(room);
    } catch {
      this.setData({ roomStatus: '房间状态已变化或已满，请刷新后重试' });
      await this.refreshEntertainmentHall();
    } finally {
      this.setData({ loading: false });
    }
  },

  async createRoom() {
    if (this.data.creating) {
      return;
    }
    this.setData({ creating: true });
    try {
      const requestId = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
      const room = await createEntertainmentRoom(requestId);
      this.navigateToRoom(room);
    } catch {
      this.setData({ roomStatus: '暂时无法创建娱乐房，请稍后重试' });
    } finally {
      this.setData({ creating: false });
    }
  },

  navigateToRoom(room: RoomEntry) {
    wx.navigateTo({
      url: `/pages/gametable/gametable?roomId=${encodeURIComponent(room.roomId)}&seat=${room.seat}&version=${room.version}`
    });
  },

  openSettings() {
    wx.showToast({ title: '设置与反馈服务尚未接入', icon: 'none' });
  }
});
