#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
PORT="${1:-8081}"
NAME=campus-reto
if ! [[ "$PORT" =~ ^[0-9]{4,5}$ ]] || (( 10#$PORT < 1024 || 10#$PORT > 65535 )); then
  echo 'Usa un puerto entre 1024 y 65535. Ejemplo: bash iniciar.sh 8081' >&2
  exit 1
fi
if ! command -v docker >/dev/null; then
  echo 'Falta Docker. Consulta LEEME_DOCENTE.txt.' >&2
  exit 1
fi
sudo docker info >/dev/null
if sudo docker inspect "$NAME" >/dev/null 2>&1; then
  if [[ "$(sudo docker inspect --format '{{index .Config.Labels "campus.reto"}}' "$NAME")" != 1 ]]; then
    echo 'Hay un contenedor con ese nombre que no pertenece al reto.' >&2
    exit 1
  fi
  CURRENT="$(sudo docker port "$NAME" 8000/tcp 2>/dev/null | head -n 1 || true)"
  if [[ -n "$CURRENT" && "$CURRENT" != "127.0.0.1:$PORT" ]]; then
    echo "El contenedor ya utiliza $CURRENT. Usa ese puerto o consulta LEEME_DOCENTE.txt." >&2
    exit 1
  fi
  if ! sudo docker start "$NAME" >/dev/null; then
    echo "No pudo iniciarse. Revisa qué ocupa $PORT: sudo ss -lntp 'sport = :$PORT'" >&2
    exit 1
  fi
else
  if command -v ss >/dev/null && [[ -n "$(ss -H -lnt "sport = :$PORT")" ]]; then
    echo "El puerto $PORT está ocupado. Identifica el servicio con: sudo ss -lntp 'sport = :$PORT'" >&2
    echo 'No se detuvo ningún servicio. Puedes elegir otro puerto: bash iniciar.sh 8082' >&2
    exit 1
  fi
  sudo docker build -t campus-reto:1 ./objetivo
  if ! sudo docker run -d --name "$NAME" --label campus.reto=1 --restart=no \
    --read-only --tmpfs /tmp:rw,nosuid,nodev,size=16m --cap-drop=ALL \
    --security-opt=no-new-privileges --memory=128m --cpus=1 \
    -p "127.0.0.1:$PORT:8000" campus-reto:1; then
    echo 'Docker no pudo publicar el puerto. No se detuvo ningún servicio ajeno.' >&2
    echo "Revisa: sudo ss -lntp 'sport = :$PORT'" >&2
    exit 1
  fi
fi
for attempt in {1..20}; do
  if curl -fsS "http://127.0.0.1:$PORT/" >/dev/null 2>&1; then
    echo "CampusLab listo: http://127.0.0.1:$PORT/"
    echo 'Entrega al alumno únicamente la carpeta alumnos o el ZIP Entrega_Alumnos.zip.'
    exit 0
  fi
  sleep 0.5
done
sudo docker logs --tail 15 "$NAME"
echo 'La web aún no responde. Revisa el mensaje anterior.' >&2
exit 1
