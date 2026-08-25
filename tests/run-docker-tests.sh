#!/usr/bin/env zsh
#
# Corre la batería de godev en un contenedor Debian limpio.
#
# Por qué en contenedor: estas pruebas escriben en ~/.zshrc, simulan una
# instalación de Homebrew y ejercitan el instalador de punta a punta. Nada de
# eso se puede probar contra el HOME real sin arriesgarlo.
#
# En Mac se usa Colima (no Docker Desktop):  colima start
#
# Uso:  zsh tests/run-docker-tests.sh

set -e
REPO="${0:A:h:h}"

if ! docker info >/dev/null 2>&1; then
    echo "Docker no responde. En Mac: colima start" >&2
    exit 1
fi

echo "Construyendo imagen de prueba..."
docker build -q -t godev-test "$REPO/tests/docker" >/dev/null

echo "Corriendo la batería..."
# La suite se pasa como argumento en vez de montarse: Colima sólo monta $HOME,
# así que un montaje desde /tmp fallaría.
docker run --rm -v "$REPO":/src:ro godev-test \
    zsh -c "$(cat "$REPO/tests/docker/suite.zsh")"
