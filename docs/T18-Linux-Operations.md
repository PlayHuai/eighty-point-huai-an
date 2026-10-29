# T18 Linux 部署与运维手册

本手册适用于仓库当前的单机 Docker Compose 部署。命令从仓库根目录执行。该 Compose 当前只监听 `127.0.0.1`，不会提供 TLS 终止或公网入口；接入经批准的 TLS 反向代理前不得开放服务端口。当前 `serve` 仍是服务端骨架，`/healthz` 只表示 HTTP 进程可响应，不代表 MySQL、Redis、游戏 API 或完整业务已就绪。

## 生产启用门槛

开始生产演练前，负责人必须书面确认目标在线人数、备份频率、RPO、RTO、告警接收渠道及维护窗口，并确认恢复目标能由单机拓扑满足。架构文档没有给出这些数值，本手册不代替产品/运维确认，也不承诺单机高可用。

前置任务状态：

- T01 已完成；但生产容量、备份频率和 RPO/RTO 数值仍待确认。
- T15 为“待验证”：Compose、初始化、迁移、健康检查及备份恢复需要由负责人验收。
- T17 为“TODO”：服务端安全/并发/集成验证及客户端三端兼容验证尚未完成。

在 T15、T17 和上述生产决策完成前，只能执行隔离的预生产演练，不得将演练记录描述为生产发布验收。

## 首次 Linux 部署

1. 准备受支持的 Linux 主机、Docker Engine、Docker Compose V2 和受限的运维账号。按已批准的网络策略设置主机防火墙；数据库和 Redis 端口不得从主机外部访问。
2. 获取经过审查的发布版本/源码，在仓库根目录执行：

   ```sh
   ./deploy/scripts/init.sh
   ```

   首次运行会创建 `deploy/.env` 并退出。使用密码管理器为 `DB_PASSWORD` 和 `DB_ROOT_PASSWORD` 分别设置不同的强随机值，不保留 `replace-with-` 占位值；限制文件权限：

   ```sh
   chmod 600 deploy/.env
   ```

   不要将 `.env`、备份或凭据提交到版本库。确认后再次运行 `init.sh`。
3. 确认容器状态和应用健康检查：

   ```sh
   docker compose --env-file deploy/.env -f deploy/compose.yaml ps
   docker compose --env-file deploy/.env -f deploy/compose.yaml exec server /server healthcheck
   curl --fail --silent --show-error http://127.0.0.1:8080/healthz
   ```

   `/healthz` 返回 HTTP 204。检查迁移容器退出状态及服务日志；不得把该检查当作依赖就绪或游戏功能验收。
4. 按已批准的边界部署 TLS 反向代理和证书；只允许该入口接收外部流量。现有 `deploy/compose.yaml` 不含 Envoy、证书管理或公网配置，不能直接承担公网服务。
5. 依照已确认的 RPO 配置加密、异机备份和保留策略。初次上线前必须在隔离环境恢复一次备份，验证数据库可读和服务可启动；不得只以备份命令成功作为可恢复证明。

若选择 systemd 而非 Compose，先按 `deploy/scripts/install-systemd.sh` 的参数要求配置独立环境文件及 MySQL，再执行安装；此路径不提供 Compose 中的 Redis 等依赖管理，需单独设计并验收。

## 监控与告警

`deploy/monitoring/prometheus.yml` 和 `alerts.yml` 提供 Prometheus 的基础 HTTP 可用性探测与告警规则。该配置通过 Blackbox Exporter 的 `http_2xx` 模块探测 `/healthz`（健康时返回 HTTP 204），因此须在 Prometheus 同一主机安装并运行 Blackbox Exporter，且其默认地址为 `127.0.0.1:9115`。配置假设 Prometheus 与服务端运行在同一 Linux 主机，因此探测目标为默认映射端口 `127.0.0.1:8080`；若 `HTTP_PORT` 使用其他值，须同步修改目标。若由集中式 Prometheus 抓取，须通过受控网络/代理改成可达的内部地址，不能为监控而将应用端口暴露到公网。

将这两个配置载入主机上的 Prometheus，并将 Alertmanager 配置到已确认的值班通知渠道（配置文件内目标为本机 `127.0.0.1:9093`）。告警依据 `probe_success` 判断 HTTP 探测结果；Prometheus 的 `up` 用于发现 Blackbox Exporter 抓取失败，`probe_duration_seconds` 用于判断探测耗时。启用前验证规则已加载、测试告警确实送达值班渠道，并记录责任人及升级路径。当前规则仅覆盖健康端点失败、探测目标丢失和探测耗时；目前没有可抓取的 Prometheus 应用指标端点，因而不覆盖架构要求的游戏、数据库连接池、Redis、结算或 WebSocket 指标。不能据此推断业务健康。

规则中的 1 分钟和 2 秒是基础故障探测值，不是已批准的业务 SLO；生产启用前须结合确认后的容量和告警策略复核。

故障初查：

```sh
docker compose --env-file deploy/.env -f deploy/compose.yaml ps
docker compose --env-file deploy/.env -f deploy/compose.yaml logs --since=15m server mysql redis
df -h
free -h
```

先确认告警是否为应用/主机故障或监控配置故障；保留相关时间范围内的日志和容器状态，避免记录、转发密码、Token 或未授权牌面。若数据库故障或数据完整性不确定，停止写流量并升级给值班负责人，不要直接反复重启或覆盖数据。

## 版本升级

1. 确认发布版本、数据库迁移说明、变更兼容性、维护窗口、回滚责任人和最近一次可恢复备份。迁移必须兼容回滚版本，或明确演练数据库恢复步骤。
2. 记录当前镜像并为回滚保留不可变本地标签（以发布版本或提交 SHA 命名），确认磁盘空间充足：

   ```sh
   docker image inspect eighty-point-huai-an/server:local
   docker image tag eighty-point-huai-an/server:local eighty-point-huai-an/server:rollback-<旧版本>
   ```

3. 获取目标发布版本的源码，并核对其发布标签/提交与已批准版本一致；核对该版本的数据库迁移文件及迁移兼容性说明。`upgrade.sh` 不会下载或切换源码，只会构建当前工作区，因此必须在目标版本的源码工作区执行。保留现有 `deploy/.env` 和 `deploy/backups/`，不得用目标源码覆盖或删除环境文件及备份。
4. 将入口置于维护状态，确认没有新的写请求；从目标版本工作区的仓库根目录运行：

   ```sh
   ./deploy/scripts/upgrade.sh
   ```

   脚本会先备份 MySQL，再构建服务端/迁移镜像、停止服务、运行迁移并等待新服务健康。若任一步失败，保持维护状态并执行下方回滚，不要继续接收写流量。
5. 检查 `docker compose ... ps`、`server healthcheck`、迁移日志和监控告警；在业务 API 可用后按发布验收清单做登录、房间、牌局恢复及结算的端到端检查。当前骨架没有这些已接通的运行时接口，不能在本仓库状态下通过这些业务验收。

## 回滚

回滚可能丢失备份之后产生的数据。仅由授权负责人决定并记录影响；先停止外部写流量并保全故障现场。将 `<旧版本>` 替换为升级前保存的标签：

```sh
docker compose --env-file deploy/.env -f deploy/compose.yaml stop server
docker image tag eighty-point-huai-an/server:rollback-<旧版本> eighty-point-huai-an/server:local
```

若已执行的迁移确认向后兼容，可按兼容性说明恢复旧应用后验证；否则必须将升级前备份恢复到**隔离/已停止写入**的目标数据库。`restore.sh` 会替换目标数据库数据，执行前再次核对目标主机和备份文件：

```sh
./deploy/scripts/restore.sh <升级前备份.sql.gz> --confirm
docker compose --env-file deploy/.env -f deploy/compose.yaml up -d --wait server
docker compose --env-file deploy/.env -f deploy/compose.yaml exec server /server healthcheck
```

验证数据时间点、服务日志、告警和客户端访问后，由负责人决定恢复流量。若恢复失败，继续保持维护状态并升级处置；不要删除卷或备份。每次回滚均记录版本、迁移、备份文件校验结果、影响范围及恢复时间。

## 发布演练与记录

在与生产隔离、但配置等同的 Linux 环境中，用经过审查的发布版本完成首次部署、备份恢复、升级、升级中断后的回滚、服务健康告警送达及恢复验证。不得在生产库上制造故障或演练破坏性恢复。记录主机/版本、变更与迁移、演练人和时间、备份校验、告警收件确认、每个步骤结果、恢复耗时、数据损失窗口及问题整改。

本任务已在临时隔离的 Docker Compose 环境执行初始化、迁移、健康检查、MySQL 备份及 gzip 校验、升级、备份恢复、恢复旧镜像标签和重启健康检查；命令成功，测试卷及临时镜像标签已清理。该演练未验证生产主机、外部告警送达、TLS 入口或业务 API，不替代正式预生产/生产验收。

演练通过后仍需负责人确认 T15/T17 验收、生产容量、备份频率、RPO/RTO、通知渠道、TLS/公网边界和回滚决策，才能安排生产发布。本代码任务未执行真实生产演练，也未验证外部通知渠道。
