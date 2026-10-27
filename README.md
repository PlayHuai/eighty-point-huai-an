# eighty-point-huai-an
淮安80分新版本

## 文档

- [功能需求](docs/design.md)
- [技术架构设计](docs/architecture.md)
- [业务规则](docs/淮安80分业务规则.md)
- [项目任务清单](docs/tasks.md)

## Flutter SDK

Flutter SDK 以 Git 子模块固定在当前 stable 版本（3.47.8），不依赖 Snap 安装。

```sh
git submodule update --init third-party/flutter
third-party/flutter/bin/flutter --version
```

更新到 Flutter stable 分支的最新提交后，将子模块指针提交到本仓库：

```sh
git submodule update --remote third-party/flutter
git add .gitmodules third-party/flutter
```
