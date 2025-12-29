# Runbook - godev Tools

Este documento describe los scripts de la suite godev y cómo utilizarlos.

---

## install.sh - Script de Instalación

### Descripción
Script de instalación que permite instalar `godev` en cualquier sistema mediante una descarga directa desde GitHub o desde un repositorio local.

### Características Principales

1. **Instalación Remota**
   - Descarga automática del script `godev` desde GitHub cuando se ejecuta vía curl
   - Detección automática del método de ejecución (piped curl vs. archivo local)
   - Limpieza automática de archivos temporales

2. **Instalación Local**
   - Soporte para instalación desde un repositorio clonado localmente
   - Usa el script `godev` del mismo directorio cuando está disponible

3. **Configuración Automática**
   - Crea el directorio de instalación si no existe (`~/.local/bin`)
   - Opción para agregar automáticamente al PATH en `~/.zshrc`
   - Verificación de instalación exitosa

### Instalación

#### Instalación Remota (Recomendada)
```bash
curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/install.sh | zsh
```

#### Instalación Local
```bash
# 1. Clonar el repositorio
git clone https://github.com/augustose/godev.git
cd godev

# 2. Ejecutar el script de instalación
zsh install.sh
```

### Funcionamiento

El script detecta automáticamente cómo está siendo ejecutado:

- **Piped curl**: Cuando se ejecuta mediante `curl ... | zsh`, el script descarga el archivo `godev` desde GitHub y lo instala en `~/.local/bin`
- **Archivo local**: Cuando se ejecuta desde un repositorio clonado, usa el archivo `godev` del mismo directorio

### Actualización de godev

Para actualizar `godev` a la última versión, simplemente ejecuta el mismo comando de instalación:

```bash
curl -fsSL https://raw.githubusercontent.com/augustose/godev/main/install.sh | zsh
```

El script detectará automáticamente que `godev` ya está instalado y te preguntará si deseas actualizarlo. El proceso de actualización:

1. **Detecta la versión instalada**: Muestra la versión actual si está disponible
2. **Pregunta por confirmación**: Te permite confirmar antes de sobrescribir
3. **Descarga la última versión**: Obtiene la versión más reciente desde GitHub
4. **Reemplaza el script**: Actualiza el archivo en `~/.local/bin/godev`
5. **Mantiene la configuración**: No modifica tu PATH ni otras configuraciones

**Nota**: Si `godev` está en tu PATH, podrás usar la nueva versión inmediatamente después de la actualización. Si no está en tu PATH actual, puedes usar la ruta completa: `~/.local/bin/godev version` para verificar la nueva versión.

### Verificación del PATH

El script de instalación verifica automáticamente si `~/.local/bin` está en tu PATH de varias maneras:

1. **PATH actual de la sesión**: Verifica si está disponible en la sesión actual
2. **Archivo ~/.zshrc**: Busca si está configurado en tu archivo de configuración de ZSH
3. **Otros archivos de configuración**: Revisa `~/.zshenv`, `~/.zprofile`, y `~/.profile`

Si el directorio no está en el PATH, el script te ofrece:

- **Agregar automáticamente**: Opción para agregar la línea al `~/.zshrc` automáticamente
- **Comandos manuales**: Instrucciones claras para agregarlo manualmente si prefieres

**Comandos para agregar al PATH manualmente**:

```bash
# Opción 1: Agregar a ~/.zshrc (recomendado, permanente)
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Opción 2: Solo para la sesión actual (temporal)
export PATH="$HOME/.local/bin:$PATH"
```

### Solución de Problemas

#### Error: "godev script not found"
Este error puede ocurrir cuando:
- El script se ejecuta desde un directorio que no contiene el archivo `godev`
- Hay problemas de conectividad al descargar desde GitHub

**Solución**: Asegúrate de tener conexión a internet cuando uses la instalación remota, o clona el repositorio y ejecuta el script localmente.

#### Error: "Failed to download godev script from GitHub"
- Verifica tu conexión a internet
- Verifica que la URL del repositorio sea correcta
- Intenta la instalación local como alternativa

### Requisitos

- **ZSH**: El script requiere ZSH para ejecutarse
- **curl**: Necesario para la instalación remota (generalmente preinstalado en macOS/Linux)
- **Permisos de escritura**: En `~/.local/bin` y opcionalmente en `~/.zshrc`

---

## govap.sh - Verificador Avanzado de Actividad de Proyectos

### Descripción
Script avanzado que analiza todos los repositorios Git en un directorio base (búsqueda recursiva) y muestra un resumen detallado de la actividad de cada proyecto. Proporciona información sobre la última actividad, estado del repositorio, branch actual y estadísticas de commits.

**Búsqueda Recursiva**: El script busca recursivamente en subdirectorios (hasta 5 niveles de profundidad) para encontrar todos los repositorios Git, permitiendo encontrar proyectos anidados en directorios organizacionales (ej: `~/DEV/company/project1`, `~/DEV/company/project2`).

**Exclusiones Automáticas**: El script excluye automáticamente directorios comunes de dependencias y builds para mejorar el rendimiento y evitar falsos positivos. Los directorios excluidos son: `node_modules`, `dist`, `build`, `vendor`, `.next`, `target`, `__pycache__`, `.venv`. Esta configuración es consistente con `godev.sh` y permite manejar correctamente estructuras de carpetas complejas donde algunos subdirectorios pueden ser proyectos sin repositorio Git (librerías o módulos).

### Características Principales

1. **Análisis Completo de Repositorios**
   - Fecha del último commit (relativa y absoluta)
   - Branch actual
   - Estado del repositorio (clean, modified, ahead, behind, diverged)
   - Estadísticas de commits (últimos 30 días y total)

2. **Ordenamiento Flexible**
   - Por fecha (más reciente primero) - predeterminado
   - Por nombre (alfabético)
   - Por actividad (número de commits)

3. **Filtrado por Actividad**
   - Muestra solo proyectos activos en los últimos N días

4. **Visualización Mejorada**
   - Colores para diferentes estados
   - Indicadores de actividad visual
   - Resumen estadístico al final

### Requisitos

**IMPORTANTE**: Este script **REQUIERE ZSH** (Z Shell) y **NO funcionará con Bash**.

El script utiliza características específicas de ZSH como:
- Expansión de parámetros con flags (`${(@s:|:)variable}`)
- Operaciones avanzadas con arrays
- Sustitución de parámetros específica de ZSH
- Indexación de arrays base 1

### Instalación

```bash
# 1. Verificar que tienes ZSH instalado
zsh --version

# 2. Hacer el script ejecutable
chmod +x ~/bin/govap.sh

# 3. Agregar al PATH (opcional)
# Agregar a ~/.zshrc:
export PATH="$HOME/bin:$PATH"

# 4. Ejecutar con ZSH (por defecto en macOS)
./govap.sh
```

### Configuración

El script usa la variable `DEV_BASE` para definir el directorio base de proyectos (por defecto: `~/DEV`). Esta configuración es consistente con `godev.sh`.

Para cambiar el directorio por defecto, edita la variable `DEV_BASE` en el script:

```bash
# Base projects directory (adjust according to your configuration)
DEV_BASE="${HOME}/DEV"  # Cambiar a tu directorio preferido
```

O usa la opción `-d` para especificar un directorio diferente en cada ejecución.

### Uso

#### Uso Básico
```bash
# Escanear directorio por defecto (~/DEV)
./govap.sh
```

#### Opciones Disponibles

```bash
# Escanear directorio personalizado
./govap.sh -d ~/Projects

# Mostrar solo proyectos activos en los últimos 30 días
./govap.sh -f 30

# Ordenar por actividad
./govap.sh -s activity

# Ordenar por nombre
./govap.sh -s name

# Mostrar todos los proyectos (incluyendo los que no son Git)
./govap.sh -a

# Combinar opciones
./govap.sh -d ~/Projects -f 7 -s activity
```

#### Opciones de Línea de Comandos

| Opción | Descripción |
|--------|-------------|
| `-d, --dir <path>` | Directorio base a escanear (por defecto: ~/DEV) |
| `-s, --sort <mode>` | Modo de ordenamiento: `date`, `name`, `activity` (por defecto: `date`) |
| `-f, --filter <days>` | Mostrar solo proyectos activos en los últimos N días |
| `-a, --all` | Mostrar todos los proyectos, incluyendo directorios sin Git |
| `-v, --version` | Mostrar versión |
| `-h, --help` | Mostrar ayuda |

### Estados del Repositorio

El script identifica los siguientes estados (en orden de prioridad: modified > diverged > ahead/behind > clean):

- **✓ clean**: Repositorio limpio, sin cambios pendientes, sincronizado con el remoto
- **● modified**: Hay cambios sin confirmar en el working directory
- **↑ ahead**: Hay commits locales que no se han subido al remoto
- **↓ behind**: El remoto tiene commits que no están en local
- **↕ diverged**: El repositorio local y remoto han divergido (ambos tienen commits diferentes)
- **○ no git**: El directorio no es un repositorio Git (se muestra solo con la opción `-a`)

**Nota**: Si un repositorio tiene cambios sin confirmar (modified), este estado tiene prioridad sobre los demás. Si no hay cambios locales pero hay diferencias con el remoto, se mostrará el estado correspondiente (ahead, behind, o diverged).

### Indicadores de Actividad

Los proyectos muestran un indicador visual de actividad basado en commits de los últimos 30 días:

- **●●●** (verde): Muy activo (>10 commits)
- **●●○** (amarillo): Activo (6-10 commits)
- **●○○** (gris): Poco activo (1-5 commits)
- **○○○** (gris): Inactivo (0 commits)

### Salida del Script

El script muestra:

1. **Encabezado**: Información del directorio escaneado
2. **Tabla de Proyectos**: 
   - Nombre del proyecto (muestra la ruta relativa desde el directorio base, ej: `senetca/my-web-app` para proyectos anidados)
   - Última fecha de commit (relativa)
   - Branch actual
   - Estado del repositorio
   - Indicador de actividad
3. **Resumen**: Estadísticas generales
   - Total de proyectos
   - Repositorios Git
   - Repositorios activos
   - Repositorios modificados
   - Repositorios ahead/behind

**Nota sobre nombres de proyectos**: Para proyectos anidados en subdirectorios organizacionales (como `senetca/my-web-app`), el script muestra la ruta relativa completa desde el directorio base, permitiendo identificar fácilmente la estructura organizacional de los proyectos.

### Ejemplos de Uso

#### Ejemplo 1: Revisión General
```bash
./govap.sh
```
Muestra todos los repositorios Git ordenados por fecha de último commit.

#### Ejemplo 2: Proyectos Activos Recientemente
```bash
./govap.sh -f 7
```
Muestra solo proyectos con actividad en los últimos 7 días.

#### Ejemplo 3: Análisis de Actividad
```bash
./govap.sh -s activity
```
Ordena los proyectos por nivel de actividad (más commits primero).

#### Ejemplo 4: Directorio Personalizado
```bash
./govap.sh -d ~/Work/Projects -f 30 -s activity
```
Analiza proyectos en un directorio específico, filtrando por actividad reciente y ordenando por nivel de actividad.

### Requisitos Técnicos

- **Shell**: ZSH (Z Shell) - **REQUERIDO**, no compatible con Bash
  - El script utiliza características específicas de ZSH
  - Por defecto disponible en macOS
  - En Linux puede requerir instalación: `sudo apt install zsh` o `sudo yum install zsh`
- **Git**: Debe estar instalado y disponible en PATH
- **Sistema**: macOS/Linux

**Nota sobre compatibilidad**: Este script está diseñado específicamente para ZSH y utiliza características avanzadas que no están disponibles en Bash. No intentes ejecutarlo con Bash, ya que fallará.

### Solución de Problemas

#### Error: "Base directory does not exist"
- Verifica que el directorio especificado con `-d` exista
- El directorio por defecto es `~/DEV`, créalo si no existe

#### No se muestran proyectos
- Verifica que haya directorios dentro del directorio base
- Verifica que los directorios contengan repositorios Git (`.git`)
- El script busca recursivamente hasta 5 niveles de profundidad
- Si tus proyectos están más profundos, puedes modificar `MAX_DEPTH` en el script
- Usa `-a` para ver también directorios sin Git (solo en el primer nivel)

#### El script es lento
- El script escanea todos los directorios recursivamente
- Para directorios con muchos proyectos, puede tomar tiempo
- El script excluye automáticamente directorios comunes (node_modules, dist, build, etc.) para mejorar el rendimiento
- Considera usar `-f` para filtrar y reducir la salida

#### Problemas de Formateo de Colores
- El script utiliza códigos ANSI para colores en las columnas STATUS y ACTIVITY
- Si los colores no se muestran correctamente, verifica que tu terminal soporte códigos ANSI
- El script calcula correctamente el ancho de las columnas excluyendo los códigos ANSI para mantener la alineación
- La función `strip_ansi()` se utiliza internamente para calcular el ancho real de las cadenas con color

### Mantenimiento

#### Actualizar el Script
El script está versionado. Para actualizar:

1. Revisar cambios en el repositorio
2. Verificar compatibilidad con tu entorno
3. Probar con `-h` para verificar la versión

#### Personalización
El script está configurado para usar `DEV_BASE="${HOME}/DEV"` como directorio base, igual que `godev.sh`. Para cambiar el directorio por defecto, edita la variable `DEV_BASE` en el script:

```bash
# Base projects directory (adjust according to your configuration)
DEV_BASE="${HOME}/DEV"  # Cambiar a tu directorio preferido
```

**Nota:** Esta configuración es consistente con `godev.sh`, permitiendo que ambos scripts compartan la misma base de directorios de proyectos.

### Comparación con govap.sh

`govap.sh` es la versión avanzada del verificador de actividad con:

- ✅ Información más detallada (branch, estado, estadísticas)
- ✅ Ordenamiento flexible
- ✅ Filtrado por fecha
- ✅ Visualización mejorada con colores
- ✅ Resumen estadístico
- ✅ Manejo robusto de errores
- ✅ Opciones de línea de comandos

---

## godev - Navegador Inteligente de Proyectos (Unificado)

### Descripción
Script unificado que permite navegar rápidamente a proyectos de desarrollo buscando por patrón de nombre. Combina las funcionalidades de navegación y monitoreo de estado en un solo comando.

### Características Principales

1. **Navegación Rápida**
   - Búsqueda por patrón de nombre
   - Selección interactiva con fzf (si está disponible)
   - Fallback a lista numerada si fzf no está disponible
   - Soporte para múltiples coincidencias

2. **Integración con fzf**
   - Usa fzf para selección interactiva cuando hay múltiples coincidencias
   - Validación automática de disponibilidad de fzf
   - Validación de permisos de escritura en directorio temporal
   - Opción para deshabilitar fzf mediante variable de entorno

### Uso Básico

```bash
# Navegar a un proyecto (comando por defecto)
godev nav react
godev react              # Mismo comando (nav es por defecto)

# Forzar creación de directorio (cuando no está en modo readonly)
godev nav new-project -f
```

### Opciones de Navegación

| Opción | Descripción |
|--------|-------------|
| `<pattern>` | Patrón de búsqueda para el nombre del proyecto |
| `-f, --force` | Forzar creación de directorio (deshabilitado en modo readonly) |
| `-h, --help` | Mostrar ayuda del comando nav |

### Integración con fzf

#### Comportamiento Automático

El script detecta automáticamente:
- **Disponibilidad de fzf**: Verifica si el comando `fzf` está disponible en el PATH
- **Permisos de escritura**: Valida que se pueda escribir en el directorio temporal (`$TMPDIR` o `/tmp`)

Si alguna de estas validaciones falla, el script automáticamente usa el modo de lista numerada como fallback.

#### Deshabilitar fzf para Pruebas

Para probar la funcionalidad sin fzf, puedes usar la variable de entorno `GODEV_NO_FZF`:

```bash
# Deshabilitar fzf y usar lista numerada
GODEV_NO_FZF=1 godev nav react

# O exportar para toda la sesión
export GODEV_NO_FZF=1
godev nav react
```

**Nota**: Esta opción es útil para:
- Probar la funcionalidad de fallback
- Entornos donde fzf no está disponible
- Debugging de problemas relacionados con fzf

#### Validaciones Realizadas

El script realiza las siguientes validaciones antes de usar fzf:

1. **Disponibilidad de fzf**
   ```bash
   command -v fzf >/dev/null 2>&1
   ```

2. **Permisos de escritura en directorio temporal**
   ```bash
   [[ -w "${TMPDIR:-/tmp}" ]]
   ```

Si alguna validación falla, se muestra un mensaje informativo y se usa el modo de lista numerada.

### Modo de Lista Numerada (Fallback)

Cuando fzf no está disponible o está deshabilitado, el script muestra una lista numerada:

```
Found 5 directories:

  [1] company/react-app
  [2] personal/react-tutorial
  [3] tests/react-test
  [4] legacy/react-old
  [5] sandbox/react-playground

Select a number (1-5) or press Enter to cancel:
```

### Solución de Problemas

#### fzf no se usa aunque esté instalado

1. Verifica que fzf esté en el PATH:
   ```bash
   which fzf
   command -v fzf
   ```

2. Verifica permisos de escritura en directorio temporal:
   ```bash
   test -w "${TMPDIR:-/tmp}" && echo "OK" || echo "No write access"
   ```

3. Verifica si la variable `GODEV_NO_FZF` está establecida:
   ```bash
   echo "${GODEV_NO_FZF:-not set}"
   ```

#### Error: "Cannot write to temporary directory"

- Verifica permisos del directorio temporal
- El script continuará funcionando usando el modo de lista numerada
- Los archivos temporales para el wrapper de función pueden no crearse

### Ejemplos de Uso

#### Ejemplo 1: Navegación Simple
```bash
godev nav api
```
Si hay una sola coincidencia, muestra el directorio directamente.

#### Ejemplo 2: Selección Interactiva
```bash
godev nav react
```
Si hay múltiples coincidencias, muestra menú interactivo (fzf o lista numerada).

#### Ejemplo 3: Probar sin fzf
```bash
GODEV_NO_FZF=1 godev nav react
```
Fuerza el uso de lista numerada incluso si fzf está disponible.

#### Ejemplo 4: Crear Nuevo Proyecto
```bash
godev nav new-project -f
```
Crea un nuevo directorio (solo si no está en modo readonly).

---

## Nota sobre versiones anteriores

La versión básica anterior de `govap.sh` ha sido reemplazada por la versión avanzada actual que incluye todas las funcionalidades mejoradas.

---

## Notas de Desarrollo

- Todos los scripts requieren ZSH
- Los scripts están bajo licencia Apache 2.0
- Para contribuciones o mejoras, consultar el repositorio

---

**Última actualización**: 2024
**Versión de govap**: 1.0.0

