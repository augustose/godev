# Top Notch Tools: Scripts para Desarrolladores

Este documento contiene una colección de ideas para scripts de shell diseñados para automatizar tareas, mejorar la calidad del código y agilizar el flujo de trabajo de un desarrollador en su día a día.

---

### 1. Verificador de Actividad de Proyectos

**Objetivo:** Obtener un resumen rápido de cuándo fue la última vez que se trabajó en cada proyecto dentro de un directorio principal. Es útil para identificar proyectos abandonados o para saber cuáles son los más activos.

**¿Por qué es útil?** Permite hacer limpieza de proyectos antiguos o simplemente tener una visión clara del estado de tu espacio de trabajo.

**Implementación de ejemplo (`bash`):**

```bash
#!/bin/bash

echo "Última actividad en los repositorios locales:"
echo "=========================================="

for dir in */ ;
  do
    if [ -d "$dir/.git" ]; then
      pushd "$dir" > /dev/null
      last_commit_date=$(git log -1 --format="%ar (%ci)")
      echo -e "[\033[0;32m${dir%?}\033[0m]: $last_commit_date"
      popd > /dev/null
    fi
done
```

---

### 2. Auditor de Repositorios Git

**Objetivo:** Revisar todos los subdirectorios para encontrar proyectos que no tengan un repositorio Git inicializado, o que teniéndolo, tengan cambios sin confirmar o commits sin subir al remoto.

**¿Por qué es útil?** Garantiza que todo tu trabajo esté bajo control de versiones y sincronizado, evitando pérdidas de código o conflictos inesperados.

**Implementación de ejemplo (`bash`):**

```bash
#!/bin/bash

echo "Auditoría de repositorios Git:"
echo "=============================="

for dir in */ ;
  do
    if [ -d "$dir" ]; then
      if [ ! -d "$dir/.git" ]; then
        echo -e "[\033[0;33m${dir%?}\033[0m]: ⚠️ No es un repositorio Git."
      else
        pushd "$dir" > /dev/null
        git_status=$(git status --porcelain)
        
        # Revisa si hay commits locales no pusheados
        ahead=$(git status -sb | grep 'ahead')

        if [ -n "$git_status" ]; then
          echo -e "[\033[0;31m${dir%?}\033[0m]: ✗ Tienes cambios sin confirmar."
        elif [ -n "$ahead" ]; then
          echo -e "[\033[0;34m${dir%?}\033[0m]: 📤 Tienes commits sin subir al remoto."
        else
          # Opcional: mostrar un mensaje si está todo en orden
          # echo -e "[\033[0;32m${dir%?}\033[0m]: ✓ Todo en orden."
        fi
        popd > /dev/null
      fi
    fi
done

```

---

### 3. Analizador de Dependencias Obsoletas

**Objetivo:** Recorrer múltiples proyectos (Node.js, Python, etc.) y generar un informe sobre las dependencias que están desactualizadas.

**¿Por qué es útil?** Es una herramienta clave para la seguridad y el mantenimiento. Permite identificar y actualizar paquetes con vulnerabilidades conocidas o simplemente mantener tus proyectos al día.

**Implementación de ejemplo (`bash`):**

```bash
#!/bin/bash

echo "Buscando dependencias obsoletas:"
echo "================================="

for dir in */ ;
  do
  # Para proyectos Node.js
  if [ -f "${dir}package.json" ]; then
    echo "--- Analizando (Node.js): ${dir%?} ---"
    (cd "$dir" && npm outdated)
  fi
  
  # Para proyectos Python
  if [ -f "${dir}requirements.txt" ]; then
    echo "--- Analizando (Python): ${dir%?} ---"
    (cd "$dir" && python3 -m pip list --outdated)
  fi
done
```

---

### 4. Buscador de Tareas Pendientes (TODOs)

**Objetivo:** Rastrear todos los archivos de código fuente en tus proyectos en busca de comentarios como `TODO:`, `FIXME:`, o `HACK:`.

**¿Por qué es útil?** Ayuda a no perder de vista la deuda técnica y las tareas de refactorización que te dejaste a ti mismo o a tu equipo para el futuro.

**Implementación de ejemplo (usando `grep`):**

```bash
#!/bin/bash

echo "Buscando tareas pendientes (TODO, FIXME, HACK):"
echo "==============================================="

# Excluye directorios comunes como node_modules, vendor, .git, etc.
grep -r --exclude-dir={node_modules,vendor,.git,dist,build} -E 'TODO:|FIXME:|HACK:' .
```

---

### 5. Generador de "Quick Start"

**Objetivo:** Crear o actualizar un archivo `QUICK_START.md` en un proyecto, analizando su estructura para adivinar los comandos de instalación y ejecución.

**¿Por qué es útil?** Unifica la forma de arrancar cualquier proyecto. Es extremadamente útil para nuevos miembros del equipo o para ti mismo cuando retomas un proyecto después de mucho tiempo.

**Implementación de ejemplo (`bash`):**

```bash
#!/bin/bash

# Este script se ejecutaría dentro de la carpeta de un proyecto

FILE="QUICK_START.md"
echo "# Guía de Inicio Rápido" > $FILE
echo "---" >> $FILE

if [ -f "docker-compose.yml" ]; then
    echo "## Con Docker" >> $FILE
    echo "Levanta los servicios con:" >> $FILE
    echo "\`\`\`bash\`\`\`" >> $FILE
    echo "docker-compose up -d" >> $FILE
    echo "\`\`\`" >> $FILE
fi

if [ -f "package.json" ]; then
    echo "## Con Node.js" >> $FILE
    echo "Instala las dependencias:" >> $FILE
    echo "\`\`\`bash\`\`\`" >> $FILE
    echo "npm install" >> $FILE
    echo "\`\`\`" >> $FILE
    echo "Ejecuta el proyecto:" >> $FILE
    echo "\`\`\`bash\`\`\`" >> $FILE
    echo "npm start" >> $FILE
    echo "\`\`\`" >> $FILE
fi

if [ -f "requirements.txt" ]; then
    echo "## Con Python" >> $FILE
    echo "Crea un entorno virtual (recomendado):" >> $FILE
    echo "\`\`\`bash\`\`\`" >> $FILE
    echo "python3 -m venv .venv && source .venv/bin/activate" >> $FILE
    echo "\`\`\`" >> $FILE
    echo "Instala las dependencias:" >> $FILE
    echo "\`\`\`bash\`\`\`" >> $FILE
    echo "pip install -r requirements.txt" >> $FILE
    echo "\`\`\`" >> $FILE
fi

echo "¡El archivo $FILE ha sido generado!"
```
