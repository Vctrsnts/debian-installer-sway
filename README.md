# 🖌️ Módulo: Aplicación Automática de Tema e Iconos GTK

Este módulo aplica automáticamente el tema GTK, los iconos, la fuente y el cursor definidos en tu archivo `modules.conf`, evitando modificar el script cada vez que cambias de estilo. Es compatible con **GTK2** y **GTK3**.

---

## 📖 Explicación del script

- **Propósito:** Centralizar la configuración visual del sistema para que cualquier cambio se haga desde `modules.conf`.
- **Archivos modificados:**
  - `~/.config/gtk-3.0/settings.ini`
  - `~/.gtkrc-2.0`
- **Qué aplica:** Tema GTK, paquete de iconos, fuente, tema de cursor y tamaño de cursor.
- **Valores por defecto:** Si no defines las variables en `modules.conf`, se aplican valores estándar seguros.

---

## ⚙️ Funcionamiento

1. **Carga configuración:** Usa `source` para leer `modules.conf`.
2. **Asigna valores por defecto:** Si falta una variable, usa el valor predefinido.
3. **Muestra resumen:** Imprime en consola qué configuración se aplicará.
4. **Escribe configuración GTK3:** Crea/actualiza `~/.config/gtk-3.0/settings.ini`.
5. **Escribe configuración GTK2:** Crea/actualiza `~/.gtkrc-2.0`.
6. **Aplica cambios:** Normalmente se ven al reiniciar aplicaciones GTK.

---

## 🔧 Configuración en `modules.conf`

Ejemplo:

```bash
# Activar tema oscuro
THEME_DARK=YES

# Tema GTK
THEME_DARK_NAME="Nordic"

# Iconos
ICON_DARK_NAME="Papirus-Dark"

# Fuente
GTK_FONT_NAME="Sans 10"

# Cursor
GTK_CURSOR_THEME="Adwaita"
GTK_CURSOR_SIZE=0
```

**Valores por defecto:**

| Variable            | Defecto           |
|---------------------|-------------------|
| THEME_DARK_NAME     | `Materia-dark`    |
| ICON_DARK_NAME      | `Papirus-Dark`    |
| GTK_FONT_NAME       | `Sans 10`         |
| GTK_CURSOR_THEME    | `Adwaita`         |
| GTK_CURSOR_SIZE     | `0`               |

> 💡 Los nombres deben coincidir con los instalados en el sistema:
> - Temas GTK: `/usr/share/themes` o `~/.themes`
> - Iconos: `/usr/share/icons` o `~/.icons`

---

## 🚀 Instalación y uso

Estructura sugerida:
```
modules/
  └── theme-dark/
       ├── install.sh
       └── apply_gtk_settings.sh
modules.conf
```

Pasos:

```bash
# 1. Dar permisos al script
chmod +x modules/theme-dark/apply_gtk_settings.sh

# 2. Llamar al script desde install.sh
bash "$(dirname "$0")/apply_gtk_settings.sh"

# 3. Editar modules.conf con tu configuración deseada

# 4. Ejecutar instalación
./install.sh
```

---

## 🧩 Ejemplo de cambio rápido de estilo

```bash
# Configuración actual
THEME_DARK_NAME="Nordic"
ICON_DARK_NAME="Papirus-Dark"

# Nuevo estilo
THEME_DARK_NAME="Materia-dark"
ICON_DARK_NAME="Colloid-Purple-Dracula-Dark"

# Aplicar cambios
./install.sh
```

---

## 🛟 Solución de problemas

- **Tema o iconos no cambian:**
  - Comprueba que el nombre existe en `/usr/share/themes` o `/usr/share/icons`.
  - Cierra y reabre las aplicaciones GTK.
- **Fuente no cambia:**
  - Comprueba que la fuente está instalada (`fc-list | grep -i "nombre"`).
- **Cursor no cambia:**
  - Verifica que el tema de cursor está instalado.
  - Algunos entornos requieren cerrar sesión para aplicar cambios globales.
- **Permisos o rutas:**
  - Asegúrate de que el script es ejecutable.
  - Verifica la ruta relativa para leer `modules.conf`.
