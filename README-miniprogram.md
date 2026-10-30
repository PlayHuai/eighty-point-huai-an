# 淮安80分微信小程序

原生微信小程序客户端位于 `miniprogram/`，采用 TypeScript、WXML 和 WXSS，仅注册 Lobby 与 GameTable 页面。

## 本地打开

1. 安装 Node.js 22 或更新版本及 npm，然后运行 `cd miniprogram && npm ci && npm run typecheck && npm test`。
2. 在微信开发者工具中导入仓库根目录（即 `project.config.json` 所在目录）。
3. 在小程序后台申请 AppID，并将 `project.config.json` 和 `miniprogram/config/env.ts` 中的 `YOUR_WECHAT_APP_ID` 换为实际 AppID。服务端部署环境设置 `WECHAT_APP_ID` 与 `WECHAT_APP_SECRET`。
4. 将 `miniprogram/config/env.ts` 的开发/生产 API 和 WSS 地址改为已部署的 HTTPS/WSS 服务。
5. 在微信公众平台的 request 合法域名中配置 HTTPS API 域名，在 socket 合法域名中配置 WSS 域名；真机预览不能依赖开发者工具的本地服务跳过域名校验。
6. 开发者工具的「工具 → 构建 npm」用于存在小程序运行时依赖时生成 `miniprogram_npm/`；当前运行时代码没有额外 npm 依赖。

小程序静默登录通过服务端微信 `code2session` 换取唯一 ID，不请求微信头像、昵称等额外权限。该账号只可看到和加入独立“娱乐厅”；普通客户端不会看到该厅。小程序 REST 接口支持列出、创建、加入及离开娱乐厅房间；牌桌收到房间成员变更通知后会刷新成员状态。

服务端没有游戏动作和完整牌局快照 API；当前 WebSocket 只提供已接线的通知事件，不是牌局动作通道。因此本版本提供娱乐房间入口与分享进房，完整实时牌局仍需后续服务端实现。
