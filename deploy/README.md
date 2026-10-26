# Server deployment

This package runs the server image, MySQL 8.4, and Redis with Docker Compose.
MySQL and Redis are private to the Compose network and use named data volumes.
The MySQL schema is managed by the server's embedded, checksummed migrations;
the migration job is run explicitly before the server starts or is upgraded.

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

The health checks independently verify MySQL, Redis, and the server's HTTP
liveness endpoint. They do not establish that application RPCs or game
operations are ready.
