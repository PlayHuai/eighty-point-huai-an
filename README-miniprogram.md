# 淮安80分微信小程序

原生微信小程序客户端位于 `miniprogram/`，采用 TypeScript、WXML 和 WXSS，仅注册 Lobby 与 GameTable 页面。

## 本地打开

1. 安装 Node.js 22 或更新版本及 npm，然后运行 `cd miniprogram && npm ci && npm run typecheck && npm test`。
2. 在微信开发者工具中导入仓库根目录（即 `project.config.json` 所在目录）。
3. 在小程序后台申请 AppID，并将 `project.config.json` 和 `miniprogram/config/env.ts` 中的 `YOUR_WECHAT_APP_ID` 换为实际 AppID。
4. 将 `miniprogram/config/env.ts` 的开发/生产 API 和 WSS 地址改为已部署的 HTTPS/WSS 服务。
5. 在微信公众平台的 request 合法域名中配置 HTTPS API 域名，在 socket 合法域名中配置 WSS 域名；真机预览不能依赖开发者工具的本地服务跳过域名校验。
6. 开发者工具的「工具 → 构建 npm」用于存在小程序运行时依赖时生成 `miniprogram_npm/`；当前运行时代码没有额外 npm 依赖。

`/api/auth/wx-login`、默认房/分享进房 REST 服务和牌局动作/快照 API 尚未由当前 Go 服务提供；接通这些服务前，界面会明确报告不可用，不会使用假牌局或客户端计算的结果。当前服务端 WebSocket 只提供已接线的通知事件，不是牌局动作通道。
