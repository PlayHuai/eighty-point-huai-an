# 环境规则

1. 本地开发及 Windows GitHub Actions runner 预装 Flutter stable 3.47.8，并将 SDK 的 `bin` 目录加入 `PATH`。Windows 工作流使用已配置 Flutter 的 self-hosted runner。
2. 检查本地 Flutter 环境：

   ```sh
   flutter --version
   ```

3. 使用已安装的 `flutter` 命令执行 `doctor`、`pub get`、`analyze`、`test` 和 `build`。
4. 升级 Flutter 版本时，同步更新此文件、README、`client/pubspec.yaml` 及 Windows 工作流中的版本检查。
