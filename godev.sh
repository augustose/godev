#!/bin/bash

godev_function() {
    # --- CONFIGURACIÓN ---
    local BASE_DIR="$HOME/DEV"
    local TREE_LEVEL=2
    local FORCE_CREATE=0
    local OPTIND

    show_help() {
        echo "godev - Navegador inteligente de proyectos"
        echo ""
        echo "Uso: godev [OPCIONES] <patrón>"
        echo ""
        echo "Busca proyectos en $BASE_DIR que coincidan con <patrón>."
        echo ""
        echo "Comportamiento:"
        echo "  • 1 coincidencia  → Navega automáticamente"
        echo "  • Varias          → Lista las opciones encontradas"
        echo "  • 0 coincidencias → Sugiere crear con -f"
        echo ""
        echo "Opciones:"
        echo "  -f           Crear directorio si no existe."
        echo "  -l [nivel]   Nivel de tree (default: 2)."
        echo "  -h           Mostrar esta ayuda."
    }

    # Sin argumentos → Ayuda
    if [ $# -eq 0 ]; then
        show_help
        return 0
    fi

    # --- Procesar opciones ---
    while getopts ":fl:h" opt; do
      case $opt in
        f)
          FORCE_CREATE=1
          ;;
        l)
          if [[ "$OPTARG" =~ ^[0-9]+$ ]]; then
              TREE_LEVEL="$OPTARG"
          else
              TREE_LEVEL=2
              OPTIND=$((OPTIND - 1))
          fi
          ;;
        h)
          show_help
          return 0
          ;;
        :) 
          if [ "$OPTARG" = "l" ]; then
              TREE_LEVEL=2
          else
              echo "❌ Error: -${OPTARG} requiere un valor." >&2
              return 1
          fi
          ;;
        \?)
          echo "❌ Error: Opción inválida -${OPTARG}." >&2
          return 1
          ;;
      esac
    done

    shift $((OPTIND-1))
    local PATTERN="$1"

    if [ -z "$PATTERN" ]; then
        echo "❌ Error: Faltó especificar el patrón de búsqueda."
        return 1
    fi

    # --- Verificar que exista el directorio base ---
    if [ ! -d "$BASE_DIR" ]; then
        echo "❌ Error: No existe el directorio base '$BASE_DIR'."
        echo "Créalo primero con: mkdir -p $BASE_DIR"
        return 1
    fi

    # --- BÚSQUEDA DE PROYECTOS ---
    # Buscar directorios que contengan el patrón (búsqueda recursiva 1 nivel)
    local all_matches=()
    while IFS= read -r -d '' dir; do
        all_matches+=("$dir")
    done < <(find "$BASE_DIR" -maxdepth 2 -type d -iname "*${PATTERN}*" -print0 2>/dev/null)

    # Filtrar resultados: excluir BASE_DIR y directorio del script
    local matches=()
    local SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    for dir in "${all_matches[@]}"; do
        # Excluir el BASE_DIR mismo y el directorio donde está el script
        if [ "$dir" != "$BASE_DIR" ] && [ "$dir" != "$SCRIPT_DIR" ]; then
            matches+=("$dir")
        fi
    done

    local count=${#matches[@]}

    # --- CASO 1: No hay coincidencias ---
    if [ $count -eq 0 ]; then
        if [ "$FORCE_CREATE" -eq 1 ]; then
            local NEW_PROJECT="$BASE_DIR/$PATTERN"
            echo "✨ Creando nuevo proyecto: $NEW_PROJECT"
            mkdir -p "$NEW_PROJECT"
            cd "$NEW_PROJECT" || return 1
            
            echo "🚀 Proyecto: $PATTERN"
            echo "📂 Ruta:     $NEW_PROJECT"
            echo "---------------------------------"
            
            if command -v tree &> /dev/null; then
                tree -L "$TREE_LEVEL"
            else
                ls -la
            fi
        else
            echo "❌ No se encontró ningún proyecto que coincida con: '$PATTERN'"
            echo ""
            echo "Usa 'godev -f $PATTERN' para crear un nuevo proyecto."
            return 1
        fi
        return 0
    fi

    # --- CASO 2: Una sola coincidencia ---
    if [ $count -eq 1 ]; then
        local TARGET="${matches[0]}"
        cd "$TARGET" || return 1
        
        local PROJECT_NAME=$(basename "$TARGET")
        echo "🚀 Proyecto: $PROJECT_NAME"
        echo "📂 Ruta:     $TARGET"
        echo "---------------------------------"
        
        if command -v tree &> /dev/null; then
            tree -L "$TREE_LEVEL"
        else
            ls -la
        fi
        return 0
    fi

    # --- CASO 3: Múltiples coincidencias ---
    echo "🔍 Se encontraron $count proyectos que coinciden con '$PATTERN':"
    echo ""
    for ((i=0; i<count; i++)); do
        local dir_name=$(basename "${matches[$i]}")
        local parent_dir=$(dirname "${matches[$i]}")
        local parent_name=$(basename "$parent_dir")
        
        # Mostrar jerarquía si está en subcarpeta
        if [ "$parent_dir" != "$BASE_DIR" ]; then
            echo "  $((i+1)). $parent_name/$dir_name"
        else
            echo "  $((i+1)). $dir_name"
        fi
    done
    echo ""
    echo "💡 Refina tu búsqueda con un patrón más específico."
    return 0
}

godev_function "$@"
unset -f godev_function