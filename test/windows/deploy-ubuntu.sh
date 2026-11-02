#!/usr/bin/env bash
set -euo pipefail
cd /home/derek/auto_test
umask 077
if [[ ! -f deploy/.env ]]; then
  {
    printf 'DB_NAME=huai_auto_test\nDB_USER=huai_auto_test\n'
    printf 'DB_PASSWORD=%s\n' "$(openssl rand -hex 24)"
    printf 'DB_ROOT_PASSWORD=%s\n' "$(openssl rand -hex 24)"
  } > deploy/.env
fi
# Preserve database credentials between rounds; never remove persistent volumes.
sed -i '/^HTTP_BIND_ADDRESS=/d; /^GRPC_BIND_ADDRESS=/d; /^HTTP_PORT=/d; /^GRPC_PORT=/d' deploy/.env
printf 'HTTP_BIND_ADDRESS=0.0.0.0\nGRPC_BIND_ADDRESS=0.0.0.0\nHTTP_PORT=8080\nGRPC_PORT=8081\n' >> deploy/.env
if ! grep -q '^ENV GOPROXY=' server/Dockerfile; then
  sed -i '\|^WORKDIR /src$|a ENV GOPROXY=https://mirrors.aliyun.com/goproxy/,direct' server/Dockerfile
fi
cp test/windows/Dockerfile.autotest server/Dockerfile.autotest
# Local aliases pin the first successfully downloaded dependency images.
# Only this project's aliases are used; no global Docker settings are changed.
cache_image() {
  local source="$1" cached="$2"
  if ! docker image inspect "$cached" >/dev/null 2>&1; then
    if ! docker image inspect "$source" >/dev/null 2>&1; then
      docker pull "$source"
    fi
    docker tag "$source" "$cached"
  fi
  docker image inspect --format '{{.Id}}' "$cached"
}
cache_image mysql:8.4 huai-auto-test/mysql:cached
cache_image redis:7-alpine huai-auto-test/redis:cached
if ! docker image inspect golang:1.25-alpine >/dev/null 2>&1; then
  docker pull golang:1.25-alpine
fi
docker image inspect --format '{{.RepoTags}} {{.Id}}' \
  huai-auto-test/mysql:cached huai-auto-test/redis:cached golang:1.25-alpine \
  > test/windows/cached-images.txt
export SERVER_COMMIT
SERVER_COMMIT="$(cat test/windows/source-commit.txt)"
export SERVER_VERSION
SERVER_VERSION="$(tr -d '\r\n' < VERSION)"
export SERVER_CHANGELIST
SERVER_CHANGELIST="$(base64 < CHANGELOG.md | tr -d '\r\n')"
compose=(docker compose --project-name huai-auto-test --env-file deploy/.env -f deploy/compose.yaml -f test/windows/compose.test.yaml)
"${compose[@]}" build --pull=false
"${compose[@]}" up -d --no-build --pull never --wait --wait-timeout 240
"${compose[@]}" ps
curl --fail --silent --show-error http://127.0.0.1:8080/healthz
