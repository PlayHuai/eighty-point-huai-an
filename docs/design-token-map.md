# Flutter Token → WXSS 对照

`miniprogram/styles/tokens.wxss` 按 `ui-design/DarkTokens.json` / `client/lib/src/ui/theme/app_theme.dart` 的值定义暗色默认主题。尺寸采用 375px 设计基准，Flutter 逻辑像素乘 2 后写为 WXSS 的 `rpx`。

| Flutter Token | WXSS 变量 | 值 |
|---|---|---|
| `bgBase` | `--color-bg-base` | `#0a0e14` |
| `bgPanel` | `--color-bg-panel` | `#131a24` |
| `bgCard` | `--color-bg-card` | `#1c2530` |
| `goldPrimary` | `--color-gold-primary` | `#c9a24b` |
| `goldBright` | `--color-gold-bright` | `#e6c56a` |
| `goldDark` | `--color-gold-dark` | `#8a6a2f` |
| `redAccent` | `--color-red-accent` | `#8b1a2b` |
| `redBright` | `--color-red-bright` | `#b3273d` |
| `cardFace` | `--color-card-face` | `#f5efe0` |
| `cardBack` | `--color-card-back` | `#22303e` |
| `textPrimary` | `--color-text-primary` | `#ede8dc` |
| `textSecondary` | `--color-text-secondary` | `#9a927f` |
| `textDisabled` | `--color-text-disabled` | `#5a5748` |
| `suitRed` | `--color-suit-red` | `#c0392b` |
| `suitBlack` | `--color-suit-black` | `#1c1c1c` |
| `infoBlue` | `--color-info-blue` | `#4a7ba6` |
| `fontSizeL1`–`fontSizeL6` | `--font-size-l1`–`--font-size-l6` | `80rpx`–`24rpx` |
| `radiusCard`, `radiusButton`, `radiusPanel`, `radiusBadge` | `--radius-card`, `--radius-button`, `--radius-panel`, `--radius-badge` | `16rpx`, `16rpx`, `24rpx`, `1998rpx` |
| `spacingS1`–`spacingS6` | `--spacing-s1`–`--spacing-s6` | `8rpx`–`64rpx` |

GameTable 的牌面、动画和完整牌桌状态仍需等服务端牌局快照/事件契约落地后实现。
