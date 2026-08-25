#!/usr/bin/env zsh
# Batería de pruebas de godev en contenedor limpio.
PASS=0; FAIL=0
ok()   { echo "  ✓ $1"; PASS=$((PASS+1)); return 0 }
bad()  { echo "  ✗ $1"; FAIL=$((FAIL+1)); return 0 }
check(){ [[ "$2" == *"$3"* ]] && ok "$1" || { bad "$1"; echo "      esperaba: $3"; echo "      obtuvo:   ${2:0:200}"; } }

mkdir -p ~/dev/{alpha,beta,gamma} ~/.local/bin
cd ~/dev/alpha && git init -q 2>/dev/null; cd ~
mkdir -p ~/.config/godev
cat > ~/.config/godev/config << 'EOF'
GODEV_BASE_DIR="/home/tester/dev"
GODEV_FZF_ENABLED="false"
EOF

echo ""
echo "═══ 1. --init --install --yes sobre .zshrc limpio ═══"
cp /src/godev ~/.local/bin/godev && chmod +x ~/.local/bin/godev
echo '# mi zshrc' > ~/.zshrc
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
out=$(~/.local/bin/godev --init --install --yes 2>&1)
check "instala sin preguntar" "$out" "✓ Shell integration installed"
check "reporta el binario" "$out" "/home/tester/.local/bin/godev"
grep -qE '^eval "\$\((command )?godev --init zsh\)"$' ~/.zshrc && ok "línea eval presente" || bad "línea eval ausente"
[[ -n "$(find ~ -maxdepth 1 -name ".zshrc.backup-*" 2>/dev/null)" ]] && ok "backup creado" || bad "backup ausente"
zsh -n ~/.zshrc && ok ".zshrc parsea" || bad ".zshrc roto"

echo ""
echo "═══ 2. el wrapper funciona de verdad (cd en shell padre) ═══"
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev alpha >/dev/null 2>&1; echo $PWD')
check "navega a ~/dev/alpha" "$res" "/home/tester/dev/alpha"
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev --version')
check "--version pasa derecho" "$res" "godev version"

echo ""
echo "═══ 3. idempotencia: correr --install dos veces ═══"
before=$(grep -c 'godev --init zsh' ~/.zshrc)
~/.local/bin/godev --init --install --yes >/dev/null 2>&1
after=$(grep -c 'godev --init zsh' ~/.zshrc)
[[ "$before" == "1" && "$after" == "1" ]] && ok "no duplica la línea ($before -> $after)" || bad "duplicó: $before -> $after"

echo ""
echo "═══ 4. migración: wrapper viejo del instalador ═══"
cat > ~/.zshrc << 'EOF'
# mi zshrc
export PATH="$HOME/.local/bin:$PATH"
alias gd='godev'
alias mio='echo intacto'

# godev - Function wrapper (added by installer)
godev() {
    local result
    if [[ "$1" =~ ^- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        echo "$result"
        return $exit_code
    fi
}
EOF
~/.local/bin/godev --init --install --yes >/dev/null 2>&1
grep -q '^godev() {' ~/.zshrc && bad "quedó la función vieja" || ok "función vieja removida"
grep -qF "alias gd='godev'" ~/.zshrc && ok "alias gd del usuario SOBREVIVE" || bad "se perdió alias gd"
grep -qF "alias mio=" ~/.zshrc && ok "otras líneas intactas" || bad "se perdieron líneas"
grep -qE '^eval "\$\((command )?godev --init zsh\)"$' ~/.zshrc && ok "línea nueva presente" || bad "falta línea nueva"
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev beta >/dev/null 2>&1; echo $PWD')
check "sigue navegando tras migrar" "$res" "/home/tester/dev/beta"

echo ""
echo "═══ 5. _install_kind: simulacro de Homebrew ═══"
mkdir -p ~/brew/Cellar/godev/9.9.9/bin ~/brew/bin
cp /src/godev ~/brew/Cellar/godev/9.9.9/bin/godev
chmod +x ~/brew/Cellar/godev/9.9.9/bin/godev
ln -sf ~/brew/Cellar/godev/9.9.9/bin/godev ~/brew/bin/godev
out=$(~/brew/bin/godev --init zsh | grep godev_bin=)
check "wrapper embebe el SYMLINK, no el Cellar" "$out" "/home/tester/brew/bin/godev"
[[ "$out" == *"Cellar"* ]] && bad "embebió la ruta del Cellar (rompería en upgrade)" || ok "no embebió la ruta del Cellar"

echo ""
echo "═══ 6. --update bajo brew debe REDIRIGIR, no escribir ═══"
sed 's/^VERSION="[^"]*"/VERSION="0.0.1"/' /src/godev > ~/brew/Cellar/godev/9.9.9/bin/godev
chmod +x ~/brew/Cellar/godev/9.9.9/bin/godev
sum_before=$(md5sum ~/brew/Cellar/godev/9.9.9/bin/godev | cut -d' ' -f1)
out=$(~/brew/bin/godev --update 2>&1 </dev/null)
check "detecta gestión por Homebrew" "$out" "managed by Homebrew"
check "sugiere brew upgrade" "$out" "brew upgrade godev"
sum_after=$(md5sum ~/brew/Cellar/godev/9.9.9/bin/godev | cut -d' ' -f1)
[[ "$sum_before" == "$sum_after" ]] && ok "EL CELLAR QUEDÓ SIN TOCAR" || bad "¡se modificó el Cellar!"
[[ -n "$(find ~/brew/Cellar -name "godev.new.*" 2>/dev/null)" ]] && bad "dejó temporales en el Cellar" || ok "sin temporales en el Cellar"
[[ -n "$(find ~/brew -name "godev.backup-*" 2>/dev/null)" ]] && bad "dejó backups en el prefix" || ok "sin backups en el prefix"
[[ -L ~/brew/bin/godev ]] && ok "el symlink sigue siendo symlink" || bad "el symlink fue reemplazado"

echo ""
echo "═══ 7. --update standalone: destino = binario real ═══"
sed 's/^VERSION="[^"]*"/VERSION="0.0.1"/' /src/godev > ~/.local/bin/godev
chmod +x ~/.local/bin/godev
out=$(~/.local/bin/godev --update 2>&1 </dev/null)
check "anuncia versión nueva" "$out" "A new version is available"
[[ "$out" == *"managed by Homebrew"* ]] && bad "confundió standalone con brew" || ok "detectado como standalone"

echo ""
echo "═══ 8. errores de --init ═══"
out=$(~/.local/bin/godev --init bash 2>&1); check "rechaza bash" "$out" "only supports zsh"
out=$(~/.local/bin/godev --init pepe 2>&1); check "rechaza arg inválido" "$out" "Unknown argument"
out=$(~/.local/bin/godev --init --install --yes --alias '1mal' 2>&1); check "rechaza alias inválido" "$out" "is not a valid alias name"

echo ""
echo "═══ 9. flujo INTERACTIVO con tty real ═══"
cp /src/godev ~/.local/bin/godev && chmod +x ~/.local/bin/godev
printf '# limpio\n' > ~/.zshrc
# Responde: Enter (sin alias) + "y" (confirmar)
out=$(python3 -c '
import pty, os, sys
out = []
def rd(fd):
    d = os.read(fd, 1024)
    out.append(d)
    return d
def wr(fd):
    return b""
pid, fd = pty.fork()
if pid == 0:
    os.execvp("/home/tester/.local/bin/godev", ["godev", "--init", "--install"])
import time, select
buf = b""
sent = 0
while True:
    r, _, _ = select.select([fd], [], [], 5)
    if not r: break
    try: d = os.read(fd, 4096)
    except OSError: break
    if not d: break
    buf += d
    if sent == 0 and b"alias" in buf and b"skip" in buf:
        os.write(fd, b"\n"); sent = 1
    elif sent == 1 and b"Continue?" in buf:
        os.write(fd, b"y"); sent = 2
sys.stdout.write(buf.decode("utf-8", "replace"))
' 2>&1)
check "pregunta por el alias" "$out" "Add an alias for godev"
check "pide confirmación" "$out" "Continue?"
check "instala tras confirmar" "$out" "Shell integration installed"
grep -qE '^eval "\$\((command )?godev --init zsh\)"$' ~/.zshrc && ok "línea escrita en modo interactivo" || bad "no escribió la línea"
grep -q "^alias " ~/.zshrc && bad "agregó un alias sin pedirlo" || ok "sin alias por defecto"

echo ""
echo "═══ 10. cancelar en modo interactivo NO toca nada ═══"
printf '# intacto\n' > ~/.zshrc
before=$(md5sum ~/.zshrc | cut -d" " -f1)
out=$(python3 -c '
import pty, os, sys, select
pid, fd = pty.fork()
if pid == 0:
    os.execvp("/home/tester/.local/bin/godev", ["godev", "--init", "--install"])
buf = b""; sent = 0
while True:
    r, _, _ = select.select([fd], [], [], 5)
    if not r: break
    try: d = os.read(fd, 4096)
    except OSError: break
    if not d: break
    buf += d
    if sent == 0 and b"skip" in buf:
        os.write(fd, b"\n"); sent = 1
    elif sent == 1 and b"Continue?" in buf:
        os.write(fd, b"n"); sent = 2
sys.stdout.write(buf.decode("utf-8", "replace"))
' 2>&1)
check "reporta cancelación" "$out" "Cancelled"
after=$(md5sum ~/.zshrc | cut -d" " -f1)
[[ "$before" == "$after" ]] && ok "el .zshrc quedó BYTE A BYTE igual" || bad "modificó el .zshrc al cancelar"

echo ""
echo "═══ 11. installer.sh de punta a punta ═══"
rm -rf ~/.local/bin/godev ~/.config/godev
printf '# nuevo usuario\n' > ~/.zshrc
mkdir -p ~/work/proj1
cd /src
out=$(python3 -c '
import pty, os, sys, select
pid, fd = pty.fork()
if pid == 0:
    os.chdir("/src")
    os.execvp("zsh", ["zsh", "/src/installer.sh"])
buf = b""; step = 0
while True:
    r, _, _ = select.select([fd], [], [], 20)
    if not r: break
    try: d = os.read(fd, 4096)
    except OSError: break
    if not d: break
    buf += d
    if step == 0 and b"Continue without FZF" in buf:
        os.write(fd, b"y"); step = 1
    elif step >= 1 and b"Base directory for projects" in buf and step == 1:
        os.write(fd, b"/home/tester/work\n"); step = 2
sys.stdout.write(buf.decode("utf-8", "replace"))
' 2>&1)
cd ~
check "instalador delega la integración" "$out" "Shell integration configured"
check "verificación post-install OK" "$out" "Installation completed"
grep -qE '^eval "\$\((command )?godev --init zsh\)"$' ~/.zshrc && ok "installer dejó la línea eval" || bad "installer no dejó la línea"
grep -q '^godev() {' ~/.zshrc && bad "installer escribió la función vieja" || ok "installer NO escribió función literal"
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev proj1 >/dev/null 2>&1; echo $PWD')
check "navega tras instalación limpia" "$res" "/home/tester/work/proj1"

echo ""
echo "═══ 12. migración desde una instalación pre-2.7.0 real ═══"
# Reproduce el caso que falló en la vida real: el wrapper viejo llama a
# ~/.local/bin/godev por ruta absoluta, y ese binario no conoce --init.
rm -rf ~/.local/bin/godev ~/brew
# El test 11 dejó la config apuntando a ~/work; restaurar la base de esta suite
mkdir -p ~/.config/godev
cat > ~/.config/godev/config << 'CFG'
GODEV_BASE_DIR="/home/tester/dev"
GODEV_FZF_ENABLED="false"
CFG
git -C /src show v2.6.0:godev > ~/.local/bin/godev 2>/dev/null && chmod +x ~/.local/bin/godev
mkdir -p ~/brew/Cellar/godev/2.7.0/bin ~/brew/bin
cp /src/godev ~/brew/Cellar/godev/2.7.0/bin/godev
chmod +x ~/brew/Cellar/godev/2.7.0/bin/godev
ln -sf ~/brew/Cellar/godev/2.7.0/bin/godev ~/brew/bin/godev
cat > ~/.zshrc << 'EOF'
export PATH="$HOME/brew/bin:$PATH:$HOME/.local/bin"

# godev - Function wrapper (added by installer)
godev() {
    local result
    if [[ "$1" =~ ^- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        echo "$result"
        return $exit_code
    fi
}
EOF

# El síntoma: `godev --init` a través del wrapper viejo NO funciona
out=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev --init --install --yes' 2>&1 </dev/null)
[[ "$out" == *"Shell integration installed"* ]] && bad "el wrapper viejo alcanzó --init (inesperado)" || ok "reproducido: el wrapper viejo NO llega a --init"

# El arreglo documentado: llamar al binario nuevo por ruta explícita
out=$(~/brew/bin/godev --init --install --yes 2>&1 </dev/null)
check "la ruta explícita sí funciona" "$out" "Shell integration installed"
check "avisa del binario viejo (shadowing)" "$out" "/home/tester/.local/bin/godev"
rm -f ~/.local/bin/godev
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev gamma >/dev/null 2>&1; echo $PWD')
check "navega tras migrar" "$res" "/home/tester/dev/gamma"
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev --init zsh | grep godev_bin=')
check "el wrapper ya apunta a la copia de brew" "$res" "/home/tester/brew/bin/godev"

echo ""
echo "═══ 13. shell envenenado: función vieja cargada al sourcear ═══"
# Reproduce el fallo real: se migra desde un shell que YA tiene la función
# vieja definida. Sourcear .zshrc hace que esa función intercepte el propio
# eval de la integración nueva, el eval recibe vacío y la vieja sobrevive.
rm -rf ~/.local/bin/godev ~/brew
mkdir -p ~/.local/bin ~/brew/Cellar/godev/2.7.0/bin ~/brew/bin
cat > ~/.config/godev/config << 'CFG'
GODEV_BASE_DIR="/home/tester/dev"
GODEV_FZF_ENABLED="false"
CFG
cp /src/godev ~/brew/Cellar/godev/2.7.0/bin/godev
chmod +x ~/brew/Cellar/godev/2.7.0/bin/godev
ln -sf ~/brew/Cellar/godev/2.7.0/bin/godev ~/brew/bin/godev
git -C /src show v2.6.0:godev > ~/.local/bin/godev 2>/dev/null && chmod +x ~/.local/bin/godev
cat > ~/.zshrc << 'EOF'
export PATH="$HOME/brew/bin:$PATH:$HOME/.local/bin"

# godev - Function wrapper (added by installer)
godev() {
    local result
    if [[ "$1" =~ ^- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        echo "$result"
        return $exit_code
    fi
}
EOF
~/brew/bin/godev --init --install --yes >/dev/null 2>&1
rm -f ~/.local/bin/godev

check "la línea usa 'command'" "$(grep '^eval ' ~/.zshrc)" 'command godev --init zsh'

# El escenario exacto: shell con la función vieja YA cargada, que sourcea .zshrc
res=$(zsh -c '
godev() { command ~/.local/bin/godev "$@"; }   # la función vieja, ya cargada
source ~/.zshrc >/dev/null 2>&1                 # esto la debe reemplazar
godev --version 2>&1')
check "sobrevive al shell envenenado" "$res" "godev version"
[[ "$res" == *"no such file or directory"* ]] && bad "la función vieja secuestró el eval" || ok "la función vieja NO secuestró el eval"

# Y navegar sigue funcionando en ese shell
res=$(zsh -c '
godev() { command ~/.local/bin/godev "$@"; }
source ~/.zshrc >/dev/null 2>&1
godev alpha >/dev/null 2>&1; echo $PWD')
check "navega tras el rescate" "$res" "/home/tester/dev/alpha"

# Regresión: la forma vieja de la línea (sin `command`) debe ser reemplazada
printf '# base\n%s\n' 'eval "$(godev --init zsh)"' > ~/.zshrc
~/brew/bin/godev --init --install --yes >/dev/null 2>&1
n=$(grep -c 'godev --init zsh' ~/.zshrc)
[[ "$n" == "1" ]] && ok "la línea vieja se reemplaza, no se duplica" || bad "quedaron $n líneas"
check "y queda en la forma nueva" "$(grep '^eval ' ~/.zshrc)" 'command godev'

echo ""
echo "═══ 14. multi-match SIN fzf (zsh: `status` es readonly) ═══"
# En zsh `status` es una variable especial de sólo lectura (sinónimo de $?).
# Un `local status=...` aborta el bucle y el multi-match manual queda roto:
# en vez de la lista numerada, ofrece crear un proyecto.
export GIT_AUTHOR_NAME=t GIT_AUTHOR_EMAIL=t@t GIT_COMMITTER_NAME=t GIT_COMMITTER_EMAIL=t@t
cp /src/godev ~/.local/bin/godev && chmod +x ~/.local/bin/godev
mkdir -p ~/.config/godev
printf 'GODEV_BASE_DIR="/home/tester/dev"\nGODEV_FZF_ENABLED="false"\n' > ~/.config/godev/config
for prj in multi-one multi-two; do
    mkdir -p ~/dev/$prj && (cd ~/dev/$prj && git init -q && echo x > f && git add . && git commit -qm init)
done
(cd ~/dev/multi-one && echo change >> f)
out=$(echo "" | ~/.local/bin/godev multi- 2>&1)
[[ "$out" == *"read-only variable"* ]] && bad "regresión: 'local status' rompe el bucle" || ok "sin error de variable de sólo lectura"
check "muestra la lista de coincidencias" "$out" "Multiple projects found matching"
plain=$(print -r -- "$out" | sed $'s/\033\[[0-9;]*m//g')
check "numera la primera opción" "$plain" " 1) multi-one"
check "numera la segunda opción" "$plain" " 2) multi-two"
check "marca el proyecto modificado" "$out" "multi-one"
check "pide selección" "$out" "Select a number (1-2)"

echo ""
echo "═══ 15. salida en inglés, sin restos en español ═══"
allout=""
allout+=$(~/.local/bin/godev --init bash 2>&1)
allout+=$(~/.local/bin/godev --init pepe 2>&1)
allout+=$(echo "" | ~/.local/bin/godev multi- 2>&1)
allout+=$(echo "n" | ~/.local/bin/godev inexistente-xyz 2>&1)
allout+=$(~/.local/bin/godev --list 2>&1)
allout+=$(~/.local/bin/godev --help 2>&1)
if echo "$allout" | grep -qE '[áéíóúñ¿¡]'; then
    bad "quedó texto en español en la salida"
    echo "$allout" | grep -oE '[^ ]*[áéíóúñ¿¡][^ ]*' | sort -u | head -5 | sed 's/^/      /'
else
    ok "ninguna salida contiene caracteres del español"
fi
check "LAST COMMIT en inglés" "$(~/.local/bin/godev --list 2>&1)" "today"

echo ""
echo "═══════════════════════════════════════"
echo "  PASS: $PASS   FAIL: $FAIL"
echo "═══════════════════════════════════════"
[[ $FAIL -eq 0 ]]
