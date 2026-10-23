# Guion de video — Fase 3 (versión corta)
**Duración objetivo: 5:30 – 6:00 min** | MediCitas | UNAD 2026
[ NOMBRE DEL ESTUDIANTE ] — Framework para el Desarrollo de Aplicaciones Móviles

> **Antes de grabar:** 1920×1080, VS Code fuente 16, emulador en tamaño teléfono, fuente del sistema al 100 %.
> Salta a una línea con `Ctrl + G`. Muestra solo 8–12 líneas alrededor y ve señalando con el cursor.

---

## BLOQUE 1 — Apertura y estructura (0:00 – 0:35)

**Pantalla:** VS Code con `lib/` desplegado.

**Di:**
> "Hola, soy [NOMBRE], estudiante de [PROGRAMA] de la UNAD. Presento la Fase 3 del curso Framework para el Desarrollo de Aplicaciones Móviles: interfaces, navegación, formularios y validaciones de MediCitas, una app de citas médicas en Flutter.
>
> El proyecto se organiza en `core/theme` para el tema global, `models` para las clases de datos, `data` para la información simulada, `screens` para las pantallas y `widgets` para los componentes reutilizables."

---

## BLOQUE 2 — Widgets reutilizables (0:35 – 1:50)

**Mostrar:** `lib/widgets/` y luego cada uso.

**Di:**
> "La parte más importante de la organización son los widgets reutilizables, porque mantienen el diseño consistente y evitan repetir código.
>
> `SectionHeader`, en `section_header.dart` línea 6, es el encabezado de sección; se usa en el inicio, líneas 125, 135 y 168, y en agendar, líneas 142, 158 y 178.
>
> `InfoBanner`, en `info_banner.dart` línea 6, muestra los mensajes de requerimientos; está en el inicio, línea 238, y en agendar, líneas 235, 424 y 468.
>
> `ResponsiveContent`, en `responsive_content.dart` línea 5, limita el ancho en tablets; se usa en perfil línea 75, agendar línea 51 y citas línea 78.
>
> Y `MedicitasLogo`, en `medicitas_logo.dart` línea 6, se usa en el login, línea 50."

**Acción:** mostrar brevemente en la app el encabezado y un banner (Inicio y Agendar), y el diseño centrado al ampliar la ventana.

---

## BLOQUE 3 — Validaciones (1:50 – 3:40)

### 3.1 Login

**Mostrar:** `lib/screens/login_screen.dart:58`, `:86` y `:181–194`.

**Di:**
> "El login usa un `Form` en la línea 58 y `TextFormField` con `validator` en 86 y 110. Las reglas están entre 181 y 194: documento obligatorio de mínimo seis caracteres y contraseña de mínimo seis. Si hay errores, `_login` no permite entrar."

**Acción:** borrar los campos, pulsar *Iniciar sesión*, mostrar los mensajes; escribir datos válidos y entrar.

### 3.2 Perfil

**Mostrar:** `lib/screens/perfil_screen.dart:76`, `:150–172` y `:56`.

**Di:**
> "En perfil, el formulario está en la línea 76. Nombre, correo y teléfono tienen validador en 150, 161 y 172: el correo debe tener formato válido y el teléfono entre siete y diez dígitos. `_guardar`, línea 56, solo confirma si todo está correcto."

**Acción:** escribir `correo-invalido` y `12`, pulsar *Guardar cambios*, mostrar errores; corregir y guardar.

### 3.3 Agendamiento

**Mostrar:** `lib/screens/agendar_screen.dart:22` y `:498–523`.

**Di:**
> "En agendar, el estado está en la línea 22 y la validación por pasos en 498 y 508: `_puedeContinuar` define qué falta y `_continuar` muestra el error sin avanzar. Al confirmar, línea 572, se crea la cita, se bloquea el cupo y se entrega el número."

**Acción:** paso 1 → Continuar; en paso 2 pulsar *Continuar sin hora* para mostrar el aviso rojo; elegir 8:00 a. m., continuar y confirmar.

---

## BLOQUE 4 — Navegación (3:40 – 4:05)

**Mostrar:** `lib/screens/main_shell.dart:19` y `:27`.

**Di:**
> "La navegación principal está en `main_shell`: un `IndexedStack` en la línea 19 conserva el estado de las pestañas y un `NavigationBar` en la 27 ofrece Inicio, Citas y Perfil."

**Acción:** tocar las tres pestañas y volver a Inicio.

---

## BLOQUE 5 — Demostración de la app (4:05 – 5:25)

**Mostrar:** la app de corrido, sin cortes.

**Di:**
> "Recorro la aplicación completa: inicio de sesión, pantalla principal con la próxima cita, agendamiento en tres pasos con su validación, confirmación, listado de citas y perfil. Toda la interacción se actualiza en memoria y se refleja en las demás pantallas."

**Acción:** login → inicio → agendar (8:00 a. m.) → confirmar → Aceptar → Citas → Perfil.

---

## BLOQUE 6 — Cierre (5:25 – 5:50)

**Di:**
> "Con esto queda cumplida la Fase 3: interfaces funcionales, navegación, validaciones, accesibilidad y diseño responsivo. El proyecto tiene `flutter analyze` sin hallazgos y cinco pruebas aprobadas. El repositorio y el proyecto comprimido están en los enlaces de la entrega. Gracias."

---

## Si te pasas de tiempo

- Recorta el bloque 5 a 30 segundos (login → agendar → confirmar).
- En el bloque 2, muestra solo `SectionHeader` y `ResponsiveContent`.
- En el bloque 3, omite la corrección de datos en perfil.

## Checklist

- [ ] Se ven los widgets reutilizables y dónde se usan.
- [ ] Se ven las tres validaciones (login, perfil, agendar).
- [ ] La app funciona en pantalla durante la demo.
- [ ] Máximo 6 minutos.
- [ ] Audio claro, sin notificaciones y enlace público.
