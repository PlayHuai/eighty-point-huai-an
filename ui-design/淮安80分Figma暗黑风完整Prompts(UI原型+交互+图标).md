# 淮安80分 · Figma UI 原型 + 交互设计 Prompts（偏暗黑风格 · 完整版）

> **用途**：在 Figma 中生成/搭建"淮安80分"全部界面、图标、交互与原型。
> **风格基调**：**偏暗黑（Dark）**，扁平为主、辅以克制的高级金色点缀；深黑蓝底、暗金描边、暗红警示，营造庄重神秘的牌桌氛围。
> **Token 已导入**：Collection `darkTokens`（color 16 / font 6 / radius 4 / spacing 6），全程引用，禁止硬编码。
> **目标**：设计稿经 Dev Mode / MCP 转码，由 GitHub Copilot 生成 Flutter 界面 + 逻辑交互。
> **规则依据**：《淮安80分业务规则.md》《design.md》《architecture.md》。
> **进度状态**：第 1~10 屏 ✅ 已完成（Figma Make AI 生成）；第 11~14 屏 ⏳ TODO（计划 11 月开始设计）。

---

## 〇、全局暗黑基调（所有屏通用）

- 背景：`color/bgBase` #0A0E14（深黑蓝），大面积留暗，避免花哨。
- 面板/卡片：`color/bgPanel` #131A24 / `color/bgCard` #1C2530，暗色分层。
- 点缀：`color/goldPrimary` #C9A24B 金线描边、金色按钮、金色装饰（庄家/级牌/胜利）。
- 警示/失败：`color/redAccent` #8B1A2B、`color/redBright` #B3273D。
- 文字：`color/textPrimary` #EDE8DC 主文 / `color/textSecondary` #9A927F 次文 / `color/textDisabled` #5A5748 禁用。
- 牌面 `color/cardFace` #F5EFE0、牌背 `color/cardBack` #22303E。
- 全部圆角/间距/字号用 Token（radius / spacing / font）。
- 视觉风格：扁平 2D、克制的微阴影、无线条阴影、无浮雕塑形、暗黑不刺眼。

---

## 第 1 屏 · 应用图标（AppIcon · 1024×1024） ✅

```
设计"淮安80分"应用图标，方形圆角，偏暗黑风。
深黑蓝底（color/bgBase）+ 暗金元素（color/goldPrimary / color/goldBright）。
构图：顶部弧形暗金牌匾"淮安"，中央大字"80分"（暗金扁平字），左下圆形内画淮安古建桥梁水景（暗金扁平线条），底部飘带"510k"，点缀小颗金色星与金币。
整体暗黑、庄重、干净扁平，无线条阴影，无大红喜庆。
尺寸 1024×1024。命名 AppIcon。转成 Flutter 应用图标。
```

---

## 第 2 屏 · 登录页（LoginScreen · 1440×900 + 375×812 双画板） ✅

```
设计"淮安80分"登录页，偏暗黑风，桌面 1440×900 + 手机 375×812 双画板（Auto Layout）。
背景：color/bgBase 深黑蓝 + 极淡几何牌桌暗纹（不喧宾夺主）。
顶部：金色扁平 Logo（扑克牌+皇冠）+ "淮安80分"标题（font/sizeL1、Bold、color/textPrimary）。
中部：登录表单卡（color/bgPanel、radius/panel、暗金细边）：
 - 账号输入框：深底、聚焦金边、占位 textSecondary；
 - 密码输入框：带可见性切换图标；
 - 金色扁平"登录"主按钮（color/goldPrimary 底 + textPrimary 字、radius/button）。
附加：Token 自动登录静默提示"正在恢复登录…"（textSecondary、sizeL5）；输错 5 次锁定警示（redAccent 描边）。
底部：版本号（sizeL6、textDisabled）。
命名：LoginScreen / LoginForm / LogoMark / PrimaryButton / InputField。转成 Flutter 登录页。
```

---

## 第 3 屏 · 注册页（RegisterScreen · 1440×900） ✅

```
设计"淮安80分"注册页，同登录页暗黑风、共用 Logo/按钮。
字段：账号、密码（提示≥8位含字母数字）、确认密码、昵称、头像选择（圆形系统头像，选中暗金边）。
校验：错误 redAccent 描边提示；密码强度条（弱红→中金→强亮金三段）。
底部：金色"注册"主按钮 + "已有账号，去登录"链接。
命名：RegisterScreen / RegisterForm / StrengthIndicator / AvatarPicker。转成 Flutter 注册页。
```

---

## 第 4 屏 · 大厅（LobbyScreen · 1440×900 + 手机 9:16） ✅

```
设计"淮安80分"大厅页，偏暗黑风，桌面 + 手机双画板（断点 <600 单列 / >1024 网格）。
顶部个人栏：头像 + 昵称 + 积分 + 段位徽章（王者 goldBright 至尊样式）；大厅 TabBar（普通 ×1.0 / 高手 ×1.5 / 至尊 ×2.0），选中项 goldPrimary 暗金边。
中部房间卡片（color/bgCard、goldPrimary 暗金描边、radius/card）：房间名、房主、人数 x/4、类型标签、是否密码房（锁）、是否观战中；等待中可进入。
右上：暗金"创建房间"按钮 + 房间号搜索框。
侧栏（桌面）：好友列表 + 最近战绩入口。
命名：LobbyScreen / RoomCard / HallTab / CreateRoomDialog / FriendList / RankBadge。转成 Flutter 大厅。
```

---

## 第 5 屏 · 房间牌桌（GameTable · 1440×900 + 手机 9:16）——核心屏 ✅

```
设计"淮安80分"牌桌主界面，偏暗黑风，桌面 + 手机双画板。
中央：深色牌桌（扁平圆桌，goldPrimary 暗金桌沿、redAccent 暗红台呢、radius/panel）。
四座位环：上/下/左/右四座，每座显示头像、昵称、段位、级数徽章（2~A，必打级 2/J/A 特殊暗金标记、radius/badge）、庄家暗金皇冠、本局得分；对家（上下 / 左右）同色暗金线连线。
底部本方手牌区：25 张扇形排布（牌面 cardFace，桌面 62×88、radius/card），可选暗金描边；级牌暗金边+级牌徽章；红五（红桃5）goldBright 高亮。
牌局信息条：庄家、级牌、主花色指示、剩余牌数、双方得分（font/sizeL3~L5）、底牌区（8 张，扣底显示 / 否则 cardBack 背面）。
互动区：出牌确认（radius/button）、托管提示（60s 倒计时环+"托管中"、infoBlue）、聊天、观战主视角切换（1~4）、开牌/关牌（眼睛图标）。
结算面板：双方最终级数、级差、胜负（goldBright 胜利 / redBright 失败）、积分变动（×1.0/1.5/2.0 系数）、特殊结果标签（自然级/翻盘/春天，春天 goldBright 高亮）。
命名：GameTable / SeatRing / SeatBadge / HandArea / CardVisual / CardBack / TrumpIndicator / DiscardArea / SettlementPanel / LevelBadge。转成 Flutter 牌桌。
```

---

## 第 6 屏 · 好友列表（FriendListScreen · 桌面 + 手机 9:16） ✅

```
设计"淮安80分"好友列表页，偏暗黑风，桌面 + 手机双画板。
顶部：标题"好友" + 搜索框（昵称/ID/手机号）+ "添加好友"按钮。
列表项（color/bgCard、goldPrimary 暗金描边、radius/card）：头像、昵称、在线/离线（绿/灰点）、当前所在大厅/房间（可选公开）、段位徽章。
行尾操作：进入聊天、邀请加入房间（在线好友）、删除好友。
底部/侧栏：好友申请入口（未读红点 redAccent）。
命名：FriendListScreen / FriendItem / FriendSearch / AddFriendDialog / OnlineBadge。转成 Flutter 好友列表。
```

---

## 第 7 屏 · 好友信息 / 战绩（FriendProfileScreen · 桌面 + 手机 9:16） ✅

```
设计"淮安80分"好友信息页，偏暗黑风，桌面 + 手机双画板。
顶部：大头像 + 昵称 + 段位徽章 + 在线状态；操作：聊天 / 邀请 / 删除。
中部战绩卡（color/bgCard、radius/card）：总场数、胜场/负场/胜率、当前积分、段位。
下方最近战绩列表（最近 20 局）：对手、级差、胜负、积分变动（+ goldBright / - redBright），每行 color/bgCard。
命名：FriendProfileScreen / StatCard / RecentResultRow。转成 Flutter 好友信息/战绩页。
```

---

## 第 8 屏 · 私聊（ChatScreen · 桌面 + 手机 9:16） ✅

```
设计"淮安80分"好友私聊页，偏暗黑风，桌面 + 手机双画板。
顶部：对方头像 + 昵称 + 在线状态。
消息区：自己右对齐（goldPrimary 暗金气泡）、对方左对齐（color/bgCard 深色气泡）；时间戳小字；底部输入框 + 发送按钮。
离线消息：顶部提示"对方离线，消息将在上线后送达"；未读红点。
命名：ChatScreen / MessageBubble / ChatInput。转成 Flutter 私聊。
```

---

## 第 9 屏 · 创建房间（CreateRoomDialog · 居中弹窗） ✅

```
设计"淮安80分"创建房间弹窗，偏暗黑风，桌面居中（color/bgPanel、radius/panel、暗金边）。
字段：房间名、私密开关（开启显示密码输入）、最低准入积分门槛、是否允许观战。
底部：取消 / 创建（暗金按钮、radius/button）。
校验：房间门槛 ≤ 当前大厅上限提示；积分不满足时 redAccent 提示。
命名：CreateRoomDialog / RoomSettingsForm。转成 Flutter 创建房间弹窗。
```

---

## 第 10 屏 · 图标集（Icon Set · 完整清单） ✅

```
设计"淮安80分"图标集，偏暗黑风：扁平线性 + 暗金描边（color/goldPrimary），24×24（附 16/32 变体），2px 线宽，圆头端点；禁用态用 textDisabled。
一、功能类：登录（用户/锁）、设置、搜索、加好友、邀请、聊天、关闭、返回、更多、刷新。
二、游戏类：座位、旁观（眼睛）、开牌（眼+牌）、关牌（眼斜杠）、倒计时（时钟）、托管（机器人）、级牌（皇冠+牌）、主花色（花色符号 ♠♥♦♣）、庄家（皇冠）、换庄（箭头交换）。
三、大厅类：普通（铜徽章）/高手（银徽章）/至尊（金徽章）、创建房间（加号房）、密码房（锁）、观战中（眼）。
四、状态类：在线（绿点）、离线（灰点）、等待中（沙漏）、托管中（机器人+环）、锁定（锁+警示）、胜利（奖杯）、失败（灰旗）。
五、卡牌类：红五高亮（红桃5+光晕）、级牌（金边牌）、主花色角标、牌背纹样、510k组合、抽筋（闪电抽取）、上天入地（光柱）、春天（双旗）、翻盘（反转箭头）、自然级（绿叶）。
命名：ic_login / ic_spectator / ic_trump / ic_open_hand / ic_closed_hand / ic_host / ic_level / ic_suit_heart 等。
全部描边引用 goldPrimary、禁用 textDisabled。转成 Flutter 图标资源。
```

---

## 第 11 屏 · 卡牌体系（两副 108 张含大小王） ⏳ TODO（计划 11 月设计）

```
设计"淮安80分"卡牌体系（两副标准扑克 108 张含大小王），偏暗黑风。
基础牌：牌面 cardFace 纸白，角标点数 + 中心花色（suitRed / suitBlack），桌面 62×88 / 手机 44×62、radius/card。
牌背：cardBack 深蓝 + 暗纹 + goldPrimary 暗金边徽章。
变体：
 - 级牌：当前级别全 goldPrimary 暗金边 + 顶部级牌徽章；
 - 红五（红桃5）：goldBright 金色高亮光晕；
 - 主花色：牌面角落主花色角标；
 - 大小王：暗金/暗银双王 + 装饰。
用组件变体（Variant）覆盖花色×点数，不逐张手画。
命名 CardVisual / CardBack / LevelCardHighlight / RedFiveHighlight / TrumpCorner。转成 Flutter 卡牌组件。
```

---

## 第 12 屏 · 原型交互（Prototype · 供 Flutter 交互实现） ⏳ TODO（计划 11 月设计）

```
在 Prototype 面板为关键界面建立交互流（连接 Frame 间跳转）：
一、登录流程：LoginScreen → (成功) LobbyScreen / (失败) 错误提示；Token 自动登录静默 → LobbyScreen。
二、注册流程：RegisterScreen → 注册成功 LobbyScreen。
三、大厅→房间：LobbyScreen 点房间卡 → GameTable；点"创建房间" → CreateRoomDialog → 确认 → GameTable。
四、牌桌交互：出牌选牌高亮；托管倒计时环；观战主视角切换（1~4）；开牌/关牌即时生效；结算面板滑入。
五、好友：FriendListScreen → 点项 → FriendProfileScreen；点聊天 → ChatScreen；邀请 → 跳转房间。
六、错误/加载：gRPC 错误映射 Toast（FAILED_PRECONDITION=阶段不符等）；AsyncValue 三态（loading 骨架 / error 重试 / data）。
输出：每个跳转给 trigger / 目标 Frame / 返回方式。转成 Flutter 路由与状态交互。
```

---

## 第 13 屏 · 动效（Animation · 供 Flutter AnimationController） ⏳ TODO（计划 11 月设计）

```
设计并描述以下动效（偏暗黑，金/红闪光克制不刺眼）：
- 发牌：4 张一组从桌面中心飞向各座位，150ms/张，轻微弧线。
- 定主/反主（暗扣）：级牌暗扣 + 反主换底牌暗金高亮反馈（暗反不亮牌面）。
- 扣底：庄家替换底牌动画。
- 出牌：落牌 + 轻微震屏；甩牌/510k 扩散暗金光效；主 510k 抽筋抽取光效。
- 抄底：底牌翻倍结算 + 分数飘字。
- 升级/换庄：级数徽章推进暗金光效；庄家皇冠转移。
- 特殊结算：自然级小光效 / 翻盘 redBright 红闪 / 春天 goldBright 金色盛典 / 上天入地光柱。
- 结算面板：滑入 + 数字滚动。
输出：每个动画给 trigger / duration / 元素 / 情绪。
```

---

## 第 14 屏 · 多平台自适应（iOS / Windows / Web） ⏳ TODO（计划 11 月设计）

```
确保以上所有设计在 iOS / Windows / Web 三端统一且自适应：
- Auto Layout 断点：手机 <600 竖版、平板 600~1024、桌面 >1024 横版。
- 牌桌：大屏四座位环 + 完整手牌扇形；小屏压缩手牌、折叠侧栏。
- 大厅：桌面网格、手机单列。
- 全部尺寸/间距/字号引用 Token。
- 端差异：Web/Windows hover、iOS 触控；桌面返回键 vs iOS 手势返回；游戏数据全走服务端、Web 无 dart:io。
输出：每屏三端自适应变体。
```

---

## 使用流程

1. 确认 Token 已导入（Collection `darkTokens`）。
2. 建 Frame：AppIcon(1024) / Login(1440×900) / Register / Lobby / GameTable / FriendList / FriendProfile / Chat / CreateRoomDialog。
3. 进度：第 1~10 屏 ✅ 已完成；第 11~14 屏 ⏳ TODO（计划 11 月继续：第 11 卡牌 → 第 12 原型 → 第 13 动效 → 第 14 三端自适应）。
4. 转码：Dev Mode / MCP 逐 Frame 转 Flutter，业务逻辑交给 Copilot（参考 `flutter-copilot-prompts.md` + `.github/copilot-instructions.md`）。

> 本清单为 Figma 设计输入，不含 Flutter 代码。生成的设计稿经 Dev Mode 转码为 Flutter 页面与交互。
