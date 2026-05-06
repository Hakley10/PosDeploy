#!/bin/sh
set -eu

APP_DIR="${APP_DIR:-/opt/pos}"
mkdir -p "$APP_DIR"
cd "$APP_DIR"

if [ ! -f .env ]; then
  echo "Missing $APP_DIR/.env. Create it on the droplet before deploying." >&2
  exit 1
fi

docker compose pull pos_api pos_file pos_report
docker compose up -d pos_api pos_file pos_report
docker image prune -f
