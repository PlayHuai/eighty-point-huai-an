# 小程序 API 对接清单

所有 API 均应使用 HTTPS JSON；除微信登录外，客户端在 `Authorization` 请求头中携带访问令牌。目前下表所列 REST API 均未由 Go 服务提供。

| 状态 | 方法与路径 | 请求/响应概要 | 鉴权 |
|---|---|---|---|
| 未实现 | `POST /api/auth/wx-login` | `{code, clientType:"miniprogram"}` → `{token, openid, userId, nickname?, avatar?}` | 无 |
| 未实现 | `POST /api/lobby/joinDefault` | `{}` → `{roomId, seat, baseScore, members, status}` | access token |
| 未实现 | `POST /api/lobby/joinRoom` | `{roomId}` → 房间摘要与成员；须验证有效房间、容量及邀请权限 | access token |
| 未实现 | `POST /api/game/act` | `{roomId, handId, requestId, expectedVersion, action}` → `{accepted, stateVersion, errorCode?}` | access token |
| 未实现 | `GET /api/game/snapshot?roomId=...` | 授权后的个性化牌局快照（仅含本人可见手牌） | access token |
| 已有但不同用途 | `WSS /events` | JSON 通知事件，序列号字段为 `seq`；认证子协议为 `huai.events.v1` 与 `huai.auth.<token>` | WebSocket 子协议 |

## 当前后端边界

- 当前 Go 服务启动 `GET /healthz` 和 `/events`，没有以上 REST 路由；Proto 定义的 `GameService` 也没有运行中的服务端 handler。
- `/events` 仅推送已接线的通知，不接受游戏动作；现有 handler 忽略客户端发来的 WebSocket 数据帧，因此不要在此发送出牌或聊天命令。
- 小程序 WSS 客户端按服务端要求使用认证子协议，并实现断线退避；当前服务端没有 ping/pong、游戏事件补发或快照恢复协议，不能据此宣称已支持在线对局恢复。
- Proto 当前使用持久 access/refresh opaque token，而非 JWT；微信 `code2Session`、openid 账户关联及默认房分配尚未实现。实现前须设计身份映射、账户唯一性、隐私与幂等语义。
- 接口补齐前，小程序页面只展示连接/房间状态错误；客户端出牌规则只能作为提示，不得替代服务端合法性和状态裁决。
