export interface UserProfile {
  userId: string;
  nickname?: string;
  avatar?: string;
}

export interface LoginResponse extends UserProfile {
  token: string;
  openid: string;
}

export interface RoomMember {
  userId: string;
  nickname: string;
  seat: number;
}

export interface RoomEntry {
  roomId: string;
  seat: number;
  baseScore: number;
  members: RoomMember[];
  status?: 'WAITING' | 'PLAYING' | 'CLOSED';
}

export interface GameActionRequest {
  roomId: string;
  handId: string;
  requestId: string;
  expectedVersion: number;
  action: Record<string, unknown>;
}

export interface RealtimeEvent {
  type: string;
  seq: number;
  room_id?: string;
  entity_id?: string;
  version?: number;
  payload?: Record<string, unknown>;
}
