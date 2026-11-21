import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicitas_app/database/db_helper.dart';
import 'package:medicitas_app/main.dart';

Future<void> _iniciarSesion(WidgetTester tester) async {
  await tester.pumpWidget(const MediCitasApp());
  await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 100));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    DbHelper.initFfiIfNeeded();
    await DbHelper.instance.resetForTesting();
  });
  testWidgets('El login valida campos vacíos', (tester) async {
    await tester.pumpWidget(const MediCitasApp());
    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
    await tester.pump();

    expect(
      find.text('Ingresa tu documento, correo o teléfono'),
      findsOneWidget,
    );
    expect(find.text('Ingresa tu contraseña'), findsOneWidget);
  });

  testWidgets('El login válido navega a la pantalla principal', (tester) async {
    await _iniciarSesion(tester);

    expect(find.text('¿Cómo podemos ayudarte?'), findsOneWidget);
    expect(find.text('Tu próxima cita'), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);
  });

  testWidgets('Agendar valida el horario y confirma la cita', (tester) async {
    await _iniciarSesion(tester);

    await _tocar(tester, find.text('Agendar cita'));
    await _tocar(tester, find.widgetWithText(ElevatedButton, 'Continuar'));

    await _tocar(tester, find.widgetWithText(ElevatedButton, 'Continuar'));
    expect(
      find.textContaining('Selecciona un horario disponible'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('8:00 a. m.'));
    await _tocar(tester, find.widgetWithText(ElevatedButton, 'Continuar'));
    await _tocar(tester, find.widgetWithText(ElevatedButton, 'Confirmar cita'));

    expect(find.text('¡Cita confirmada!'), findsOneWidget);
  });

  testWidgets('El perfil valida el correo y el teléfono', (tester) async {
    await _iniciarSesion(tester);
    await _tocar(tester, find.byIcon(Icons.person_outline));

    await tester.enterText(find.byType(TextFormField).at(1), 'correo-invalido');
    await tester.enterText(find.byType(TextFormField).at(2), '12');
    await _tocar(tester, find.text('Guardar cambios'));

    expect(
      find.text('Ingresa un correo válido (ejemplo@dominio.com)'),
      findsOneWidget,
    );
    expect(
      find.text('El teléfono debe tener entre 7 y 10 dígitos'),
      findsOneWidget,
    );
  });

  testWidgets('La interfaz soporta texto ampliado y pantallas grandes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1280, 900);
    tester.view.devicePixelRatio = 1.0;
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await _iniciarSesion(tester);
    expect(tester.takeException(), isNull);

    await _tocar(tester, find.text('Agendar cita'));
    expect(tester.takeException(), isNull);
  });
}
