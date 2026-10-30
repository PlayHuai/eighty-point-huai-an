import { joinRoom, leaveRoom as leaveRoomRequest } from '../../services/api';
import { ensureLogin } from '../../services/auth';
import { EventSocket } from '../../services/socket';
import type { RoomEntry } from '../../types/api';

let roomSocket: EventSocket | undefined;
let unsubscribeRoomEvents: (() => void) | undefined;
let roomRefresh: Promise<void> | undefined;

Page({
  data: {
    roomId: '',
    seat: undefined as number | undefined,
    version: 0,
    userId: '',
    roomMembers: ['等待玩家', '等待玩家', '等待玩家', '等待玩家'],
    status: '正在验证进入权限…'
  },

  async onLoad(options: Record<string, string | undefined>) {
    try {
      const profile = await ensureLogin();
      if (!options.roomId) {
        wx.reLaunch({ url: '/pages/lobby/lobby' });
        return;
      }
      this.setData({ roomId: options.roomId, userId: profile.userId });
      await this.refreshRoom();
      roomSocket = new EventSocket();
      unsubscribeRoomEvents = roomSocket.on((event) => {
        if (event.type === 'ROOM_STATE_CHANGED' && event.room_id === this.data.roomId) {
          void this.refreshRoom().catch(() => undefined);
        }
      });
      void roomSocket.connect().catch(() => undefined);
    } catch {
      this.setData({ status: '无法进入房间，请检查房号或稍后重试' });
      setTimeout(() => wx.reLaunch({ url: '/pages/lobby/lobby' }), 1200);
    }
  },

  onShow() {
    if (this.data.roomId) {
      void this.refreshRoom().catch(() => undefined);
    }
  },

  async refreshRoom() {
    if (!this.data.roomId || roomRefresh) {
      return roomRefresh;
    }
    roomRefresh = (async () => {
      const room = await joinRoom(this.data.roomId, 0);
      const ownSeat = room.seat || 1;
      const displaySeats = [0, 1, 2, 3].map((offset) => ((ownSeat - 1 + offset) % 4) + 1);
      const memberBySeat = new Map(room.members?.map((member) => [member.seat, member]) ?? []);
      this.setData({
        seat: room.seat,
        version: room.version,
        roomMembers: displaySeats.map((seat) => {
          const member = memberBySeat.get(seat);
          return member
            ? member.userId === this.data.userId ? '你' : `玩家 ${seat}`
            : '等待玩家';
        }),
        status: room.status === 'PLAYING' ? '牌局进行中' : '等待其他玩家加入'
      });
    })();
    try {
      await roomRefresh;
    } catch (error) {
      this.setData({ status: '无法刷新房间成员，请稍后重试' });
      throw error;
    } finally {
      roomRefresh = undefined;
    }
  },

  onShareAppMessage() {
    const roomId = this.data.roomId;
    return {
      title: `淮安80分 · 房号 ${roomId}`,
      path: `/pages/gametable/gametable?roomId=${encodeURIComponent(roomId)}`
    };
  },

  async leaveRoom() {
    try {
      await leaveRoomRequest(this.data.roomId);
      this.setData({ roomId: '' });
      wx.navigateBack({
        delta: 1,
        fail: () => wx.reLaunch({ url: '/pages/lobby/lobby' })
      });
    } catch {
      wx.showToast({ title: '暂时无法离开房间，请重试', icon: 'none' });
    }
  },

  onUnload() {
    unsubscribeRoomEvents?.();
    unsubscribeRoomEvents = undefined;
    roomSocket?.close();
    roomSocket = undefined;
    const roomId = this.data.roomId;
    if (roomId) {
      void (async () => {
        try {
          await roomRefresh?.catch(() => undefined);
          await leaveRoomRequest(roomId);
        } catch {
          return;
        }
      })();
    }
  }
});
