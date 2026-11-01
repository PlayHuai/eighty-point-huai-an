# eighty-point-huai-an
淮安80分新版本

## 文档

- [功能需求](docs/design.md)
- [技术架构设计](docs/architecture.md)
- [业务规则](docs/淮安80分业务规则.md)
- [项目任务清单](docs/tasks.md)
- [微信小程序](README-miniprogram.md)

## Flutter SDK

本地开发及 Windows GitHub Actions 使用预先安装的 Flutter stable 3.47.8。Windows 工作流要求使用已安装 Flutter 的 self-hosted runner；GitHub 托管的 `windows-latest` runner 不提供本项目所需的 Flutter SDK。

```sh
flutter --version
```

本地开发请安装 Flutter 3.47.8，并将 Flutter SDK 的 `bin` 目录加入 `PATH`。

客户端使用该 Flutter 版本自带的 Dart 3.13.7。`client/pubspec.lock` 随应用提交，安装时使用 `flutter pub get --enforce-lockfile`，避免本地与 CI 解析出不同依赖。不要使用 `dependency_overrides` 强行替换 analyzer 或 protobuf。

在仓库根目录执行以下 PowerShell 命令（需要已安装 `buf`，且 Pub 全局可执行目录已加入 `PATH`）：

```powershell
dart pub global activate protoc_plugin 25.1.0
Push-Location api
buf generate --template buf.gen.dart.yaml --include-imports
Pop-Location
Push-Location client
flutter pub get --enforce-lockfile
dart run build_runner build
flutter analyze
flutter test
Pop-Location
```

`protoc_plugin 25.1.0` 与 protobuf 6 配套，`--include-imports` 同时生成 `Any`、`Timestamp` 等标准类型。Riverpod 运行时、注解和生成器需配套升级；当前生成器仍依赖 build 4，因此 build_runner 限制在 2.17 之前。升级依赖后应重新生成代码、运行分析和测试，并一并提交更新后的锁文件。

## Windows 客户端打包

本地 Windows 打包需要 Flutter 3.47.8、启用 Windows Developer Mode，并安装带有“使用 C++ 的桌面开发”工作负载的 Visual Studio。先按上文生成 Dart API bindings，再从仓库根目录用 PowerShell 执行：

```powershell
$env:API_ENDPOINT = "https://localhost:8443"
$env:WEBSOCKET_ENDPOINT = ""

Push-Location client
try {
  flutter pub get --enforce-lockfile
  if ($LASTEXITCODE -ne 0) { throw "flutter pub get failed" }
  dart run build_runner build
  if ($LASTEXITCODE -ne 0) { throw "Riverpod code generation failed" }
  flutter build windows --release `
    "--dart-define=API_ENDPOINT=$env:API_ENDPOINT" `
    "--dart-define=WEBSOCKET_ENDPOINT=$env:WEBSOCKET_ENDPOINT"
  if ($LASTEXITCODE -ne 0) { throw "Windows release build failed" }
} finally {
  Pop-Location
}
```

将 `API_ENDPOINT` 和 `WEBSOCKET_ENDPOINT` 替换为部署环境的 HTTPS / WSS 地址；同一 TLS 网关同时提供 API 与 `/events` 时，可留空 `WEBSOCKET_ENDPOINT`。Windows release 文件生成在 `client/build/windows/x64/runner/Release/`。
