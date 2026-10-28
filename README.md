# eighty-point-huai-an
淮安80分新版本

## 文档

- [功能需求](docs/design.md)
- [技术架构设计](docs/architecture.md)
- [业务规则](docs/淮安80分业务规则.md)
- [项目任务清单](docs/tasks.md)

## Flutter SDK

本地开发及 Windows GitHub Actions 使用预先安装的 Flutter stable 3.47.8。Windows 工作流要求使用已安装 Flutter 的 self-hosted runner；GitHub 托管的 `windows-latest` runner 不提供本项目所需的 Flutter SDK。

```sh
flutter --version
```

本地开发请安装 Flutter 3.47.8，并将 Flutter SDK 的 `bin` 目录加入 `PATH`。
