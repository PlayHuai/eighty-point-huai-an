export interface UserProfile {
  userId: string;
}

export interface LoginResponse {
  token: string;
  userId: string;
}

export interface Hall {
  hallId: string;
  name: string;
}

export interface RoomSummary {
  roomId: string;
  name: string;
  status: 'WAITING' | 'PLAYING' | 'CLOSED';
  occupiedSeats: number;
  capacity: number;
  version: number;
}

export interface RoomMember {
  userId: string;
  nickname: string;
  seat: number;
}

export interface RoomEntry {
  roomId: string;
  name: string;
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
