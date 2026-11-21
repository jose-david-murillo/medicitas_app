import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'database/db_helper.dart';
import 'screens/login_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DbHelper.initFfiIfNeeded();
  try {
    await DbHelper.instance.database;
    await NotificationService.instance.init();
  } catch (e) {
    debugPrint('Error en inicialización previa de servicios: $e');
  }

  runApp(const MediCitasApp());
}

class MediCitasApp extends StatelessWidget {
  const MediCitasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCitas - UNAD',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const LoginScreen(),
    );
  }
}
