#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/opt/pos-source}"
ENV_FILE="${ENV_FILE:-/opt/pos/.env}"
REPO_URL="${REPO_URL:-https://github.com/Hakley10/PosDeploy.git}"
SWAP_FILE="${SWAP_FILE:-/swapfile}"

require_env() {
  key="$1"
  value="$(grep -E "^${key}=" "$ENV_FILE" 2>/dev/null | tail -n 1 | cut -d '=' -f 2- || true)"
  case "$value" in
    ""|"replace-me"|"your-db-host"|"your-db-user"|"your-db-password"|"your_jwt_secret")
      echo "Invalid or missing ${key} in ${ENV_FILE}" >&2
      exit 1
      ;;
  esac
}

if [ ! -f "$ENV_FILE" ]; then
  echo "Missing $ENV_FILE. Create it before deploying." >&2
  exit 1
fi

require_env DB_CONNECTION
require_env DB_HOST
require_env DB_PORT
require_env DB_USERNAME
require_env DB_PASSWORD
require_env DB_DATABASE
require_env JWT_SECRET
require_env JS_PASSWORD
require_env JS_SESSION_SECRET

if [ ! -f "$SWAP_FILE" ]; then
  fallocate -l 2G "$SWAP_FILE" || dd if=/dev/zero of="$SWAP_FILE" bs=1M count=2048
  chmod 600 "$SWAP_FILE"
  mkswap "$SWAP_FILE"
fi
swapon "$SWAP_FILE" 2>/dev/null || true
grep -q "$SWAP_FILE" /etc/fstab || echo "$SWAP_FILE none swap sw 0 0" >> /etc/fstab

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
docker compose --env-file "$ENV_FILE" -f docker-compose.api-file.yml up -d --build pos_file pos_report pos_api pos_proxy || {
  docker compose --env-file "$ENV_FILE" -f docker-compose.api-file.yml logs --tail=120
  exit 1
}
docker image prune -f
docker compose --env-file "$ENV_FILE" -f docker-compose.api-file.yml ps
