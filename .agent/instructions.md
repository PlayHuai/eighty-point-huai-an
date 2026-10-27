# 环境规则

1. Flutter SDK 通过本仓库的 Git 子模块 `./third-party/flutter` 提供。**禁止使用 Snap、apt 或 wget 下载 Flutter。**
2. 启动步骤：

   ```sh
   git submodule update --init --recursive
   export PATH="$PWD/third-party/flutter/bin:$PATH"
   export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
   export PUB_HOSTED_URL=https://pub.flutter-io.cn
   ```

3. 优先使用本地子模块中的 `flutter` 命令执行 `doctor`、`pub get` 和 `build`。
4. 不要修改 Flutter 子模块内部代码。如需升级 Flutter 版本，更新子模块指向的 commit 并提交主仓库。
