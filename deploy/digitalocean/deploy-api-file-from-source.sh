#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/opt/pos-source}"
ENV_FILE="${ENV_FILE:-/opt/pos/.env}"
REPO_URL="${REPO_URL:-https://github.com/Hakley10/PosDeploy.git}"

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE. Create it before deploying." >&2
  exit 1
fi

if ! command -v git >/dev/null 2>&1 || ! command -v curl >/dev/null 2>&1; then
  apt-get update
  apt-get install -y git curl
fi

if ! command -v docker >/dev/null 2>&1 || ! docker compose version >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

if [ ! -d "$APP_DIR/.git" ]; then
  rm -rf "$APP_DIR"
  git clone "$REPO_URL" "$APP_DIR"
else
  git -C "$APP_DIR" pull --ff-only
fi

cd "$APP_DIR"
docker compose --env-file "$ENV_FILE" -f docker-compose.api-file.yml up -d --build pos_file pos_report pos_api pos_proxy
docker image prune -f
