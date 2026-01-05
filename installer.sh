#!/usr/bin/env zsh

# godev Installer
# Un solo paso para instalar godev

set -e

# Colores
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
BLUE=$'\033[0;34m'
CYAN=$'\033[0;36m'
BOLD=$'\033[1m'
NC=$'\033[0m'

INSTALL_DIR="$HOME/.local/bin"
GODEV_SCRIPT="$INSTALL_DIR/godev"
ZSHRC="$HOME/.zshrc"

# URL del script principal
SCRIPT_URL="https://raw.githubusercontent.com/augustose/godev/main/godev"

echo "${BOLD}${CYAN}"
cat << "EOF"
   __ _  ___     __| | _____   __
  / _` |/ _ \   / _` |/ _ \ \ / /
 | (_| | (_) | | (_| |  __/\ V / 
  \__, |\___/   \__,_|\___| \_/  
  |___/                           
  
  Demystify Your Development Tree
  Navigate 100+ projects in seconds ⚡
EOF
echo "${NC}"

echo "${BOLD}godev installer v1.0.0${NC}"
echo ""

# ============================================================================
# VERIFICACIONES
# ============================================================================

# Verificar instalación existente
if [[ -x "$GODEV_SCRIPT" ]]; then
    CURRENT_VERSION=$(~/.local/bin/godev --version 2>/dev/null | grep -o '[0-9.]*' || echo "desconocida")
    echo "${YELLOW}⚠ godev ya está instalado (versión $CURRENT_VERSION)${NC}"
    echo -n "¿Actualizar/reinstalar? (s/N): "
    read -k 1 reinstall
    echo
    echo ""
    if [[ ! "$reinstall" =~ ^[sS]$ ]]; then
        echo "${CYAN}Instalación cancelada${NC}"
        exit 0
    fi
fi

echo "${CYAN}[1/10]${NC} Verificando ZSH..."
if [[ -z "$ZSH_VERSION" ]]; then
    echo "${RED}✗ Error: Este instalador debe ejecutarse con ZSH${NC}"
    echo "  Ejecuta: zsh -c '\$(curl -fsSL URL_DEL_INSTALADOR)'"
    exit 1
fi
echo "${GREEN}✓ ZSH detectado${NC}"

echo ""
echo "${CYAN}[2/10]${NC} Verificando FZF..."
if command -v fzf &> /dev/null; then
    echo "${GREEN}✓ FZF instalado${NC}"
    FZF_INSTALLED=true
else
    echo "${YELLOW}⚠ FZF no detectado${NC}"
    echo "  ${BOLD}Se recomienda instalar FZF para mejor experiencia:${NC}"
    echo "  • macOS: ${CYAN}brew install fzf${NC}"
    echo "  • Ubuntu/Debian: ${CYAN}sudo apt install fzf${NC}"
    echo "  • Fedora: ${CYAN}sudo dnf install fzf${NC}"
    echo ""
    echo -n "¿Continuar sin FZF? (s/N): "
    read -k 1 continue
    echo
    if [[ ! "$continue" =~ ^[sS]$ ]]; then
        echo "${YELLOW}Instalación cancelada. Instala FZF y vuelve a intentar.${NC}"
        exit 0
    fi
    FZF_INSTALLED=false
fi

# ============================================================================
# CREAR DIRECTORIOS
# ============================================================================

echo ""
echo "${CYAN}[3/10]${NC} Creando directorios necesarios..."
mkdir -p "$INSTALL_DIR"
mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/godev"
echo "${GREEN}✓ Directorios creados${NC}"

# ============================================================================
# VERIFICAR PATH
# ============================================================================

echo ""
echo "${CYAN}[4/10]${NC} Verificando PATH..."
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
    echo "${YELLOW}⚠ $INSTALL_DIR no está en PATH${NC}"
    echo "  Agregando a ~/.zshrc..."

    # Backup antes de modificar
    cp "$ZSHRC" "$ZSHRC.backup-$(date +%s)" 2>/dev/null

    echo "" >> "$ZSHRC"
    echo "# godev - agregado por instalador" >> "$ZSHRC"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$ZSHRC"
    echo "${GREEN}✓ PATH actualizado${NC}"
else
    echo "${GREEN}✓ PATH correcto${NC}"
fi

# ============================================================================
# DESCARGAR SCRIPT
# ============================================================================

echo ""
echo "${CYAN}[5/10]${NC} Descargando script principal..."

# Para desarrollo/testing: copiar desde archivo local si existe
if [[ -f "./godev" ]]; then
    echo "${YELLOW}  Usando versión local para desarrollo${NC}"
    cp "./godev" "$GODEV_SCRIPT"
else
    # En producción: descargar desde URL
    if command -v curl &> /dev/null; then
        curl -fsSL "$SCRIPT_URL" -o "$GODEV_SCRIPT"
    elif command -v wget &> /dev/null; then
        wget -q "$SCRIPT_URL" -O "$GODEV_SCRIPT"
    else
        echo "${RED}✗ Error: Necesitas curl o wget instalado${NC}"
        exit 1
    fi
fi

echo "${GREEN}✓ Script descargado${NC}"

# ============================================================================
# DAR PERMISOS
# ============================================================================

echo ""
echo "${CYAN}[6/10]${NC} Configurando permisos..."
chmod +x "$GODEV_SCRIPT"
echo "${GREEN}✓ Permisos configurados${NC}"

# ============================================================================
# AGREGAR FUNCIÓN WRAPPER
# ============================================================================

echo ""
echo "${CYAN}[7/10]${NC} Configurando función wrapper en ZSH..."

# Verificar si ya existe
if grep -q "^godev()" "$ZSHRC" 2>/dev/null; then
    echo "${YELLOW}⚠ La función godev ya existe en ~/.zshrc${NC}"
    echo -n "  ¿Reemplazar? (s/N): "
    read -k 1 replace
    echo
    
    if [[ "$replace" =~ ^[sS]$ ]]; then
        # Backup antes de modificar
        cp "$ZSHRC" "$ZSHRC.backup-$(date +%s)"
        # Remover función vieja (entre godev() { y el } que la cierra)
        sed -i.backup '/^godev() {$/,/^}$/d' "$ZSHRC"
        echo "${GREEN}✓ Función anterior removida (backup creado)${NC}"
    else
        echo "${YELLOW}⚠ Usando función existente${NC}"
        SKIP_WRAPPER=true
    fi
fi

if [[ "$SKIP_WRAPPER" != "true" ]]; then
    cat >> "$ZSHRC" << 'EOF'

# godev - Function wrapper (agregado por instalador)
godev() {
    local result
    
    # Comandos que no cambian directorio (empiezan con -)
    if [[ "$1" =~ ^- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi
    
    # Comando de navegación
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?
    
    # Si el resultado es un directorio válido, cambiar a él
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        # Si no, mostrar el output (error o mensaje)
        echo "$result"
        return $exit_code
    fi
}
EOF
    echo "${GREEN}✓ Función wrapper agregada a ~/.zshrc${NC}"
fi

# ============================================================================
# GUARDAR INFO DE INSTALACIÓN
# ============================================================================

echo ""
echo "${CYAN}[8/10]${NC} Guardando información de instalación..."
cat > "${XDG_CONFIG_HOME:-$HOME/.config}/godev/version_info" << EOF
version=2.1.11
install_date=$(date +%s)
install_source=$SCRIPT_URL
fzf_available=$FZF_INSTALLED
EOF
echo "${GREEN}✓ Información guardada${NC}"

# ============================================================================
# CONFIGURACIÓN INICIAL
# ============================================================================

echo ""
echo "${CYAN}[9/10]${NC} Configuración inicial..."
echo ""

# Preguntar directorio base
local default_base="$HOME/dev"
echo -n "Directorio base para proyectos [${CYAN}${default_base}${NC}]: "
read base_dir
base_dir="${base_dir:-$default_base}"
base_dir="${base_dir/#\~/$HOME}"

# Crear si no existe
if [[ ! -d "$base_dir" ]]; then
    echo -n "El directorio no existe. ¿Crearlo? (S/n): "
    read -k 1 create
    echo
    if [[ ! "$create" =~ ^[nN]$ ]]; then
        mkdir -p "$base_dir"
        echo "${GREEN}✓ Directorio creado: $base_dir${NC}"
    else
        echo "${RED}✗ Necesitas un directorio base válido${NC}"
        exit 1
    fi
fi

# Guardar configuración
cat > "${XDG_CONFIG_HOME:-$HOME/.config}/godev/config" << EOF
# godev configuration
GODEV_BASE_DIR="$base_dir"
GODEV_FZF_ENABLED="$FZF_INSTALLED"
GODEV_CACHE_TTL=3600
EOF

echo "${GREEN}✓ Configuración guardada${NC}"

# ============================================================================
# VERIFICACIÓN POST-INSTALACIÓN
# ============================================================================

echo ""
echo "${CYAN}[10/11]${NC} Verificando instalación..."

# Verificar que el script existe y es ejecutable
if [[ -x "$GODEV_SCRIPT" ]]; then
    echo "${GREEN}✓ Script instalado correctamente${NC}"
else
    echo "${RED}✗ Error: Script no encontrado o sin permisos${NC}"
    exit 1
fi

# Verificar que la función wrapper existe en .zshrc
if grep -q "^godev()" "$ZSHRC"; then
    echo "${GREEN}✓ Función wrapper configurada${NC}"
else
    echo "${YELLOW}⚠ Función wrapper no encontrada en .zshrc${NC}"
fi

# Verificar configuración
if [[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/godev/config" ]]; then
    echo "${GREEN}✓ Configuración creada${NC}"
else
    echo "${RED}✗ Error: Archivo de configuración no encontrado${NC}"
    exit 1
fi

# ============================================================================
# FINALIZAR
# ============================================================================

echo ""
echo "${CYAN}[11/11]${NC} Finalizando instalación..."
echo ""

cat << EOF
${GREEN}${BOLD}✓ ¡Instalación completada!${NC}

${BOLD}Próximos pasos:${NC}

1. Recarga tu configuración:
   ${CYAN}source ~/.zshrc${NC}

2. Prueba godev:
   ${CYAN}godev${NC}                 ${GRAY}# Menú interactivo${NC}
   ${CYAN}godev --list${NC}          ${GRAY}# Lista tus proyectos${NC}
   ${CYAN}godev <nombre>${NC}        ${GRAY}# Cambia a un proyecto${NC}

3. Para ayuda:
   ${CYAN}godev --help${NC}

${BOLD}Configuración:${NC}
   Directorio base: ${CYAN}$base_dir${NC}
   FZF disponible: ${CYAN}$FZF_INSTALLED${NC}
   
EOF

if [[ "$FZF_INSTALLED" == "false" ]]; then
    echo "${YELLOW}${BOLD}💡 Recomendación:${NC}"
    echo "   Instala FZF para una experiencia premium:"
    echo "   ${CYAN}brew install fzf${NC} (macOS)"
    echo "   ${CYAN}sudo apt install fzf${NC} (Ubuntu/Debian)"
    echo ""
fi

echo "${BOLD}¡Disfruta godev! 🚀${NC}"
echo ""
