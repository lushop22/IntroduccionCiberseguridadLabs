#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")"
NAME=aulalab-enum
if ! command -v docker >/dev/null; then
  echo 'Instala Docker y las herramientas con los comandos de LEEME.txt.' >&2
  exit 1
fi
sudo docker info >/dev/null
if sudo docker inspect "$NAME" >/dev/null 2>&1; then
  if [[ "$(sudo docker inspect --format '{{index .Config.Labels "aula.enum"}}' "$NAME")" != 1 ]]; then
    echo 'Ya existe un contenedor con ese nombre que no pertenece a este paquete.' >&2
    exit 1
  fi
  sudo docker start "$NAME" >/dev/null
else
  sudo docker build -t aulalab-enum:1 .
  sudo docker run -d --name "$NAME" --label aula.enum=1 \
    -p 127.0.0.1:8080:80 aulalab-enum:1
fi
echo 'Abre en Firefox de Kali: http://127.0.0.1:8080/'
