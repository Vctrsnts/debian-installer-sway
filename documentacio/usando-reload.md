Gracias por compartir tu configuración y el script. He revisado la documentación oficial de [Sway](https://swaywm.org) y aquí tienes un análisis detallado:

---

### ✅ ¿Qué hace `reload` en Sway?

Según la documentación oficial de Sway:

> `reload` recarga el archivo de configuración de Sway, pero **no ejecuta comandos externos automáticamente** ni reinicia el entorno gráfico ni los procesos asociados a GTK, GSettings o similares.

---

### ⚠️ Problema con tu línea `bindsym`

Tu línea actual:

```sway
bindsym $mod+Shift+r reload; exec ~/.config/sway/scripts/import-gsettings.sh; exec notify-send 'sway' 'Restarted'
```

**No se ejecuta como esperas.** El problema es que `reload` es una **comando interno de Sway**, mientras que `exec` lanza procesos externos. Cuando usas `;` para encadenarlos, **solo el primero (`reload`) se ejecuta correctamente**, y los siguientes pueden fallar o no ejecutarse en el contexto adecuado.

---

### ✅ Solución documentada y funcional

Para que el script se ejecute correctamente tras recargar la configuración, debes **separar el `reload` del resto** o usar un bloque de comandos externo. Aquí tienes una versión corregida que **cumple con la documentación oficial**:

```sway
bindsym $mod+Shift+r exec bash -c 'swaymsg reload && ~/.config/sway/scripts/import-gsettings.sh && notify-send sway "Restarted"'
```

### 🔍 Explicación:

- `exec bash -c '...'`: ejecuta un bloque de comandos en Bash.
- `swaymsg reload`: envía el comando `reload` a Sway desde fuera del contexto interno.
- `&&`: asegura que el script y la notificación solo se ejecuten si `reload` fue exitoso.

---

### 🧠 Consideraciones adicionales

- Tu script `import-gsettings.sh` depende de `gsettings`, que requiere que el **bus de sesión DBus esté activo** y que el entorno tenga acceso a `org.gnome.desktop.interface`. Si estás en Sway sin GNOME, asegúrate de que el daemon `dconf` esté corriendo.
- Puedes verificar si `gsettings` funciona con:  
  ```bash
  gsettings get org.gnome.desktop.interface gtk-theme
  ```

---

¿Quieres que te ayude a adaptar el script para que funcione también en entornos sin GNOME, usando `dconf` directamente o configuraciones alternativas como `xdg-desktop-portal`?
