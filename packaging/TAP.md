# Publicar godev en Homebrew

Pasos para poner el tap en línea. Nada de esto está hecho todavía: hasta que se
complete, `brew install augustose/godev/godev` devuelve "No available formula".

## 1. Cortar el release

El hook `pre-commit` auto-incrementa el PATCH en cada commit que toque `godev`, pero
respeta un `VERSION` cambiado a mano. Así que el bump va en el último commit antes
del tag, y el tag sale de ese commit exacto.

```bash
grep -m1 '^VERSION=' godev          # confirmar que dice 2.7.0
git tag -a v2.7.0 -m "v2.7.0 — Homebrew support"
git push origin main --tags
gh release create v2.7.0 --title "v2.7.0" --notes "Homebrew support, godev --init"
```

El release importa: `_resolve_remote()` prioriza GitHub Releases sobre la rama.

## 2. Calcular el sha256 del tarball

```bash
curl -fsSL https://github.com/augustose/godev/archive/refs/tags/v2.7.0.tar.gz | shasum -a 256
```

## 3. Crear el tap

El repo **tiene que** llamarse `homebrew-godev` para que `brew tap augustose/godev`
resuelva.

```bash
gh repo create augustose/homebrew-godev --public \
  --description "Homebrew tap for godev"
git clone https://github.com/augustose/homebrew-godev
mkdir -p homebrew-godev/Formula
cp packaging/godev.rb homebrew-godev/Formula/godev.rb
# reemplazar REPLACE_WITH_TARBALL_SHA256 por el sha del paso 2
```

## 4. Validar antes de anunciar

```bash
brew install --build-from-source augustose/godev/godev
brew test godev
brew audit --strict augustose/godev/godev
godev --version          # debe coincidir con el tag
godev --update           # debe redirigir a `brew upgrade godev`, sin descargar
```

> **Nota:** en esta máquina `brew audit` falla por un problema del bundle de gems
> vendorizado de Homebrew (`json` compilado contra otra portable-ruby), no del
> Formula. Si vuelve a pasar: `brew update-reset` suele reconstruirlo. `brew audit`
> además activa el modo developer solo (`homebrew.devcmdrun`); se revierte con
> `git -C "$(brew --repository)" config --unset homebrew.devcmdrun`.

## 5. Actualizar en cada release futuro

Bump manual de `VERSION` → tag → release → nuevo `sha256` → commit en el tap.
Cuando la cadencia lo justifique, automatizar con `brew bump-formula-pr`.

## Por qué no homebrew-core

homebrew-core exige notoriedad (~75 stars / 30 forks / 30 watchers) y revisión de
mantenedores. El tap propio no tiene requisitos y se publica hoy. La postulación a
core queda para cuando el proyecto tenga tracción; el Formula ya está escrito para
pasar `brew audit --strict`.
