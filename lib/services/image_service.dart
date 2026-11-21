import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../core/theme/app_theme.dart';

/// Servicio Singleton para la selección y captura de imágenes (Cámara y Galería).
class ImageService {
  static final ImageService instance = ImageService._internal();
  factory ImageService() => instance;
  ImageService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Captura una foto con la cámara o selecciona un archivo de la galería.
  /// Retorna la ruta local del archivo o `null` si el usuario canceló.
  Future<String?> seleccionarImagen({required ImageSource origen}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: origen,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      return file?.path;
    } on PlatformException catch (e) {
      debugPrint('Error de permisos o plataforma al seleccionar imagen: $e');
      rethrow;
    } catch (e) {
      debugPrint('Error general al seleccionar imagen: $e');
      rethrow;
    }
  }

  /// Despliega un menú inferior modal (BottomSheet) para que el paciente elija
  /// entre la cámara, la galería o remover su foto actual.
  Future<void> mostrarSelector(
    BuildContext context, {
    required ValueChanged<String> onFotoSeleccionada,
    VoidCallback? onFotoEliminada,
    bool tieneFoto = false,
  }) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Text(
                  'Foto de perfil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.camera_alt_outlined,
                        color: AppColors.primary),
                  ),
                  title: const Text('Tomar foto con la cámara'),
                  subtitle: const Text('Usa la cámara de tu dispositivo'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _procesarSeleccion(
                      context,
                      ImageSource.camera,
                      onFotoSeleccionada,
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.photo_library_outlined,
                        color: AppColors.teal),
                  ),
                  title: const Text('Elegir de la galería'),
                  subtitle: const Text('Selecciona una imagen guardada'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await _procesarSeleccion(
                      context,
                      ImageSource.gallery,
                      onFotoSeleccionada,
                    );
                  },
                ),
                if (tieneFoto && onFotoEliminada != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.delete_outline, color: Colors.red),
                    ),
                    title: const Text(
                      'Eliminar foto actual',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      onFotoEliminada();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _procesarSeleccion(
    BuildContext context,
    ImageSource origen,
    ValueChanged<String> onFotoSeleccionada,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ruta = await seleccionarImagen(origen: origen);
      if (ruta != null && context.mounted) {
        onFotoSeleccionada(ruta);
      }
    } on PlatformException catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(
              'Permiso denegado para acceder a ${origen == ImageSource.camera ? "la cámara" : "la galería"}. (${e.message ?? e.code})',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('No se pudo cargar la imagen: $e')),
        );
      }
    }
  }

  /// Verifica si una ruta de archivo local existe y es válida
  static bool existeArchivo(String? ruta) {
    if (ruta == null || ruta.trim().isEmpty) return false;
    if (kIsWeb) return true;
    try {
      return File(ruta).existsSync();
    } catch (_) {
      return false;
    }
  }
}
