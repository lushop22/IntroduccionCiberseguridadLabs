#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/util.sh"
mkdir -p evidencias_docente
BASE="http://127.0.0.1:$HTTP_PORT"
curl -fsS "$BASE/" > evidencias_docente/portada.html
curl -fsS "$BASE/wp-content/themes/campuspress/style.css" | grep -q 'Theme Name: CampusPress'
curl -fsS "$BASE/wp-content/plugins/campus-agenda/readme.txt" | grep -q 'Stable tag: 1.0'
curl -fsS "$BASE/robots.txt" | grep -q 'wp-sitemap.xml'
curl -fsS "$BASE/material/inventario.csv" | grep -q PC-DEMO-01
curl -fsS "$BASE/contacto/" | grep -q 'campus@example.test'
curl -fsS "$BASE/wp-json/wp/v2/users?_fields=id,name,slug" > evidencias_docente/autores.json
python3 - <<'PY'
import json
from pathlib import Path
data=json.loads(Path('evidencias_docente/autores.json').read_text())
assert isinstance(data,list),data
slugs={u['slug'] for u in data}
assert {'lucia_redaccion','mateo_agenda'} <= slugs,slugs
print('Autores públicos:',', '.join(sorted(slugs)))
PY
ssh-keyscan -T 5 -p "$SSH_PORT" -t ed25519 127.0.0.1 > evidencias_docente/ssh.keys 2>/dev/null
ssh-keygen -lf evidencias_docente/ssh.keys
# Auditor, no root: además de leer el inventario, el verificador intenta una escritura inocua.
sudo docker run --rm --network host -e MYSQL_PWD='EnumSQL-2026!' mysql:8.4 \
  mysql --protocol=TCP -h127.0.0.1 -P "$MYSQL_PORT" --get-server-public-key \
  --ssl-mode=DISABLED -u auditor --batch \
  -e 'SHOW DATABASES; USE inventario_lab; SHOW TABLES; SELECT * FROM v_servicios; SHOW GRANTS;' \
  > evidencias_docente/mysql.txt
if sudo docker run --rm --network host -e MYSQL_PWD='EnumSQL-2026!' mysql:8.4 \
  mysql --protocol=TCP -h127.0.0.1 -P "$MYSQL_PORT" --get-server-public-key \
  --ssl-mode=DISABLED -u auditor \
  -e 'UPDATE inventario_lab.servicios SET nombre=nombre WHERE 1=0;' \
  > evidencias_docente/escritura.txt 2>&1; then
  echo 'ERROR: auditor pudo enviar UPDATE. Revisa los permisos antes de clase.' >&2
  exit 1
fi
grep -qi 'denied' evidencias_docente/escritura.txt
dc run --rm --entrypoint wp setup core version > evidencias_docente/version-wordpress.txt
echo 'Comprobaciones HTTP, autores, SSH, SQL y permisos completadas.'
echo 'Las salidas se guardaron en evidencias_docente/.'
