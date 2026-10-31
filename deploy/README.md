# 服务端部署指南

本文介绍两种部署方式：使用 Docker Compose 部署服务，或将编译后的服务端程序安装为 Linux `systemd` 服务。Compose 方式使用独立容器运行 MySQL 8.4 和 Redis 7，并通过持久化卷保存数据；`systemd` 方式使用主机上安装的 MySQL 和 Redis。

服务端通过独立 TCP 端口提供 gRPC（默认 `8081`）和带令牌认证的 WebSocket（HTTP `/events`），并保留 `/healthz` 存活检查。数据库迁移仍由独立 `migrate` 服务执行；运行时连接 MySQL。Redis 当前尚未接入。

## 首次部署（Docker Compose）

需要安装 Docker Engine、Docker Compose v2 插件和 Bash。

```sh
./deploy/scripts/init.sh
```

首次运行会从示例文件创建 `deploy/.env`，并退出。请将两个数据库密码占位值替换为不同的强密码，妥善保护该文件后再次运行命令。该文件已加入 Git 忽略规则。HTTP 和 gRPC 默认只绑定到主机本地地址 `127.0.0.1:8080` 和 `127.0.0.1:8081`；可分别通过 `HTTP_PORT`、`GRPC_PORT` 修改端口。绑定地址也可分别通过 `HTTP_BIND_ADDRESS`、`GRPC_BIND_ADDRESS` 显式覆盖；仅在需要从其他主机访问且已配置防火墙/私有网络保护时，才设置为可对外访问的地址。原始 HTTP 和 gRPC 监听器不启用 TLS，不应直接暴露到公网。部署 Web 客户端时，将其确切 Origin 加入 `WEBSOCKET_ALLOWED_ORIGINS`，并由 TLS 反向代理转发 WebSocket `/events` 和 gRPC。

`/healthz` 只表示进程存活，不代表数据库依赖已就绪。对外访问必须经 TLS 反向代理，并按部署域名配置允许的 WebSocket Origin。

## 编译并打包 Linux 可执行文件

可在 Linux 上编译，也可使用 Go 1.25 或更高版本进行交叉编译。根据目标主机选择 `GOARCH`（`amd64` 或 `arm64`）：

```sh
mkdir -p dist
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 bash deploy/scripts/build-server.sh
cp deploy/scripts/install-systemd.sh deploy/scripts/uninstall-systemd.sh deploy/systemd.env.example dist/
tar -C dist -czf eighty-point-linux-amd64.tar.gz server install-systemd.sh uninstall-systemd.sh systemd.env.example
```

### 版本信息与反馈

发布前手动编辑仓库根目录的 `VERSION`（例如 `1.0.0`）和 `CHANGELOG.md`（UTF-8 更新记录）。
`build-server.sh` 从本地仓库读取完整的 `git rev-parse HEAD`、版本号和更新记录，通过 Go linker flags
固化进程序；运行时不需要 Git 或这些文件。直接 `go build` 仅生成 `development` 版本。
未提交的修改不改变 commit ID；正式发布应从已提交的源码打包。

Docker Compose 的 `init.sh`、`upgrade.sh` 与 GitHub Server package 工作流使用同一个
`build-info.sh` 固化信息。手动构建镜像时先 `source deploy/scripts/build-info.sh`，再传入
`--build-arg SERVER_COMMIT --build-arg SERVER_VERSION --build-arg SERVER_CHANGELIST`。
缺少构建信息时 Docker 构建会失败，避免发布信息不完整的镜像。
这些脚本需要 Bash、Git 和 `base64`（原生编译另需 Go）。

登录后的 Flutter 大厅通过 `SupportService/GetServerInfo` 获取上述信息。
`SupportService/SubmitFeedback` 接收 Bug 或建议，内容为 1–2000 字，保存到 MySQL `feedback` 表，
包含认证用户、类型、内容、提交时间。迁移 `0008_feedback.sql` 随已有迁移流程执行。
同一用户重试时复用 UUID `request_id`，相同内容不重复写入，不同内容返回 `ALREADY_EXISTS`。
反馈是新建记录，不修改带版本的游戏或房间状态，因此不使用 `expected_version`。
本次不提供反馈管理后台，可由运维通过数据库查询处理。

将压缩包传到目标主机并解压。将 `systemd.env.example` 复制为 `server.env`，填写数据库连接信息和唯一强密码，并限制文件访问权限：

```sh
cp systemd.env.example server.env
chmod 600 server.env
sudo ./install-systemd.sh ./server ./server.env
```

安装脚本会将程序安装到 `/opt/eighty-point/server`，将环境配置复制到 `/etc/eighty-point/server.env`，并启用服务（但不会立即启动）。服务启动时，systemd 会先运行内置的 MySQL 迁移，再启动 HTTP 进程。请确保 MySQL 和应用数据库已可用：

```sh
sudo systemctl start eighty-point
sudo systemctl status eighty-point
sudo journalctl -u eighty-point -f
```

### 升级 systemd 部署

编译并传输新版本前，请先备份数据库。然后停止服务、用新程序重新运行安装脚本，再启动服务。待执行的数据库迁移会在服务进程启动前运行：

```sh
sudo systemctl stop eighty-point
sudo ./install-systemd.sh ./server ./server.env
sudo systemctl start eighty-point
```

安装脚本不会修改作为源文件的环境配置，但会用指定路径的文件更新系统中安装的副本。请只使用管理员可信任的配置文件。示例配置将 HTTP 监听地址设为本地回环地址；如需对外提供访问，请使用 TLS 反向代理。

## 主机安装 MySQL 和 Redis（systemd 部署）

在 Ubuntu（或提供 MySQL 8.x 软件包的其他发行版）上安装服务并设置为开机启动：

```sh
sudo apt update
sudo apt install mysql-server redis-server
sudo systemctl enable --now mysql redis-server
```

确保 Redis 仅监听本机地址并启用保护模式；在 `/etc/redis/redis.conf` 中启用 AOF 持久化：

```conf
bind 127.0.0.1 ::1
protected-mode yes
appendonly yes
```

修改后执行 `sudo systemctl restart redis-server`。接下来在 MySQL 中创建应用数据库和权限受限的应用账号。请使用唯一强密码，并将同一密码配置到 `server.env`。Ubuntu 默认使用本地 root 身份认证，可通过以下命令进入 MySQL 管理控制台：

```sh
sudo mysql
```

在 MySQL 控制台中执行：

```sql
CREATE DATABASE eighty_point CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'eighty_point'@'127.0.0.1' IDENTIFIED BY 'replace-with-a-unique-secret';
GRANT ALL PRIVILEGES ON eighty_point.* TO 'eighty_point'@'127.0.0.1';
```

在 `server.env` 中设置 `DB_HOST=127.0.0.1`、`DB_PORT=3306`、`DB_NAME=eighty_point`、`DB_USER=eighty_point` 和 `DB_PASSWORD=...`。服务启动时会通过 `migrate` 命令创建或更新数据库结构。

### 主机 MySQL 备份与恢复

以下示例会生成权限受限的压缩备份，并在压缩校验通过后再写入最终文件：

```sh
set -euo pipefail
umask 077
backup="mysql-$(date -u +%Y%m%dT%H%M%SZ)-$$.sql.gz"
tmp="$backup.tmp"
trap 'rm -f "$tmp"' EXIT
sudo mysqldump --single-transaction --routines --triggers --add-drop-table eighty_point | gzip > "$tmp"
gzip -t "$tmp"
mv "$tmp" "$backup"
trap - EXIT
# 恢复会覆盖数据库中的表；执行前请确认备份文件和目标数据库。
set -euo pipefail
gzip -t "$backup"
gzip -cd "$backup" | sudo mysql eighty_point
```

请将备份复制到异机保存，并定期验证恢复流程。目前 Redis 未保存该服务端程序的运行状态；若后续接入 Redis，应根据恢复目标备份其 `/var/lib/redis` 数据。

## Compose 升级

```sh
./deploy/scripts/upgrade.sh
```

脚本会等待数据库和 Redis 就绪、创建压缩的 MySQL 备份、停止旧服务、构建新镜像、应用待执行的数据库迁移，然后启动新服务。迁移版本及校验和会被检查，已应用的迁移不会重复执行。若迁移失败，服务将保持停止；如需恢复，请先恢复备份再启动服务。

## Compose 备份与恢复

创建一致性压缩 MySQL 备份：

```sh
./deploy/scripts/backup.sh
```

默认备份到 `deploy/backups/`，文件权限仅允许当前用户访问；也可将输出目录作为第一个参数传入。请根据部署环境的保留策略保护备份并复制到异机保存。

恢复会覆盖现有数据库，必须通过 `--confirm` 明确确认。请先确保 Compose 中的 MySQL 服务正在运行，再执行：

```sh
./deploy/scripts/restore.sh deploy/backups/mysql-YYYYMMDDTHHMMSSZ.sql.gz --confirm
```

备份包含删除表的语句，因此恢复后原有表内容会被替换。正式依赖备份前，请先在测试环境验证恢复流程。

## 卸载

卸载 Compose 服务并保留数据库数据卷：

```sh
docker compose --env-file deploy/.env -f deploy/compose.yaml down
```

如需同时删除 MySQL 和 Redis 数据卷，在命令末尾添加 `-v`。此操作不可撤销。

卸载 `systemd` 服务时运行随包提供的脚本：

```sh
sudo ./uninstall-systemd.sh
```

脚本会停止并禁用服务，删除 unit 文件和服务端程序，但保留 `/etc/eighty-point/server.env`、MySQL/Redis 数据及 `eighty-point` 系统账号。若要彻底回收主机，再单独移除保留的配置和账号：

```sh
sudo rm -rf /etc/eighty-point
sudo userdel eighty-point
```

主机上的 MySQL/Redis 软件包及其数据不会被卸载脚本删除；请先备份，只有在明确要删除数据时再单独卸载。

健康检查分别确认 MySQL、Redis 和 HTTP 存活端点可用；它们不能证明 RPC、游戏操作等业务已经就绪。
