#!/bin/zsh

# godev - Navegar a directorios de proyectos de desarrollo
# Uso: godev <patrón> [-f] [-v]
# Versión: 1.0.0

VERSION="1.0.0"

# Directorio base de proyectos (ajusta según tu configuración)
DEV_BASE="${HOME}/DEV"

# Verificar que el directorio base existe
if [[ ! -d "$DEV_BASE" ]]; then
    echo "Error: El directorio base $DEV_BASE no existe"
    return 1
fi

# Desactivar el alias temporalmente si existe
if alias godev &>/dev/null; then
    unalias godev
fi

# Función principal
_godev_func() {
    local pattern=""
    local force_create=false
    
    # Procesar argumentos
    for arg in "$@"; do
        case "$arg" in
            -v|--version)
                echo "godev versión $VERSION"
                return 0
                ;;
            -f|--force)
                force_create=true
                ;;
            -h|--help)
                echo "godev - Navegar a directorios de proyectos de desarrollo"
                echo ""
                echo "Uso: godev <patrón> [-f] [-v]"
                echo ""
                echo "Opciones:"
                echo "  <patrón>        Patrón de búsqueda del directorio"
                echo "  -f, --force     Forzar creación del directorio si no existe"
                echo "  -v, --version   Mostrar versión del script"
                echo "  -h, --help      Mostrar esta ayuda"
                return 0
                ;;
            -*)
                echo "Opción desconocida: $arg"
                echo "Usa 'godev -h' para ver la ayuda"
                return 1
                ;;
            *)
                pattern="$arg"
                ;;
        esac
    done
    
    # Verificar que se proporcionó un patrón
    if [[ -z "$pattern" ]]; then
        echo "Uso: godev <patrón> [-f] [-v]"
        echo "  -f, --force     Forzar creación del directorio si no existe"
        echo "  -v, --version   Mostrar versión"
        echo "  -h, --help      Mostrar ayuda completa"
        return 1
    fi
    
    # Buscar directorios que coincidan con el patrón
    # Excluir: node_modules, .git, dist, build, vendor, .next, etc.
    local matches=()
    while IFS= read -r -d '' dir; do
        matches+=("$dir")
    done < <(find "$DEV_BASE" -maxdepth 3 -type d \
        -not -path "*/node_modules/*" \
        -not -path "*/.git/*" \
        -not -path "*/dist/*" \
        -not -path "*/build/*" \
        -not -path "*/vendor/*" \
        -not -path "*/.next/*" \
        -not -path "*/target/*" \
        -not -path "*/__pycache__/*" \
        -not -path "*/.venv/*" \
        -iname "*${pattern}*" -print0 2>/dev/null)
    
    local count=${#matches[@]}
    
    if [[ $count -eq 0 ]]; then
        # No se encontraron coincidencias
        if [[ "$force_create" == true ]]; then
            local new_dir="${DEV_BASE}/${pattern}"
            mkdir -p "$new_dir"
            echo "✓ Directorio creado: $new_dir"
            cd "$new_dir"
        else
            echo "No se encontró ningún directorio con el patrón: $pattern"
            echo "Usa 'godev $pattern -f' para crear el directorio"
            return 1
        fi
    elif [[ $count -eq 1 ]]; then
        # Una sola coincidencia - cambiar al directorio
        cd "${matches[1]}"
        echo "→ ${matches[1]}"
    else
        # Múltiples coincidencias - mostrar lista
        echo "Se encontraron $count directorios:"
        echo ""
        local i=1
        for dir in "${matches[@]}"; do
            echo "  [$i] ${dir#$DEV_BASE/}"
            ((i++))
        done
        echo ""
        echo -n "Selecciona un número (1-$count) o presiona Enter para cancelar: "
        read selection
        
        if [[ "$selection" =~ ^[0-9]+$ ]] && [[ "$selection" -ge 1 ]] && [[ "$selection" -le $count ]]; then
            cd "${matches[$selection]}"
            echo "→ ${matches[$selection]}"
        else
            echo "Cancelado"
            return 1
        fi
    fi
}

# Ejecutar la función
_godev_func "$@"