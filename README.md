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

### 本地服务器部署与 Windows 免安装 ZIP 包

自测环境复用 [自动化部署脚本](test/windows/Deploy.ps1)，服务器为
`derek@192.168.117.129`，需预先配置 SSH 公钥登录。只更新
`/home/derek/auto_test` 的 `huai-auto-test` Compose 项目，保留原 MySQL／Redis
数据；会重建服务，正在进行的内存牌局会中断。该环境使用 `autotest` 构建，
仅限可信局域网自测，不得当作生产服务或暴露到公网。

在 Windows 上按前文准备 Flutter、生成代码及 Visual Studio C++ 工具；
无需 Inno Setup／ISCC 或其他安装包制作工具。从仓库根目录执行：

```powershell
# 1. 上传当前工作区代码，部署服务，并检查 HTTP 8080 / gRPC 8081。
.\test\windows\Deploy.ps1 `
  -ServerHost 192.168.117.129 `
  -OutputDirectory D:\huai_an_80\auto_test\manual_build

# 2. 编译普通客户端入口（不运行 integration_test），生成 Release 免安装 ZIP。
.\test\windows\Build-Package.ps1 `
  -ServerHost 192.168.117.129 `
  -OutputDirectory D:\huai_an_80\auto_test\manual_build
```

两条命令可分开运行；只重新打包无需重新部署。

脚本按根目录 `VERSION` 编译 x64 Release，并固定注入：

- `API_ENDPOINT=http://192.168.117.129:8081`
- `WEBSOCKET_ENDPOINT=ws://192.168.117.129:8080/events`

这是局域网明文连接，仅用于本地自测。换服务器须重新打包，不能靠修改安装后
的环境变量切换。输出位于
`manual_build\package-<版本>-<时间>-<标识>\`：

- `HuaiAn80-<版本>-windows-x64-local.zip`：完整客户端免安装压缩包。
- 同名 `.sha256`：ZIP 的 SHA256 校验值。
- `app\`：完整免安装客户端（含 Flutter 资源、插件和可再分发的 x64 MSVC 运行库）。
- `app\local-environment.json`：本次构建的版本、源码提交及注入地址，仅供核对，不是动态配置文件。

将 ZIP 完整解压到可写目录，运行其中 `app\eighty_point_huai_an.exe` 即可自测，
无需管理员权限。可手动创建快捷方式；退出后删除解压目录即可移除程序（不会主动清理用户日志或凭据）。
不要仅复制客户端 EXE，必须保留同目录 DLL 和 `data`。客户端未进行代码签名，
Windows 可能提示未知发布者；仅在确认来源和校验值后运行。
