# Server deployment

This guide covers the provided Docker Compose deployment and a Linux `systemd`
deployment of the compiled server binary. The Compose setup installs MySQL 8.4
and Redis 7 in private containers with persistent named volumes. The native
`systemd` setup uses host-installed MySQL and Redis.

The current executable provides HTTP liveness and the MySQL migration command;
application RPC/WebSocket service wiring is not yet included, and the executable
does not currently connect to Redis. Do not treat a healthy process as proof that
game services are ready.

## First deployment

Requirements: Docker Engine with the Compose v2 plugin, and Bash.

```sh
./deploy/scripts/init.sh
```

On its first run, the script creates `deploy/.env` from the example and exits.
Replace both placeholder passwords with unique values, keep the file private,
and run the command again. The file is ignored by Git. The server health endpoint
is bound to `127.0.0.1` on port 8080 by default; set `HTTP_PORT` to change it.

The current server executable exposes `/healthz` for liveness; application
transports and service wiring are not yet part of this deployment scaffold.
Place a TLS reverse proxy in front of the loopback-bound endpoint when exposing
the host.

## Build and package a Linux binary

Build on Linux or cross-compile from a Go 1.25+ environment. Choose `GOARCH`
for the target host (`amd64` or `arm64`):

```sh
mkdir -p dist
cd server
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -trimpath -ldflags="-s -w" -o ../dist/server ./cmd/server
cd ..
cp deploy/scripts/install-systemd.sh deploy/scripts/uninstall-systemd.sh deploy/systemd.env.example dist/
tar -C dist -czf eighty-point-linux-amd64.tar.gz server install-systemd.sh uninstall-systemd.sh systemd.env.example
```

Transfer and unpack the archive on the target host. Copy `systemd.env.example`
to `server.env`, set the database connection values and a unique password, and
keep that file private:

```sh
cp systemd.env.example server.env
chmod 600 server.env
sudo ./install-systemd.sh ./server ./server.env
```

The installer installs the binary at `/opt/eighty-point/server`, copies the
environment file to `/etc/eighty-point/server.env`, and enables (but does not
start) the service. On service start, systemd applies the embedded MySQL
migrations before starting the HTTP process. The MySQL server and application
database must already be available:

```sh
sudo systemctl start eighty-point
sudo systemctl status eighty-point
sudo journalctl -u eighty-point -f
```

For an upgrade, build and transfer the new archive, back up the database, stop
the service, rerun the installer with the updated binary and current environment
file, then start the service; pending migrations run before the process starts:

```sh
sudo systemctl stop eighty-point
sudo ./install-systemd.sh ./server ./server.env
sudo systemctl start eighty-point
```

The installer does not overwrite the environment file's source, but refreshes
the installed copy from the path supplied. Keep it administrator-controlled and
do not use untrusted content. The HTTP listener defaults in the example to
loopback and should be exposed externally only through a TLS reverse proxy.

## Host MySQL and Redis (systemd deployment)

On Ubuntu (or another distribution with a MySQL 8.x package), install the host
services and start them at boot:

```sh
sudo apt update
sudo apt install mysql-server redis-server
sudo systemctl enable --now mysql redis-server
```

Keep Redis bound to localhost with protected mode enabled; enable AOF persistence
in `/etc/redis/redis.conf`:

```conf
bind 127.0.0.1 ::1
protected-mode yes
appendonly yes
```

Then apply the configuration with `sudo systemctl restart redis-server`. Create
the application database and least-privilege account in MySQL. Use the same
unique password in `server.env`. On Ubuntu's default local root
authentication, open a privileged MySQL console and run the SQL statements:

```sh
sudo mysql
```

```sql
CREATE DATABASE eighty_point CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'eighty_point'@'127.0.0.1' IDENTIFIED BY 'replace-with-a-unique-secret';
GRANT ALL PRIVILEGES ON eighty_point.* TO 'eighty_point'@'127.0.0.1';
```

Save these values in `server.env` as `DB_HOST=127.0.0.1`, `DB_PORT=3306`,
`DB_NAME=eighty_point`, `DB_USER=eighty_point`, and `DB_PASSWORD=...`. The
`migrate` command creates/updates the schema. Back up and restore host MySQL
with a protected dump file:

```sh
set -o pipefail
umask 077
backup="mysql-$(date -u +%Y%m%dT%H%M%SZ)-$$.sql.gz"
tmp="$backup.tmp"
trap 'rm -f "$tmp"' EXIT
sudo mysqldump --single-transaction --routines --triggers --add-drop-table eighty_point | gzip > "$tmp"
gzip -t "$tmp"
mv "$tmp" "$backup"
trap - EXIT
# Restore is destructive: verify the file and target database before running.
set -o pipefail
gzip -cd "$backup" | sudo mysql eighty_point
```

Keep backups off-host and test restores. Redis currently holds no server runtime
state in this executable; if it is later wired into runtime services, back up
its `/var/lib/redis` data according to the chosen recovery point.

## Upgrade

```sh
./deploy/scripts/upgrade.sh
```

The script waits for the data services, creates a compressed MySQL backup,
stops the old server, builds the new image, applies pending migrations, and
starts the new server. Migration checksums are validated and applied versions
are not rerun. If migration fails, the server remains stopped; restore a backup
before restarting if recovery is needed.

## Backup and restore

Create a consistent compressed MySQL backup:

```sh
./deploy/scripts/backup.sh
```

Backups are written with private file permissions under `deploy/backups/` by
default; an optional first argument selects another output directory. Protect
and copy backups off-host according to the deployment's retention policy.

Restore is destructive and requires an explicit confirmation argument. Ensure
the Compose MySQL service is running, then run:

```sh
./deploy/scripts/restore.sh deploy/backups/mysql-YYYYMMDDTHHMMSSZ.sql.gz --confirm
```

The dump includes table drops so the restored database replaces existing table
contents. Test restores before relying on backups for recovery.

## Uninstall

For the Compose deployment, stop and remove containers while retaining database
volumes:

```sh
docker compose --env-file deploy/.env -f deploy/compose.yaml down
```

To erase the MySQL and Redis data volumes too, add `-v`; this cannot be undone.
For a `systemd` deployment, run the packaged uninstaller:

```sh
sudo ./uninstall-systemd.sh
```

It stops and disables the service and removes the unit and binary, but preserves
`/etc/eighty-point/server.env`, the MySQL/Redis data, and the `eighty-point`
system account. If decommissioning the host, remove the retained config and
account separately:

```sh
sudo rm -rf /etc/eighty-point
sudo userdel eighty-point
```

Host MySQL/Redis packages and their data are left intact; remove them only after
backing up or intentionally deleting their data.

The health checks independently verify MySQL, Redis, and the server's HTTP
liveness endpoint. They do not establish that application RPCs or game
operations are ready.
