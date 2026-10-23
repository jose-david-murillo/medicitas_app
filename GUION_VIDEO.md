# Guion de video - MediCitas Fase 2
**Duración objetivo: 7:30 – 8:00 minutos**
UNAD 2026 | Framework para el Desarrollo de Aplicaciones Móviles | Jose David Murillo Arredondo

> Reglas de grabación: resolución 1920x1080, audio claro, VS Code con fuente tamaño 16, zoom del 110%.
> Antepon siempre el código sobre la app cuando la rúbrica pida "entendimiento del código".

---

## BLOQUE 1 — Apertura y entorno (0:00 – 0:50)

**Pantalla:** Terminal + `flutter --version`

**Qué decir:**
> "Hola, mi nombre es Jose David Murillo Arredondo, estudiante de Tecnología en Desarrollo de Software de la UNAD. En este video presento la fase 2 del componente práctico del curso Framework para el Desarrollo de Aplicaciones Móviles, donde construí **MediCitas**, un sistema de agendamiento de citas médicas hecho en **Flutter con Dart**.
>
> Esta fase consistía en instalar el entorno, crear la estructura de un proyecto Flutter, construir interfaces con widgets fundamentales, implementar la navegación entre pantallas y ejecutar la aplicación en un emulador. Todo lo que voy a mostrar son **prácticas simuladas** con datos en memoria, sin base de datos."

**Acción:** Mostrar `flutter --version` con la versión 3.35.5.

---

## BLOQUE 2 — Estructura del proyecto (0:50 – 1:40)

**Pantalla:** VS Code con el explorador de archivos abierto en `lib/`

**Qué decir:**
> "Este es el proyecto. Flutter separa el código en carpetas con una responsabilidad clara cada una, y esa separación es la que quiero explicarles primero."

Señalar cada carpeta en el explorador:

> "**`core/theme`** contiene el tema global de la aplicación. **`models`** tiene las clases de datos. **`data`** tiene la información simulada. **`screens`** tiene las cinco pantallas. **`widgets`** tiene los componentes reutilizables que yo creé para no repetir código. Y en la raíz, **`main.dart`**, que es el punto de entrada."

**Acción:** Desplegar `lib/screens` y `lib/widgets` para que se vean los nombres de los archivos.

---

## BLOQUE 3 — Punto de entrada y tema (1:40 – 2:40)

**Pantalla:** `lib/main.dart` completo

**Qué decir:**
> "Todo arranca en `main.dart`. Dart ejecuta la función `main`, y esa función llama a `runApp` pasando el widget `MediCitasApp`."

Señalar líneas 14 a 18:
> "`MediCitasApp` es un `StatelessWidget`, es decir, un widget sin estado propio: solo describe cómo se ve. Dentro construyo un `MaterialApp`, que es el contenedor que le pone Material Design a toda la app. Ahí defino tres cosas importantes: el título, el tema con `AppTheme.light`, y cuál es la pantalla inicial con `home: LoginScreen`.
>
> Pongo `debugShowCheckedModeBanner` en false para quitar la banderita roja de debug cuando corre la app."

**Pantalla:** `lib/core/theme/app_theme.dart`

**Qué decir:**
> "En el archivo del tema definí una clase `AppColors` con todos los colores de la app en variables estáticas. Si mañana quiero cambiar el azul de toda la aplicación, lo cambio en un solo lugar."

Señalar las líneas 4 a 12: `primary`, `teal`, `accent`, `bg`, `textDark`.

> "La clase `AppTheme` centraliza el `ThemeData`. Ahí configuro una sola vez el aspecto de los botones, las tarjetas y los campos de texto para toda la app."

Señalar `elevatedButtonTheme`, `cardTheme`, `inputDecorationTheme`:
> "Por ejemplo, con `cardTheme` defino que todas las tarjetas tengan esquinas redondeadas de 16 píxeles y un borde gris sutil en lugar de la sombra pesada por defecto. Con `inputDecorationTheme` defino el relleno blanco y el borde de los campos de formulario. Así de simple, pero las cuatro pantallas se ven consistentes sin escribir estilos repetidos."

---

## BLOQUE 4 — Modelos y datos simulados (2:40 – 3:30)

**Pantalla:** `lib/models/models.dart`

**Qué decir:**
> "En `models.dart` definí cinco clases de Dart. `Sede`, `Especialidad`, `Profesional`, `Cita` y `Slot`."

Señalar `Cita`:
> "Por ejemplo, la clase `Cita` tiene los campos id, especialidad, profesional, sede, fechaHora y estado. Los campos son `final` excepto en `Cita`, porque una cita necesita poder cambiar de estado cuando la reprogramamos o la cancelamos. Los constructores usan `required`, así el compilador me obliga a pasar todos los datos y evito forgetar alguno."

Señalar `Slot`:
> "`Slot` es el más simple: una hora y un booleano que dice si está disponible. Esa es toda la lógica de disponibilidad."

**Pantalla:** `lib/data/mock_data.dart`

**Qué decir:**
> "En `data/mock_data.dart` está la información. Son tres sedes, cinco especialidades, cinco profesionales, tres citas de ejemplo y un mapa de horarios por día.
>
> Todo son variables estáticas en memoria. Esto es lo que la guía pide, prácticas simuladas. Más adelante se reemplazaría por una llamada a una API o base de datos, y como los modelos ya están definidos ese cambio no rompería las pantallas."

---

## BLOQUE 5 — Widgets reutilizables (3:30 – 4:20)

**Pantalla:** `lib/widgets/` (4 archivos)

**Qué decir:**
> "Aquí está algo que para mí fue importante: no repetir código."

Señalar `section_header.dart`:
> "`SectionHeader` es un encabezado de sección con título y una acción opcional a la derecha. Lo uso en Home, en Agendar y en Perfil. Antes de crear esto tenía el mismo `Row` con un `Text` escrito cuatro veces."

Señalar `info_banner.dart`:
> "`InfoBanner` es el banner informativo con ícono y texto que uso en Agendar para indicar qué requisito funcional se está demostrando."

Señalar `medicitas_logo.dart`:
> "`MedicitasLogo` es el logotipo, un ícono más el nombre, con un subtítulo opcional."

Señalar `app_dropdown.dart`:
> "Y `AppDropdown` es el más técnico. En Flutter 3.33 la propiedad `value` del `DropdownButtonFormField` quedó obsoleta y fue reemplazada por `initialValue`. Como uso el dropdown en varias pantallas, en vez de repetir la configuración envuelvo el widget una sola vez y lo llamo igual en todos lados. Además, al centralizarlo, `flutter analyze` no reporta ninguna advertencia de código obsoleto."

---

## BLOQUE 6 — Navegación entre pantallas (4:20 – 4:50)

**Pantalla:** `lib/screens/main_shell.dart`

**Qué decir:**
> "Esta pantalla es el corazón de la navegación. `MainShell` es un `StatefulWidget` porque necesita recordar en qué pestaña está el usuario, con una variable `index` de tipo entero.
>
> El `Scaffold` muestra `pages[index]` en el cuerpo, y abajo un `NavigationBar` de Material 3 con tres destinos: Inicio, Citas y Perfil. Cuando el usuario toca un destino, `onDestinationSelected` llama a `setState`, que reconstruye la pantalla con el nuevo índice.
>
> Un detalle: `HomeScreen` recibe un callback `onTabChange`. Eso permite que, si desde Inicio yo toco el ícono de abajo, la barra también se actualice y quede sincronizada."

---

## BLOQUE 7 — Demostración de la app en ejecución (4:50 – 7:20)

> Cerrar la pestaña de código o minimizar VS Code. Emulador o Chrome en pantalla completa.

### 7.1 Login (0:40)
> "Esta es la pantalla de inicio de sesión, el RF-01. Fondo con degradado, logo y un formulario en una tarjeta blanca. Uso `Form` con una `GlobalKey` y validadores: si el documento está vacío sale 'Campo requerido', y si la contraseña tiene menos de cuatro caracteres sale 'Mínimo 4 caracteres'. Primero borro los datos para mostrar la validación, y después ingreso y entro."

**Acción:** Vaciar campo → mostrar error. Escribir datos → **Iniciar sesión**.

### 7.2 Home / Inicio (0:35)
> "El Inicio. Arriba un `SliverAppBar` con degradado que se encoge al hacer scroll. Debajo el saludo, las especialidades en una lista horizontal, y la sección de próximas citas con un botón para agendar."

**Acción:** Scroll vertical para mostrar el SliverAppBar colapsando. Scroll horizontal de especialidades.

### 7.3 Agendar paso 1 (0:35)
> "Agendar es un formulario de tres pasos, el RF-03 y RF-04. Paso uno: selecciono sede, especialidad y profesional. Los desplegables son el `AppDropdown` que les mostré, y los profesionales se muestran con `RadioListTile`. Al cambiar la especialidad, el código filtra la lista automáticamente con un `where` sobre los datos."

**Acción:** Elegir Sede Centro → Medicina general → ver que solo aparecen Dra. Laura Gómez y Dr. Carlos Pérez → elegir uno → **Continuar**.

### 7.4 Agendar paso 2 (0:25)
> "Paso dos, el RF-05, disponibilidad. Arriba los días, abajo los horarios en `ChoiceChip`. Los horarios que no están disponibles salen deshabilitados, y eso viene del booleano `disponible` del modelo Slot."

**Acción:** Tocar un día, elegir un horario, **Continuar**.

### 7.5 Agendar paso 3 y confirmación (0:25)
> "Paso tres, resumen de la cita. Al confirmar se crea el objeto `Cita`, se genera un identificador y se muestra un `AlertDialog` con el número de cita. Eso es el RF-06."

**Acción:** **Confirmar cita** → mostrar el diálogo con el ID.

### 7.6 Mis Citas: reprogramar y cancelar (0:35)
> "Pestaña Citas, RF-07, 08 y 09. Arriba las próximas citas, más abajo el historial. Sobre cada cita hay dos acciones."

**Acción:** Tocar **Reprogramar** → mostrar el diálogo de nuevos horarios → elegir → confirmar. Luego volver y tocar **Cancelar** → mostrar la confirmación.

> "Cuando reprogramo, el código crea una cita nueva con la hora nueva, y la anterior queda con estado 'Reprogramada'. Al cancelar se marca 'Cancelada' y el horario vuelve a quedar libre."

### 7.7 Perfil (0:25)
> "Perfil, el RF-02. Datos del usuario editables con un `Form`, y un switch de notificaciones que es el RF-10. Abajo el botón de administración de oferta, el RF-12, que por ahora solo muestra un mensaje de confirmación porque es una práctica simulada."

**Acción:** Mostrar el switch, tocar el botón de administración.

---

## BLOQUE 8 — Cierre y conclusiones (7:20 – 7:50)

**Pantalla:** VS Code con `lib/` visible

**Qué decir:**
> "Para cerrar, esta fase me permitió entender tres cosas. Primero, la diferencia entre un `StatelessWidget` y un `StatefulWidget`: los primeros solo dibujan, los segundos además guardan información y cambian con `setState`. Segundo, el valor de la reutilización: los cuatro widgets que creé meitektaron más de veinte repeticiones. Y tercero, que Flutter permite un mismo código correr en Android y en web, y lo demonstrated porque `flutter run -d chrome` levanta esta misma app.
>
> También debo reconocer algo. Durante las pruebas encontré errores de desbordamiento de texto, los famous *RenderFlex overflowed*. Se producían cuando un texto era más largo de lo que el espacio disponible, por ejemplo 'Medicina general' en las tarjetas de especialidad. Lo solucioné acotando el ancho, reduciendo el tamaño de fuente y usando `maxLines` con `TextOverflow.ellipsis`. Es un recordatorio de que en Flutter el layout se calcula con restricciones, y hay que probarlo en distintos tamaños de pantalla.
>
> Eso es todo. Muchas gracias por su atención, quedo atento a sus preguntas."

---

## Checklist antes de grabar

- [ ] `flutter analyze` sin issues y `flutter doctor` sin errores
- [ ] Emulador o Chrome abierto con la app limpia, sin datos de prueba viejos
- [ ] VS Code con tema claro y fuente ≥ 16 para que el código se lea
- [ ] Terminal separada lista para `flutter --version`
- [ ] Grabar audio de prueba de 10 s y revisar que no haya eco
- [ ] Grabar en varias tomas si se traba, no intentar hacerlo de una sola vez
- [ ] Resolución 1920x1080, 30 fps
- [ ] Revisar la duración final entre 7:00 y 8:00

## Si te sobra o falta tiempo

| Problema | Ajuste |
|---|---|
| Video muy largo (> 8:30) | Recortar Bloques 3 y 4, dejar 40 s de tema y 30 s de modelos |
| Video muy corto (< 6:00) | Ampliar la demo a 3:30 y agregar 30 s explicando `mock_data.dart` |
| Se traba grabando | Grabar por bloques separados y unir en un solo archivo |
