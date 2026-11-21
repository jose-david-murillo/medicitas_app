import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Servicio Singleton para la gestión de notificaciones locales del dispositivo (RF-10).
class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Inicializa el plugin de notificaciones locales
  Future<void> init() async {
    if (_initialized || kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) {
      _initialized = true;
      return;
    }

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      );

      await _plugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (response) {
          debugPrint('Notificación seleccionada: ${response.payload}');
        },
      );

      _initialized = true;
    } catch (e) {
      debugPrint('Aviso: Inicialización de notificaciones omitida o simulada: $e');
    }
  }

  /// Solicita permisos de notificación en Android (API 33+) e iOS.
  /// Retorna `true` si el permiso fue concedido o si está en un entorno donde no aplica.
  Future<bool> solicitarPermisos() async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return true;

    try {
      if (Platform.isAndroid) {
        final androidPlugin = _plugin
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>();
        if (androidPlugin != null) {
          final granted =
              await androidPlugin.requestNotificationsPermission();
          return granted ?? false;
        }
      } else if (Platform.isIOS) {
        final iosPlugin = _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>();
        if (iosPlugin != null) {
          final granted = await iosPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      } else if (Platform.isMacOS) {
        final macPlugin = _plugin
            .resolvePlatformSpecificImplementation<
                MacOSFlutterLocalNotificationsPlugin>();
        if (macPlugin != null) {
          final granted = await macPlugin.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
          return granted ?? false;
        }
      }
      return true;
    } catch (e) {
      debugPrint('Error al solicitar permisos de notificación: $e');
      return false;
    }
  }

  /// Dispara una notificación local con los detalles de la cita agendada o reprogramada
  Future<bool> mostrarNotificacionCita({
    required String titulo,
    required String especialidad,
    required String profesional,
    required String sede,
    required String fecha,
    required String hora,
    int id = 101,
  }) async {
    if (kIsWeb || Platform.environment.containsKey('FLUTTER_TEST')) return true;

    try {
      await init();

      const androidDetails = AndroidNotificationDetails(
        'medicitas_citas_channel',
        'Recordatorios de Citas',
        channelDescription:
            'Canal para confirmaciones y recordatorios de citas médicas en MediCitas',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        styleInformation: BigTextStyleInformation(''),
      );

      const darwinDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: darwinDetails,
        macOS: darwinDetails,
      );

      final cuerpo =
          '$especialidad con $profesional en $sede.\nFecha: $fecha • Hora: $hora';

      await _plugin.show(
        id: id,
        title: titulo,
        body: cuerpo,
        notificationDetails: details,
        payload: 'cita_$id',
      );
      return true;
    } catch (e) {
      debugPrint('Error al disparar notificación local: $e');
      return false;
    }
  }
}
