# 环境规则

1. Flutter SDK 不再作为仓库子模块。GitHub Actions 使用 `subosito/flutter-action`，固定 Flutter stable 3.47.8，并缓存 SDK 与 Pub 依赖。
2. 本地开发使用 Flutter 官方安装说明安装 3.47.8，并将 SDK 的 `bin` 目录加入 `PATH`：

   ```sh
   flutter --version
   ```

3. 使用已安装的 `flutter` 命令执行 `doctor`、`pub get` 和 `build`。
4. 升级 Flutter 版本时，同步更新此文件、README、`client/pubspec.yaml` 及 GitHub Actions 工作流中的版本。
