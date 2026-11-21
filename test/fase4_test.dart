import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicitas_app/data/mock_data.dart';
import 'package:medicitas_app/database/db_helper.dart';
import 'package:medicitas_app/main.dart';
import 'package:medicitas_app/models/models.dart';
import 'package:medicitas_app/services/image_service.dart';
import 'package:medicitas_app/services/notification_service.dart';

void main() {
  setUp(() async {
    DbHelper.initFfiIfNeeded();
    await DbHelper.instance.resetForTesting();
  });

  group('Fase 4: Persistencia SQLite (CRUD completo)', () {
    test('Precarga inicial automática de citas y perfil en base de datos vacía', () async {
      final citas = await DbHelper.instance.getCitas();
      expect(citas.length, greaterThanOrEqualTo(3));

      final perfil = await DbHelper.instance.getPerfil();
      expect(perfil.nombre, 'José David Murillo');
      expect(perfil.documento, 'CC 1017234567');
      expect(perfil.correo, 'jose.murillo@unad.edu.co');
      expect(perfil.notificacionesActivas, isTrue);
    });

    test('Create: Guardar una nueva cita en SQLite', () async {
      final nueva = Cita(
        id: 'CIT-TEST-999',
        especialidad: 'Cardiología',
        profesional: 'Dr. Alejandro Soto',
        sede: 'Sede Norte',
        fechaHora: DateTime(2026, 12, 1, 9, 30),
        estado: 'Confirmada',
      );

      final insertId = await DbHelper.instance.insertCita(nueva);
      expect(insertId, greaterThan(0));

      final citas = await DbHelper.instance.getCitas();
      expect(citas.any((c) => c.id == 'CIT-TEST-999'), isTrue);

      final proxima = await DbHelper.instance.getProximaCita();
      expect(proxima, isNotNull);
    });

    test('Read: Filtrar citas próximas e historial correctamente', () async {
      final proximas = await DbHelper.instance.getCitasProximas();
      for (final c in proximas) {
        expect(c.estado, 'Confirmada');
      }

      final historial = await DbHelper.instance.getCitasHistorial();
      for (final c in historial) {
        expect(c.estado, isNot('Confirmada'));
      }
    });

    test('Update: Actualizar fecha/hora al reprogramar cita', () async {
      final nuevaFecha = DateTime(2026, 11, 20, 15, 0);
      final cita = Cita(
        id: 'CIT-2026-001',
        especialidad: 'Medicina general',
        profesional: 'Dra. Laura Gómez',
        sede: 'Sede Centro',
        fechaHora: nuevaFecha,
        estado: 'Confirmada',
      );

      final updated = await DbHelper.instance.updateCita(cita);
      expect(updated, 1);

      final citas = await DbHelper.instance.getCitas();
      final guardada = citas.firstWhere((c) => c.id == 'CIT-2026-001');
      expect(guardada.fechaHora, nuevaFecha);
    });

    test('Update: Actualizar perfil de paciente en SQLite (nombre, correo, canal, notificaciones, foto)', () async {
      final perfilModificado = PerfilPaciente(
        id: 1,
        nombre: 'José Murillo Actualizado',
        documento: 'CC 1017234567',
        correo: 'nuevo.correo@unad.edu.co',
        telefono: '3119876543',
        canal: 'WhatsApp',
        notificacionesActivas: false,
        fotoRuta: '/data/user/0/avatar.jpg',
      );

      await DbHelper.instance.updatePerfil(perfilModificado);

      final perfilGuardado = await DbHelper.instance.getPerfil();
      expect(perfilGuardado.nombre, 'José Murillo Actualizado');
      expect(perfilGuardado.correo, 'nuevo.correo@unad.edu.co');
      expect(perfilGuardado.telefono, '3119876543');
      expect(perfilGuardado.canal, 'WhatsApp');
      expect(perfilGuardado.notificacionesActivas, isFalse);
      expect(perfilGuardado.fotoRuta, '/data/user/0/avatar.jpg');
    });

    test('Delete/Cancelar: Actualizar estado a Cancelada y liberar horario', () async {
      const dia = '2026-11-02';
      const hora = '10:30 a. m.';

      // Bloquear cupo
      MockData.bloquearCupo(dia, hora);
      expect(
        MockData.horariosPorDia[dia]!.firstWhere((s) => s.hora == hora).disponible,
        isFalse,
      );

      // Cancelar cita en SQLite
      await DbHelper.instance.updateEstadoCita('CIT-2026-001', 'Cancelada');

      // Liberar horario
      MockData.liberarCupo(dia, hora);
      expect(
        MockData.horariosPorDia[dia]!.firstWhere((s) => s.hora == hora).disponible,
        isTrue,
      );

      final citas = await DbHelper.instance.getCitas();
      final cancelada = citas.firstWhere((c) => c.id == 'CIT-2026-001');
      expect(cancelada.estado, 'Cancelada');
    });
  });

  group('Fase 4: Servicios del dispositivo', () {
    test('Servicio 1: Notificaciones locales inicialización y permisos', () async {
      await NotificationService.instance.init();
      final permisos = await NotificationService.instance.solicitarPermisos();
      expect(permisos, isTrue);

      final notifEnviada = await NotificationService.instance.mostrarNotificacionCita(
        titulo: 'Recordatorio Test',
        especialidad: 'Medicina general',
        profesional: 'Dra. Laura Gómez',
        sede: 'Sede Centro',
        fecha: '2026-11-02',
        hora: '10:30 a. m.',
      );
      expect(notifEnviada, isTrue);
    });

    test('Servicio 2: Validación de archivo de imagen y fallback avatar', () {
      expect(ImageService.existeArchivo(null), isFalse);
      expect(ImageService.existeArchivo(''), isFalse);
      expect(ImageService.existeArchivo('/ruta/que/no/existe.jpg'), isFalse);
    });
  });

  group('Fase 4: Navegación e Integración UI', () {
    testWidgets('Mis citas muestra tabs Próximas e Historial desde SQLite', (tester) async {
      await tester.pumpWidget(const MediCitasApp());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
      await tester.pumpAndSettle();

      // Navegar a Citas
      await tester.tap(find.text('Citas'));
      await tester.pumpAndSettle();

      expect(find.text('Mis citas'), findsOneWidget);
      expect(find.text('Próximas'), findsOneWidget);
      expect(find.text('Historial'), findsOneWidget);
    });

    testWidgets('Perfil muestra fallback de avatar con iniciales JM', (tester) async {
      await tester.pumpWidget(const MediCitasApp());
      await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar sesión'));
      await tester.pumpAndSettle();

      // Navegar a Perfil
      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();

      expect(find.text('JM'), findsOneWidget);
      expect(find.text('José David Murillo'), findsWidgets);
      expect(find.text('Recibir recordatorios (RF-10)'), findsOneWidget);
    });
  });
}
