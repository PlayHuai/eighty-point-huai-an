# Service API TODO

本文统一记录 Flutter 页面需要、但当前 `api/proto/huai/v1/api.proto` 尚未提供的 Service 接口或数据字段。页面开发发现新缺口时先补充本文，再由后续工作确认并实现对应版本化 Protobuf/API；不要在客户端伪造响应或绕过 Service 层。

以下缺口依据现有原型需求与当前 Protobuf 契约整理，均为 `TODO`，不是已实现接口。补充/实现前须确认访问控制、隐私范围、分页、错误码和幂等语义。

| 状态 | 使用页面 | 当前缺口 | 待设计接口/字段 |
|---|---|---|---|
| TODO | FriendProfile | `PlayerService.GetStatistics(Empty)` 和 `ListRecentResults(PageRequest)` 没有目标玩家参数，不能读取好友的统计和最近战绩。 | 设计按 `user_id` 查询好友统计与分页战绩的请求/响应；明确只允许读取可查看的好友资料，并保留现有查询本人资料的兼容行为。 |
| TODO | FriendList、Lobby | `Friend` 只有资料和成为好友时间，不能展示好友在线状态及当前公开大厅/房间；`RoomSummary` 也没有房主资料，无法完整展示原型房卡信息。 | 设计好友 presence/可见房间信息的查询或事件字段，以及房卡房主资料字段；明确隐私过滤、观战状态可见范围及离线/未知状态表示。 |
| TODO | CreateRoomDialog | `CreateRoomRequest` 目前只有大厅、名称、密码，未包含是否允许观战；原型也要求房间准入门槛设置。 | 设计创建请求的观战选项及准入门槛字段，定义与大厅准入范围的服务端校验规则，并在响应中返回实际生效设置。 |
| TODO | Chat | `ChatMessage` 没有收件人/会话标识或离线投递状态，不能直接确认原型要求的离线送达反馈。 | 设计私聊消息中的会话/收件人和投递状态表示，以及必要的送达事件；明确重试的 `request_id` 幂等行为。 |
| TODO | Lobby、GameTable、FriendList | 多个有副作用的请求尚无 `request_id`；房间状态变更请求也没有一致的 `expected_version`。例如 `CreateRoomRequest`、`RoomRequest`、`SeatRequest`、好友申请/删除/邀请请求。 | 逐项为变更请求补充稳定的幂等键，并为基于房间状态的变更补充 `expected_version`；明确重复请求返回行为、版本冲突错误和客户端重试复用同一 `request_id` 的约定。`GameService.SubmitAction` 已包含这两个字段，可作为游戏动作的现有参考。 |
| TODO | GameTable | `RoomDetails`/`GameSnapshot` 缺少完整牌桌展示所需的庄家、双方级数、主花色、剩余牌数、结算明细等字段；当前接口也没有客户端 WebSocket 订阅实现。只凭现有字段无法可靠展示牌局全貌和实时变化。 | 逐项核对业务规则与牌桌设计，补充服务端授权的快照/事件字段及 WebSocket 订阅、重连与序号补发契约；客户端不得推算缺失状态。 |
| TODO | Register | `AuthService.Register` 和注册后的 `PlayerService.UpdateProfile` 都没有 `request_id`；注册成功但响应丢失时重试可能得到账号已存在，不能确认首次请求结果。 | 为注册和资料更新补充稳定的幂等键及服务端去重/重放语义；账号操作不适用 `expected_version`。 |

## 已有接口复用

页面实现前优先核对并复用已有接口，例如 `AuthService.Login/Register`、`LobbyService`、`RoomService`、`GameService`、`FriendService`、`PlayerService` 和 `ChatService`。本表不代表这些已有接口均已在客户端接入或完成服务端实现。
