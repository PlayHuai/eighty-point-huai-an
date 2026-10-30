import { config } from '../config/env';
import { getAccessToken, silentLogin } from './auth';
import type { RealtimeEvent } from '../types/api';

export type EventListener = (event: RealtimeEvent) => void;

export class EventSocket {
  private task?: WechatMiniprogram.SocketTask;
  private closed = false;
  private reconnects = 0;
  private reconnectTimer?: ReturnType<typeof setTimeout>;
  private listeningForNetwork = false;
  private readonly listeners = new Set<EventListener>();
  private readonly networkListener = ({ isConnected }: WechatMiniprogram.OnNetworkStatusChangeListenerResult) => {
    if (isConnected && !this.closed && !this.task) {
      this.scheduleReconnect();
    }
  };

  async connect(): Promise<void> {
    if (this.task) {
      return;
    }
    this.closed = false;
    if (!this.listeningForNetwork) {
      wx.onNetworkStatusChange(this.networkListener);
      this.listeningForNetwork = true;
    }
    if (!getAccessToken()) {
      await silentLogin();
    }
    this.open();
  }

  on(listener: EventListener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  close(): void {
    this.closed = true;
    if (this.reconnectTimer) {
      clearTimeout(this.reconnectTimer);
      this.reconnectTimer = undefined;
    }
    if (this.listeningForNetwork) {
      wx.offNetworkStatusChange(
        this.networkListener as unknown as WechatMiniprogram.OffNetworkStatusChangeCallback
      );
      this.listeningForNetwork = false;
    }
    this.task?.close({});
    this.task = undefined;
  }

  private open(): void {
    const token = getAccessToken();
    if (!token || this.closed) {
      return;
    }
    const task = wx.connectSocket({
      url: config.socketUrl,
      protocols: ['huai.events.v1', `huai.auth.${token}`]
    });
    this.task = task;
    task.onOpen(() => {
      this.reconnects = 0;
    });
    task.onMessage(({ data }) => {
      try {
        const event = JSON.parse(String(data)) as RealtimeEvent;
        this.listeners.forEach((listener) => listener(event));
      } catch {
        wx.showToast({ title: '收到无法识别的实时消息', icon: 'none' });
      }
    });
    task.onClose(() => {
      if (this.task === task) {
        this.task = undefined;
      }
      this.scheduleReconnect();
    });
    task.onError(() => {
      if (this.task === task) {
        this.task = undefined;
      }
      this.scheduleReconnect();
    });
  }

  private scheduleReconnect(): void {
    if (this.closed || this.reconnectTimer || this.reconnects >= 5) {
      return;
    }
    const delay = 1000 * (2 ** this.reconnects);
    this.reconnects += 1;
    this.reconnectTimer = setTimeout(async () => {
      this.reconnectTimer = undefined;
      try {
        await silentLogin();
        this.open();
      } catch {
        this.scheduleReconnect();
      }
    }, delay);
  }
}
