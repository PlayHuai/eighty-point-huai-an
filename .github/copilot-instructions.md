# GitHub Copilot Instructions — 淮安80分（前端专用）

本文件由 GitHub Copilot（VS Code / github.com cloud agent）在每个会话中自动读取。

> **适用范围（最重要）**：本文件**仅在前端（Flutter 客户端）开发时遵守**——即编辑 `ui-design/`（Figma 转码产物）、Flutter 界面 / 图标资源 / 路由交互 / 动效 / 三端适配相关代码时。**服务端开发时忽略本文件**，不要用本文件内容约束或校验服务端（`server/`、Go、gRPC、MySQL、Redis、Proto）代码。

## 项目概况（前端视角）

- 项目：淮安80分，四人两两配合的"吃分升级"扑克游戏，线上多人平台。客户端 **Flutter**，共享 **iOS / Windows / Web** 一套代码（**不是 macOS**）。
- 权威文档（前端实现冲突时以此为准）：
  - 玩法规则：`docs/淮安80分业务规则.md`
  - 软件需求：`docs/design.md`
  - 技术架构：`docs/architecture.md`
  - 界面/交互/图标设计：`ui-design/淮安80分Figma暗黑风完整Prompts(UI原型+交互+图标).md`
- 前端设计稿由 Figma 经 Dev Mode / MCP 转码为 Flutter 页面与交互，业务逻辑交给 Copilot 实现。

## 客户端（Flutter）硬约束

1. **服务端权威**：洗牌、手牌、底牌、出牌合法性、轮次、升级、积分结算全部由 Go 服务端决定。客户端只提交意图并展示服务端状态，绝不本地推算结果。
2. **通信**：一律 Protobuf/gRPC（iOS/Windows 原生 gRPC，Web 用 gRPC-Web 或 HTTP/JSON 网关）+ WebSocket 实时事件。客户端不直接访问 MySQL/Redis。
3. **数据模型**：使用 protoc 生成的 Dart 类（`lib/generated/`），禁止手写 fromJson/toJson，禁止用 freezed 重复包装服务端消息。
4. **幂等与防重**：每个动作请求带 `request_id`（UUID）+ `expected_version`；重发必须复用同一 `request_id`。
5. **WebSocket**：事件带 `seq`，断线重连用 `last_seen_seq` 补发；倒计时只展示，有效性以服务端为准。
6. **状态管理**：Riverpod（riverpod_generator），禁止混用 Provider/Bloc。
7. **平台差异**：用 `Platform.isWindows` / `kIsWeb` 条件分支或条件导入；Web 无 `dart:io`，涉及本地的访问须 `kIsWeb` 条件隔离。
8. **敏感数据**：手牌/底牌/暗扣定主/暗反仅展示服务端允许看到的内容；旁观者按开牌/关牌设置过滤。
9. **座位模型**：固定 4 席，座位 1、2 一队，3、4 一队（对家为相隔 2 的座位）；换座仅限牌局开始前空位间。
10. **布局**：用 MediaQuery / LayoutBuilder 自适应，禁止写死宽高。

## `ui-design/` 目录约定（Figma 转码产物，前端页面的唯一来源）

- 每个**子目录对应一个页面功能，目录名即功能名**，目录内为与该功能同名的 `.dart` 页面文件。
- 现有页面（以此为基准，新增页面沿用同样命名）：
  - `ui-design/Login/login.dart`、`Register/Register.dart`、`Lobby/Lobby.dart`、`GameTable/GameTable.dart`、`Chat/Chat.dart`、`FriendList/FriendList.dart`、`FriendProfile/FriendProfile.dart`、`CreateRoomDialog/CreateRoomDialog.dart`。
- 新增页面时：目录名 = 功能名，文件 = 功能名 `.dart`（沿用目录内已有文件的命名风格）。
- 实现/修改某个页面时，先读取对应子目录的 `.dart` 文件作为设计稿依据；`ui-design/` 下的 `.md` 为设计说明，不参与构建。
- **同目录 PNG 校验**：每个 `.dart` 页面文件的**同级目录**都有一张与页面同名的 `.png` 设计截图（如 `GameTable/GameTable.png`，`Login/login.dart` 旁的 `Login.png`）。实现或修改后，**以该 png 为基准**校验 Flutter 页面与设计稿是否一致（布局、间距、配色、圆角、字体），有差异须修正到与设计一致，不得跳过。
- **Token 变量**：`ui-design/DarkTokens.json` 是本项目需要的变量定义（`darkTokens`：color 16 / font 6 / radius 4 / spacing 6），`ui-design/export.json` 是全量变量值。所有 `.dart` 页面都引用这两个文件里的变量（而非自行定义），**禁止硬编码颜色 / 字号 / 圆角 / 间距**。
- **最外层 Frame 尺寸**：部分页面转码时最外层 Frame 大小不一致。除**桌面版 `CreateRoomDialog`**外，其余页面默认统一采用一致的 Frame 尺寸（新增页面沿用既有页面的统一尺寸）；只有桌面版 `CreateRoomDialog` 允许保留其自有外层 Frame 尺寸。

## `ui-design/asserts/` 图标资源约定（前端唯一图标来源）

- 全部前端图标统一放在 `ui-design/asserts/` 下，**每个图标一个子目录，目录命名 `ic_<图标名>`**（`ic_` 前缀 + 图标名，例如 `ic_back`、`ic_host`、`ic_trump`、`ic_level`、`ic_suit_heart`）。
- 每个图标目录内**只认 32×32 的状态命名图标**，且仅以下两种命名范式（按该图标目录内实际文件为准，二者取其一）：
  1. `32xenabled.svg` / `32xdisabled.svg`
  2. `state=enabled.svg` / `state=disabled.svg`
- 两种范式表示同一图标在「启用（enabled）/ 禁用（disabled）」两个状态下的 **32×32** 资源；引用图标时按当前状态选择对应文件，禁止混用两种命名。
- **忽略其他尺寸**：目录内出现的 `16x…`、`24x…` 等非 32px 变体（例如 `ic_login/` 下的 16x/24x、`ic_settings/` 下的 16x）一律不使用，只使用 `32x` 或 `state=` 命名。
- 特例：`ic_card/` 是**卡牌组件设计**，不是状态图标。它包含 `Card.dart`（卡牌的全部样式设计：不同点数、不同形态、特殊牌的标记/角标/级牌徽章/牌背纹样等，**不代表一个页面**），以及 pdf / png / svg 贴图。当需要实现卡牌组件（`CardVisual` / `CardBack` / `LevelCardHighlight` / `RedFiveHighlight` / `TrumpCorner`）时：**解析 `Card.dart`** 得到卡牌在不同点数、形态下的样式与特殊牌标记；**卡牌本体图片**从 `third-party/playing-cards/` 取对应点数 / 花色的贴图，再叠加 `Card.dart` 里的标识，据此**创建一个统一的卡牌组件**。它不套用上述 `32x` / `state=` 图标状态命名。
- 引用图标必须从 `ui-design/asserts/ic_*` 读取，禁止自造图标名、路径或绕过该目录。

## 前端交互 / 动效 / 三端自适应要求（源自设计文档第 12 / 13 / 14 屏描述）

### 第 12 屏 · 原型交互（Prototype → Flutter 路由与状态交互）

- 登录流程：`LoginScreen →`（成功）`LobbyScreen` /（失败）错误提示；Token 自动登录静默 → `LobbyScreen`。
- 注册流程：`RegisterScreen →` 注册成功 `LobbyScreen`。
- 大厅→房间：`LobbyScreen` 点房间卡 → `GameTable`；点"创建房间" → `CreateRoomDialog` → 确认 → `GameTable`。
- 牌桌交互：出牌选牌高亮；托管倒计时环；观战主视角切换（1~4）；开牌/关牌即时生效；结算面板滑入。
- 好友：`FriendListScreen` → 点项 → `FriendProfileScreen`；点聊天 → `ChatScreen`；邀请 → 跳转房间。
- 错误/加载：gRPC 错误映射 Toast（如 `FAILED_PRECONDITION`=阶段不符）；`AsyncValue` 三态（loading 骨架 / error 重试 / data）。

### 第 13 屏 · 动效（Animation → Flutter AnimationController）

- 发牌：4 张一组从桌面中心飞向各座位，150ms/张，轻微弧线。
- 定主/反主（暗扣）：级牌暗扣 + 反主换底牌暗金高亮反馈（暗反不亮牌面）。
- 扣底：庄家替换底牌动画。
- 出牌：落牌 + 轻微震屏；甩牌 / 510k 扩散暗金光效；主 510k 抽筋抽取光效。
- 抄底：底牌翻倍结算 + 分数飘字。
- 升级/换庄：级数徽章推进暗金光效；庄家皇冠转移。
- 特殊结算：自然级小光效 / 翻盘 `redBright` 红闪 / 春天 `goldBright` 金色盛典 / 上天入地光柱。
- 结算面板：滑入 + 数字滚动。

### 第 14 屏 · 三端自适应（iOS / Windows / Web）

- Auto Layout 断点：手机 <600 竖版、平板 600~1024、桌面 >1024 横版。
- 牌桌：大屏四座位环 + 完整手牌扇形；小屏压缩手牌、折叠侧栏。
- 大厅：桌面网格、手机单列。
- 全部尺寸/间距/字号引用 Token（`darkTokens`：color 16 / font 6 / radius 4 / spacing 6），禁止硬编码。
- 端差异：Web/Windows hover、iOS 触控；桌面返回键 vs iOS 手势返回；游戏数据全走服务端、Web 无 `dart:io`。

### 视觉基调（所有前端界面通用）

- 偏暗黑（Dark）扁平风：深黑蓝底（`color/bgBase` #0A0E14）、暗色分层面板/卡片、克制的高级金色点缀（`color/goldPrimary` #C9A24B）、暗红警示（`redAccent` #8B1A2B）；无线条阴影、无浮雕塑形、暗黑不刺眼。

## 交付质量门槛（前端）

- 生成代码必须通过 `flutter analyze` + `flutter test` 后才可交付。
- 测试需覆盖 iOS / Windows / Web 三端条件分支，并校验 request_id 幂等与 expected_version 冲突处理。
- 棋牌术语使用项目术语：红五、必打级、抄底/扣底、翻盘、510k、抽筋、上天入地、春天、拖拉机、自然级、抢定者、回头望。
