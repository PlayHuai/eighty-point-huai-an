# 小程序 API 对接清单

所有 API 均使用 HTTPS JSON；除微信登录外，客户端在 `Authorization` 请求头中携带现有不透明访问令牌。服务端从环境变量读取 `WECHAT_APP_ID`、`WECHAT_APP_SECRET`，仅在服务端向微信 `code2session` 换取 OpenID。

| 状态 | 方法与路径 | 请求/响应概要 | 鉴权 |
|---|---|---|---|
| 已实现 | `POST /api/auth/wx-login` | `{code, clientType:"miniprogram"}` → `{token, userId}`；不返回 OpenID 或个人资料 | 无 |
| 已实现 | `GET /api/lobby/halls` | `{halls:[{hallId:"entertainment",name:"娱乐厅"}]}` | 微信账户 token |
| 已实现 | `GET /api/lobby/rooms?hallId=entertainment&pageSize=20&pageToken=...` | `{hallId, rooms:[{roomId,name,status,occupiedSeats,capacity,version}], nextPageToken}` | 微信账户 token |
| 已实现 | `POST /api/lobby/createRoom` | `{requestId}` → 娱乐厅房间摘要、座位与成员；同账户/请求 ID 重放同一结果 | 微信账户 token |
| 已实现 | `POST /api/lobby/joinRoom` | `{roomId, expectedVersion}` → 娱乐厅房间摘要、座位与成员；重复加入返回已有成员状态 | 微信账户 token |
| 未实现 | `POST /api/game/act` | `{roomId, handId, requestId, expectedVersion, action}` → `{accepted, stateVersion, errorCode?}` | access token |
| 未实现 | `GET /api/game/snapshot?roomId=...` | 授权后的个性化牌局快照（仅含本人可见手牌） | access token |
| 已有但不同用途 | `WSS /events` | JSON 通知事件，序列号字段为 `seq`；认证子协议为 `huai.events.v1` 与 `huai.auth.<token>` | WebSocket 子协议 |

## 当前后端边界

- 当前 Go 服务启动 `GET /healthz`、`/events` 和上表中的小程序认证/娱乐厅 REST 路由；Proto 定义的 `GameService` 仍没有运行中的服务端 handler。
- `/events` 仅推送已接线的通知，不接受游戏动作；现有 handler 忽略客户端发来的 WebSocket 数据帧，因此不要在此发送出牌或聊天命令。
- 小程序 WSS 客户端按服务端要求使用认证子协议，并实现断线退避；当前服务端没有 ping/pong、游戏事件补发或快照恢复协议，不能据此宣称已支持在线对局恢复。
- 小程序微信登录只申请临时 `wx.login()` code，不申请头像、昵称或其他用户资料权限。OpenID 仅由服务端验证并与唯一账户关联；客户端只接收内部 `userId` 和现有 opaque access token。账户密码是随机生成的内部 Argon2id 值，不是共享默认密码，也不开放给客户端。
- gRPC `ListHalls` 对微信账户只返回娱乐厅，普通账户不显示娱乐厅；小程序 REST 房间列表固定过滤娱乐厅，其他账户无权访问该接口。服务端的娱乐厅房间当前为进程内状态。
- `/api/game/act`、游戏快照及牌局事件仍未实现。`/events` 仅推送已接线通知，不接受游戏动作；断线补发/ping-pong 也尚无服务端协议。客户端不得将本地牌型判断当作服务端裁决。
