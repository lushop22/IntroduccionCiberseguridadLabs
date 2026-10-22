#!/usr/bin/env bash
set -euo pipefail
source "$(dirname -- "${BASH_SOURCE[0]}")/util.sh"
dc stop
echo 'Servicios detenidos. Los datos y claves SSH se conservan.'
