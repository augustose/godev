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
check "instala sin preguntar" "$out" "✓ Integración instalada"
check "reporta el binario" "$out" "/home/tester/.local/bin/godev"
grep -qF 'eval "$(godev --init zsh)"' ~/.zshrc && ok "línea eval presente" || bad "línea eval ausente"
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
before=$(grep -cF 'eval "$(godev --init zsh)"' ~/.zshrc)
~/.local/bin/godev --init --install --yes >/dev/null 2>&1
after=$(grep -cF 'eval "$(godev --init zsh)"' ~/.zshrc)
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
grep -qF 'eval "$(godev --init zsh)"' ~/.zshrc && ok "línea nueva presente" || bad "falta línea nueva"
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
check "detecta gestión por Homebrew" "$out" "la gestiona Homebrew"
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
check "anuncia versión nueva" "$out" "Hay una versión nueva"
[[ "$out" == *"la gestiona Homebrew"* ]] && bad "confundió standalone con brew" || ok "detectado como standalone"

echo ""
echo "═══ 8. errores de --init ═══"
out=$(~/.local/bin/godev --init bash 2>&1); check "rechaza bash" "$out" "sólo soporta zsh"
out=$(~/.local/bin/godev --init pepe 2>&1); check "rechaza arg inválido" "$out" "Argumento desconocido"
out=$(~/.local/bin/godev --init --install --yes --alias '1mal' 2>&1); check "rechaza alias inválido" "$out" "no es un nombre de alias válido"

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
    if sent == 0 and b"alias" in buf and b"omitir" in buf:
        os.write(fd, b"\n"); sent = 1
    elif sent == 1 and b"Continuar" in buf:
        os.write(fd, b"y"); sent = 2
sys.stdout.write(buf.decode("utf-8", "replace"))
' 2>&1)
check "pregunta por el alias" "$out" "¿Agregar un alias"
check "pide confirmación" "$out" "¿Continuar?"
check "instala tras confirmar" "$out" "Integración instalada"
grep -qF 'eval "$(godev --init zsh)"' ~/.zshrc && ok "línea escrita en modo interactivo" || bad "no escribió la línea"
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
    if sent == 0 and b"omitir" in buf:
        os.write(fd, b"\n"); sent = 1
    elif sent == 1 and b"Continuar" in buf:
        os.write(fd, b"n"); sent = 2
sys.stdout.write(buf.decode("utf-8", "replace"))
' 2>&1)
check "reporta cancelación" "$out" "Cancelado"
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
grep -qF 'eval "$(godev --init zsh)"' ~/.zshrc && ok "installer dejó la línea eval" || bad "installer no dejó la línea"
grep -q '^godev() {' ~/.zshrc && bad "installer escribió la función vieja" || ok "installer NO escribió función literal"
res=$(zsh -c 'source ~/.zshrc >/dev/null 2>&1; godev proj1 >/dev/null 2>&1; echo $PWD')
check "navega tras instalación limpia" "$res" "/home/tester/work/proj1"

echo ""
echo "═══════════════════════════════════════"
echo "  PASS: $PASS   FAIL: $FAIL"
echo "═══════════════════════════════════════"
[[ $FAIL -eq 0 ]]
