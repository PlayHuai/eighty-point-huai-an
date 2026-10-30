import { ensureLogin } from '../../services/auth';
import {
  createEntertainmentRoom,
  joinRoom,
  listEntertainmentHalls,
  listEntertainmentRooms
} from '../../services/api';
import type { RoomEntry, RoomSummary, UserProfile } from '../../types/api';

const pendingCreateRequestIdKey = 'pendingCreateRoomRequestId';

Page({
  data: {
    profile: {} as UserProfile,
    halls: [] as { hallId: string; name: string }[],
    rooms: [] as RoomSummary[],
    nextPageToken: '',
    loading: false,
    loadingMore: false,
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
    this.setData({ loading: true, rooms: [], nextPageToken: '' });
    try {
      const { halls } = await listEntertainmentHalls();
      const entertainmentOnly = halls.filter((hall) => hall.hallId === 'entertainment');
      const { rooms, nextPageToken } = await listEntertainmentRooms();
      this.setData({
        halls: entertainmentOnly,
        rooms,
        nextPageToken,
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

  async onReachBottom() {
    await this.loadMoreRooms();
  },

  async loadMoreRooms() {
    const pageToken = this.data.nextPageToken;
    if (!pageToken || this.data.loading || this.data.loadingMore) {
      return;
    }
    this.setData({ loadingMore: true });
    try {
      const { rooms, nextPageToken } = await listEntertainmentRooms(pageToken);
      const existing = new Set(this.data.rooms.map((room) => room.roomId));
      this.setData({
        rooms: this.data.rooms.concat(rooms.filter((room) => !existing.has(room.roomId))),
        nextPageToken
      });
    } catch {
      this.setData({ roomStatus: '暂时无法加载更多房间，请稍后重试' });
    } finally {
      this.setData({ loadingMore: false });
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
      let requestId = wx.getStorageSync(pendingCreateRequestIdKey) as string;
      if (!requestId) {
        requestId = `${Date.now()}-${Math.random().toString(36).slice(2)}`;
        wx.setStorageSync(pendingCreateRequestIdKey, requestId);
      }
      const room = await createEntertainmentRoom(requestId);
      wx.removeStorageSync(pendingCreateRequestIdKey);
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
