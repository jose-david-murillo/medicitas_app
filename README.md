# MediCitas - UNAD 2026 - Fase 2
**Jose David Murillo Arredondo - Grupo 2 - Tecnología en Desarrollo de Software - UNAD Medellín**

App Flutter que implementa el Sistema de citas médicas de Fase 1.

## Requisitos cubiertos
- RF-01 Registro e inicio de sesión (Login con validación)
- RF-02 Gestión del perfil (Perfil editable + canal notificaciones)
- RF-03 Consulta de sedes y especialidades (Paso 1 Agendar)
- RF-04 Consulta de profesionales (Filtro por especialidad)
- RF-05 Consulta de disponibilidad (Calendario + chips horarios)
- RF-06 Agendamiento (Crear cita, bloquea cupo, entrega ID)
- RF-07 Consulta de citas (Próximas/Historial)
- RF-08 Reprogramación (Dialog nuevo horario)
- RF-09 Cancelación (Confirmación + libera horario)
- RF-10 Recordatorios (Switch + Mock notificación)
- RF-11 Consulta de agenda (Info en mock)
- RF-12 Administración de oferta (Botón admin simulado)

## Estructura Flutter solicitada por la guía
- `lib/main.dart` - MaterialApp, tema
- `lib/core/theme/app_theme.dart` - AppColors, ThemeData, widgets fundamentales
- `lib/models/models.dart` - Modelos Dart
- `lib/data/mock_data.dart` - Datos simulados
- `lib/screens/login_screen.dart` - RF-01
- `lib/screens/main_shell.dart` - NavigationBar (navegación entre pantallas)
- `lib/screens/home_screen.dart` - Mockup 1
- `lib/screens/agendar_screen.dart` - Mockup 2 (Stepper 3 pasos)
- `lib/screens/citas_screen.dart` - RF-07/08/09
- `lib/screens/perfil_screen.dart` - RF-02/10/12

## Widgets utilizados
Scaffold, AppBar, SliverAppBar, Card, Chip, ChoiceChip, DropdownButtonFormField, RadioListTile, BottomNavigationBar/NavigationBar, TabBar, Form, TextFormField, ElevatedButton, OutlinedButton, SnackBar, AlertDialog

## Cómo ejecutar
```bash
cd C:\Users\josed\Desktop\medicitas_app
flutter pub get
flutter doctor
flutter run -d chrome   # web
# o
flutter run             # emulador Android / dispositivo
```

Credenciales demo: cualquier documento válido (ej: 1017234567) y pass 123456.

## Evidencias para Anexo 1
1. Captura `flutter --version` + `flutter doctor`
2. Captura app en emulador: Login, Home, Agendar paso2, Mis citas
3. Link video sustentación (subir a YouTube no listado)
4. Link Drive del .zip público

## Video guion sugerido (5 min)
1. Mostrar estructura de carpetas
2. Explicar main.dart + app_theme.dart
3. Mostrar mock_data y models
4. Navegar app: login -> home -> agendar -> confirmar -> ver en Mis Citas -> cancelar/reprogramar -> perfil
5. Cerrar con conclusiones Flutter vs nativo
