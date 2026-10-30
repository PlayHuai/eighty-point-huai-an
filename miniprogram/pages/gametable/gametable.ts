import { joinRoom } from '../../services/api';
import { ensureLogin } from '../../services/auth';
import type { RoomEntry } from '../../types/api';

Page({
  data: {
    roomId: '',
    seat: undefined as number | undefined,
    version: 0,
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
      const room = await joinRoom(options.roomId, Number(options.version) || 0);
      this.setData({
        roomId: room.roomId,
        seat: room.seat,
        version: room.version,
        roomMembers: [1, 2, 3, 4].map((seat) =>
          room.members?.some((member) => member.seat === seat)
            ? room.members.find((member) => member.seat === seat)?.userId === profile.userId
              ? '你'
              : `玩家 ${seat}`
            : '等待玩家'),
        status: room.status === 'PLAYING' ? '牌局进行中' : '等待其他玩家加入'
      });
    } catch {
      this.setData({ status: '无法进入房间，请检查房号或稍后重试' });
      setTimeout(() => wx.reLaunch({ url: '/pages/lobby/lobby' }), 1200);
    }
  },

  onShareAppMessage() {
    const roomId = this.data.roomId;
    return {
      title: `淮安80分 · 房号 ${roomId}`,
      path: `/pages/gametable/gametable?roomId=${encodeURIComponent(roomId)}&version=${this.data.version}`
    };
  },

  leaveRoom() {
    wx.navigateBack({ delta: 1 });
  }
});
