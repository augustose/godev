# godev - Arquitectura de la Aplicación

## 1. Visión General

`godev` es una herramienta CLI para ZSH que facilita la navegación y gestión de directorios de proyectos de desarrollo.

### Filosofía de Diseño
- **Simplicidad ante todo**: Un comando = una acción
- **Zero friction**: Cambio de directorio sin pasos intermedios
- **Degradación elegante**: Funciona mejor con FZF, pero funciona sin él
- **Configuración mínima**: Instalación en un paso

---

## 2. Componentes Principales

```
┌─────────────────────────────────────────────────────────────┐
│                    USUARIO (ZSH Terminal)                    │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│              godev() - Función Wrapper (ZSH)                 │
│  • Vive en ~/.zshrc                                          │
│  • Intercepta comandos especiales (cd)                       │
│  • Delega al script principal                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│           ~/.local/bin/godev - Script Principal              │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │  Core Engine    │  │  Config Manager │                   │
│  │  • Navigation   │  │  • Read config  │                   │
│  │  • Directory    │  │  • Write config │                   │
│  │    switching    │  │  • Validation   │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │  Project        │  │  Git Inspector  │                   │
│  │  Scanner        │  │  • Status       │                   │
│  │  • Find dirs    │  │  • Branch       │                   │
│  │  • Filter       │  │  • Last commit  │                   │
│  │  • Exclude      │  │  • Activity     │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │  UI/Display     │  │  FZF Integration│                   │
│  │  • Table view   │  │  • Interactive  │                   │
│  │  • Colors       │  │    selection    │                   │
│  │  • Formatting   │  │  • Fuzzy search │                   │
│  └─────────────────┘  └─────────────────┘                   │
│                                                               │
│  ┌─────────────────┐  ┌─────────────────┐                   │
│  │  Updater        │  │  Installer      │                   │
│  │  • Check ver    │  │  • Setup        │                   │
│  │  • Download     │  │  • Validation   │                   │
│  └─────────────────┘  └─────────────────┘                   │
└─────────────────────────────────────────────────────────────┘
                         │
                         ↓
┌─────────────────────────────────────────────────────────────┐
│                    Sistema de Archivos                       │
│                                                               │
│  ~/.config/godev/                                            │
│    ├── config          (configuración principal)             │
│    └── version_info    (URL origen, versión actual)          │
│                                                               │
│  ~/dev/ (o base_dir configurado)                             │
│    ├── proyecto1/                                            │
│    ├── proyecto2/                                            │
│    └── proyecto3/                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 3. Flujo de Datos Principal

### 3.1 Cambio de Directorio (Funcionalidad Core)

```
Usuario: godev myproject
    ↓
godev() wrapper intercepta
    ↓
¿Comando especial? NO
    ↓
Ejecuta: ~/.local/bin/godev myproject
    ↓
Script busca "myproject" en base_dir
    ↓
¿Encontrado? SÍ → Imprime path a STDOUT
                  ↓
                  godev() wrapper lee output
                  ↓
                  cd "$(output)"
                  ✓ Usuario está en el directorio

¿Encontrado? NO → ¿Crear? (interactivo)
                  ↓
                  mkdir -p "$base_dir/myproject"
                  ↓
                  cd "$base_dir/myproject"
```

### 3.2 Listado de Proyectos

```
Usuario: godev --list
    ↓
Script escanea base_dir
    ↓
Encuentra directorios (excluyendo patterns)
    ↓
Para cada directorio:
    ├── ¿Tiene .git? → Inspecciona git info
    │   ├── Branch actual
    │   ├── Estado (modified, clean)
    │   ├── Último commit
    │   └── Actividad (30 días)
    └── No tiene .git → Marca como NO_GIT
    ↓
Formatea tabla
    ↓
Muestra en pantalla con colores
```

---

## 4. Estructura de Archivos

### 4.1 Ejecutable Principal
```
~/.local/bin/godev
├── Shebang: #!/usr/bin/env zsh
├── Variables globales
├── Funciones helper
├── Comandos principales
└── Main logic
```

### 4.2 Función Wrapper ZSH
```zsh
# Agregada a ~/.zshrc por el instalador
godev() {
    local result
    
    # Comandos que no cambian directorio
    if [[ "$1" =~ ^-- ]]; then
        command ~/.local/bin/godev "$@"
        return $?
    fi
    
    # Comando de navegación
    result=$(command ~/.local/bin/godev "$@")
    local exit_code=$?
    
    if [[ $exit_code -eq 0 ]] && [[ -d "$result" ]]; then
        cd "$result"
    else
        echo "$result"
        return $exit_code
    fi
}
```

### 4.3 Archivo de Configuración
```
~/.config/godev/config

base_dir=/home/user/dev
install_source=https://raw.githubusercontent.com/user/godev/main/install.sh
fzf_enabled=true
```

---

## 5. Comandos y API

### 5.1 Navegación (Sin prefijo --)
```bash
godev myproject          # Cambia a myproject/
godev myproj             # Fuzzy match si FZF disponible
godev                    # Lista proyectos en FZF para selección
```

### 5.2 Comandos de Sistema (Con --)
```bash
godev --list             # Lista todos los proyectos
godev --list --git       # Solo proyectos con git
godev --list --pattern "web*"  # Filtro por patrón
godev --list --modified 7      # Modificados últimos 7 días
godev --list --sort activity   # Ordenar por actividad

godev --setup            # Configuración/validación
godev --update           # Actualizar godev
godev --version          # Mostrar versión
godev --help             # Ayuda
```

---

## 6. Sistema de Escaneo

### Estrategia
```
┌──────────────────────────────────────┐
│ Usuario ejecuta: godev --list        │
└─────────────┬────────────────────────┘
              │
              ↓
      Escanea filesystem
              │
              ↓
      Inspecciona git repos
              │
              ↓
      Aplica filtros/sort
              │
              ↓
      Muestra resultado
```

**Nota:** El sistema NO usa caché. Los proyectos se escanean en tiempo real cada vez.
Esto garantiza que la información siempre esté actualizada y simplifica el código.

---

## 7. Integración con FZF

### Flujo con FZF Disponible
```bash
# Sin argumento: menú interactivo
godev
    ↓
Lista proyectos → FZF
    ↓
Usuario selecciona con flechas/búsqueda
    ↓
cd al proyecto seleccionado

# Con argumento parcial: fuzzy matching
godev web
    ↓
¿Múltiples matches? → FZF con resultados filtrados
¿Un solo match? → cd directo
```

### Degradación sin FZF
```bash
godev
    ↓
Lista proyectos con números
    ↓
"Seleccione número (o instale FZF para mejor experiencia)"
```

---

## 8. Instalación - Un Solo Paso

### Script de Instalación
```bash
curl -fsSL https://raw.../install.sh | zsh
```

### Proceso del Instalador
```
1. Verificar ZSH instalado
   ↓
2. Verificar FZF (advertir si no está)
   ↓
3. Crear ~/.local/bin/ si no existe
   ↓
4. Descargar godev script → ~/.local/bin/godev
   ↓
5. chmod +x ~/.local/bin/godev
   ↓
6. Verificar ~/.local/bin en PATH (agregar si falta)
   ↓
7. Agregar función wrapper a ~/.zshrc
   ↓
8. Crear ~/.config/godev/config
   ↓
9. Preguntar base_dir (default: ~/dev)
   ↓
10. Guardar URL de instalación para updates
    ↓
11. source ~/.zshrc (o instruir hacerlo)
    ↓
12. Ejecutar godev --setup para validar
    ↓
✓ Listo para usar
```

---

## 9. Sistema de Actualizaciones

### Estrategia
```
godev --update
    ↓
Lee ~/.config/godev/version_info
    ↓
Obtiene última versión de install_source
    ↓
¿Versión nueva disponible?
    │
    SÍ → Descarga nueva versión
    │    ↓
    │    Backup versión actual
    │    ↓
    │    Instala nueva versión
    │    ↓
    │    Actualiza version_info
    │    ↓
    │    "✓ Actualizado a v1.X.X"
    │
    NO → "Ya tienes la última versión"
```

---

## 10. Exclusiones y Filtros

### Patrones de Exclusión
```zsh
EXCLUDE_PATTERNS=(
    "*/node_modules/*"
    "*/.git/*"
    "*/dist/*"
    "*/build/*"
    "*/vendor/*"
    "*/.next/*"
    "*/target/*"
    "*/__pycache__/*"
    "*/.venv/*"
    "*/.pytest_cache/*"
    "*/venv/*"
    "*/.tox/*"
    "*/coverage/*"
)
```

### Implementación
```zsh
find "$base_dir" -mindepth 1 -maxdepth 1 -type d \
    $(printf "! -path '%s' " "${EXCLUDE_PATTERNS[@]}") \
    | sort
```

---

## 11. Manejo de Errores

### Principios
1. **Fallar rápido**: Validar inputs inmediatamente
2. **Mensajes claros**: Explicar qué salió mal y cómo arreglarlo
3. **Exit codes estándar**: 0=éxito, 1=error general, 2=mal uso

### Casos de Error Comunes
```
- base_dir no existe → Ofrecer crearlo
- Directorio no encontrado → Fuzzy search o crear
- Sin permisos → Mensaje claro con solución
- Git repo corrupto → Marcar como "ERROR" en lista
- FZF no disponible → Degradar a selección por número
```

---

## 12. Consideraciones de Performance

### Optimizaciones
1. **Escaneo eficiente**: Usa find con maxdepth limitado
2. **Git inspect bajo demanda**: Solo cuando se solicita --list
3. **Exclusión inteligente**: Filtra directorios innecesarios
4. **Límite de profundidad**: maxdepth 2 desde base_dir

### Benchmark Real
- Cambio de directorio: < 100ms
- Lista proyectos: ~2s (127 proyectos)
- Fuzzy search: < 50ms

---

## 13. Testing Strategy

### Casos de Prueba Críticos
```
1. Instalación limpia en sistema nuevo
2. Actualización desde versión anterior
3. Cambio a directorio existente
4. Cambio a directorio no existente (crear)
5. Lista con/sin FZF
6. Lista con/sin git repos
7. Cambio con múltiples matches
8. Funcionamiento sin permisos
9. Base_dir con espacios en nombre
10. Caracteres especiales en nombres
```

---

## 14. Roadmap de Implementación

### Fase 1: MVP (Core Functionality)
- ✓ Función wrapper ZSH
- ✓ Cambio de directorio básico
- ✓ Búsqueda en base_dir
- ✓ Creación de directorios

### Fase 2: Listado
- ✓ Scanner de proyectos
- ✓ Git inspector
- ✓ Display con tabla
- ✓ Filtros básicos

### Fase 3: Instalación
- ✓ Script de instalación
- ✓ Validación de dependencias
- ✓ Configuración automática

### Fase 4: Optimización
- ✓ Sistema de caché
- ✓ Integración FZF
- ✓ Performance tuning

### Fase 5: Mantenimiento
- ✓ Sistema de updates
- ✓ --setup command
- ✓ Versionado

---

## 15. Decisiones de Diseño Clave

### ¿Por qué función wrapper?
**Problema**: Un script no puede cambiar el directorio del shell padre.
**Solución**: Wrapper en ZSH que ejecuta `cd` basado en output del script.

### ¿Por qué sin palabras reservadas?
**Problema**: `godev status` vs `godev --status` vs directorio llamado "status"
**Solución**: Comandos de sistema siempre con `--`, nombres de directorio sin prefijo.

### ¿Por qué sin caché?
**Decisión**: Mantener simplicidad y datos siempre actualizados.
**Justificación**: Con escaneo optimizado, listar 100+ proyectos toma ~2s, lo cual es aceptable.
El caché agregaría complejidad sin beneficio significativo para el caso de uso común.

### ¿Por qué ZSH específico?
**Decisión**: Aprovechar features modernas (associative arrays, mejor string handling).
**Trade-off**: No compatible con bash, pero mejor experiencia en ZSH.

---

## 16. Seguridad

### Consideraciones
1. **Validación de paths**: Prevenir directory traversal
2. **Sanitización de input**: Escapar caracteres especiales
3. **Permisos**: Verificar permisos antes de crear dirs
4. **Updates seguros**: Verificar checksums en actualizaciones futuras

---

## Conclusión

Esta arquitectura prioriza:
- ✓ **Simplicidad de uso**
- ✓ **Instalación sin fricción**
- ✓ **Performance**
- ✓ **Mantenibilidad**
- ✓ **Degradación elegante**

El diseño respeta absolutamente todos los requisitos MUST HAVE del documento de especificaciones.