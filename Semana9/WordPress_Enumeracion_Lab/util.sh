#!/usr/bin/env bash
set -euo pipefail
LAB_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd -- "$LAB_DIR"
if sudo docker compose version >/dev/null 2>&1; then
  COMPOSE=(sudo docker compose)
elif command -v docker-compose >/dev/null; then
  COMPOSE=(sudo docker-compose)
else
  echo 'Falta Compose. En Kali: sudo apt install -y docker-compose' >&2
  exit 1
fi
[[ -f .env ]] || cp .env.example .env
get_port() {
  local name="$1" fallback="$2" value
  value="$(sed -n "s/^${name}=//p" .env | tail -n 1 | tr -d '\r')"
  value="${value:-$fallback}"
  if ! [[ "$value" =~ ^[0-9]{4,5}$ ]] || (( 10#$value < 1024 || 10#$value > 65535 )); then
    echo "Puerto inválido en .env: $name" >&2
    exit 1
  fi
  printf '%s' "$value"
}
HTTP_PORT="$(get_port HTTP_PORT 8082)"
SSH_PORT="$(get_port SSH_PORT 2222)"
MYSQL_PORT="$(get_port MYSQL_PORT 3307)"
if [[ "$HTTP_PORT" == "$SSH_PORT" || "$HTTP_PORT" == "$MYSQL_PORT" || "$SSH_PORT" == "$MYSQL_PORT" ]]; then
  echo 'Los tres puertos de .env deben ser diferentes.' >&2
  exit 1
fi
dc() { "${COMPOSE[@]}" -p wp-enum --env-file .env -f compose.yaml "$@"; }
