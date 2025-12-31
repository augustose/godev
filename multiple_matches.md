# Selección Múltiple de Proyectos - godev

## 🎯 Característica CRÍTICA Implementada

Cuando buscas un proyecto y existen **múltiples directorios que coinciden**, godev automáticamente muestra una lista interactiva para que selecciones el proyecto correcto.

---

## 📋 Comportamiento

### Caso 1: Búsqueda Exacta (1 resultado)
```bash
$ godev my-exact-project
# ✓ Cambia directamente al proyecto
```

### Caso 2: Múltiples Coincidencias → **LISTA INTERACTIVA**
```bash
$ godev web
```

---

## 🎨 Experiencia con FZF (Modo Premium)

Si tienes FZF instalado, obtienes una interfaz interactiva completa:

```
Múltiples proyectos encontrados con 'web':

┌───────────────────────────────────────────────────────────┐
│ Selecciona proyecto >                                      │
├───────────────────────────────────────────────────────────┤
│ > /home/user/dev/webapp                                    │
│   /home/user/dev/website-old                               │
│   /home/user/dev/web-api                                   │
│   /home/user/dev/webserver                                 │
│                                                             │
│ ↑↓ navega | Enter selecciona | Esc cancela                │
└───────────────────────────────────────────────────────────┘

┌─────────────────────── PREVIEW ────────────────────────┐
│ 📁 /home/user/dev/webapp                                │
│                                                          │
│ Git Info:                                                │
│ a3b2c1d - Update dependencies (2 hours ago)             │
│                                                          │
│  M package.json                                          │
│  M src/components/App.tsx                                │
│ ?? new-feature.md                                        │
└──────────────────────────────────────────────────────────┘
```

**Características FZF:**
- ✅ Búsqueda fuzzy en tiempo real
- ✅ Preview del último commit
- ✅ Estado de archivos modificados
- ✅ Navegación con flechas ↑↓
- ✅ Enter para seleccionar
- ✅ Esc para cancelar

---

## 📝 Experiencia sin FZF (Modo Básico)

Si no tienes FZF, obtienes una lista numerada con información de Git:

```bash
$ godev web

Múltiples proyectos encontrados con 'web':

┌─────────────────────────────────────────────────────────
 1) webapp                           [main - ✓]
 2) website-old                      [develop - ●]
 3) web-api                          [feature/auth - ✓]
 4) webserver                        [no git]
└─────────────────────────────────────────────────────────

Selecciona un número (1-4) o Enter para cancelar: 
```

**Leyenda:**
- `[main - ✓]` = Branch main, sin cambios pendientes (clean)
- `[develop - ●]` = Branch develop, con cambios sin commit (modified)
- `[no git]` = No es un repositorio git

### Selección por número:
```bash
Selecciona un número (1-4) o Enter para cancelar: 2

✓ Seleccionado: website-old
# Cambia al directorio website-old
```

### Cancelar selección:
```bash
Selecciona un número (1-4) o Enter para cancelar: [Enter]

Selección cancelada
# No cambia de directorio
```

### Número inválido:
```bash
Selecciona un número (1-4) o Enter para cancelar: 99

✗ Selección inválida
# No cambia de directorio
```

---

## 🔍 Búsqueda Case-Insensitive

La búsqueda **NO distingue mayúsculas de minúsculas**:

```bash
$ godev WEB      # Encuentra: webapp, website-old, web-api, webserver
$ godev Web      # Encuentra: webapp, website-old, web-api, webserver  
$ godev web      # Encuentra: webapp, website-old, web-api, webserver
$ godev MyApp    # Encuentra: myapp, MyApp, MYAPP, my-app
```

---

## 🎯 Algoritmo de Búsqueda

### 1. Búsqueda Exacta (Prioridad Alta)
```bash
$ godev webapp
# Si existe exactamente "webapp" → Va directo
```

### 2. Búsqueda Fuzzy (Contiene el término)
```bash
$ godev app
# Encuentra: webapp, my-app, app-backend, mobile-app
# Muestra lista para seleccionar
```

### 3. Orden de Resultados
Los resultados se muestran en orden alfabético para fácil navegación.

---

## 📊 Ejemplos Reales

### Ejemplo 1: Proyectos de React

Estructura:
```
~/dev/
├── react-app/
├── react-native-app/
├── react-admin/
└── my-react-project/
```

Comando:
```bash
$ godev react
```

Resultado:
```
Múltiples proyectos encontrados con 'react':

 1) react-app              [main - ✓]
 2) react-native-app       [develop - ●]
 3) react-admin            [feature/dashboard - ✓]
 4) my-react-project       [main - ●]

Selecciona: 3

✓ Seleccionado: react-admin
```

---

### Ejemplo 2: Diferentes versiones

Estructura:
```
~/dev/
├── myapp/
├── myapp-v2/
├── myapp-v3/
└── myapp-legacy/
```

Comando:
```bash
$ godev myapp
```

Resultado:
```
Múltiples proyectos encontrados con 'myapp':

 1) myapp           [main - ✓]
 2) myapp-v2        [main - ●]
 3) myapp-v3        [develop - ✓]
 4) myapp-legacy    [no git]

Selecciona: 2

✓ Seleccionado: myapp-v2
```

---

### Ejemplo 3: Búsqueda específica

Estructura:
```
~/dev/
├── api-backend/
├── api-gateway/
├── mobile-api/
└── graphql-api/
```

Búsqueda amplia:
```bash
$ godev api
# Muestra los 4 proyectos
```

Búsqueda específica:
```bash
$ godev api-back
# Va directo a "api-backend" (único match)
```

---

## ⚙️ Configuración

No requiere configuración especial. El comportamiento es automático:

- **Con FZF instalado** → Interfaz interactiva con preview
- **Sin FZF** → Lista numerada simple

Para obtener la mejor experiencia, instala FZF:
```bash
# macOS
brew install fzf

# Ubuntu/Debian
sudo apt install fzf

# Fedora
sudo dnf install fzf
```

---

## 🚀 Flujo de Trabajo Típico

```bash
# 1. Tienes muchos proyectos
$ godev --list
# Ves: webapp, web-api, website-old, webserver, etc.

# 2. Quieres ir a uno pero no recuerdas el nombre exacto
$ godev web
# Te muestra lista de todos los que contienen "web"

# 3. Seleccionas visualmente el correcto
# [Con FZF]: Navegas con flechas y ves preview
# [Sin FZF]: Ingresas el número

# 4. ¡Estás en tu proyecto!
$ pwd
/home/user/dev/webapp
```

---

## 🔧 Comportamiento Técnico

### Código Clave

```zsh
# Búsqueda case-insensitive
if [[ "${dir_name:l}" == *"${search:l}"* ]]; then
    matches+=("$dir")
fi
```

### Estados Posibles

| Matches | Comportamiento |
|---------|----------------|
| 0       | Preguntar si crear nuevo proyecto |
| 1       | Cambiar directamente |
| 2+      | **Mostrar lista interactiva** |

---

## ✅ Ventajas

1. **Sin ambigüedad** - Nunca vas al proyecto equivocado
2. **Rápido** - Tipea poco, selecciona visualmente
3. **Informativo** - Ves estado de Git antes de seleccionar
4. **Flexible** - Funciona con o sin FZF
5. **Cancelable** - Siempre puedes abortar la selección

---

## 🎓 Pro Tips

### Tip 1: Búsqueda más específica
```bash
# En vez de: godev app (20 resultados)
# Usa: godev app-back (2 resultados)
```

### Tip 2: Prefijos comunes
```bash
$ godev web-    # Encuentra: web-api, web-app, web-server
$ godev my-     # Encuentra: my-app, my-project, my-tool
```

### Tip 3: Con FZF, búsqueda adicional
```bash
$ godev app
# En FZF: tipea "react" para filtrar más
# Resultado: solo apps de React
```

---

## 🐛 Troubleshooting

### Problema: No muestra todos los proyectos esperados
**Solución:** Verifica que los directorios estén en el nivel correcto:
```bash
# ✓ Correcto: ~/dev/myproject
# ✗ Incorrecto: ~/dev/subfolder/myproject  (no se escanea)
```

### Problema: FZF no funciona
**Solución:** Instala FZF o reconfigura:
```bash
brew install fzf  # o apt install fzf
godev --setup
```

### Problema: Siempre va al mismo proyecto
**Solución:** Sé más específico en la búsqueda:
```bash
# En vez de: godev my
# Usa: godev my-app-v2
```

---

## 📚 Relacionado

- [README.md](README.md) - Documentación principal
- [TESTING.md](TESTING.md) - Guía de testing
- Comando: `godev --help` - Ayuda rápida

---

**Esta funcionalidad es CRÍTICA y está completamente implementada en godev.** 🎉
