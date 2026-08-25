# Diseño: Distribución de godev vía Homebrew

Fecha: 2026-08-21
Estado: implementado (secciones 1-4). Pendiente: publicar el tag, el release y el tap (ver packaging/TAP.md).

## Objetivo

Permitir instalar godev con `brew install augustose/godev/godev`, sin romper la
instalación actual por `curl | zsh` ni la auto-actualización (`--update`).

## El problema de fondo

godev no es un binario normal: necesita una **función wrapper en `~/.zshrc`** para
poder hacer `cd` en el shell padre. Un proceso hijo no puede cambiar el `cwd` de su
padre — es POSIX, no una limitación de Homebrew. Y **Homebrew nunca modifica el
`.zshrc` del usuario**: es política del proyecto y no existe mecanismo en un Formula
para hacerlo (`caveats` solo imprime texto). Toda esta familia de herramientas
(`zoxide`, `direnv`, `starship`, `fzf`) vive con la misma restricción.

De ahí salen cuatro conflictos concretos, todos reales:

| # | Conflicto | Consecuencia |
|---|---|---|
| 1 | `self_update()` hardcodea `dest="$HOME/.local/bin/godev"` (`godev:1245`) | Bajo brew descarga la versión nueva **al lado** de la instalada, imprime "✓ Actualizado" y `--version` sigue mostrando la vieja. Divergencia silenciosa. |
| 2 | `$(brew --prefix)/bin/godev` es un **symlink** al Cellar | Si `--update` escribiera ahí, el `mv` de `godev:1286` reemplazaría el symlink por un archivo regular y rompería `brew unlink`/`uninstall`. En `/opt/homebrew` el prefix es del usuario: no falla por permisos, corrompe en silencio. El siguiente `brew upgrade` borra el cambio. |
| 3 | Shadowing de PATH entre las dos copias | `installer.sh` hace `export PATH="$HOME/.local/bin:$PATH"` (**antepone**), pero solo si `~/.local/bin` no estaba ya en PATH. Según el `.zshrc` de cada uno, gana la copia de curl o la de brew. En ambas direcciones el usuario puede quedar ejecutando un binario que cree haber actualizado. |
| 4 | El wrapper del installer llama a `command ~/.local/bin/godev` (ruta absoluta) | Ni consulta el PATH. Para quien ya tiene godev, `brew install` no tiene **ningún** efecto. |

## Decisiones de diseño

- **Canal**: tap propio (`augustose/homebrew-godev`). homebrew-core exige notoriedad
  (~75 stars / 30 forks) y revisión de mantenedores; se puede postular más adelante.
- **Activación del wrapper**: `godev --init zsh` (patrón zoxide/starship) más
  `godev --init --install`, que cablea la línea por el usuario. Homebrew no escribe en
  el `.zshrc`; godev sí puede, porque el usuario se lo pidió explícitamente.
  Precedente directo: `fzf` en homebrew-core hace exactamente esto.
- **`--update` bajo brew**: detectar y **redirigir**. Consulta la versión remota,
  informa si hay una nueva, y dice `brew upgrade godev`. Nunca escribe en el Cellar.
- **Una sola implementación del wrapper**: `installer.sh` deja de escribir la función
  literal y pasa a escribir la misma línea `eval`. No se mantienen dos copias.

### UX final para el usuario

```bash
brew install augustose/godev/godev
godev --init --install && source ~/.zshrc
```

Dos comandos, cero edición manual de archivos. Es el piso alcanzable dada la
restricción de Homebrew.

## Sección 1 — `godev --init`

Nuevo comando en `main()`. La función wrapper se mueve de `installer.sh` al script,
como fuente única de verdad.

**Por qué `--init` y no `init` pelado** (que es la convención de zoxide/starship):
el wrapper decide con `[[ "$1" == -* ]]` si NO debe hacer `cd`, así que `--init`
pasa derecho sin caso especial; y un subcomando sin guiones colisionaría con un
proyecto llamado `init`, que dejaría de ser navegable. Todo el CLI de godev ya es
`--flag`.

**`godev --init zsh`** imprime la función a stdout y nada más. Se consume con
`eval "$(godev --init zsh)"`.

**Trampa de zsh**: `$0` dentro de una función es el *nombre de la función*, no el
del script (opción `FUNCTION_ARGZERO`, activa por defecto). Por eso la ruta se captura
en globales a nivel top-level, `GODEV_BIN`/`GODEV_BIN_REAL`, y no dentro de una función.

La ruta del binario se resuelve **en tiempo de generación** con `${0:a}` de zsh:
absoluta pero *sin* resolver symlinks. Bajo brew eso da `/opt/homebrew/bin/godev`
(el symlink estable), no `.../Cellar/godev/2.7.0/bin/godev`. El symlink sobrevive a
`brew upgrade`; la ruta del Cellar no. La función sigue apuntando bien tras cada
actualización sin re-ejecutar `--init`. **Cierra el conflicto #4.**

**`godev --init --install`**:

1. Backup de `~/.zshrc` con timestamp.
2. Detecta el bloque viejo (`^godev() {` … `^}`) y lo reemplaza por la línea `eval`.
3. Si existe un `~/.local/bin/godev` distinto del que se ejecuta, **avisa** del
   shadowing de PATH (**conflicto #3**) e indica cuál gana. No borra nada.
4. Pide confirmación antes de escribir.

**Alcance recortado a propósito**: `--init` solo soporta `zsh`. `main()` ya aborta sin
`$ZSH_VERSION` (`godev:1310`), así que bash/fish sería código muerto. Cualquier otro
argumento → error claro.

### El alias corto: opt-in, nunca automático

No se renombra la función a `gd` ni se agrega el alias durante la instalación.
`gd` es un alias del plugin `git` de oh-my-zsh (`git diff`), el setup zsh más
extendido que hay; pisarlo es un fallo **silencioso** — `gd` simplemente hace otra
cosa, sin error. Además el nombre de la función debe coincidir con el del binario y
el del Formula (`godev`), que es lo que dicen `--help`, los caveats de brew y los docs.

En su lugar, `--init` acepta `--alias NOMBRE` (opt-in), y `--init --install`
pregunta con **"no" por defecto**. Antes de escribir, avisa si el nombre ya está
tomado: busca `alias NOMBRE=` en el `.zshrc` y contrasta contra la lista de aliases
del plugin `git` de oh-my-zsh cuando ese plugin está activo.

`--init --install` **nunca borra un `alias X='godev'` escrito a mano** por el
usuario. Solo reemplaza la función wrapper.

## Sección 2 — `--update` deja de adivinar dónde vive

**Cambio 1 — destino real.** `dest` pasa de `$HOME/.local/bin/godev` a `${0:a}`: el
binario en ejecución. Cierra el **conflicto #1** para todos los casos, no solo brew
(hoy rompe cualquier instalación fuera de `~/.local/bin`). El `mktemp` sigue en el
mismo directorio, así que el `mv` atómico de `godev:1286` no cambia.

**Cambio 2 — `_install_kind()`.** Devuelve `brew` o `standalone`:

1. Test gratis: `${0:A}` (symlinks resueltos) matchea `*/Cellar/godev/*` → `brew`.
2. Fallback: `$HOMEBREW_PREFIX` (o `brew --prefix`) y el binario cuelga de ahí → `brew`.
3. Si no → `standalone`.

**Rendimiento, no cosmética**: godev corre en cada navegación. `_install_kind()` se
invoca **solo** dentro de `--update`, nunca en el camino caliente; y el paso 2
prefiere la variable de entorno antes que lanzar el proceso `brew`.

**Cambio 3 — la política.** Con `kind == brew`, `self_update()` consulta la versión
remota igual que hoy (`_resolve_remote()` queda intacto) y compara:

| Situación | Comportamiento |
|---|---|
| Al día | Mismo mensaje ✓ de siempre, salir 0. |
| Hay versión nueva | Anuncia `LOCAL → REMOTA` y dice `brew upgrade godev`. **No descarga, no escribe, no toca `version_info`.** Salir 0. |
| `kind == standalone` | Flujo actual idéntico, con `dest` corregido. |

Cierra el **conflicto #2**. Falla en cerrado a propósito: si alguien copió el script
a mano bajo el prefix de brew, se trata como brew y se niega a auto-actualizarse.
Preferible a corromper.

## Sección 3 — El tap y el Formula

Repo aparte: `augustose/homebrew-godev`. El prefijo `homebrew-` es obligatorio para
que `brew tap augustose/godev` resuelva. Un solo archivo: `Formula/godev.rb`.

```ruby
class Godev < Formula
  desc "Navigate 100+ development projects in seconds with fuzzy search"
  homepage "https://github.com/augustose/godev"
  url "https://github.com/augustose/godev/archive/refs/tags/v2.7.0.tar.gz"
  sha256 "<calculado del tarball>"
  license "MIT"

  depends_on "fzf"
  uses_from_macos "zsh"

  def install
    bin.install "godev"
  end

  def caveats
    <<~EOS
      godev necesita una función de shell para poder cambiar de directorio:
        godev --init --install && source ~/.zshrc
    EOS
  end

  test do
    assert_match "godev version #{version}", shell_output("#{bin}/godev --version")
    assert_match "godev()", shell_output("#{bin}/godev init zsh")
  end
end
```

- **`uses_from_macos "zsh"`**: macOS ya trae zsh (no instala nada); en Linux brew lo resuelve.
- **`fzf` como dependencia dura**: Homebrew dejó obsoletos `:optional` y `:recommended`
  (obligan a compilar con flags `--with-`). godev funciona sin fzf, pero fzf es chico
  y popular; exigirlo es la opción limpia.
- **El test compara versión contra tag**: si se olvida bumpear `VERSION`, `brew test`
  falla. Fragilidad buscada — detecta el drift.

## Sección 4 — Migración desde la instalación por script

Para quien ya tiene godev instalado por `curl | zsh`. **La configuración se conserva
sola**: `~/.config/godev/` es XDG y la versión de brew lee exactamente la misma ruta,
así que `config`, `version_info` y el cache HTML sobreviven sin hacer nada.

Lo que sí hay que quitar es el binario viejo y la función vieja del `.zshrc`, porque
esa función llama a `~/.local/bin/godev` por ruta absoluta (**conflicto #4**) e
ignoraría la instalación de brew por completo.

Texto a incorporar al README (bloque "Migrar desde la instalación por script"):

```bash
# 1. Instalar por Homebrew
brew install augustose/godev/godev

# 2. Cablear el wrapper nuevo. Detecta la función vieja, la reemplaza,
#    y deja backup con timestamp de tu ~/.zshrc
godev --init --install

# 3. Quitar el binario viejo (tu config en ~/.config/godev NO se toca)
rm ~/.local/bin/godev

# 4. Recargar
source ~/.zshrc

# 5. Verificar que corre el de brew
command -v godev && godev --version
```

Notas para el README:

- **No borrar `~/.config/godev/`**: ahí viven tu directorio base y el cache.
- Un `alias gd='godev'` sigue funcionando sin cambios: apunta al nombre de la
  función, no al binario.
- Si `installer.sh` había agregado su línea `export PATH=".../.local/bin:$PATH"` y no
  se usa para nada más, se puede quitar — pero es decisión del usuario, no del
  procedimiento. El README lo menciona, no lo automatiza.
- Los `godev.backup-*` que haya dejado `--update` en `~/.local/bin/` quedan a
  criterio del usuario.

`godev --init --install` (Sección 1, punto 3) detecta el caso de tener las dos copias
conviviendo y avisa cuál gana, para que el paso 3 no se olvide.

## Prerequisito: falta el archivo LICENSE

`README.md:8` (badge) y `README.md:599` declaran MIT y enlazan a `LICENSE`, pero
**el archivo no existe**: ambos enlaces están rotos. `brew audit` exige un `license`
declarado. Crear `LICENSE` (MIT) es bloqueante, no opcional.

## Archivos afectados

- **`godev`**: `godev init` (`--init zsh` + `--init --install`); `_install_kind()`;
  `self_update()` con `dest="${0:a}"` y la rama brew; línea en `show_help()`;
  bump `VERSION="2.7.0"`.
- **`installer.sh`**: escribir `eval "$(godev --init zsh)"` en vez de la función literal.
- **`LICENSE`** (nuevo): MIT.
- **`README.md`**: sección de instalación con Homebrew; bloque "Migrar desde la
  instalación por script" (Sección 4); documentar `--init`.
- **Repo nuevo** `augustose/homebrew-godev`: `Formula/godev.rb`.
- **Sin dependencias nuevas** en el script.

## Orden de trabajo

1. Crear `LICENSE` (MIT) — desbloquea `license "MIT"` y repara los links rotos.
2. Implementar secciones 1 y 2.
3. Convergir `installer.sh` sobre la línea `eval`.
4. Bump a `2.7.0`, `show_help()`, README (incluida la guía de migración).
5. Tag `v2.7.0` **y GitHub Release** (`_resolve_remote()` prioriza releases).

   > **Ojo con el hook `pre-commit`**: auto-incrementa el PATCH en cada commit que
   > toque `godev`, así que la versión sube sola mientras se implementa. El hook
   > respeta un `VERSION` cambiado a mano (si difiere de HEAD lo deja). Por eso el
   > bump a `2.7.0` va en el **último** commit antes del tag, y el tag se saca de
   > ese commit exacto: el `test do` del Formula compara la salida de `--version`
   > contra la versión del tag y falla si hay drift.
6. `curl -fsSL <tarball> | shasum -a 256` para el `sha256`.
7. Crear el tap con el Formula.

## Testing

Matriz mínima, además de `zsh -n godev`:

| Caso | Verificar |
|---|---|
| `--init zsh` bajo brew | La función embebe `$(brew --prefix)/bin/godev`, no la ruta del Cellar. |
| `--init zsh` standalone | Embebe `~/.local/bin/godev`. |
| `--init --install` con función vieja presente | La reemplaza, deja backup, `.zshrc` queda válido. |
| `--init --install` con ambas instalaciones | Emite el aviso de shadowing de PATH. |
| `--init --alias gd` con oh-my-zsh+git | Avisa de la colisión con `git diff` y pide confirmación. |
| `--init --install` con `alias gd='godev'` a mano | El alias del usuario sobrevive intacto. |
| `.zshrc` resultante | Pasa `zsh -n` antes de reemplazar el original. |
| `--update` bajo brew, versión nueva | Anuncia y redirige. **El Cellar queda sin tocar** (verificar mtime). |
| `--update` bajo brew, al día | Mensaje ✓, sin red de descarga. |
| `--update` standalone | Flujo actual intacto, backup creado. |
| Formula | `brew install --build-from-source`, `brew audit --strict`, `brew test`. |
| Navegación tras `brew upgrade` | El wrapper sigue resolviendo al binario nuevo sin re-ejecutar `--init`. |
| Migración completa (Sección 4) | Tras los 5 pasos: `command -v godev` apunta a brew y `~/.config/godev/config` quedó intacto. |

## Qué NO toca

Ni el `config`, ni el `cache`, ni los proyectos, ni la lógica de navegación,
scanning o Git. `installer.sh` sigue funcionando como camino de instalación
alternativo; las dos vías convergen en la misma función wrapper.

## Fuera de alcance (por ahora)

- Automatización CI que abra PR al tap en cada release (`brew bump-formula-pr`).
  Se agrega cuando la cadencia de releases lo justifique.
- Soporte bash/fish en `--init`.
- Postulación a homebrew-core.
