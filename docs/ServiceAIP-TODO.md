# Service API TODO

本文统一记录 Flutter 页面需要、但当前 API 尚未完整实现的 Service 接口或数据字段。页面开发发现新缺口时先补充本文，再由后续工作确认并实现对应版本化 Protobuf/API；不要在客户端伪造响应或绕过 Service 层。

以下条目依据原型需求及当前 API 实现状态整理。标为 `TODO` 或“部分实现”的项目尚未完整交付；添加 Proto 字段不代表后端 handler 或运行服务已经实现。补充/实现前须确认访问控制、隐私范围、分页、错误码和幂等语义。

**运行时阻塞（T22 审查，2026-10-29）：** `server/cmd/server/main.go` 当前只启动 HTTP 健康检查或数据库迁移，没有 gRPC listener/service registration。现有 transport handler 和生成的 Protobuf 客户端即使存在，也不能通过当前服务进程调用；接入任意页面前须实现并集成正式服务启动、认证拦截器和 graceful shutdown。

| 状态 | 使用页面 | 当前缺口 | 待设计接口/字段 |
|---|---|---|---|
| 已实现（待运行验证） | FriendProfile | 原本人统计/战绩 RPC 保持兼容；新增好友统计与分页战绩 RPC，服务端仅允许本人或已建立好友关系的查看者读取。Flutter API 客户端也已接入这两个 RPC。 | `GetFriendStatistics(user_id)`、`ListFriendRecentResults(user_id, page)`；服务端完成访问控制及分页，Go transport/service 测试覆盖好友与非好友访问。 |
| TODO | FriendList、Lobby | `Friend` 仍缺在线状态/当前公开大厅或房间；`RoomSummary` 的房主及设置字段已有 schema，但现有列表/创建 API 尚无运行中的 gRPC handler 来填充它们。 | 实现 presence/可见房间信息及房卡房主字段的查询或事件；补齐 Lobby/Room gRPC handler，并定义隐私过滤及离线/未知状态。 |
| 部分实现（TODO） | CreateRoomDialog | `CreateRoomRequest` 已增加观战选项和最低准入积分，`RoomSummary` 增加对应设置字段；但大厅创建 handler 未接线，无法保证服务端实际校验并返回生效值。好友房不使用最低积分门槛。 | 实现并注册房间创建 API；观战/积分门槛须按业务规则由服务端验证并返回实际设置。 |
| 部分实现（未接线） | Chat | 私聊服务端现已增加好友授权、历史分页、请求 ID 持久去重、事务 outbox、gRPC handler 和不含正文的用户定向 WebSocket 通知。当前 ChatService/WebSocket 尚未由服务进程注册，Flutter 客户端尚未订阅；无持久事件回放/送达确认，不能显示离线送达状态。 | 确认私聊留存期限、删除与举报流程；接通运行时并实现可恢复、有序事件补发和明确 delivery 状态后再开放。 |
| TODO | Lobby、GameTable、FriendList | 若干请求 schema 已增加 `request_id`/`expected_version` 字段，但对应 gRPC handlers 未接线或尚未实现去重、payload 冲突和重放语义；仅有字段不能视为幂等完成。 | 为每类变更请求实现持久去重、同 ID 不同 payload 冲突、相同请求安全重放及版本冲突错误；客户端重试复用同一 `request_id`。 |
| TODO | GameTable | `RoomDetails`/`GameSnapshot` 缺少完整牌桌展示所需的庄家、双方级数、主花色、剩余牌数、结算明细等字段；当前接口也没有客户端 WebSocket 订阅实现。只凭现有字段无法可靠展示牌局全貌和实时变化。 | 逐项核对业务规则与牌桌设计，补充服务端授权的快照/事件字段及 WebSocket 订阅、重连与序号补发契约；客户端不得推算缺失状态。 |
| TODO | Register | 注册和资料更新的 schema 已增加 `request_id`，但服务端仍无稳定的去重/重放实现；注册成功但响应丢失时重试可能得到账号已存在。 | 实现注册和资料更新的服务端去重/安全重放；账号操作不适用 `expected_version`，不得缓存或重放可泄露明文凭据的响应。 |
| 部分实现（待决策/验证） | Chat | 私聊读写 gRPC transport/service、MySQL 持久化和发送请求去重已实现；用户隔离的 WebSocket 通知 Hub/handler 已实现但未接入 server main。尚无 room chat、持久通知回放、确认送达字段或 Flutter WebSocket client。 | 明确私聊/房间聊天各自留存、删除和举报政策；定义并实现跨重启补发与送达确认，再考虑接线开放。 |

好友房新增邀请准入流程：FriendService 发送已建立好友关系的邀请，RoomService `JoinInvitedRoom(room_id, request_id)` 只允许该房间已获授权的邀请对象加入，并在重复接受时返回已加入的房间快照；去重状态与房间同为进程内状态。该领域逻辑和 transport handler 已实现；`RegisterRoomService` 尚未由 server 主程序注册，且其他 RoomService/LobbyService handlers 仍未实现，因此部署前仍需完成服务接线。好友 presence、聊天可靠补发/送达和实时牌桌快照仍未实现。

### T22 后续服务端实现状态（2026-10-29）

- 新增的 `chat.Service` 和 MySQL 实现只覆盖私聊：要求双方仍为有效好友；消息写入与 outbox 事件同事务提交；相同 sender/request_id 重试仅在 recipient 和 body 均一致时返回原消息，否则冲突。
- `RegisterChatService` 覆盖私聊发送/历史；Proto 中 room chat RPC 仍为未实现。WebSocket handler 使用 access token 子协议认证，并只将消息标识/双方 ID/序号发给参与者，不在推送中带正文。
- 上述 handler 尚未在 `server/cmd/server/main.go` 注册，事件 Hub 是进程内、容量有限的 best-effort 通知，没有持久化 replay consumer，也没有 Flutter WebSocket 客户端。因此这不是可上线的离线送达系统。
- 私聊留存、删除、举报规则尚未取得产品确认；按 `docs/tasks.md` 状态规则，不在默认无限保留的假设下开放接口。实时游戏事件同样缺少 GameService handler、玩家/观战授权的快照过滤和 WebSocket 接线。

## 已有接口复用

页面实现前优先核对并复用已有接口，例如 `AuthService.Login/Register`、`LobbyService`、`RoomService`、`GameService`、`FriendService`、`PlayerService` 和 `ChatService`。本表不代表这些已有接口均已在客户端接入或完成服务端实现。
