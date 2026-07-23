# Diseño: Auto-actualización de godev (`--update`)

Fecha: 2026-07-23
Estado: aprobado, pendiente de implementación

## Objetivo

Permitir que godev verifique si hay una versión nueva en el repositorio público
de GitHub (`augustose/godev`) y la instale, mediante el comando `godev --update`.
Hoy ese comando es un placeholder (`godev:1214`) que solo imprime
*"Función de actualización en desarrollo"*.

## Decisiones de diseño

- **Fuente de la última versión**: GitHub Releases (release-first), descargando
  **desde el tag del release** para garantizar que *lo anunciado == lo instalado*.
  *Fallback* al raw de `main` solo si no hay releases publicados.
- **Comportamiento**: `--update` chequea, muestra el diff de versión y pide
  confirmación `(y/N)` antes de descargar e instalar.
- **Sin auto-aviso en segundo plano**: godev solo contacta GitHub cuando el
  usuario corre `--update` explícitamente. Cero latencia y cero red en el uso normal.
- **Instalación segura**: descargar a temporal → validar → backup → reemplazo atómico.

### Nota sobre releases vs main (hallazgo del testing)

Al probar, se detectó que los releases iban atrasados respecto a `main`
(último release `v2.2.0` vs `main` en `2.5.0`). Se resolvió adoptando el modelo
profesional: **release-first descargando desde el tag** (anunciado == instalado),
y como parte de la puesta en marcha se taggea `v2.6.0` (primera versión con
`--update`) como release oficial. La versión del script se sube a `2.6.0`.

## Sección 1 — Flujo de `--update`

Nueva función `self_update()` llamada desde el `case --update`.

1. **Resolver versión remota** (única fase con red) — `_resolve_remote` devuelve
   `version|ref`:
   - `GET https://api.github.com/repos/augustose/godev/releases/latest` →
     `tag_name` (ej. `v2.6.0`). `version` = `2.6.0`, `ref` = `v2.6.0` (el tag).
   - Si no hay releases (404 / vacío / sin red a la API), *fallback*: descargar el
     raw de `main`, extraer `VERSION="..."`; `ref` = `main`.
   - Si ambos fallan → error claro en español, salir con código 1 (sin tocar nada).
   - La descarga posterior usa `ref`, por lo que se instala exactamente la versión
     anunciada.
2. **Comparar** versión local (`$VERSION`) vs remota con `sort -V` (semántico).
   - local ≥ remota → *"Ya tienes la última versión (X) ✓"*, salir 0.
   - remota > local → mostrar `LOCAL → REMOTA` y pedir confirmación en `/dev/tty`.
3. Confirmación afirmativa → fase de instalación. Negativa → cancelar sin cambios.

## Sección 2 — Instalación segura

1. **Descargar a temporal** (nunca directo sobre el binario en uso):
   `curl -fsSL --max-time 10 "$RAW_URL" -o "$tmpfile"` (o `wget` como fallback).
   `$tmpfile` creado en `~/.local/bin/` para garantizar `mv` atómico.
2. **Validar** antes de instalar:
   - Sintaxis: `zsh -n "$tmpfile"`.
   - Contenido: el archivo debe contener la línea `VERSION=` (no una página de
     error HTML de GitHub).
3. **Backup + reemplazo atómico**:
   - Destino: `$HOME/.local/bin/godev`.
   - Copiar el actual a `godev.backup-<timestamp>` (preservar información: nunca
     sobrescribir sin backup).
   - `chmod +x "$tmpfile"` → `mv "$tmpfile" "$destino"`.
4. **Actualizar `version_info`** con versión, fecha y fuente. Corrige de paso el
   desajuste actual (installer escribe `2.1.11`).
5. **Mensaje final**: *"✓ Actualizado a vX. Backup en ... Recargá con: source ~/.zshrc"*.
   El wrapper en `.zshrc` no cambia; no hace falta reinstalar.

## Sección 3 — Errores, alcance y qué NO toca

**No toca**: `~/.zshrc`, la función wrapper, el `config`, ni los proyectos.
Solo reemplaza el binario `~/.local/bin/godev`.

| Situación | Comportamiento |
|---|---|
| Sin `curl` ni `wget` | Error claro, salir 1. |
| Sin red / timeout | `--max-time 10`; mensaje "No se pudo contactar GitHub", salir 1. |
| Rate-limit / 404 releases | Fallback silencioso al raw de `main`. |
| Descarga corrupta (falla `zsh -n` o sin `VERSION=`) | Aborta antes de reemplazar; godev actual intacto. |
| Ya en la última versión | Mensaje ✓, salir 0. |
| Usuario responde "no" | Cancela sin cambios. |

## Archivos afectados

- **`godev`**: nueva función `self_update()`; reemplazar placeholder en `godev:1214`;
  línea de doc en `show_help()`; constante `GODEV_REPO="augustose/godev"` arriba.
- **`installer.sh`**: corregir `version=2.1.11` para eliminar el desajuste con `$VERSION`.
- **Sin dependencias nuevas**: `curl`/`wget`, `grep`, `sort -V`, `mktemp` (ya presentes).

## Testing

Según `testing_guide.md`: versión local mayor / igual / menor que la remota; con y
sin releases publicados; simular descarga corrupta; verificar creación del backup.
