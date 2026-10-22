#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/util.sh"
echo 'Cliente de solo lectura. Usuario: auditor. Contraseña docente de práctica: EnumSQL-2026!'
echo 'Se conecta por TCP al puerto publicado en Kali; no entra al servidor como root.'
sudo docker run --rm -it --network host mysql:8.4 \
  mysql --protocol=TCP -h127.0.0.1 -P "$MYSQL_PORT" \
  --get-server-public-key --ssl-mode=DISABLED -u auditor -p
