#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/util.sh"
sudo docker info >/dev/null
dc config --quiet
# No se detienen procesos ajenos cuando un puerto está ocupado.
for port in "$HTTP_PORT" "$SSH_PORT" "$MYSQL_PORT"; do
  own="$(dc ps -q 2>/dev/null | head -n 1 || true)"
  if [[ -z "$own" ]] && command -v ss >/dev/null && [[ -n "$(ss -H -lnt "sport = :$port")" ]]; then
    echo "Puerto $port ocupado. Identifica el proceso: sudo ss -lntp 'sport = :$port'" >&2
    echo 'Elige puertos libres en .env antes de volver a iniciar.' >&2
    exit 1
  fi
done
dc up -d --build db wordpress ssh
dc run --rm setup
for attempt in {1..30}; do
  if curl -fsS "http://127.0.0.1:$HTTP_PORT/" >/dev/null 2>&1; then
    dc ps
    printf '\nWordPress: http://127.0.0.1:%s/\nSSH: 127.0.0.1:%s\nMySQL: 127.0.0.1:%s\n' "$HTTP_PORT" "$SSH_PORT" "$MYSQL_PORT"
    echo 'Verifica el conjunto con: bash verificar.sh'
    exit 0
  fi
  sleep 1
done
dc logs --tail=30 wordpress
echo 'WordPress todavía no responde. Revisa el log anterior.' >&2
exit 1
