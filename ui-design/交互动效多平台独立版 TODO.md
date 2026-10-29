# 淮安80分 · Figma 交互/动效/多平台（第 12~14 屏 · 独立版）

> 来源：`figma-prompts-80-dark.md`（淮安80分Figma暗黑风完整Prompts）第 12~14 屏，单独抽出的后续流程文档。
> 说明：这三屏**不是"创建 Frame"的 prompts**，分别是——第 12 屏【连线交互】、第 13 屏【动效描述】、第 14 屏【多平台适配】。
> 前置：需要第 1~11 屏的 Frame 已生成（尤其 Login / Register / Lobby / GameTable / FriendList / FriendProfile / Chat / CreateRoomDialog）。
> 状态：⏳ TODO（计划 11 月设计，供后续流程使用）。

---

## 第 12 屏 · 原型交互（Prototype · 供 Flutter 交互实现） ⏳ TODO（计划 11 月设计）

> 类型：**连线交互**，在已有 Frame 之间画连接线（Prototype 面板），**不新建 Frame**。

```
在 Prototype 面板为关键界面建立交互流（连接 Frame 间跳转）：
一、登录流程：Login → (成功) Lobby / (失败) 错误提示；Token 自动登录静默 → Lobby。
二、注册流程：Register → 注册成功 Lobby。
三、大厅→房间：Lobby 点房间卡 → GameTable；点"创建房间" → CreateRoomDialog → 确认 → GameTable。
四、牌桌交互：出牌选牌高亮；托管倒计时环；观战主视角切换（1~4）；开牌/关牌即时生效；结算面板滑入。
五、好友：FriendList → 点项 → FriendProfile；点聊天 → Chat；邀请 → 跳转房间。
六、错误/加载：gRPC 错误映射 Toast（FAILED_PRECONDITION=阶段不符等）；AsyncValue 三态（loading 骨架 / error 重试 / data）。
输出：每个跳转给 trigger / 目标 Frame / 返回方式。转成 Flutter 路由与状态交互。
```

---

## 第 13 屏 · 动效（Animation · 供 Flutter AnimationController） ⏳ TODO（计划 11 月设计）

> 类型：**文字描述**动效清单，Figma 内基本不需要操作，直接**交给 Flutter 端实现**（AnimationController）。

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

> 类型：**适配调整**，回头微调已有 Frame 的断点/布局，**不新建全新 Frame**。

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

