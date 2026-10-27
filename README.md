# eighty-point-huai-an
淮安80分新版本

## 文档

- [功能需求](docs/design.md)
- [技术架构设计](docs/architecture.md)
- [业务规则](docs/淮安80分业务规则.md)
- [项目任务清单](docs/tasks.md)

## Flutter SDK

GitHub Actions 使用 `subosito/flutter-action` 安装 Flutter stable 3.47.8，并缓存 SDK 与 Pub 依赖。Flutter SDK 不再作为仓库子模块提交。

```sh
flutter --version
```

本地开发请按 Flutter 官方安装说明安装 Flutter 3.47.8，并将 Flutter SDK 的 `bin` 目录加入 `PATH`。
