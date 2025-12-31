# Guía de Testing - godev

Esta guía te ayudará a probar godev localmente antes de publicarlo.

## Configuración del entorno de testing

### 1. Crear directorio de prueba

```bash
# Crear estructura de testing
mkdir -p ~/godev-test/{projects,install}
cd ~/godev-test
```

### 2. Estructura del proyecto

```
~/godev-test/
├── godev                  # Script principal
├── install.sh             # Instalador
├── projects/              # Directorio de prueba
│   ├── test-project-1/
│   ├── test-project-2/
│   └── test-project-3/
└── README.md
```

### 3. Crear proyectos de prueba

```bash
cd ~/godev-test/projects

# Proyecto con git
mkdir test-project-1
cd test-project-1
git init
echo "# Test 1" > README.md
git add .
git commit -m "Initial commit"
cd ..

# Proyecto con git y cambios
mkdir test-project-2
cd test-project-2
git init
echo "# Test 2" > README.md
git add .
git commit -m "Initial commit"
echo "Modified" >> README.md  # Cambios sin commit
cd ..

# Proyecto sin git
mkdir test-project-3
cd test-project-3
echo "No git here" > info.txt
cd ..

# Proyecto con nombre con espacios (edge case)
mkdir "test project 4"
cd "test project 4"
git init
cd ..

cd ~/godev-test
```

## Testing del script principal

### Prueba 1: Verificar sintaxis

```bash
zsh -n godev
# No debería mostrar errores
```

### Prueba 2: Setup inicial

```bash
# Ejecutar directamente el script
zsh godev --setup

# Cuando pida el directorio base:
# ~/godev-test/projects
```

### Prueba 3: Testing sin función wrapper

```bash
# Listar proyectos
zsh godev --list

# Debería mostrar:
# - test-project-1 (clean)
# - test-project-2 (modified)
# - test-project-3 (NO_GIT)
# - test project 4 (clean)
```

### Prueba 4: Navegación (sin wrapper)

```bash
# Esto NO cambiará el directorio (es esperado)
# Solo imprimirá el path
result=$(zsh godev test-project-1)
echo "Path encontrado: $result"

# Verificar que es correcto
[[ "$result" == *"test-project-1"* ]] && echo "✓ OK" || echo "✗ FAIL"
```

### Prueba 5: Crear proyecto nuevo

```bash
# Simular entrada del usuario (s = sí)
echo "s" | zsh godev new-project
```

### Prueba 6: Búsqueda fuzzy

```bash
# Crear proyectos con nombres similares
cd ~/godev-test/projects
mkdir webapp web-api website webserver
cd ~/godev-test

# Buscar con "web" debería encontrar MÚLTIPLES
godev web

# CON FZF: debería abrir selector interactivo mostrando:
# - webapp
# - web-api
# - website
# - webserver

# SIN FZF: debería mostrar lista numerada con info de git:
# 1) webapp      [main - ✓]
# 2) web-api     [no git]
# 3) website     [develop - ●]
# 4) webserver   [no git]

# Verificar que puedes seleccionar con número
# Verificar que puedes cancelar con Enter vacío
# Verificar que rechaza números inválidos

# Probar búsqueda case-insensitive
godev WEB    # Debería encontrar los mismos
godev Web    # Debería encontrar los mismos
```

### Prueba 7: Caché

```bash
# Primera ejecución (crea caché)
time zsh godev --list

# Segunda ejecución (usa caché)
time zsh godev --list
# Debería ser más rápida
```

### Prueba 8: Invalidar caché

```bash
# Ver timestamp del caché
cat ~/.config/godev/cache | grep timestamp

# Esperar o modificar manualmente el archivo
# O borrar el caché
rm ~/.config/godev/cache

# Verificar que se regenera
zsh godev --list
ls -la ~/.config/godev/cache
```

## Testing del instalador

### Prueba 1: Instalación limpia

```bash
# Backup de tu configuración actual
cp ~/.zshrc ~/.zshrc.backup

# Ejecutar instalador
cd ~/godev-test
zsh install.sh

# Verificar instalación
which godev
# Debería mostrar: ~/.local/bin/godev

# Verificar función en .zshrc
grep "godev()" ~/.zshrc
```

### Prueba 2: Verificar función wrapper

```bash
# Recargar shell
source ~/.zshrc

# Verificar que la función existe
type godev
# Debería mostrar: "godev is a shell function..."

# AHORA sí debería cambiar directorio
godev test-project-1
pwd
# Debería mostrar: .../projects/test-project-1
```

### Prueba 3: Comandos con --

```bash
# Estos NO deberían cambiar directorio
godev --list
pwd  # No debería haber cambiado

godev --help
pwd  # No debería haber cambiado
```

### Prueba 4: Re-instalación

```bash
# Ejecutar instalador de nuevo
cd ~/godev-test
zsh install.sh

# Debería detectar instalación existente
# y preguntar si reemplazar
```

## Testing con FZF

### Si tienes FZF instalado

```bash
# Menú interactivo
godev
# Debería abrir FZF con todos los proyectos

# Búsqueda fuzzy con múltiples resultados
godev test
# Debería abrir FZF con proyectos filtrados
```

### Si NO tienes FZF

```bash
# Debería mostrar advertencia
godev

# Y usar modo de selección por números
# Selecciona: 1
```

## Testing de edge cases

### 1. Múltiples proyectos con mismo patrón (CRÍTICO)

```bash
cd ~/godev-test/projects

# Crear proyectos similares
mkdir my-app my-app-v2 my-app-backend my-app-frontend
cd my-app && git init && cd ..
cd my-app-v2 && git init && echo "test" > README.md && cd ..
cd my-app-backend && git init && cd ..
cd my-app-frontend && cd ..  # Sin git intencionalmente

cd ~/godev-test

# Test 1: Buscar "my-app" debe mostrar TODOS (4 proyectos)
godev my-app

# Verificar:
# - Se muestran los 4 proyectos
# - Se indica cuáles tienen git
# - Se muestra el estado (modified/clean)
# - Permite seleccionar por número O con FZF
# - Permite cancelar

# Test 2: Búsqueda más específica
godev my-app-back
# Debería ir directo a my-app-backend (solo 1 match)

# Test 3: Cancelar selección
godev my-app
# Presiona Enter sin número (debe cancelar)
# O presiona Esc en FZF (debe cancelar)
# Verificar que NO cambia de directorio

# Test 4: Selección inválida
godev my-app
# Ingresa "99" (fuera de rango)
# Debería mostrar error y no cambiar directorio

# Test 5: Selección válida
godev my-app
# Ingresa "2"
# Debería cambiar a my-app-v2
pwd  # Verificar que estás en my-app-v2
```

### 2. Proyecto con nombre con espacios

```bash
godev "test project 4"
pwd
# Debería funcionar correctamente
```

### 2. Proyecto que no existe

```bash
godev nonexistent-project
# Debería preguntar si crear
# Responde: n (no)
```

### 3. Directorio base no existe

```bash
# Editar config para usar directorio inexistente
echo 'GODEV_BASE_DIR="/tmp/nonexistent"' > ~/.config/godev/config

godev --list
# Debería mostrar error claro
```

### 4. Sin permisos

```bash
# Crear directorio sin permisos de escritura
mkdir -p /tmp/godev-readonly
chmod 444 /tmp/godev-readonly

# Intentar crear proyecto ahí
# (modificar config temporalmente)
```

### 5. Caracteres especiales

```bash
cd ~/godev-test/projects
mkdir "project-with-@-symbol"
cd "project-with-@-symbol"
git init
cd ~/godev-test

godev "project-with-@-symbol"
# Debería funcionar
```

## Testing de performance

### Benchmark básico

```bash
# Crear muchos proyectos
cd ~/godev-test/projects
for i in {1..50}; do
    mkdir "bench-project-$i"
    cd "bench-project-$i"
    git init
    echo "test" > README.md
    git add .
    git commit -m "init"
    cd ..
done

# Medir tiempo sin caché
rm ~/.config/godev/cache
time godev --list

# Medir tiempo con caché
time godev --list
```

## Checklist de testing completo

- [ ] ✓ Sintaxis ZSH correcta
- [ ] ✓ Setup inicial funciona
- [ ] ✓ Lista proyectos correctamente
- [ ] ✓ Detecta git repos
- [ ] ✓ Muestra estado (modified/clean)
- [ ] ✓ Calcula actividad (30 días)
- [ ] ✓ Navegación con wrapper funciona
- [ ] ✓ Navegación sin wrapper no cambia dir
- [ ] ✓ Comandos con -- no cambian dir
- [ ] ✓ Crea proyectos nuevos
- [ ] ✓ Búsqueda exacta funciona
- [ ] ✓ **Búsqueda fuzzy con múltiples resultados muestra lista**
- [ ] ✓ **Selección numerada funciona correctamente**
- [ ] ✓ **Selección con FZF funciona correctamente**
- [ ] ✓ **Cancelación de selección funciona**
- [ ] ✓ **Rechaza selecciones inválidas**
- [ ] ✓ **Búsqueda case-insensitive funciona**
- [ ] ✓ FZF se integra correctamente
- [ ] ✓ Modo sin FZF funciona
- [ ] ✓ Caché funciona
- [ ] ✓ Caché se invalida correctamente
- [ ] ✓ Maneja proyectos sin git
- [ ] ✓ Maneja nombres con espacios
- [ ] ✓ Maneja caracteres especiales
- [ ] ✓ Mensajes de error claros
- [ ] ✓ Instalador funciona
- [ ] ✓ Re-instalación funciona
- [ ] ✓ PATH se actualiza correctamente
- [ ] ✓ Función wrapper se agrega correctamente

## Limpieza después del testing

```bash
# Restaurar .zshrc original
cp ~/.zshrc.backup ~/.zshrc
source ~/.zshrc

# Eliminar instalación de testing
rm ~/.local/bin/godev
rm -rf ~/.config/godev

# Eliminar proyectos de prueba
rm -rf ~/godev-test

# Si instalaste FZF solo para probar
# brew uninstall fzf  # (opcional)
```

## Automatización de tests

### Script de testing automatizado

```bash
#!/usr/bin/env zsh
# test-godev.sh

set -e

echo "🧪 Testing godev..."

# Array de tests
tests=(
    "test_syntax"
    "test_setup"
    "test_list"
    "test_navigation"
    "test_cache"
)

test_syntax() {
    echo "→ Testing syntax..."
    zsh -n godev && echo "✓ Syntax OK" || echo "✗ Syntax FAIL"
}

test_setup() {
    echo "→ Testing setup..."
    echo "$HOME/godev-test/projects" | zsh godev --setup >/dev/null
    [[ -f ~/.config/godev/config ]] && echo "✓ Setup OK" || echo "✗ Setup FAIL"
}

test_list() {
    echo "→ Testing list..."
    zsh godev --list >/dev/null && echo "✓ List OK" || echo "✗ List FAIL"
}

test_navigation() {
    echo "→ Testing navigation..."
    result=$(zsh godev test-project-1)
    [[ "$result" == *"test-project-1"* ]] && echo "✓ Navigation OK" || echo "✗ Navigation FAIL"
}

test_cache() {
    echo "→ Testing cache..."
    zsh godev --list >/dev/null
    [[ -f ~/.config/godev/cache ]] && echo "✓ Cache OK" || echo "✗ Cache FAIL"
}

# Ejecutar todos los tests
for test in "${tests[@]}"; do
    $test
done

echo "✅ Testing completo"
```

## Debugging

### Habilitar modo verbose

Agrega al inicio del script godev:

```bash
set -x  # Debug mode
```

### Ver qué hace la función wrapper

```bash
# Agregar temporalmente al wrapper
godev() {
    echo "DEBUG: Args: $@" >&2
    echo "DEBUG: First arg: $1" >&2
    # ... resto del código
}
```

### Verificar configuración

```bash
cat ~/.config/godev/config
cat ~/.config/godev/cache
cat ~/.config/godev/version_info
```

## Reportar issues

Si encuentras bugs durante el testing:

1. Descripción del problema
2. Comando ejecutado
3. Salida esperada vs obtenida
4. Versión de ZSH: `echo $ZSH_VERSION`
5. FZF instalado: `fzf --version`
6. Sistema operativo
7. Contenido de `~/.config/godev/config`

---

**¡Happy testing!** 🧪
