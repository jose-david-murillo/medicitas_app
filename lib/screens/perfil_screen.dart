import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../database/db_helper.dart';
import '../models/models.dart';
import '../services/image_service.dart';
import '../services/notification_service.dart';
import '../widgets/responsive_content.dart';
import 'login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController(text: 'José David Murillo');
  final _correoCtrl = TextEditingController(text: 'jose.murillo@unad.edu.co');
  final _telCtrl = TextEditingController(text: '300 123 4567');
  String documento = 'CC 1017234567';
  String canal = 'Correo';
  bool notif = true;
  String? fotoRuta;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarPerfilDesdeDb();
  }

  Future<void> _cargarPerfilDesdeDb() async {
    try {
      final perfil = await DbHelper.instance.getPerfil();
      if (mounted) {
        setState(() {
          _nombreCtrl.text = perfil.nombre;
          _correoCtrl.text = perfil.correo;
          _telCtrl.text = perfil.telefono;
          documento = perfil.documento;
          canal = perfil.canal;
          notif = perfil.notificacionesActivas;
          fotoRuta = perfil.fotoRuta;
          _cargando = false;
        });
      }
    } catch (e) {
      debugPrint('Error al cargar perfil desde SQLite: $e');
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _correoCtrl.dispose();
    _telCtrl.dispose();
    super.dispose();
  }

  String? _validarNombre(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'El nombre es obligatorio';
    if (v.length < 3) return 'Ingresa al menos 3 caracteres';
    if (!RegExp(r"^[a-zA-ZáéíóúÁÉÍÓÚñÑüÜ\s'.-]+$").hasMatch(v)) {
      return 'El nombre solo admite letras y espacios';
    }
    return null;
  }

  String? _validarCorreo(String? valor) {
    final v = valor?.trim() ?? '';
    if (v.isEmpty) return 'El correo es obligatorio';
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[\w.-]+$').hasMatch(v)) {
      return 'Ingresa un correo válido (ejemplo@dominio.com)';
    }
    return null;
  }

  String? _validarTelefono(String? valor) {
    final soloDigitos = (valor ?? '').replaceAll(RegExp(r'\D'), '');
    if (soloDigitos.isEmpty) return 'El teléfono es obligatorio';
    if (soloDigitos.length < 7 || soloDigitos.length > 10) {
      return 'El teléfono debe tener entre 7 y 10 dígitos';
    }
    return null;
  }

  Future<void> _gestionarFoto() async {
    await ImageService.instance.mostrarSelector(
      context,
      tieneFoto: fotoRuta != null && fotoRuta!.isNotEmpty,
      onFotoSeleccionada: (nuevaRuta) async {
        setState(() => fotoRuta = nuevaRuta);
        try {
          await DbHelper.instance.updateFotoPerfil(nuevaRuta);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil actualizada en SQLite'),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al guardar la foto: $e')),
            );
          }
        }
      },
      onFotoEliminada: () async {
        setState(() => fotoRuta = null);
        try {
          await DbHelper.instance.updateFotoPerfil(null);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Foto de perfil eliminada'),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error al eliminar la foto: $e')),
            );
          }
        }
      },
    );
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Revisa los campos marcados en rojo antes de guardar'),
        ),
      );
      return;
    }

    try {
      final perfilActualizado = PerfilPaciente(
        id: 1,
        nombre: _nombreCtrl.text.trim(),
        documento: documento,
        correo: _correoCtrl.text.trim(),
        telefono: _telCtrl.text.trim(),
        canal: canal,
        notificacionesActivas: notif,
        fotoRuta: fotoRuta,
      );

      await DbHelper.instance.updatePerfil(perfilActualizado);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Perfil actualizado en SQLite exitosamente. Canal: $canal',
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            content: Text('Error al persistir cambios en la base de datos: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tieneFotoValida =
        fotoRuta != null && ImageService.existeArchivo(fotoRuta);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: SafeArea(
        child: _cargando
            ? const Center(child: CircularProgressIndicator())
            : ResponsiveContent(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Stack(
                                  children: [
                                    GestureDetector(
                                      onTap: _gestionarFoto,
                                      child: ExcludeSemantics(
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundColor: AppColors.primary,
                                          backgroundImage: tieneFotoValida &&
                                                  !kIsWeb
                                              ? FileImage(File(fotoRuta!))
                                              : null,
                                          child: !tieneFotoValida
                                              ? const Text(
                                                  'JM',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 18,
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: GestureDetector(
                                        onTap: _gestionarFoto,
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: AppColors.teal,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.camera_alt,
                                            size: 12,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _nombreCtrl.text.isNotEmpty
                                            ? _nombreCtrl.text
                                            : 'José David Murillo',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w800),
                                      ),
                                      Text(
                                        documento,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                      const Text(
                                        'Paciente',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.teal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  tooltip: 'Cambiar foto de perfil',
                                  onPressed: _gestionarFoto,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Gestión del perfil (RF-02)',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _nombreCtrl,
                          textInputAction: TextInputAction.next,
                          textCapitalization: TextCapitalization.words,
                          validator: _validarNombre,
                          onChanged: (_) => setState(() {}),
                          decoration: const InputDecoration(
                            labelText: 'Nombre completo',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _correoCtrl,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: _validarCorreo,
                          decoration: const InputDecoration(
                            labelText: 'Correo',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _telCtrl,
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          validator: _validarTelefono,
                          decoration: const InputDecoration(
                            labelText: 'Teléfono',
                            helperText: 'Entre 7 y 10 dígitos',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Canal autorizado para notificaciones',
                          style: TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          initialValue: canal,
                          items: const [
                            DropdownMenuItem(
                                value: 'Correo', child: Text('Correo')),
                            DropdownMenuItem(
                                value: 'SMS', child: Text('SMS')),
                            DropdownMenuItem(
                              value: 'WhatsApp',
                              child: Text('WhatsApp'),
                            ),
                          ],
                          onChanged: (v) => setState(() => canal = v!),
                          validator: (v) => v == null
                              ? 'Selecciona un canal de notificación'
                              : null,
                        ),
                        SwitchListTile(
                          value: notif,
                          onChanged: (v) async {
                            if (v) {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final concedido = await NotificationService
                                    .instance
                                    .solicitarPermisos();
                                if (!concedido && mounted) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Permiso de notificaciones no concedido. Habilítalo en los ajustes del dispositivo.',
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (mounted) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al solicitar permisos: $e',
                                      ),
                                    ),
                                  );
                                }
                              }
                            }
                            if (mounted) {
                              setState(() => notif = v);
                            }
                          },
                          title: const Text(
                            'Recibir recordatorios (RF-10)',
                            style: TextStyle(fontSize: 13),
                          ),
                          subtitle: const Text(
                            'Notificación previa con fecha, hora y sede',
                            style: TextStyle(fontSize: 11),
                          ),
                          activeThumbColor: AppColors.primary,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: _guardar,
                          icon: const Icon(Icons.save_outlined),
                          label: const Text('Guardar cambios'),
                        ),
                        const SizedBox(height: 14),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.admin_panel_settings_outlined,
                                      color: AppColors.primary,
                                    ),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Administración de oferta (RF-12)',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Usuario autorizado puede crear/actualizar/inactivar sedes, especialidades, profesionales y reglas de disponibilidad.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'RF-12: Módulo admin simulado',
                                              ),
                                            ),
                                          );
                                        },
                                        child:
                                            const Text('Gestionar oferta'),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Row(
                                  children: [
                                    Icon(
                                      Icons.schedule,
                                      size: 14,
                                      color: AppColors.textLight,
                                    ),
                                    SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'RF-11 Consulta de agenda (Profesional)',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textLight,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                            (r) => false,
                          ),
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Cerrar sesión',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Center(
                          child: Text(
                            'v1.0.0 • Flutter 3.35.5 • UNAD 2026',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
